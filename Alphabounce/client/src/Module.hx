import mt.bumdum.Sprite;
import mt.bumdum.Lib;

typedef Special = {>flash.MovieClip, id:Int, sid:Int, cx:Float  };

class Module {//}

	public var flEndConnect:Bool;
	public var flPress:Bool;
	public var flClick:Bool;
	public var flVictory:Bool;
	public var flView:Bool;
	public var flPause:Bool;

	public var wx:Int;
	public var wy:Int;
	public var pauseCount:Int;
	var pauseCoef:Float;
	var capsCoef:Float;

	public var level:Level;

	public var victoryTimer:Float;

	public var min:mt.flash.VarSecure;
	public var missile:mt.flash.VarSecure;


	public var specials:Array<Special>;
	public var caps:Array<Special>;

	public var mcEnding:{>flash.MovieClip,field:flash.TextField};
	public var mcPause:{>flash.MovieClip,fieldName:flash.TextField,fieldDesc:flash.TextField,flFadeName:Bool,b0:flash.MovieClip,b1:flash.MovieClip};

	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;

	public var ml:Dynamic;
	public var kl:Dynamic;

	public function new(mc){
		root = mc;
		dm = new mt.DepthManager(root);
		initMouseListener();
		flView = false;
	}

	public function initLevel(x,y,zid,flMinerai,?lvl){
		wx = x;
		wy = y;
		level = new Level(x,y,zid,flMinerai,lvl);
	}
	public function initPlay(){
		flView = true;
	}

	// UPDATE
	public function update(){
		//flClick = false;
		if(pauseCoef!=null){
			updatePause();
			return;
		}
	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// TOOLS
	function getBmpBg(col){
		var bmpBg = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,col);


		// CLOUDS
		var seed = new Random(wx*1000+wy);
		var brushLight = dm.attach("mcLuz",0);
		var sc = 6;
		for( i in 0...6 ){
			var m = new flash.geom.Matrix();
			m.scale((0.5+seed.rand())*sc,(0.5+seed.rand())*sc);
			m.translate(seed.random(Cs.mcw),seed.random(Cs.mch));
			var bi = 5;
			var ri = 50;
			var o = {
				r:bi+seed.random(ri),
				g:bi+seed.random(ri),
				b:bi+seed.random(ri)
			}
			Col.setPercentColor( brushLight.smc,100,Col.objToCol(o));
			brushLight.smc._alpha = 50;
			var bl = "add";
			if( i%2 == 0 )bl = "subtract";

			bmpBg.draw(brushLight,m,null,bl);
		}
		brushLight.removeMovieClip();

		// STARS
		var brushStar =  dm.attach("mcStar",0);
		for( i in 0...100 ){
			var m = new flash.geom.Matrix();
			var sc  = 0.2+seed.rand()*0.3;
			m.scale(sc,sc);
			m.translate(seed.rand()*Cs.mcw,seed.rand()*Cs.mch);
			bmpBg.draw(brushStar,m,null,"add");
		}
		brushStar.removeMovieClip();
		return bmpBg;
	}

	// ENDING
	public function initEnding(fl){
		flVictory = fl;
		victoryTimer = 0;
		flEndConnect = false;
	}
	function updateEnding(){
		victoryTimer += mt.Timer.tmod;

		if( victoryTimer>12 ){
			if( mcEnding == null ){
				mcEnding = cast dm.attach("mcEnding",20);
				mcEnding._y = Cs.mch*0.5;
				mcEnding._yscale = 0;
				Filt.glow(cast mcEnding.field,10,1,0xFFFFFF);
				mcEnding.blendMode = "ADD";

			}
			if( mcEnding._yscale <100 ){
				mcEnding._yscale += (100-mcEnding._yscale)*0.5;
				if( mcEnding._yscale >= 98 ) mcEnding._yscale = 100;
			}

			var baseStr = "MISSION OK";
			if(!flVictory)baseStr = "GAME OVER";
			var str = baseStr.substr(0,Std.int((victoryTimer-8)*0.5));
			if( victoryTimer%4 < 2 )str += "_";
			mcEnding.field.text = str ;
		}


		if( !flEndConnect && victoryTimer > 60 ){
			flEndConnect = true;
			navi.Map.me.initConnexion();
			navi.Map.me.setTimeOut(1200);
			endGame();

		}



	}
	function endGame(){

	}

	// PAUSE
	public function togglePause(){
		if( pauseCount++>31 || Cs.DEMO )return;

		flPause = !flPause;
		if( flPause ){
			pauseCoef = 0;


			if(caps==null){

				mcPause = cast Manager.dm.attach("mcBgCaps",10);
				mcPause._yscale = 0;
				mcPause._y = Cs.mch*0.5;


				//
				capsCoef = 0;
				caps = [];
				var max = specials.length;
				for( i in 0...max ){
					var spec = specials[i];
					var mc:Special = cast Manager.dm.attach("mcMenuCaps",10);
					mc.cx = (i/(max-1))*2-1;
					if(max==1)mc.cx = 0.5;
					mc._x = Cs.mcw*0.5;// + cx*(max*20);
					mc._y = Cs.mch*0.5;// + 70;
					mc.gotoAndStop(spec.id+1);
					mc.id = spec.id;
					caps.push(mc);
				}
			}
			var type = (caps.length>0)?0:1;
			mcPause.gotoAndStop( type+1 );
			mcPause.fieldDesc.text = Text.get.PAUSE_TEXT[type];



		}else{
			if(pauseCoef==null)pauseCoef = 0;
		}


	}
	public function updatePause(){

		var sens = 1;
		if(!flPause)sens = -1;

		pauseCoef = Num.mm( 0, pauseCoef+0.15*sens*mt.Timer.tmod, 1 );

		/*
		haxe.Log.clear();
		trace('');
		trace(pauseCoef);
		*/

		// MATRIX

		var base = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0,
		];

		var r = 0.3;
		var g =  0.5;
		var b = 0.1;
		var a = 30;
		var grey = [
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				0,	0,	0,	1,	0
		];
		//

		var matrix = [];
		for( i in 0...base.length ) matrix[i] = base[i]*(1-pauseCoef) + grey[i]*pauseCoef;
		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = matrix;
		root.filters = [fl];



		// CAPS
		var cc = (1-Math.cos(pauseCoef*3.14))*0.5;
		for( mc in caps ){
			mc._x = Cs.mcw*0.5 + mc.cx*cc*((caps.length-1)*30);
			mc._rotation = (1-cc)*180;

			mc._xscale = mc._yscale = 20+80*cc;

			var mcp = mcPause;
			if( pauseCoef==1 && mc.onPress==null ){
				mc.onRollOver = function(){
					Filt.glow(mc,2,4,0xFFFFFF);
					Filt.glow(mc,10,1,0xFFFFFF);
					mc.blendMode = "add";
					 mcp.fieldName.text = Text.get.CAPS_NAME[mc.id];
					 mcp.fieldName._alpha = 100;
					 mcp.flFadeName = false;
				};
				mc.onRollOut = function(){
					mc.filters  = [];
					mc.blendMode = "normal";
					mcp.flFadeName = true;
				};
				mc.onDragOver = mc.onRollOver;
				mc.onDragOut = mc.onRollOver;
				mc.onPress = callback(useSpecial,mc.id);
				mc.useHandCursor = true;
			}
			if( pauseCoef<1 && mc.onPress!=null ){
				mc.onRollOut();
				mc.onRollOver = null;
				mc.onRollOut = null;
				mc.onDragOver = null;
				mc.onDragOut = null;
				mc.onPress = null;
				mc.useHandCursor = false;
			}
		}

		mcPause._yscale = cc*100;

		if(mcPause.flFadeName && mcPause.fieldName._alpha > 0 ) mcPause.fieldName._alpha -= 10*mt.Timer.tmod;

		// BANDES
		var speed = 3;
		mcPause.b0._x = Num.sMod(mcPause.b0._x+speed, 110 );
		mcPause.b1._x = Num.sMod(mcPause.b1._x-speed, 110 );

		// RESET
		if(pauseCoef==0){
			pauseCoef = null;
			root.filters =  [];
			while(caps.length>0)caps.pop().removeMovieClip();
			caps = null;
			mcPause.removeMovieClip();
			mcPause = null;
		}


	}
	public function useSpecial(?id){

	}


	//
	public function switchView(fl){
		flView = fl;
	}

	// LISTENERS
	function initMouseListener(){
		ml = {};
		Reflect.setField(ml,"onMouseDown",mouseDown);
		Reflect.setField(ml,"onMouseUp",mouseUp);
		Reflect.setField(ml,"onMouseMove",mouseMove);
		flash.Mouse.addListener(cast ml);
	}
	public function mouseDown(){
		flPress = true;
		flClick = true;
	}
	public function mouseUp(){
		flPress = false;
	}
	function mouseMove(){
		Cs.MX = Std.int(root._xmouse);
		Cs.MY = Std.int(root._ymouse);
	}


	//
	public function kill(){

		flash.Mouse.removeListener(ml);
		flash.Key.removeListener(kl);
		root.removeMovieClip();
		flash.Mouse.show();
		Manager.dm.clear(10); // PAUSE
		Manager.dm.clear(11); // PAUSE

	}

//{
}

