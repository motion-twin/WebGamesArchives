package mt.bumdum;


class Bmp extends flash.display.BitmapData{//}

	public var root:flash.MovieClip;
	var cache:flash.display.BitmapData;
	public var pq:Float;

	public function new(mc:flash.MovieClip,?w:Int,?h:Int,?fl:Bool,?color:Int,?q:Float){
		if(w==null)w=100;
		if(h==null)h=100;
		if(fl==null)fl = true;
		if(color==null)color = 0;
		if(q==null)q = 1;

		pq = q;
		super(Std.int(w*pq),Std.int(h*pq),fl,color);



		root = mc;
		root.attachBitmap(this,0);
		root._xscale = 100/pq;
		root._yscale = 100/pq;

	}

	public function setPos(x,y){
		root._x = x;
		root._y = y;
	}
	public function kill(){
		dispose();
		if(cache!=null)cache.dispose();
		root.removeMovieClip();
	}

	// DRAW
	public function drawMc(mc:flash.MovieClip,?dx:Float,?dy:Float,?ct){
		if(dx==null)dx=0;
		if(dy==null)dy=0;
		var m = new flash.geom.Matrix();
		m.scale((mc._xscale/100)*pq, (mc._yscale/100)*pq);
		m.rotate(mc._rotation*0.0174);
		m.translate(mc._x*pq+dx,mc._y*pq+dy);
		if(ct==null)ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55);
		var b = mc.blendMode;
		draw( mc, m, ct, b, null, false );
	}

	//

	// TOOLS
	function initCache(){
		if(cache==null)cache = this.clone();
	}
	public function restore(){
		draw(cache,new flash.geom.Matrix());
	}

	public function gray(c:Float,?a){
		initCache();
		var im = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0
		];
		var r = 0.4;
		var g = 0.5;
		var b = 0.1;
		if(a==null)a = 30;
		var gm = [
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				0,	0,	0,	1,	0
		];

		var fm = [];
		for( i in 0...im.length ){
			fm.push( im[i]*(1-c) + gm[i]*c );
		}
		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = fm;

		applyFilter(this,rectangle,new flash.geom.Point(0,0),fl);


	}



//{
}
