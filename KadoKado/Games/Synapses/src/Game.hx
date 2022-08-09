import KKApi;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import Element;


typedef Influx = {>flash.MovieClip, el:Element, sx:Float, sy:Float, c:Float, sc:Float };

// TWIN SPIRIT
class Game {//}

	public static var FL_TEST =		false;
	public static var FL_TURBO =		false;
	public static var FL_INFINITE =		false;

	public static var DP_INTER =		6;
	public static var DP_FX =		5;
	public static var DP_HUNTER =		4;
	public static var DP_ELEMENTS =		3;
	public static var DP_UNDER_FX = 	2;
	public static var DP_BRANCH =		1;
	public static var DP_BG = 		0;

	public static var BG_COLOR = 		0x5C0101;

	public var lvl:Int;
	public var coef:Float;
	public var frict:Float;

	public var timer:Float;
	public var counter:Int;
	public var influxMax:Int;
	public var influxSpeed:Float;

	public var winner:Hunter;

	public var action:Void->Void;
	public var hunters:Array<Hunter>;
	public var grid:Array<Array<Array<Element>>>;
	public var elements:Array<Element>;
	public var tunnel:Array<Layer>;
	public var flux:Array<Influx>;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;

	public var bdx:Float;
	public var bdy:Float;

	public var sx:Float;
	public var sy:Float;

	public var ex:Float;
	public var ey:Float;


	// DEBUG
	public var bmpGrid:flash.display.BitmapData;


	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		hunters = [];
		elements = [];
		tunnel = [];
		flux = [];

		initBg();
		initGrid();

		lvl = 0;
		var h = new Hunter(0);




		initPlay();
	}

	function initBg(){

		bg = dm.attach("mcBg",DP_BG);
		bdx = 0;
		bdy = 0;

		//
		for( i in 0...5 ){
			var lay = new Layer();
			lay.initTunnel(0,0);
		}
		for( i in 0...tunnel.length ){
			tunnel[i].updateTunnel(i+1);
		}



	}
	function initGrid(){
		grid = [];
		for( x in  0...Cs.XMAX ){
			grid[x] = [];
			for( y in  0...Cs.YMAX ){
				grid[x][y] = [];
			}
		}
	}

	//
	public function update(){

		haxe.Log.clear();
		//trace("hunters:"+hunters.length);
		//trace("elements:"+elements.length);
		//trace("sp:"+Sprite.spriteList.length);


		frict = Math.pow(0.97,mt.Timer.tmod);

		viewGrid(grid);
		var list = Sprite.spriteList.copy();
		for(sp in list ) sp.update();
		action();

	}

	// PLAY
	public function initPlay(){

		if(FL_TURBO) lvl = 0;

		influxMax= 0;
		influxSpeed= 1;

		action = updatePlay;

		var h  = hunters[0];
		h.initPlay();


		// HUNTERS
		var max = lvl;
		if(max>=4)max = 4;
		for( i in 0...max ){
			var h = new Hunter(i+1);
			h.speed = Math.min(1+lvl,15);
		}

		// ELEMENTS
		var max = Cs.CEL_MAX;
		for( i in 0...max ){
			var el = new Element();
			el.initMove( Math.random()*6.28, 1 );
		}


		//
		counter = null;
		timer = 150;
		if(lvl==0)timer=5000;
		if(lvl==1)timer=500;
		//
		bg.onPress = initResolve;
		bg.useHandCursor = true;
		KKApi.registerButton(bg);


	}
	public function updatePlay(){

		timer-=mt.Timer.tmod;

		if(timer<0){
			if(counter==null)counter = 4;
			counter--;
			timer = 30;
			var mc = dm.attach("mcCounter",DP_INTER);
			//mc._xscale = mc._yscale = 1200;
			mc._x = Cs.mcw;
			mc._alpha = 50;
			mc.blendMode = "add";
			cast(mc)._num = counter;
			if(counter==0)initResolve();


		}


		//if( FL_TEST && flash.Key.isDown(flash.Key.SPACE) )initResolve();
	}

	// LAYER
	public function newLayer(){
		return new Layer();

	}

	// RESOLVE
	public function initResolve(){
		coef = null;
		bg.onPress = null;
		bg.useHandCursor = false;
		action = updateResolve;
		for( h in hunters )h.initResolve();

	}
	public function updateResolve(){
		updateFlux();

		if( coef == null ){
			if( checkEnd() )coef = 0;
		}else{
			influxSpeed *= 1.02;
			if( flux.length==0 ){
				coef = Math.min(coef+0.1*mt.Timer.tmod,1);
				if(coef==1)initClean();
			}
		}


		//if( checkEnd() )initClean();
	}
	public function checkEnd(){
		for( el in elements )if( el.state == Moving )return false;
		return true;
	}

	//CLEAN
	public function initClean(){
		coef = 0;
		action = updateClean;


		// WINNER
		winner =  null;
		for( h in hunters ){
			if(winner == null || h.first.size>winner.first.size ){
				winner = h;

			}
		}
		for( h in hunters ){
			if(h!=winner){
				h.flExplode = true;
			}else{
				h.cacheShape();
			}
		}
		for( el in elements ){
			if( el.col != winner.col )el.vanish();
		}


		// FLUX
		while(flux.length>0)flux.pop().removeMovieClip();
		// ZOOM
		if(winner.col==0 || FL_INFINITE ){
			winner.layer.initTunnel(-bdx,-bdy);

			var margin = 50;
			sx = bdx;
			sy = bdy;

			ex = (Math.random()*2-1)*margin;
			ey = (Math.random()*2-1)*margin;

		}

	}
	public function updateClean(){
		if( hunters.length==1 ){


			if(winner.col==0 || FL_INFINITE ){
				coef = Math.min(coef+0.05*mt.Timer.tmod,1);
				winner.root._visible = false;
				bdx = ex*coef + sx*(1-coef);
				bdy = ey*coef + sy*(1-coef);

				//trace(bdr);

				for( i in 0...tunnel.length ){
					var lay = tunnel[i];
					lay.updateTunnel(i+coef);
				}


				if(coef==1){
					lvl++;
					initPlay();
				}

			}else{
				KKApi.gameOver(null);
				action = null;
			}
		}
	}


	// FX
	public function fxScore(x,y,n){
		var p = new mt.bumdum.Phys(Game.me.dm.attach("partScore",DP_FX));
		p.x = x;
		p.y = y;
		var field:flash.TextField = cast(p.root.smc).field;
		field.text = Std.string(n);
		p.weight = -(0.1+Math.random()*0.1);
		//p.vy = 2;
		p.timer = 20;
		p.fadeLimit = 5;
		p.fadeType = 0;
		p.sleep = Math.random()*2;
		p.root.stop();
		p.updatePos();
	}

	public function updateFlux(){
		//if(coef == null && Std.random(1)==0 && mt.Timer.tmod < 1.5 && flux.length<influxMax )newInflux();

		var list = flux.copy();
		for( mc in list ){

			mc.c = Math.min(mc.c+mc.sc*influxSpeed*mt.Timer.tmod,1);

			mc._x = mc.sx*(1-mc.c) + mc.el.x*mc.c;
			mc._y = mc.sy*(1-mc.c) + mc.el.y*mc.c;


			if(mc.c==1){
				var el = mc.el.parent;
				if(el!=null){
					setInfluxElement(mc,el);
				}else{

					hunters[mc.el.col].incScore(1);
					mc.removeMovieClip();
					flux.remove(mc);
				}
			}




		}
	}

	public function newInflux(?el){
		var mc:Influx = cast dm.attach("mcInflux",Game.DP_ELEMENTS);

		if(el==null){
			var list = [];
			for( e in elements )if(e.size==0 && e.parent!=null )list.push(e);
			if(list.length==0)return;
			el = list[Std.random(list.length)];
		}


		mc.el = el;
		setInfluxElement(mc,el.parent);
		flux.push(mc);

		mc.blendMode = "add";

		Filt.blur(mc,6,6);
		//mc._alpha = 25;

	}
	public function setInfluxElement(mc:Influx,el:Element){
		mc.sx = mc.el.x;
		mc.sy = mc.el.y;
		mc._x = mc.sx;
		mc._y = mc.sy;

		mc.el = el;

		mc.c = 0;
		var dx = mc.el.x - mc.sx;
		var dy = mc.el.y - mc.sy;
		var dist = Math.sqrt(dx*dx+dy*dy);
		mc.sc = 4/dist;

	}


	// DEBUG
	function viewGrid(grid:Array<Array<Array<Element>>>){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}

		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData( Cs.XMAX, Cs.YMAX, false, 0 );
			var mc = dm.empty(DP_BG);
			mc.attachBitmap(bmpGrid,0);
			mc.blendMode = "add";

			mc._xscale = (Cs.mcw/Cs.XMAX)*100;
			mc._yscale = (Cs.mch/Cs.YMAX)*100;
		}

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){

				var n = grid[x][y].length * 20;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});
				bmpGrid.setPixel(x,y,col);
			}
		}


	}





//{
}


/*
Après un réveil difficile causée par une soirée trops arrosée, *Rémi le punk* doit tenter de remettre son cerveau en place pour partir au travail.
Aidez le en reconnectant toutes les *synapses* décollés pendant la nuit.
*/

// FX	FAIRE DU COURANT
// GFX 	GENERATION DECOR


// HISTAMINE






















