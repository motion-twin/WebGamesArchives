import Common;
import Anim;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;

import flash.Mouse;

class Game implements MMGame<Msg> {//}
	static public var FL_PLAYZONE = true;

	static public var DP_BG = 	0;
	static public var DP_TOKENS = 	1;
	static public var DP_BLOB = 	2;
	static public var DP_FX = 	3;
	static public var DP_PARTS = 	4;

	static public var mcw = 300;
	static public var mch = 300;


	public var willDisplay :Int;
	public var dm : mt.DepthManager;
	public var tdm : mt.DepthManager;

	public var anim : List<Anim>;
	public var grid : Array<Array<Cell>>;
	public var mem : Array<Array<Int>>;
	public var team : Team;

	var blobA : Blob;
	var blobB : Blob;

	var mcMask : flash.MovieClip;
	var root : flash.MovieClip;
	var mcTokens : { >flash.MovieClip, bmp:flash.display.BitmapData };
	var mcPlayZone : { >flash.MovieClip, bmp:flash.display.BitmapData };
	var mcSelector:flash.MovieClip;

	var myCount : Int;
	var oppCount : Int;

	public var step:Int;
	var buts:Array<flash.MovieClip>;
	public var victorySent : Bool;
	public var victoryReceived : Bool;
	var waitToUnlock : Bool;

	function new( base : flash.MovieClip ) {
		root = base;

		myCount = 0;
		oppCount = 0;

		anim = new List();
		dm = new mt.DepthManager(base);

		var bg = dm.attach("bground",DP_BG);
		bg.cacheAsBitmap = true;

		mcTokens = cast dm.empty(DP_TOKENS);

		victorySent = false;
		victoryReceived = false;

		// MASK
		mcMask = base.attachMovie("circle","circle",15);
		mcMask._x = 150;
		mcMask._y = 150;
		mcTokens.setMask( mcMask );

		//
		blobA = new Blob(this,true);
		blobB = new Blob(this,false);

		waitToUnlock = false;
		MMApi.lockMessages(false);
	}

	public function initStep(n){
		step = n;
		switch(step){
			case 0:
				cleanPlayZone();
				mcTokens.onPress = null;
				mcTokens.useHandCursor = false;
			case 1:
				if( MMApi.hasControl() && !MMApi.isReconnecting() && MMApi.isMyTurn() ){
					if( mcSelector != null ){
						mcSelector.removeMovieClip();
						mcSelector = null;
					}
					//MMApi.setInfos("<p>Choisissez votre point de départ.</p>");
					mcSelector = dm.attach("mcSelector",DP_FX);
					var me = this;
					mcTokens.onPress = validateStartPos;
					mcTokens.useHandCursor = true;
				}
			case 2:
				if(MMApi.hasControl() && !MMApi.isReconnecting() && MMApi.isMyTurn() )
					initInterface();
		}
	}

	public function initStartAnim(){
		anim.add( new AnimStart(mcMask, 20, 480 ) );
	}

	public function getBlob( team : Team ){
		if( team ) return blobA;
		else return blobB;
	}

	public function cleanChained(){
		for( a in grid ){
			for( c in a ){
				c.chained = false;
			}
		}
	}

	public function initialize() {
		var g = new Array();
		for( i in 0...Const.SIZE ){
			g[i] = new Array();
			for( j in 0...Const.SIZE ){
				var d = Std.int(Math.sqrt(Math.pow(i-Const.SIZE/2,2)+Math.pow(j+1-Const.SIZE/2,2))/4);
				g[i][j] = Std.random(Const.COLORS-d);
			}
		}
		return Init(Std.random(2)==0,g);
	}

	//
	public function main() {
		if(mcPlayZone._alpha==100)mcPlayZone._alpha=80;	else mcPlayZone._alpha=100;

		// BLOB UPDATE
		blobA.update();
		blobB.update();

		// DISPLAY DELAY
		if(willDisplay!=null){
			if(willDisplay--<0){
				willDisplay = null;
				displayGrid();
			}
		}

		// ETAPES
		if( step == 1 ){
			mcSelector._x = (getPos(root._xmouse)+0.5)*Const.CELL_SIZE;
			mcSelector._y = (getPos(root._ymouse)+0.5)*Const.CELL_SIZE;
		}

		//SPRITES
		for( sp in Sprite.spriteList )sp.update();
		if( waitToUnlock && Sprite.spriteList.length == 0 && anim.length == 0 ){
			waitToUnlock = false;
			MMApi.lockMessages(false);
		}

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					anim.remove( a );
				}
			}
			if( anim.length == 0 )
				onEndAnim();
		}
	}

	//
	function validateStartPos(){
		var x = getPos(mcSelector._x);
		var y = getPos(mcSelector._y);
		if( grid[y][x].team == null ){
			place( x, y );
			mcSelector.removeMovieClip();
			mcSelector = null;
		}
	}

	//
	public function onEndAnim(){
		waitToUnlock = false;
		MMApi.lockMessages(false);
		if( victoryReceived ){
			MMApi.gameOver();
		}else{
			updateInfos();
			if( MMApi.isMyTurn() && team != null && getBlob( team ).cells().length == 0 ){
				getBlob( team ).initActions();
			}
		}
	}
	
	function checkVictory(){
		if( MMApi.isReconnecting() ) return;

		if( blobA.color != null || blobB.color != null ){
			var myPM = getBlob(team).countPM();
			var oppPM = getBlob(!team).countPM();

			if( myPM + oppPM == 0 ){
				checkVictoryPoint();
			}
		}
	}

	function checkVictoryPoint(){
		myCount = 0;
		oppCount = 0;
		for( a in grid ){
			for( c in a ){
				if( c.team == team )
					myCount++;
				else if( c.team == !team )
					oppCount++;
			}
		}

		if( myCount == oppCount )
			victory(null);
		else
			victory(myCount > oppCount);
	}

	public function onTurnDone() {
		checkVictory();
		updateInfos();
		if( MMApi.isMyTurn() && team != null )
			getBlob( team ).initActions();
	}

	public function updateInfos(){
		var s = "";
		if( myCount != null && oppCount != null ){
			s += "<div class=\"score0\">"+myCount+" ("+Math.round(myCount*100/(Const.SIZE*Const.SIZE))+"%)</div>";
			s += "<div class=\"score1\">"+oppCount+" ("+Math.round(oppCount*100/(Const.SIZE*Const.SIZE))+"%)</div>";
		}

		if( MMApi.isMyTurn() && team!=null && MMApi.hasControl() ){		// CHECK
			if( getBlob( team ).cells().length == 0 ){
				s += "<p>Choisissez votre point de départ.</p>";
			}else{
				s += "<p>Choisissez votre couleur.</p>";
			}
		}else{
			s += "<p></p>";
		}
		MMApi.setInfos(s);
	}

	public function onVictory( mine : Bool ){
		victoryReceived = true;
		if( !victorySent || anim.length == 0 ){
			MMApi.gameOver();
		}
	}

	function victory( mine : Bool ){
		victorySent = true;
		MMApi.victory( mine );
	}

	public function play( c : Int ){
		if( c == getBlob(!team).color ) return false;
		getBlob( team ).cleanActions();

		while(buts.length>0)buts.pop().removeMovieClip();
		MMApi.endTurn(Extend(c));
		return true;
	}

	public function place( x : Int, y : Int ){
		getBlob( team ).cleanActions();
		MMApi.endTurn(Place(x,y));
	}

	// INTERFACE
	function initInterface(){
		buts = [];
		var me = this;
		var bl = getBlob(team);
		var pm = bl.possibleMoves();
		for( cid in 0...pm.length ){

			if( getBlob(!team).color != cid ){
				var a = pm[cid];
				for( c in a ){
					var mc = dm.attach("mcBut",DP_TOKENS);
					mc._x = c.x*Const.CELL_SIZE;
					mc._y = c.y*Const.CELL_SIZE;

					mc.onRollOver = function(){ bl.showPM(cid); };
					mc.onRollOut = mc.onDragOut = function(){ bl.hidePM(cid); };
					mc.onPress = function(){  if( me.play(cid) ) bl.hidePM(cid); };
					buts.push(mc);
					mc.blendMode = "add";
				}
			}
		}
	}

	// PLAYZONE
	public function markPlayZone(x,y){
		if(!FL_PLAYZONE)return;
		if( mcPlayZone==null ){
			mcPlayZone = cast dm.empty(DP_FX);
			mcPlayZone.bmp = new flash.display.BitmapData(mcw,mch,true,0x00000000);
			mcPlayZone.attachBitmap(mcPlayZone.bmp,0);
			var fl = new flash.filters.GlowFilter();
			fl.blurX = 4;
			fl.blurY = 4;
			fl.strength = 255;
			fl.color = 0xFFFFFF;
			Reflect.setField(fl,"knockout",true);
			mcPlayZone.filters = [fl];
		}

		mcPlayZone.bmp.fillRect(new flash.geom.Rectangle( Std.int(x*Const.CELL_SIZE), Std.int(y*Const.CELL_SIZE), Const.CELL_SIZE, Const.CELL_SIZE),0xFF000000);
	}
	public function cleanPlayZone(){
		if(!FL_PLAYZONE)return;
		mcPlayZone.bmp.fillRect(mcPlayZone.bmp.rectangle ,0x00000000);
	}

	public function onReconnectDone(){
		onTurnDone();
		if( step == 1 ) initStep( step );
	}

	// MESSAGES
	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
		case Init(c,g):
			//trace("lock");
			MMApi.lockMessages(true);
			team = (mine || c) && !(mine && c);
			grid = new Array();
			mem = [];
			for( i in 0...Const.SIZE ){
				grid[i] = new Array();
				mem[i] = [];
				for( j in 0...Const.SIZE ){
					grid[i][j] = new Cell(this,j,i,g[i][j]);
				}
			}
			for( a in grid ) for( c in a ) c.cacheNeighbour();

			displayGrid();
			initStartAnim();

		case Place(x,y):
			var c = grid[y][x];
			var t = if( mine ) team else !team;
			var blob = getBlob(t);
			c.blob( t );
			displayGrid();
			MMApi.setColors( getBlob(team).getColor(), getBlob(!team).getColor() );

		case Extend(c):
			if( MMApi.isMyTurn() != mine ){
				if( MMApi.isMyTurn() != null || !mine ){
					trace(MMApi.isMyTurn()+" != "+mine);
				}
			}
			waitToUnlock = true;
			MMApi.lockMessages(true);
			var b = if( mine ) getBlob(team) else getBlob(!team);
			b.extend( c );
			MMApi.setColors( getBlob(team).getColor(), getBlob(!team).getColor() );

			myCount = getBlob(team).cells().length;
			oppCount = getBlob(!team).cells().length;

			blobA.clearCache();
			blobB.clearCache();

			willDisplay = 6;
			if(MMApi.isReconnecting()){
				willDisplay=-1;
			}
		}
	}

	// DISPLAY
	public function displayGrid(){
		if(mcTokens.bmp==null){
			mcTokens.bmp = new flash.display.BitmapData(mcw,mch,true,0x00000000);
			mcTokens.attachBitmap(mcTokens.bmp,0);
		}

		var mc:{>flash.MovieClip,sub:flash.MovieClip,logo:flash.MovieClip} = cast dm.attach("token",10);
		var blobDone = [];
		for( x in 0...Const.SIZE )blobDone.push([]);

		var upd = 0;
		for( x in 0...Const.SIZE ){
			for( y in 0...Const.SIZE ){
				var c = grid[y][x];

				var id = 0;
				if(c.color!=null)id+=c.color;
				if(c.team!=null)id+=10;

				if( id!= mem[x][y] ){
					mem[x][y] = id;

					if( c.team == null ){
						mc.gotoAndStop( c.color + 1 );
						Col.setColor(mc.sub,Const.TOKEN_COLORS[c.color]);
						Col.setColor(mc.logo,Const.ALIEN_COLORS[c.color]);

						var m = new flash.geom.Matrix();
						m.scale(0.5,0.5);
						m.translate( (x+0.5)*Const.CELL_SIZE, (y+0.5)*Const.CELL_SIZE );
						mcTokens.bmp.draw(mc,m);
						upd++;
					}else{
						var dir = Const.DIR.copy();
						dir.push([0,0]);
						var bl = getBlob(c.team);
						for( d in dir ){
							var nx = x+d[0];
							var ny = y+d[1];
							if(blobDone[nx][ny]==null){
								blobDone[nx][ny] = true;
								var cell = grid[ny][nx];
								if( cell.team == c.team ){
									mc.gotoAndStop(10);
									var fr = cell.getBlobFrame();
									mc.smc.gotoAndStop(fr);
									mc.smc.smc.gotoAndStop(fr);
									var m = new flash.geom.Matrix();
									m.scale(0.5,0.5);
									m.translate( (nx+0.5)*Const.CELL_SIZE, (ny+0.5)*Const.CELL_SIZE );
									bl.bmp.draw(mc,m);
									upd++;
								}
							}
						}

					}
				}else{

				}
			}
		}
		mc.removeMovieClip();
	}

	// TOOLS
	public static function getPos(n:Float){
		return Std.int(n/Const.CELL_SIZE);
	}

//{
}


