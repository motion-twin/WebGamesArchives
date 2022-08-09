import mt.bumdum.Lib;
import Common;

interface Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	public function play() : Bool;
}

class AnimRedGlow implements Anim {
	public var mc : flash.MovieClip;
	//public var list : List<flash.MovieClip>;
	public var bl:Blob;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var cur : Float;
	//public var baseColor : {r:Int,g:Int,b:Int};

	public function new( blob ){
		bl = blob;
		//list = ml;
		cur = 0;
		//baseColor = Col.colToObj(bc);
	}

	public function play(){
		cur = (cur+66*mt.Timer.tmod)%628;
		
		var c = 1+Math.sin(cur*0.01);
		
		Col.setPercentColor( bl.root, c*30, 0xFF0000   );
		
		if(bl.root.filters.length>2){
			var a = bl.root.filters;
			a.pop();
			bl.root.filters = a;
		}
		
		Filt.glow( bl.root, Std.int(c*20), 1, 0xFF9999 );
		
		/*
		var t = (Math.sin(cur/7) + 1) / 2;
		var tb = 1 - t;

		var o = {
			r: Std.int(tb*baseColor.r + t*Const.GLOW_BAD_MOVE_COLOR.r),
			g: Std.int(tb*baseColor.g + t*Const.GLOW_BAD_MOVE_COLOR.g),
			b: Std.int(tb*baseColor.b + t*Const.GLOW_BAD_MOVE_COLOR.b),
		}
		
		for( mc in list )
			Col.setColor(mc,Col.objToCol(o));
			
		*/
			
		return false;
	}

	public function stop(){
		Col.setPercentColor( bl.root, 0, 0xFF0000   );
		if(bl.root.filters.length>2){
			var a = bl.root.filters;
			a.pop();
			bl.root.filters = a;
		}
		
		/*
		for( mc in list )
			Col.setColor(mc,Col.objToCol(baseColor));
		*/
	}
}

class AnimStart implements Anim {
	public var mc : flash.MovieClip;
	public var wait : Int;
	public var cur : Float;
	public var duration : Int;
	public var length : Int;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var scale : Int;

	public function new( m, d:Int, s : Int ){
		mc = m;
		duration = d;
		wait = 0;
		cur = 0;
		length = wait + duration;
		mc._xscale = 0;
		mc._yscale = 0;
		scale = s;
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;
		if( cur >= wait ){
			mc._xscale = scale * (cur-wait)/duration;
			mc._yscale = scale * (cur-wait)/duration;
		}
		var r = cur >= length;
		if( r ){
			mc.removeMovieClip();
		}
		return r;
	}
}
