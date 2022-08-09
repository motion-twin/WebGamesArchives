import mt.bumdum.Lib;
import mt.bumdum.Sprite;

class Map{//}

	static var TOLERANCE = 80;
	public static var MAX = 2;
	public var bmp:flash.display.BitmapData;
	public var root:flash.MovieClip;
	public var id:Int;
	public var focus:{x:Float,y:Float};
	
	public var startPos: Array<Array<Float>>;
	
	public function new(){
		root =  Cs.game.mdm.empty(Game.DP_MAP);
	}
	
	public function load(n){
		id = n;
		var lvl = Cs.game.mdm.attach( "mcLevel", Game.DP_CACHE );
		lvl.gotoAndStop(id+1);

		// START POS
		startPos = [];
		for( i in 0...2 ){
			var mc:flash.MovieClip = Reflect.field(lvl,"$p"+i);
			startPos.push([mc._x,mc._y]);
			mc._visible = false;
		}
		// DRAW
		bmp = new flash.display.BitmapData( Std.int(lvl._width), Std.int(lvl._height),true,0x00000000);
		bmp.draw(lvl,new flash.geom.Matrix(),null,null,null,null);
		//
		lvl.removeMovieClip();	
		root.attachBitmap(bmp,0);

		
	}
	
	// SCROLL
	public function mouseScroll(){
		var dx =  Cs.game.root._xmouse - Cs.mcw*0.5;
		var dy =  Cs.game.root._ymouse - Cs.mcw*0.5;
		var cs = 0.1;
		root._x = Num.mm( Cs.mcw-bmp.width,	root._x-dx*cs, 0 );
		root._y = Num.mm( Cs.mch-bmp.height, 	root._y-dy*cs, 0 );
	}
	public function scroll(){

		if( focus!=null ){
			var dx =  (Cs.mcw*0.5-focus.x) - root._x;
			var dy =  (Cs.mch*0.5-focus.y) - root._y;
			var cs = 0.5;
			root._x = Num.mm( Cs.mcw-bmp.width,	root._x+dx*cs, 0 );
			root._y = Num.mm( Cs.mch-bmp.height, 	root._y+dy*cs, 0 );
		}
	}
	
	// HOLE
	public function makeHole(link,x,y,?sx:Float,?sy:Float){
		var mc = Cs.game.mdm.attach(link,Game.DP_CACHE);
		if(sx==null)sx = 1;
		if(sy==null)sy = 1;
		var m = new flash.geom.Matrix();
		m.scale(sx,sy);
		m.translate(x,y);
		bmp.draw(mc,m,null,"erase");
		mc.removeMovieClip();
	}
	
	// CHECK
	public function isFree(x,y){
		return isBg( bmp.getPixel32(Std.int(x),Std.int(y)) );
	}
	
	public function isBg(col){
		var pc = Col.colToObj32(col);
		return pc.a <= TOLERANCE;
	}
//{
}