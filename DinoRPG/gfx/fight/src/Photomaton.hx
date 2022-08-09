

class Photomaton {

	var rdx:Float;
	var rdy:Float;
	public var loaded:Int;
	var dinoz:{>flash.MovieClip,_init:String->Int->Bool->Void};
	var ref:flash.MovieClip;

	public function new(mc){
		dinoz = cast mc;
		var mcl = new flash.MovieClipLoader();
		mcl.onLoadInit = skinLoaded;
		mcl.onLoadComplete = skinLoaded;
		mcl.loadClip( Main.DATA._dino, dinoz );
		loaded = 0;
	}

	function skinLoaded(mc){
		loaded++;
		if(loaded<2)return;
		dinoz._visible = false;

		//trace("oOo "+dinoz);
		/*
		// SCALE
		var side = 36;
		var sc = side / ref._width;

		//
		root.skin._x = bx = side*0.5+(dx*sc)*fighter.intSide;
		root.skin._y = by = side*0.5-(dy*sc);
		root.skin._xscale = -sc*100*fighter.intSide;
 		root.skin._yscale = sc*100;
		*/
	}

	public function setSkin(gfx){
		// SKIN
		dinoz._init( gfx, 0, true) ;
		// RECUPERATION DU REFERENCIEL ( au secours )
		var a = ["body","_p0","_p1","_view"];
		var mmc:flash.MovieClip = dinoz;
		rdx = 0.0;
		rdy = 0.0;
		for( str in a ){
			mmc = Reflect.field(mmc,str);
			if(mmc==null)trace(str);
			rdx += mmc._x;
			rdy += mmc._y;
		}

		var body = Reflect.field(dinoz,"body");
		ref = (cast body)._p0._p1._view;
		ref._visible = false;

		dinoz.filters = [];
		body.filters = [];
	}

	public function paint(mc:flash.MovieClip,?sc){
		if(sc==null)sc = 1.0;

		var bb = dinoz.getBounds(dinoz);
		var width =  Math.ceil(( bb.xMax - bb.xMin )*sc);
		var height = Math.ceil(( bb.yMax - bb.yMin )*sc);
		var bmp = new flash.display.BitmapData( width, height, true, 0 );

		var x = -bb.xMin*sc;
		var y = -bb.yMin*sc;

		var m = new flash.geom.Matrix();
		m.scale(sc,sc);
		m.translate(x,y);
		bmp.draw(dinoz,m);

		var dm = new mt.DepthManager(mc);
		var mc2 = dm.empty(0);

		mc2.attachBitmap(bmp,0);
		mc2._x = bb.xMin;
		mc2._y = bb.yMin;
	}

	public function getPortrait(side,m){
		ref._visible= false;
		var bmp = new flash.display.BitmapData( side+2*m, side+2*m, true, 0 );
		var sc = side / ref._width;
		var x = m+side*0.5 - (rdx*sc);
		var y = m+side*0.5 - (rdy*sc);

		var m = new flash.geom.Matrix();
		m.scale(sc,sc);
		m.translate(x,y);
		bmp.draw(dinoz,m);
		return bmp;
	}
}