import Fight;
import mt.bumdum.Lib;

typedef Column = {  >flash.MovieClip, slots:Array<SlotDinoz>, dm:mt.DepthManager};

class Scene {

	public static var MARGIN = 10;

	public static var DP_BG 		=	0 ;
	public static var DP_DOJO 		=	1 ;
	public static var DP_SHADE 		=	2 ;
	public static var DP_CASTLE 	=	3 ;
	public static var DP_FIGHTER 	=	4 ;
	public static var DP_EFFECT 	=	8 ;
	public static var DP_PARTS 		=	10 ;
	public static var DP_BGFRONT 	=	12 ;
	public static var DP_INTER 		=	14 ;
	public static var DP_COLUMN 	=	15 ;
	public static var DP_LOADING 	=	16 ;

	public static var WIDTH = 400 ;
	public static var HEIGHT = 300 ;
	public static var VIEW_MARGIN = false ;

	public var columns:Array<Column>;
	//public var slots:Array<Array<SlotDinoz>>;

	public var root : flash.MovieClip ;
	static public var me : Scene ;

	public var shake:Float;
	public var shakeFrict:Float;
	public var shakeTimer:Float;
	public var shakeSpeed:Float;

	public var groundType:String;
	var bg : flash.MovieClip ;
	var bgDojo : flash.MovieClip ;
	var bgFront : flash.MovieClip;
	var loading : flash.MovieClip ;
	var mcClick : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var bmpBg:flash.display.BitmapData;

	public var loaded : Int ;


	public function new(mc) {
		me = this;
		root = new mt.DepthManager(mc).empty(0) ;
		mc._x = Cs.MARGIN;
		dm = new mt.DepthManager(root) ;
		bg = dm.empty(DP_BG) ;
		bgDojo = dm.empty(DP_DOJO) ;
		loaded = 0 ;
		loading = dm.attach("loading", DP_LOADING) ;
		loading.gotoAndStop(0) ;
		// BIND
		Reflect.setField( flash.Lib._root,"_fxShake",fxShake );
		initInter();
	}

	public function endLoading() : Bool  {
		if( loading == null)
			return true ;
		loading._alpha -= 5 * mt.Timer.tmod ;
		if( loading._alpha <= 0) {
			loading.removeMovieClip() ;
			return true ;
		}
		return false ;
	}
	
	public function setSkin() {
		var mcLoader = new flash.MovieClipLoader() ;
		var mc = bg ;
		var th = this ;
	
		mcLoader.onLoadInit = skinLoaded;
		mcLoader.onLoadComplete = skinLoaded;
		mcLoader.onLoadError = onLoadingError;
			
		if( Main.DATA._dojo != null ) {
			mc = bgDojo ;
			mcLoader.loadClip(Main.DATA._dojo, mc) ;
		} else {
			mcLoader.loadClip(Main.DATA._bg, mc) ;
		}

		mc._x = -MARGIN ;
		mc._y = -MARGIN ;
		
		/*
		if( !VIEW_MARGIN)
			return ;
		var h = getYSize() ;
		var mcTest = dm.empty(DP_BG) ;
		mcTest.beginFill(1, 20) ;
		mcTest.moveTo(0, 0) ;
		mcTest.lineTo(WIDTH, 0) ;
		mcTest.lineTo(WIDTH, h) ;
		mcTest.lineTo(0, h) ;
		mcTest.lineTo(0, 0) ;
		mcTest.endFill() ;
		mcTest._y = marginUp ;
		*/
	}
	
	public function onLoadingError(mc, err) {
		trace("erreur de loading "+err);
	}
	
	public function skinLoaded(mc) {
		loaded++ ;
		if(loaded==2){
			bmpBg = new flash.display.BitmapData( Cs.mcw, Cs.mch, false, 0 );
			var m = new flash.geom.Matrix();
			m.translate(-MARGIN,-MARGIN);
			bmpBg.draw(bg,m);
		}
	}

	// UPDATE
	public function update() {
		mt.Timer.update() ;
		//trace(marginUp);
		//trace(marginDown);

		// UPDATE SORT
		var list = Sprite.spriteList.copy();
		for(sp in list ) sp.update() ;

		//
		updateForce();

		// YSORT
		var f = function(a : Dynamic, b : Dynamic) {
			if(a.y > b.y) return 1 ;
			return -1 ;
		}
		Sprite.spriteList.sort(f) ;
		for(sp in Sprite.spriteList) {
			dm.over(sp.root) ;
		}

		// SLOTS
		for( c in columns )
			for( sl in c.slots )
				sl.update();

		// SHAKE
		if( shake!= null ){
			shakeTimer += shakeSpeed;
			if( shakeTimer > 1 ){
				shakeTimer--;
				shake *= -shakeFrict;
				root._y = shake;
				if( Math.abs(shake) < 1 ) {
					root._y = 0;
					shake = null;
				}
			}
		}
	}

	// INTER
	function initInter() {
		columns = [];
		for( i in 0...2 ) {
			var mc:Column = cast dm.attach("mcColumn",DP_COLUMN);
			mc._x = -Cs.MARGIN + i*(Cs.mcw+Cs.MARGIN);
			mc.slots = [];
			mc.dm = new mt.DepthManager(mc);
			columns.push(mc);
		}
	}

	// SLOTS
	public function addSlot(f:Fighter) {
		if(f.isDino != true) return;
		var id = Std.int((-f.intSide+1)*0.5);
		var slot = new SlotDinoz( id, f );
	}

	public function setLife(coef) {
	}

	// FX
	public function genGroundPart(x:Float,y:Float,?vx:Float,?vy:Float,?vz:Float,?flJump) {
		if(vx==null) vx = 0;
		if(vy==null) vy = 0;
		if(vz==null) vz = 0;

		switch(groundType) {
			case "dirt":
				if(Std.random(2) == 0) {
					var sp = new Part(dm.attach("partDust",DP_FIGHTER));
					sp.x = x;
					sp.y = y;
					sp.z = -2;
					sp.vx = vx;
					sp.vy = vy;
					sp.vz = vz;
					sp.weight = -(0.1+Math.random()*0.1);
					sp.timer = 10+Math.random()*10;
					sp.vr = (Math.random()*2-1)*10;
					sp.setScale(50+Math.random()*75);
					sp.root._rotation = Math.random()*360;
					sp.updatePos();
					sp.fadeType = 0;
					var px = Std.int( Num.mm(0,x,bmpBg.width) );
					var py = Std.int(Scene.getY(y));
					Col.setColor( sp.root, bmpBg.getPixel(px,py), -200 );
					Filt.blur(sp.root,6,6);
					return sp;
				}

			case "water":
				if(Math.random() < 1) {
					var sp = new sp.Petal(dm.attach("partGroundWater",DP_SHADE));
					sp.flBurst = true;
					sp.x = x;
					sp.y = Scene.getY(y);
					sp.vx = 0;
					sp.gy = sp.y;
					sp.vy = -(1+Math.random()*4);
					sp.weight = 0.3+Math.random()*0.3;
					sp.setScale(50+Math.random()*75);
					sp.root._rotation = Math.random()*360;
					sp.vr = (Math.random()*2-1)*10;
					sp.updatePos();
					Filt.blur(sp.root,2,2);
					return cast sp;
				}

			case "rock":
				if( flJump && Math.random() < 0.25) {
					var sp = new Part(dm.attach("partStone",DP_FIGHTER));
					sp.x = x;
					sp.y = y;
					sp.z = -2;
					sp.vx = vx;
					sp.vy = vy;
					sp.vz = -(2+Math.random()*3);
					sp.weight = 0.5+Math.random()*0.5;
					sp.timer = 50+Math.random()*10;
					sp.setScale(50+Math.random()*50);
					sp.root._rotation = Math.random()*360;
					sp.fadeType = 0;
					var px = Std.int( Num.mm(0,x,bmpBg.width) );
					var py = Std.int(Scene.getY(y));
					sp.updatePos();
					Filt.glow(sp.root,2,4,0xAAAAAA);
					Col.setColor( sp.root, bmpBg.getPixel(px,py), -200 );
					return sp;
				}
			default:

		}
		return null;
	}
	
	public function fxShake(force=8, frict=0.75, speed=1.0) {
		if(!Main.me.flDisplay) return;
		shake = force;
		shakeFrict = frict;
		shakeTimer = 0;
		shakeSpeed = speed;
	}


	// TOOLS
	static public function getY(gy:Float){
		return Main.DATA._mtop + gy * 0.5;
	}
	
	static public function getGY(y:Float){
		return (y - Main.DATA._mtop) * 2;
	}

	static public function getPYMiddle() : Float {
		return getPYSize() * 0.5;
	}
	
	static public function getPYSize() : Float {
		//trace("!"+(Scene.HEIGHT - ( Main.DATA._mtop + Main.DATA._mbottom )));
		return (Scene.HEIGHT - (Main.DATA._mtop + Main.DATA._mbottom)) * 2 ;
	}
	
	static public function getRandomPYPos(?center : Bool) {
		return Math.random() * getPYSize();
	}

	// CLICK
	public function setClick(f:Void->Void,?flUnique,?flArrow) {
		var f2 = f;
		if(flUnique) f2 = function(){f();Scene.me.removeClick();};
		root.onPress = f2;
		root.useHandCursor = true;
		if( flArrow ) {
			mcClick = dm.attach( "mcClick", DP_LOADING );
			mcClick._x = Cs.mcw+44;
			mcClick._y = Cs.mch;
		}
	}
	
	public function removeClick() {
		root.onPress = null;
		root.useHandCursor = false;
		mcClick.removeMovieClip();
	}

	function updateForce() {
		for(i in 0...Sprite.forceList.length) {
			var c = Sprite.forceList[i] ;
			for(n in i+1...Sprite.forceList.length) {
				var c2 = Sprite.forceList[n] ;
				if( Math.abs(c.z - c2.z) < 20) {
					var dist = c.getDist(c2) ;
					var lim = c.ray + c2.ray ;
					if( dist < lim) {
						if(  Math.isNaN(c.force) || Math.isNaN(c2.force) ) continue;
						var a = c.getAng(c2) ;
						var d = lim - dist ;
						var ca = Math.cos(a) ;
						var sa = Math.sin(a) ;
						var fc = c.force / (c2.force+c.force) ;

						c.x += ca * d * (1 - fc) ;
						c.y += sa * d * (1 - fc) ;
						c2.x -= ca * d * fc ;
						c2.y -= sa * d * fc ;
					}
				}
			}
		}
	}
}
