import Protocol;
import mt.bumdum.Lib;


typedef Parallax = { >flash.MovieClip, coef:Float, dm:mt.DepthManager, num:Int, h:Int };

class Scroller {//}


	public static var HIGHSPEED = 		20;
	public static var SPEED = 		1;
	public static var BGH = 		1200;
	public static var BITMAP_HEIGHT = 	1000;

	public var destroyCount:Int;
	public var pos:Float;
	public var startPos:Int;
	public var speed:Float;
	public var bgh:Float;

	var dm:mt.DepthManager;
	public var mask:flash.MovieClip;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	//var waves:flash.MovieClip;


	var parallax:Array<Parallax>;

	public function new(){
		root = Game.me.dm.empty(Game.DP_BG);
		dm = new mt.DepthManager(root);
		startPos = BGH-100 ;
		pos = startPos;
		parallax = [];
		initBg();
		//initParallax();

		}

	// MASK
	public function attachMask(){
		mask = Game.me.dm.attach("mcMask",Game.DP_BG);
		mask._xscale = Cs.mcw;
		mask._yscale = Cs.mch;
		root.setMask(mask);
	}
	public function removeMask(){
		mask.removeMovieClip();
	}

	function initBg(){
		bg = dm.attach("mcDecor",1);
		//waves = dm.attach("mcWaves",0);
		//Col.setColor(waves,0,-25);
		//waves._alpha = 25;
		bgh = bg._height - Cs.mch;
	}
	public function addParallax(k,pmax){

		var brush = Game.me.dm.attach("mcNuage",0);
		//var bgcol = 0x155588FF;
		var bgcol = 0;


		var par = parallax[k];

		if(par==null){
			par = cast dm.empty(2);
			//par._alpha = 0;
			parallax.push(par);
			par.dm = new mt.DepthManager(par);
			//par.coef = 0.2+0.8*k/(pmax-1);
			par.coef = 0.2+0.8*k/(pmax-1);


			par.h = 0;
			par.num = 0;

			var fl = new flash.filters.DropShadowFilter();
			par.filters.push(fl);

		}

		var bgh = BGH * getSpeed(par.coef);


		var cpath = par.h/bgh;
		var bh = Std.int(Math.min( BITMAP_HEIGHT, bgh-par.h ));
		var bmp = new flash.display.BitmapData(Cs.mcw,bh,true,bgcol);
		var mc = par.dm.empty(0);
		mc._y = par.h;
		mc.attachBitmap(bmp,0);
		par.h += bmp.height;

		var nmax = Std.int( (1-par.coef)*50*Math.pow(cpath,2) ) ;

		//if( par.h+BITMAP_HEIGHT > bgh )nmax = 0;


		for( i in 0...nmax ){
			brush.smc.gotoAndStop(Std.random(brush.smc._totalframes)+1);
			//Col.setPercentColor(brush.smc, (1-par.coef)*60, 0x4488CC );

			var sc = 0.5+par.coef*1.5;
			var ma = brush._height*0.5*sc;
			var x = Math.random()*Cs.mcw;
			var y = ma+Math.random()*(bmp.height-2*ma);
			var m = new flash.geom.Matrix();
			//m.rotate(Math.random()*6.28);
			m.scale(sc,sc);
			m.translate(x,y);


			Col.setPercentColor( brush.smc, (1-par.coef)*Cs.CLOUD_FADE_PRC, Cs.CLOUD_FADE_COLOR );

			//var ct = new flash.geom.ColorTransform(1,1,1,1,0,3,20,0);

			bmp.draw(brush,m);
		}

		if( par.num == 0 ){
			var mc2 = par.dm.empty(0);
			mc2._y = bgh;
			mc2.attachBitmap(bmp,0);
		}

		par.num++;


		brush.removeMovieClip();

		return par.h>=bgh;









	}
	public function update(){
		if(destroyCount!=null){
			var par = parallax[0];
			par._alpha = destroyCount*10;
			if(destroyCount--<0){
				parallax.shift().removeMovieClip();
				destroyCount=null;
			}
		}
	}

	//
	public function inc(n:Float){
		setPos(pos+n);
		//pos += n;
		//displayPos();
	}
	public function setPos(n:Float){
		if(Game.me.mcStase!=null){
			var dec = n-pos;
			Game.me.mcStase._y += dec*SPEED;
		}
		speed = n-pos;
		pos = n;
		if( pos<0 ) pos = 0;
		displayPos();
	}

	function displayPos(){

		//bg._y = (pos*SPEED)%BGH - BGH;
		bg._y = (pos*SPEED)%bgh - bgh;

		for( par in parallax ){
			var max = Std.int( BGH*getSpeed(par.coef) );
			par._y = ( pos*getSpeed(par.coef) )%max - max;


		}


		//var cycle = 100;
		//waves._y = Math.sin(( (pos%cycle)/cycle )*6.28)*10;

	}

	function getSpeed(c:Float){
		return SPEED + c*(HIGHSPEED-SPEED);
	}

//{
}







