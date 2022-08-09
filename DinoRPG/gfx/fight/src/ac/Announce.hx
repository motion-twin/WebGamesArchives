package ac ;

import mt.bumdum.Lib;

typedef Slider = {>flash.MovieClip, tx:Float, bx:Float};


using mt.kiroukou.motion.Tween;
class Announce extends State {

	static var SCALE = 0.7;
	var f : Fighter ;
	var skill : String ;
	var loaded:Int;
	var step:Int;
	var dinoz:{>Slider,  _init:String -> Int -> Bool -> Void} ;
	var text:{>Slider, field:flash.TextField };
	var bg:Slider;
	var box:flash.MovieClip;
	var bdm:mt.DepthManager;

	public function new( f:Fighter, skill:String ) {
		super();
		this.f = f ;
		this.skill = skill ;
		loaded = 2;
		addActor(f);

		spc = 0.035;
		box = Scene.me.dm.empty(Scene.DP_INTER) ;
		bdm = new mt.DepthManager(box);

		if(f.isDino){
			dinoz = cast bdm.empty(0) ;
			Main.me.photomaton.setSkin(f.gfx);
			Main.me.photomaton.paint(dinoz, SCALE);
			dinoz._alpha = 0;
		}
	}

	override function init() {
		if(castingWait || loaded < 2 ) return;
		step = 0;

		var w = Cs.mcw * 0.5;
		var sc = SCALE;
		// DINOZ
		dinoz.bx = dinoz._x = w-f.intSide*(w+100);
		dinoz._y = Cs.mch - (10+150*sc);
		dinoz.tx = w-f.intSide*(w-(160*sc)) ;
		dinoz._xscale = -f.intSide*100;
		dinoz._alpha = 100;
		dinoz._init(f.gfx, 0, true) ;
		//
		bg = cast bdm.attach("bgAnnounce",0) ;
		bdm.under(bg);
		bg.bx = bg._x = w - f.intSide * (w+160);
		bg._y = Cs.mch;
		bg.tx = w - f.intSide * w;
		bg._xscale = f.intSide*100;

		text = cast bdm.attach("mcAnnounceText",0) ;
		text.field.text = skill.toUpperCase();
		var tw = text.field.textWidth + 8;
		text.bx = text._x = w - f.intSide * w;
		text._y = Cs.mch;
		var dx = tw;
		if(f.isDino) dx += 60;
		text.tx = w - f.intSide * (w - dx);
		if( f.side ) {
			text._x -= tw;
			text.tx -= tw;
		}

		bg.gotoAndStop(f.isDino ? 1 : 2);
		bg.smc._x = tw + 8;
		if(f.isDino) bg.smc._x += 60;

	}

	function dinozLoaded(mc){
		loaded ++;
		if(loaded == 2) init();
	}

	public override function update() {
		super.update();
		if( castingWait || loaded < 2 ) return;
		switch(step) {
			case  0:
				dinoz._x += (dinoz.tx - dinoz._x) * 0.3;
				bg._x += (bg.tx - bg._x) * 0.5;
				if(coef > 0.3) text._x += (text.tx - text._x) * 0.4;

				if( coef < 1 && f.skin.filters.length == 0 ) {
					Filt.glow(f.skin,4,4,0xFFFFFF);
				} else {
					f.skin.filters = [];
				}

				if( coef == 1 ) {
					/*
					step = 1;
					dinoz._x = dinoz.tx;
					bg._x = bg.tx;
					text._x = text.tx;
					*/
					text.tween().to( 0.20, _x = (text.bx - f.intSide * text._width ) );
					dinoz.tween().to( 0.25, _x = (dinoz.bx) );
					bg.tween().to( 0.20, _x = (bg.bx) ).onComplete( function(t) {
							box.removeMovieClip();
						});
					
					end();
				}
			/*
			case 1:
				
				dinoz._x 	+= 	(dinoz._x - dinoz.tx) - 1 * f.intSide;
				bg._x 		+= 	(bg._x - bg.tx) - 2 * f.intSide;
				text._x 	+= 	(text._x - text.tx) - 0.5 * f.intSide;

				if( Math.abs(bg._x) > Cs.mcw * 1.5 ) {
					box.removeMovieClip();
				}
			*/
		}
	}
}
