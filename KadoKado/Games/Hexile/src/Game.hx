import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;
import mt.bumdum.Bmp;

//typedef Hex = { team:Int, n:Int, x:Int, y:Int }
typedef Move = {sc:Float,h:Socle}
enum HexType {
	Beach;
	Dirt;
	Mountain;
}

enum Step {
	Play;
	Jump;
	Convert;
	GameOver;
}

class Game {//}

	public static var MODE_CLONE = false;

	public static var FL_QUICK = false;
	public static var FL_DEBUG = false;

	public static var PMIN  = 	1;
	public static var PMAX  = 	6;
	//public static var SMAX  = 	10;

	public static var CMAX = 	17;

	public static var DP_BG = 	0;
	public static var DP_HEX = 	1;
	public static var DP_SHADE = 	2;
	public static var DP_QUEUE = 	3;
	public static var DP_SOLDAT = 	4;
	public static var DP_PARTS = 	5;
	public static var DP_INTER = 	6;

	public static var CX = 2;
	public static var CY = 2;


	var flWin:mt.flash.Volatile<Bool>;
	var flBlink:Bool;

	var step:Step;
	var ssum:mt.flash.Volatile<Int>;
	var ia:mt.flash.Volatile<Int>;
	public var count:mt.flash.Volatile<Int>;
	var gstep:mt.flash.Volatile<Int>;

	var coef:Float;
	public var turn: mt.flash.Volatile<Int>;

	public var library:Array<mt.flash.PArray<Int>>;

	public var scores:Array<Int>;
	public var grid:Array<Array<Socle>>;
	public var socles:mt.flash.PArray<Socle>;
	public var work:Array<Socle>;
	public var blinks:Array<Socle>;
	public var hex:Socle;
	public var soldats:mt.flash.PArray<Soldat>;

	public var inter:flash.MovieClip;
	public var castle:{ >flash.MovieClip, base:flash.MovieClip, _obj:{register:flash.MovieClip->Void},field:flash.TextField };
	public var msg:flash.MovieClip;


	public static var me:Game;
	public var dm:mt.DepthManager;
	public var gdm:mt.DepthManager;
	public var sdm:mt.DepthManager;
	public var rdm:mt.DepthManager;
	public var ground:flash.MovieClip;
	public var root:flash.MovieClip;
	public var bg:flash.display.BitmapData;




	public function new( mc : flash.MovieClip ){
		//haxe.Log.setColor(0xFFFFFF);
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);


		flBlink = true;

		// PLACE CX
		while(true){
			CX = Std.random(20);
			CY = Std.random(20);
			var flBreak = isInBorder(CX,CY,1);
			var dx = Math.abs(6-CX);
			var dy = Math.abs(6-CY);
			var r = 2;
			if( dx<r && dy<r )flBreak = false;
			if(flBreak)break;

		}
		//CX = 5;
		//CY = 5;

		// BG
		var mc = dm.empty(DP_BG);
		bg = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x4278AC);
		mc.attachBitmap(bg,0);

		// GROUND
		ground = dm.empty(DP_HEX);
		gdm = new mt.DepthManager(ground);

		// SHADE
		var mc = dm.empty(DP_SHADE);
		mc._alpha = 30;
		mc.blendMode = "layer";
		sdm = new mt.DepthManager(mc);

		// RAY
		var mc = dm.empty(DP_QUEUE);
		mc.blendMode = "add";
		rdm = new mt.DepthManager(mc);

		scores = new mt.flash.PArray();
		scores[0] = 0;
		scores[1] = 0;
		ssum = 0;

		initInter();

		// IA
		ia = 1;//Std.random(8);

		if(Std.random(3)==0 )		ia--;
		while(Std.random(5)==0 )	ia++;
		flash.System.setClipboard(Std.string(ia));


		var field:flash.TextField = Reflect.field(inter,"_field");
		field.text = Std.string(ia);


		initGrid();
		buildLibrary();

		turn = 0;
		initPlay();

	}


	// INIT
	public function initGrid(){
		var max = 11;
		var lim = 8;
		socles = new mt.flash.PArray();
		grid = [];
		soldats = new mt.flash.PArray();



		/* FULL
		for( x in 0...max ){
			grid[x] = [];
			for( y in 0...max ){

				if( isIn(x,y) ){
					newSocle(x,y);
				}
			}
		}
		/*/ //PARTIAL

		for( x in 0...max )grid[x] = [];
		var cx = 6;
		var cy = 6;
		/*
		var dx = Math.abs(cx-CX);
		var dy = Math.abs(cy-CY);
		var r = 2;
		if( dx<r && dy<r ){

			cx = 2;
			cy = 2;
		}
		*/



		newSocle(cx,cy);


		for( i in 0...CMAX*2-1 ){
			var list = [];
			for( h in socles ){
				for( d in Cs.DIR ){
					var x = h.x+d[0];
					var y = h.y+d[1];
					if( grid[x][y]==null && isIn(x,y))list.push({x:x,y:y});
				}
			}
			var p = list[ Std.random(list.length) ];
			newSocle(p.x,p.y);
		}
		for( x in 0...max )for( y in 0...max )gdm.over(grid[x][y].root);


		//*/


		terraforming();


	}
	function newSocle(x,y){
		var mc:Socle = new Socle(x,y);

	}
	public function isIn(x,y){
		var dx =  Math.abs(x-CX);
		var dy =  Math.abs(y-CY);
		var r = 1;
		return isInBorder(x,y,0) && ( dx>r || dy>r ) ;
	}

	public function isInBorder(x,y,m){
		return x-y<5-m  && y-x<5-m && x+y>2+m && x+y<17;

	}

	// LIBRARY
	public function buildLibrary(){
		library = new mt.flash.PArray();

		var base = [
			6,
			5,5,
			4,4,4,
			3,3,3,
			2,2,2,
			1,1,
		];

		if( FL_QUICK ) base = [1,2,3,4,5,6];


		for( i in 0...2 ){
			var a = base.copy();
			var lib = new mt.flash.PArray();
			while(a.length>0){
				var index = Std.random(a.length);
				lib.push(a[index]);
				a.splice(index,1);
			}
			library.push(lib);
		}


	}

	// TERRAFORMING
	public function terraforming(){



		//
		var  beachLim = 7 +Std.random(3);
		var  mountLim = 5+Std.random(12);

		// BEACH
		//var bitches = [];

		for( h in socles )h.seekSea();
		for( h in socles ){
			var sea = h.dataSea*2.0;
			var a = h.getNeighbors();
			for( h2 in a )sea+=h2.dataSea*0.5;
			if( sea + Std.random(2) > beachLim && h.dataSea>0 ){
				h.setType(Beach);
				//bitches.push(h);
			}else{
				h.setType(Dirt);
			}
			if(Std.random(mountLim)==0){
				h.setType(Mountain);
			}
		}



		// PAINT BG

		newSocle(CX,CY);

		// BIG BLUE
		var cr = new flash.geom.ColorTransform(0,0,0,1,0,0,0,255);
		Filt.glow(ground,100,16,0x5188BF);
		bg.draw(ground);
		ground.filters = [];

		//ground._visible = false;

		// RIVAGE
		var brush = dm.attach("brushSeaSide",0);
		var fr = 0;

		for( h in socles ){
			var i = 0;
			for( d in Cs.DIR ){
				var x = h.x+d[0];
				var y = h.y+d[1];
				if( Game.me.grid[x][y] == null ){
					var m = new flash.geom.Matrix();
					var sc  = 1.01;
					m.rotate( i*6.28/6 );
					m.scale(sc,sc);
					m.translate(Cs.getX(x,y),Cs.getY(x,y));
					brush.gotoAndStop(Std.random(brush._totalframes)+1);
					brush.smc._alpha = h.type==Beach?100:40;
					bg.draw(brush,m,null,"lighten");
				}
				i++;
			}

		}
		brush.removeMovieClip();
		socles.pop();




		// CASTLE
		castle = cast dm.attach("mcCastle",DP_HEX);
		castle._x = Cs.getX(CX,CY);
		castle._y = Cs.getY(CX,CY);
		castle.base.smc.gotoAndStop(2);




		/*
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		bg.applyFilter(bg,bg.rectangle,new flash.geom.Point(0,0),fl);
		*/

	}

	// PLAY
	function initPlay(){
		step = Play;
		coef = 0;
		turn = 1-turn;
		var a = library[turn];

		if(a.length==0){
			initGameOver();
			return;
		}


		var index = Std.random(a.length);
		count = a[index];
		a.splice(index,1);

		 //PMIN+Std.random(PMAX-PMIN);
		/*
		for( i in 0...count ){
			var sol = new Soldat(turn);
			sol.id = i;
			sol.initStartPos();
		}
		*/
		var fr = turn+1;
		var f = function(mc:flash.MovieClip){
			mc.gotoAndStop(fr);
		}
		castle._obj = { register:f };
		castle.base.gotoAndStop(count+1);

		var h = library[0].length + library[1].length;
		if(h==0){
			newMsg("DERNIER COUP");
		}
		//castle.base._y = -h;
		castle.field.text = Std.string( h );




		if( turn==0 ){
			for( h in socles ){
				if(h.team==null)grid[h.x][h.y].active();
			}
		}


	}
	function updatePlay(){
		coef+=0.05*mt.Timer.tmod;

		flBlink = !flBlink;
		for( h in blinks ){
			for( sol in h.soldats ){
				Col.setPercentColor(sol,flBlink?30:0,0xFFFFFF);
			}
		}


		/*
		if(  library[0].length + library[1].length == 0 ){
			castle.base._y = -Std.random(3);
		}
		*/

		if( turn==1 && coef>=1 )autoPlay();
	}
	function autoPlay(){
		var list:Array<Move> = [];
		for( h in socles ){
			if(h.team==null){
				var score = [0.5,1,0][Type.enumIndex(h.type)];
				for( d in Cs.DIR ){
					var nx = h.x+d[0];
					var ny = h.y+d[1];
					var h2 = grid[nx][ny];
					if(h2 == null ){
						score -= 0.5;
					}else if(h2.team==null ){
						score -= 0.5;
					}else if( h2.team==1 ){
						score += Math.min(h2.n*0.25,3);
					}else if( h2.team==0 ){
						if(h2.n<count)	score += Math.pow(h2.n,1.5);
						else		score -= 1;
					}

				}
				list.push({sc:score,h:h});
			}
		}

		var f = function(a:Move,b:Move){
			if(a.sc>b.sc)return -1;
			return  1;
		}
		list.sort(f);

		var rlist = [];
		var n = -9999.9;
		var bads = ia;
		for( o in  list ){
			bads--;
			if( o.sc<n && bads<0 )break;
			n = o.sc;
			rlist.push(o);

		}

		initJump( rlist[Std.random(rlist.length)].h );




	}

	// JUMP
	public function initJump(hex:Socle){

		if(msg!=null)newMsg();
		if(hex.team!=null)	trace("ERROR TEAM");
		if(hex.n>0)		trace("ERROR NUM");

		step = Jump;
		this.hex = hex;
		hex.team = turn;
		var max = Socle.getMax(hex.type);
		var n = 0;


		for( i in 0...count ){
			var sol = new Soldat(turn);
			sol.id = n;
			sol.x = castle._x ;
			sol.y = castle._y - 16;
			sol.initJump(n>=max);
			n++;
		}


		for( h in socles )grid[h.x][h.y].unactive();
	}
	function updateJump(){
		for(sol in soldats)if(sol.step==1)return;
		initConvert();
	}

	// CONVERT
	function initConvert(){
		step = Convert;
		coef = 0;
		work = [];



		var fill = hex.getRenfort(hex.n-1);
		var clist = hex.getConvert(hex.n);
		for( h in clist ){
			h.swapTeam();
			work.push(h);
		}


		for( h in fill ){
			var sol = new Soldat(turn);
			sol.id = 0;
			sol.x = Cs.getX(hex.x,hex.y);
			sol.y = Cs.getY(hex.x,hex.y);
			sol.initJump(false,h);
			sol.jh = 40;
			hex.incSoldat(-1);
		}


	}



	function updateConvert(){
		if(soldats.length==0){
			majScore();
			initPlay();
		}
	}

	// GAMEOVER
	function initGameOver(){
		step = GameOver;
		coef = 0;

		flWin = scores[0]>=scores[1];
		gstep = 0;

		//else		newMsg("DEFAITE!");


		for( h in socles ){
			if(h.team==(flWin?0:1) ){
				for( mc in h.soldats ){
					mc.smc.gotoAndStop(2);
					mc.smc.smc.gotoAndPlay(Std.random(10)+1);
				}
			}
		}




		//for( h in socles )if(h.team==1)	work.push(h);





	}
	function updateGameOver(){
		switch(gstep){

			case 0:
				coef += 0.01;
				if( msg==null && coef>0.5 ){
					if(flWin){
						KKApi.addScore(Cs.SCORE_VICTORY);
						newMsg("+"+KKApi.val(Cs.SCORE_VICTORY)+" pts");
					}
					//newMsg();
				}
				if( coef>=1){
					gstep = 10;
					coef = 0;
				}

			case 10:
				if(coef==0){
					coef=1;
					work = [];
					for( h in socles )if(h.team==0)	work.push(h);
					newMsg("BONUS");
				}

				var h = work[0];
				if(h.n>0){
					h.incSoldat(-1);
					KKApi.addScore(Cs.SCORE_ALLY);
					h.fxStar();
				}else{
					work.shift();
					if(work.length==0){
						coef = 0;
						newMsg();
						gstep++;
					}
				}

			case 11:
				coef+= 0.04;
				if(coef>1){
					KKApi.gameOver({});
					gstep++;
				}


		}
	}

	// SCORE
	function majScore(){
		var sc = KKApi.const(0);
		for( h in socles ){
			if(h.team==0){
				//trace("!"+KKApi.val(sc) );
				//trace("!"+KKApi.val(Cs.HEX_VALUE[ Type.enumIndex(h.type)]) );
				sc = KKApi.cadd( sc, Cs.SCORE_HEX[ Type.enumIndex(h.type) ] );
			}
		}
		KKApi.setScore(sc);

	}

	// INTER
	function initInter(){
		inter = dm.attach("mcInter",DP_INTER);
		incTeamScore(0,0);
		incTeamScore(1,0);
		Filt.glow(inter,2,1,0);
	}
	public function incTeamScore(team,inc){

		scores[team] += inc;
		var field:flash.TextField = Reflect.field(inter,"_field"+team);
		field.text = Std.string(scores[team]);

		ssum = scores[0]+scores[1];
		//var a = [scores[0],scores[1]];
		//scores = a;



		//trace("inTeam("+team+")"+inc);
	}

	// TOOLS
	function newMsg(?str:String){
		if(msg!=null){
			msg.gotoAndPlay("leave");
			msg = null;
			if(str==null)return;
		}
		msg = dm.attach("mcMsg",DP_INTER);
		var field:flash.TextField = cast (msg.smc).field;
		field.text = str.toUpperCase();
		Filt.glow(msg,2,4,0);
	}

	// UPDATE
	public function update(){


		updateSprites();
		switch(step){
			case Play: 	updatePlay();
			case Jump: 	updateJump();
			case Convert: 	updateConvert();
			case GameOver:	updateGameOver();
		}


		// CHECK CHEAT
		if( socles.cheat || library[0].cheat || library[1].cheat )KKApi.flagCheater();
		if( ssum != scores[0]+scores[1] )KKApi.flagCheater();

	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}


	public function decScore(n){
		var sc = KKApi.val( KKApi.getScore() );
		var dec = KKApi.val(n);
		sc = Std.int(Math.max(0,sc-dec));
		KKApi.setScore(KKApi.const(sc));

	}

//{
}

	// X clignotement compteur - baisser ile
	// POP SCORE
	// X MONTRER RESULTAT DU PROCHAIN COUPS
	// MARQUER BORD PLAGES


	// NAME

	// HEXALT
	// HEXECUTE
	// HEX-ILE







