import Common;
import Anim;
import mt.bumdum.Lib;

class Blob {//}

	static var MAX_LIGHT = 8;

	var l : List<Cell>;
	var game : Game;
	var team : Team;
	public var color: Int;
	public var maxLight:Int;

	var cache_pm : Array<Array<Cell>>;
	var animGlowBadMove : AnimRedGlow;
	var mcBlob:flash.MovieClip;

	public var bmp:flash.display.BitmapData;
	public var root:{>flash.MovieClip,blob:flash.MovieClip};
	public var decal:Float;
	public var colSwap:{nc:Int,oc:Int,coef:Float};
	
	public function new( g, t ){
		game = g;
		team = t;
		color = null;
		l = new List();
		
		maxLight = MAX_LIGHT;
		
		bmp = new flash.display.BitmapData(Game.mcw,Game.mch,true,0x00000000);
		root = cast game.dm.empty(Game.DP_BLOB);
		
		mcBlob = new mt.DepthManager(root).empty(0);
		mcBlob.attachBitmap(bmp,0);
		
		decal = 0;
		updateFilters(1);
		Col.setColor(mcBlob,getColor(),-200);
	}
	
	public function updateFilters(coef:Float){
		root.filters= [];
		Filt.glow(root,6*coef,2,0xFFFFFF,true);
		Filt.glow(root,8*coef,2,getColor());
		game.dm.over(root);
	}

	//
	public function update(){
		if(colSwap!=null){
			colSwap.coef = Math.min(colSwap.coef+0.2,1);
			var col = Col.mergeCol(colSwap.nc,colSwap.oc,colSwap.coef);	
			Col.setColor(mcBlob,col,-200);
			if(colSwap.coef==1)colSwap=null;
		}
	}
	
	//
	public function cells(){
		return l;
	}

	public function clearCache(){
		cache_pm = null;
	}

	public function add( c : Cell ){
		clearCache();
		l.add( c );
	}

	public function possibleMoves() : Array<Array<Cell>> {
		if( cache_pm != null ) return cache_pm;

		game.cleanChained();
		var pouet = new Array();
		for( t in 0...Const.COLORS ) pouet[t] = new Array();

		for( c in l ){
			for( t in c.getPossibleMoves() ){
				pouet[t.color].push( t );
			}
		}

		cache_pm = pouet;
		return pouet;
	}

	public function countPM(){
		var pm = possibleMoves();
		var nb = 0;
		var fColor = game.getBlob(!team).color;

		for( l in pm ){
			for( a in l ){
				if( a.color == fColor ) break;
				nb++;
			}
		}
		return nb;
	}

	public function extend( c : Int ){
		var pm = possibleMoves();

		var oc = getColor();
		color = c;
		maxLight = Std.int( Math.min( 100/pm[c].length, MAX_LIGHT ) );
		for( cell in pm[c] ) cell.blob( team );

		colSwap = {nc:getColor(),oc:oc,coef:0.0};
		if(MMApi.isReconnecting()){
			colSwap.coef=1;
		}
	
		updateFilters(1);
	}

	public function initActions(){
		if( l.length > 0 ){
			var pm = possibleMoves();

			if( countPM() == 0 ){
				if( MMApi.isMyTurn() && !game.victorySent ){
					MMApi.endTurn();
				}
				return;
			}
			game.initStep(2);
			
		}else{
			game.initStep(1);
		}
	}
	
	public function cleanActions(){
		game.initStep(0);
	}
	
	public function showPM( c : Int ){
		var pm = possibleMoves()[c];
		for( cell in pm ){
			game.markPlayZone(cell.x,cell.y);
		}
		for( cell in l ){
			game.markPlayZone(cell.x,cell.y);
		}		
	}

	public function hidePM( c : Int ){
		game.cleanPlayZone();
	}

	public function showGlow(){
		for( c in l ){
			c.showGlow();
		}
	}

	public function hideGlow(){
		for( c in l ){
			c.hideGlow();
		}
	}

	public function showGlowBadMove(){
		var list = new List();
		for( c in l ){
			list.add( c.getMcBlob().sub );
		}

		animGlowBadMove = new AnimRedGlow(this);
		game.anim.add( animGlowBadMove );
	}

	public function hideGlowBadMove(){
		animGlowBadMove.stop();
		game.anim.remove( animGlowBadMove );
	}

	public function getColor(){
		if( color == null ){
			if(team)	return 0xCCCCFF;
			else			return 0xFFCCCC;
		}
		
		return Const.BLOB_COLORS[color];
	}
	
//{
}






