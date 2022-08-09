
enum Mode {
	Waiting ;
	Anim ;
	Dead ;
	Dodge;
}

typedef KTween = mt.kiroukou.motion.Tween<flash.MovieClip>;
typedef MyTween = Tween;

import Fight ;
import mt.bumdum.Lib;
import part.Ashes2;
import part.Bubbles;
import  mt.kiroukou.motion.Tween.TFx;

class Fighter extends Phys {

	public static var DP_BACK = 0 ;
	public static var DP_BODY = 1 ;
	public static var DP_STATUS = 2 ;
	public static var DP_FRONT = 3 ;

	var flFreeze:Bool;
	var flFly:Bool;
	var flLand:Bool;

	public var fid : Int ;
	public var dripTimer : Float ;
	public var side : Bool ;
	public var intSide : Int ;
	public var name : String ;
	public var life : Int ;
	public var lifeMax : Int ;
	
	public var energy : Int;
	public var maxEnergy : Int;

	public var range : Int ;
	var decal:Float;

	public var slot:SlotDinoz;

	public var mode : Mode ;

	public var gfx : String ;
	public var isDino : Bool ;
	public var currentAnim : String ;

	public var body : flash.MovieClip;
	public var skinBox:flash.MovieClip;
	public var skin : {>flash.MovieClip, _init : String -> Int -> Bool -> Void, _p0 : {>flash.MovieClip, _s : flash.MovieClip, _p1 : {>flash.MovieClip, _anim : {>flash.MovieClip, _sub : flash.MovieClip}}}};

	public var status : List<_Status> ;

	var mcOndeFront:flash.MovieClip;
	var mcOndeBack:flash.MovieClip;
	var mcIceBlockFront:flash.MovieClip;
	var mcIceBlockBack:flash.MovieClip;
	
	var mcMudWall : flash.MovieClip;

	var dm : mt.DepthManager ;
	public var bdm : mt.DepthManager ;
	public var sbdm : mt.DepthManager ;

	public var props:Array<_Property>;

	public var shake : Float ;

	public var walkSpeed : Float ;
	public var runSpeed : Float ;
	public var height:Float;
	public var size:Float;

	var defaultAnim : String ;
	var alpha : Int ;
	public var skinLoaded : Int ;

	var tweenMove:MyTween;
	public var moveType:Int;
	public var lockTimer:Float;

	public var lastCoords : {x : Float, y : Float} ;
	public var wp : {x : Float, y : Float, to:Float} ;
	public var colt: flash.geom.Transform;

	public var lock : Bool ;
	public var focus:State;

	public function new( f : FighterInfos ) {
		Main.me.fighters.push(this) ;
		super(Main.me.scene.dm.empty(Scene.DP_FIGHTER)) ;
		lock = false ;
		fid = f._fid ;
		setSide(f._side);

		isDino = f._dino ;
		name = f._name ;
		life = f._life ;
		lifeMax = f._life ;
		if( isDino && f._props.length == 0 ) lifeMax = f._size;
		
		energy = 100;
		maxEnergy = 100;

		gfx = f._gfx ;
		size = Math.pow(f._size / 100, 0.65);
		setForce(10 * size) ;
		
		// PROPS
		props = f._props.copy();
		if( haveProp(_PStatic) ) {
			flFreeze = true;
			force = Math.NaN;
		}
		
		range = 10 ;
		walkSpeed = 1.8;
		runSpeed = 8;
		ray = 10;
		height = 36;

		dm = new mt.DepthManager(root) ;
		body = dm.empty(1) ;
		bdm = new mt.DepthManager(body) ;
		skinBox = bdm.empty(DP_BODY);
		sbdm = new mt.DepthManager(skinBox) ;
		status = new List() ;

		//initValues = {walkSpeed : 1.0, levitation : 0, defaultAnim : "stand", alpha : 100} ;
		//levitation = 0 ;
		alpha = 0 ;
		defaultAnim = "stand" ;

		mode = Waiting;
	}

	public function setSide(n:Bool) {
		side = n ;
		intSide = if( side) 1 else -1 ;
		skin._xscale = -100;
		skin._x = intSide * 20 ;
	}

	public override function update() {
		super.update() ;
		// LOCK TIMER
		if(lockTimer != null) {
			lockTimer -= mt.Timer.tmod;
			if(lockTimer <= 0) lockTimer = null;
		}
		// ANIM
		switch(mode) {
			case Waiting :
				if(focus == null && lockTimer == null ) updateWait();
				checkBounds() ;
			
			case Anim :
				var mc = skin._p0._p1._anim._sub;
				if( mc._currentframe >= mc._totalframes) {
					setWaiting() ;
					// NEED _SUB for all anim
				}
			case Dead :
			case Dodge : updateDodge();
		}
		updateFx();
		updateStatus();
	}

	public function isReadyToWalk() {
		return mode == Waiting && focus == null && lockTimer == null && flFreeze != true && wp == null;
	}

	// WAIT MOVE
	public function updateWait() {
		if( flFreeze || haveProp(_PStatic) ) return;
		if( wp != null ) {
			var a = getAng(wp) ;
			var d = getDist(wp) ;
			vx = -Math.cos(a) * walkSpeed * 0.5 ;
			vy = -Math.sin(a) * walkSpeed * 0.5 ;
			wp.to -= mt.Timer.tmod;
			if( d < walkSpeed * 2 || wp.to <= 0 ) stopWalk();
			//
			if( vx * intSide < 0 ) {
				var m:flash.MovieClip = skin._p0._p1._anim._sub;
				m.stop();
				m.onEnterFrame = function() {
					if( m._currentframe <= 1 )
						m.gotoAndStop(m._totalframes - 1);
					m.prevFrame();
				}
			}
		}
	}
	
	public function startWalk() {
		playAnim("walk");
		var w = Scene.WIDTH * 0.5 ;
		var m = ray+10 ;
		wp = {
			x : w - intSide * (20 + Math.random() * (w - 80)),
			y : Num.mm( ray, y + (Math.random() * 2 - 1) * 20, Scene.getPYSize()-2*ray ),
			to : 150.0,
		}
	}
	
	public function stopWalk() {
		if(  skin._p0._p1._anim._sub != null )
			skin._p0._p1._anim._sub.onEnterFrame = null;
		playAnim(defaultAnim);
		wp = null;
		vx = 0;
		vy = 0;
	}

	// BLOQUE UN DINOZ POUR UNE ACTION
	// RENVOIE FALSE SI LE DINOZ EST DEJA OCCUPE
	public function setFocus(state) {
		if( lockTimer != null || mode != Waiting || skinLoaded < 2 || flLand )
			return false;
		
		wp = null;
		if( focus == null ) {
			backToDefault();
			focus = state ;
			vx = 0 ;
			vy = 0 ;
			if( !Math.isNaN(force) )
				force *= 1000;
			return true;
		} else {
			return focus == state;
		}
	}
	
	public function unfocus() {
		focus = null;
		if( !Math.isNaN(force) )
			force /= 1000;
	}

	// MOVE
	public function moveTo(ex:Float,ey:Float,?mt) {
		if( (ex-x)*intSide < 0 )setSens(-1);

		tweenMove = new MyTween(x,y,ex,ey);
		tweenMove.sp = this;
		moveType = mt;

		switch(moveType){
			case 0:		playAnim("jump") ; fxJump();		// STANDARD JUMP
			case 1:		playAnim("jump") ; fxJump();		// JUMP ABOVE
			case 2:		playAnim("jumpDown") ; fxJump();	// JUMP START
			default:	playAnim("run") ;			// RUN
		}

	}
	public function updateMove(c:Float) {
		tweenMove.update(c);
		switch(moveType){
			case 0 : // JUMP
				z = -Math.sin(c*3.14) * 120 ;
				if(c==1)fxLand(12);

			case 1 :// JUMP ABOVE !
				z = -Math.sin(c*1.57) * 160 ;

			case 2 :// JUMP FROM ABOVE !
				z = -Math.sin(1.57 + c*1.57) * 160 ;
				if(c==1)fxLand(12);
			default:
				Scene.me.genGroundPart(x+(Math.random()*2-1)*ray,y+(Math.random()*2-1)*ray*0.5);
		}
	}
	
	public function backToDefault() {
		setSens(1);
		if( currentAnim != "land" ) playAnim(defaultAnim);
	}
	
	public function initReturn(?bh) {
		var p = lastCoords;
		lastCoords = null;
		var rec = 40;
		if( Math.abs(Scene.WIDTH*0.5-p.x) > ray+rec+20 ) {
			p.x += rec*intSide;
		}
		var c = 0.25;
		p.y = p.y*(1-c) + y*c;
		moveTo( p.x, p.y, bh );
		setSens(-1);
		return runSpeed/getDist(p);
	}

	// ANIM
	public function launchAnim(a) {
		playAnim(a);
		mode = Anim;

	}
	public function playAnim(a : String, ?walkAgain : Bool) {
		if(flFly) {
			if(a == "run" || a == "walk") {
				return;
			}
		}
		currentAnim = a ;
		skin._p0._p1._anim.gotoAndStop(a) ;
		applySkin() ;
	}

	// DODGE
	public function dodge(a : Fighter) {
		playAnim("dodge") ;
		var angle = getAng({x : a.x, y : a.y})+0.75*(Std.random(2)*2-1) ;
		var sp = 7 ;
		vz = -15 ;
		vx = Math.cos(angle) * sp ;
		vy = Math.sin(angle) * sp ;
		weight = 1.5 ;
		mode = Dodge;
	}
	
	function updateDodge() {
		if( z==0 ) {
			weight = null ;
			vx = 0 ;
			vy = 0 ;
			vz = 0 ;
			backToDefault();
			mode = Waiting ;
		}
	}

	// HIT
	public function hit(a : Fighter, d : Int, ?fxt:_LifeEffect ) {
		if(d==0) {
			playAnim("guard") ;
			return;
		}
		//if static
		var move = !haveProp(_PStatic);
		
		if( move ) {
			var angle = getAng({x : a.x, y : a.y}) ;
			var sp = 3;
			vx = Math.cos(angle) * sp ;
			vy = Math.sin(angle) * sp ;
		}
		damages(d,6,fxt);
	}

	public function damages(d : Int, ?stun, ?fxt:_LifeEffect ) {
		if(stun == null) stun = 50;
		playAnim("hit") ;
		life -= d ;
		if(life < 0) life = 0;
		slot.setLife( life/lifeMax );
		slot.fxDamage();

		showDamages(d) ;
		lockTimer = stun;
		shake = 30;

		if( fxt != null) lifeEffect(fxt);
	}
	
	public function gainLife(n,?fxt:_LifeEffect ) {
		this.life += n ;
		slot.setLife( life/lifeMax );
		showDamages(n,0);
		lockTimer = 20;
		lockTimer = 5;
		if(fxt!=null)lifeEffect(fxt);
	}

	public function showDamages(d,?type) {
		if( d <= 0)
			return ;
		var mc = Scene.me.dm.attach("points",Scene.DP_INTER) ;
		var py = Scene.getY(y) + (z-height)*0.5;
		var p = new sp.Score(mc,x,py,d,type);
	}

	// WAIT
	public function setWaiting(?stay : Bool) {
		mode = Waiting ;
		playAnim(defaultAnim) ;
	}

	// RECALE
	function checkBounds() {
		if(  haveProp( _PStatic ) ) return;
		var m = 4 ;
		var wmod = 10 ;
		if( x < m+ray || x > Scene.WIDTH - (ray + m + Main.DATA._mright )) {
			var dx = Phys.mm(m + ray + wmod, x , Scene.WIDTH - (m + ray + wmod)) - x ;
			x += dx * 0.3 * mt.Timer.tmod ;
			vx = 0 ;
		}
		var up = ray * 0.5;
		var down = Scene.getPYSize()-ray;
		if( y < up || y > down ) {
			y = Num.mm(up,y,down);
			vy = 0 ;
		}
	}
	
	public function saveCurrentCoords() {
		if(lastCoords != null) return;
		lastCoords = {x : x, y : y} ;
	}

	// STATUS
	public function addStatus(s) {
		status.push(s) ;
		displayStatus();
	}
	
	public function removeStatus(?s : _Status) {
		//status.remove(s);
		for( s2 in status ) {
			if( Type.enumEq(s,s2) || s == null ) {
				switch (s2) {
					case _SFly :
						flLand = true;
					case _SPoison(n) :
						colt.colorTransform = new flash.geom.ColorTransform(1,1,1,1,0,0,0,0);
					default:
				}
				status.remove(s2);
			}
		}
		displayStatus();
	}
	
	public function haveStatus(s:_Status) {
		for( s2 in status ) {
			if( Type.enumEq(s,s2) ) return true;
		}
		return false;
	}
	
	function displayStatus() {
		defaultAnim = "stand";
		root._alpha = 100;
		root.filters = [];
		walkSpeed = 1.8;
		runSpeed = 8;
		flFreeze = haveProp(_PStatic);
		flFly = false ;
		//z = 0;
		decal = 0;
		if( !Math.isNaN(force) )
			force = 10;
		bdm.clear(5);

		var list = [];
		for( s in status ) {
			switch (s) {
				case _SSleep :
					defaultAnim ="sleep";
					playAnim("sleep");
					list.push(0);
					flFreeze = true ;
					
				case _SFlames :
				case _SBurn(pow):

				case _SIntang :
					root._alpha = 50;
					list.push(1);

				case _SFly :
					defaultAnim ="jump";
					playAnim("jump");
					flFly = true;
					setGroundFx(false);

				case _SSlow :
					list.push(2);
					walkSpeed *= 0.5;
					runSpeed *= 0.5;

				case _SQuick :
					list.push(3);
					walkSpeed *= 2 ;
					runSpeed *= 2 ;

				case _SStoned :
					list.push(4);
					flFreeze = true ;
					if( !Math.isNaN(force) )
						force = 100000;

				case _SBless :
					list.push(5);

				case _SPoison(pow) :
					list.push(6);

				case _SShield :		// ANIM
				case _SHeal(n) :	// ANIM
				
				case _SMonoElt(elt):
					list.push( 8 );
				case _SDazzled(pow):
					list.push( 9 );
				case _SStun:
					flFreeze = true ;
					if( !Math.isNaN(force) )
						force = 100000;
					list.push( 10 );
			}
		}

		var max = list.length;
		var size = 12;
		var ec = 2;
		var sx = -(max*(size+ec)-ec)*0.5;
		for( i in 0...list.length ) {
			var mc = bdm.attach("mcStatusIcon",5);
			mc.gotoAndStop(list[i]+1);
			mc._x = sx + i*(size+ec);
			mc._y = -40;
		}
	}
	
	function updateStatus() {
		if( flLand ) {
			z += 5;
			if(z > 0) {
				z = 0;
				flLand = false;
				setGroundFx(true);
			}
		}

		decal = (decal + 27*mt.Timer.tmod)%628;
		root.filters = [];
		for( s in status ) {
			switch (s) {
				case _SFlames :
					var sp = new mt.bumdum.Sprite( bdm.attach("fxFlameche",1) );
					sp.x = (Math.random()*2-1)*15;
					sp.y = -Math.random()*20;
					sp.updatePos();
				case _SBurn(_):
					var sp = new mt.bumdum.Sprite( bdm.attach("fxFlameche", 1) );
					Col.setColor( sp.root, Col.darken(0x0, 100) );
					sp.x = (Math.random()*2-1)*15;
					sp.y = -Math.random()*20;
					sp.updatePos();
					
				case _SFly :
					var tz  = Math.sin(decal*0.01)*15 - 60;
					var dz = tz - z;
					var lim = 3;
					z += Num.mm(-lim,dz,lim);

				case _SStoned:
					var fl = new flash.filters.ColorMatrixFilter();
					var r = 0.2;
					var g = 0.1;
					var b = 0.7;
					fl.matrix = [
						r,	g,	b,	0,	0,
						r,	g,	b,	0,	0,
						r,	g,	b,	0,	0,
						0,	0,	0,	1,	0,
					];
					var a = root.filters;
					a.push(fl);
					root.filters = a;

				case _SShield :
					var col = Col.getRainbow( decal/628 );
					var c = Col.mergeCol( Col.objToCol(col), 0xFFFF00, 0.2 );
					Filt.glow(root,4,4, c );

				case _SBless :
					var c = Math.sin(decal*0.01);
					Filt.glow(root,2,4,0xFFFFFF);
					Filt.glow(root,2+8*c,2+2*c,0xFFFFFF);

				case _SPoison(pow) :
					var c = (1+Math.cos(decal*0.01))*0.5;
					colt = new flash.geom.Transform(skin);
					colt.colorTransform = new flash.geom.ColorTransform(1,1,1,1,0,c*150,0,0);

				case _SHeal(n) :	// ANIM
					var p = new mt.bumdum.Phys( bdm.attach("fxLight",1) );
					p.x = (Math.random()*2-1)*17;
					p.y = (5-Math.random()*15) * 2;
					p.vy = -Math.random()*3;
					p.timer = 10+Math.random()*10;
					p.root.blendMode = "add";
					Col.setPercentColor( p.root, 100, Col.objToCol( Col.getRainbow(Math.random()) ) );

				case _SStun:
					var fl = new flash.filters.ColorMatrixFilter();
					var r = 0.7;
					var g = 0.7;
					var b = 0.7;
					fl.matrix = [
						r,	g,	b,	0,	0,
						r,	g,	b,	0,	0,
						r,	g,	b,	0,	0,
						0,	0,	0,	1,	0,
					];
					var a = root.filters;
					a.push(fl);
					root.filters = a;
					
				default:
			}
		}
	}

	function setGroundFx(fl) {
		mcOndeFront._visible = fl;
		mcOndeBack._visible = fl;
	}

	// FX
	public function updateShake() {
		shake *= -0.6;
		root._x += shake ;
		root.filters = [];

		if(Math.abs(shake)<1) {
			shake = null;
		} else {
			Filt.blur(root,shake,0);
		}
	}
	
	public function updateFx() {
		updateShake();
		if(dripTimer!=null) {
			dripTimer-=mt.Timer.tmod;
			fxDrip();
			if(dripTimer<0)dripTimer= null;
		}
	}

	public function fxBurn( max, ?sleep ) {
		if(sleep==null)sleep = 10;
		for( i in 0...max ) {
			var p = new mt.bumdum.Phys( bdm.attach("fxFlameche",Fighter.DP_FRONT) );
			p.x = (Math.random()*2-1)*ray;
			p.y = -Math.random()*height;
			p.vx = -Math.random()*2*intSide;
			p.sleep = Math.random()*sleep;
			p.root.stop();
			p.updatePos();
			p.root._visible = false;
			p.root._rotation = -intSide*30;
		}
	}
	
	public function fxBurst(link, max) {
		var cr = 3;
		for( i in 0...max) {
			var p = new Part( Scene.me.dm.attach(link, Scene.DP_FIGHTER) );
			var a = i/max *6.28;
			var speed = 0.5+Math.random()*3;
			var ca =  Math.cos(a)*speed;
			var sa =   Math.sin(a)*speed;
			p.x = x+ca*cr;
			p.y = y+sa*cr;
			p.vx = ca;
			p.vy = sa;
			p.vz = -Math.random()*8;
			p.friction = 0.98;

			p.root.gotoAndPlay(Std.random(10)+1);

			p.timer = 50+Math.random()*10;
			p.weight = 0.2+Math.random()*0.2;
		}
	}
	
	public function fxLeaf(max,?dvx,?dvy,?dvz) {
		for( i in 0...max ) {

			var d = Fighter.DP_FRONT;
			if( Std.random(2)==0 ) d = Fighter.DP_BACK;
			var p = new part.Faller( Scene.me.dm.attach("partAuraSnow",Scene.DP_FIGHTER) );
			p.x = x+(Math.random()*2-1)*ray;
			p.y = y+(Math.random()*2-1)*ray*0.5;
			p.z = z-Math.random()*height*2;

			p.root._rotation = Math.random()*360;
			p.setScale( 100-Math.random()*30 );
			p.vx = -intSide*Math.random()*3;
			p.vy = (Math.random()*2-1)*1.5;

			if( dvx!= null )p.vx = dvx;
			if( dvy!= null )p.vy = dvy;
			if( dvz!= null )p.vy = dvz;//BUG ?

			p.weight = 0.1+Math.random()*0.15;
			p.timer = 10+Math.random()*30;
			p.root.gotoAndStop(2);
			p.root.smc.gotoAndPlay(Std.random(10)+1);
			Filt.glow( p.root, 2, 4, 0x227700 );
			Filt.glow( p.root, 2, 4, 0x227700 );
			p.fadeLimit = 5;

			p.updatePos();
		}
	}
	
	public function fxLightning(max) {
		for( i in 0...max ) {
			var p = new mt.bumdum.Phys( bdm.attach("mcBolt",Fighter.DP_FRONT) );
			p.x = (Math.random()*2-1)*ray;
			p.y = -Math.random()*height;
			p.root._rotation = Math.random()*360;
			p.root.blendMode = "add";
			Filt.glow(p.root,10,2,0xFFFF00);
			p.setScale( 100+Math.random()*100 );
			p.sleep = Math.random()*20;
			p.root.stop();
			p.root._visible = false;
			p.updatePos();
		}
	}
	
	public function fxAir(max) {
		for( i in 0...max ) {
			var p = new mt.bumdum.Phys( bdm.attach("partWind",Fighter.DP_FRONT) );
			p.x  = Math.random()*(ray+24)*intSide;
			p.y = -Math.random()*height;
			p.vx = -(2+Math.random()*3)*intSide;

			p.timer = 10+Math.random()*10;

			p.vr = (Math.random()*2-1)*15;
			p.root.smc._x = Math.random()*20;
			p.root._rotation = Math.random()*360;

			p.sleep = Math.random()*20;
			p.root.stop();
			p.root._visible = false;
			p.updatePos();

			Filt.glow(p.root,10,1,0xFFFFFF);
		}
	}
	
	public function fxWater(max) {
		for ( i in 0...Std.int(max * 0.5) )
			fxDrip();
		dripTimer = Std.int(max*0.5);
	}
	
	public function fxDrip() {
		var p = new part.Faller( Scene.me.dm.attach("partDrip",Scene.DP_FIGHTER) );
		p.x = x+(Math.random()*2-1)*ray;
		p.y = y+(Math.random()*2-1)*ray*0.5;
		p.z = z-Math.random()*height*2;
		p.weight = 0.2+Math.random()*0.2;
		p.flBurst = true;
		Filt.glow( p.root, 8, 1, 0x00AAFF );
		p.updatePos();
	}
	
	public function fxMudWall() {
		mcMudWall = bdm.attach( "mcMudwall", DP_FRONT );
		mcMudWall._xscale = (side?1:-1) * (ray*4 + 30);
		mcMudWall._yscale = mcMudWall._xscale;
		mcMudWall._y = -.5*height;
		//skin._p0._p1._anim._sub.stop();
	}
	
	public function fxRemoveMudWall() {
		if( mcMudWall == null ) return;
		KTween.tween( mcMudWall, TBurnOut ).to( 1, _xscale = 0, _yscale = 0, _alpha = 0 ).onComplete(function(t) mcMudWall.removeMovieClip() );
	}
	
	public function fxAddIceBlock() {
		mcIceBlockBack = bdm.attach( "mcIceBlock", DP_BACK );
		mcIceBlockBack._xscale = ray*2 + 30;
		mcIceBlockBack._yscale = height + 30;
		mcIceBlockBack.gotoAndStop(1);
		mcIceBlockFront = bdm.attach( "mcIceBlock", DP_FRONT );
		mcIceBlockFront._xscale = mcIceBlockBack._xscale;
		mcIceBlockFront._yscale = mcIceBlockBack._yscale;
		mcIceBlockFront.gotoAndStop(2);
		Col.setPercentColor( skin, 100, 0x5FBEFE );
		skin._p0._p1._anim._sub.stop();
	}
	
	public function fxRemoveIceBlock(max) {
		mcIceBlockFront.removeMovieClip();
		mcIceBlockBack.removeMovieClip();
		Col.setPercentColor( skin, 0, 0x5FBEFE );
		for( i in 0...max ) {
			var p = new Part( Scene.me.dm.attach("partIce",Scene.DP_FIGHTER) );
			p.x = x + (Math.random()*2-1)*ray;
			p.y = y + (Math.random()*2-1)*ray*0.5;
			p.z = -Math.random()*(height+20);
			p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
			p.weight = 0.2+Math.random()*0.4;
			p.ray = 5;
			p.dropShadow();
			p.updatePos();
			p.fadeType = 0;
			p.timer = 10+Math.random()*80;
			p.root._rotation = Math.random()*360;
			p.vr = (Math.random()*2-1)*15;
			p.friction = 0.96;

			var dx = p.x - x;
			var dy = p.y - y;
			var dz = p.z - z;
			var c = 0.2;
			p.vx = dx*c;
			p.vy = dy*c*0.5;
			p.vz = dz*c*1.5;
		}
	}
	
	public function lifeEffect(fxt) {
		switch(fxt) {
			case _LBurn(max):
				fxBurn(max);

			case _LExplode:
				var max = 6;
				for( i in 0...max ) {
					var p = new mt.bumdum.Phys( bdm.attach("mcExploPart",Fighter.DP_FRONT) );
					p.x = (Math.random()*2-1)*ray;
					p.y = -Math.random()*height;
					p.root._xscale = p.root._yscale = 50+Math.random()*50;
					p.sleep = Math.random()*12;
					p.root._visible = false;
					p.updatePos();
					p.root.stop();

				}
			case _LHeal:
				var max = 32;
				for( i in 0...max ) {
					var p = new mt.bumdum.Phys( bdm.attach("partLightHeal",Fighter.DP_FRONT) );
					p.x = (Math.random()*2-1)*ray;
					p.y = -Math.random()*height;
					p.root._xscale = p.root._yscale = 50+Math.random()*100;
					p.sleep = Math.random()*20;
					p.root._visible = false;
					p.weight = -(0.02+Math.random()*0.1);
					p.timer = 10+Math.random()*20;
					p.updatePos();
					p.root.stop();
					p.root.blendMode = "add";
				}

			case _LSkull(size):
				var mc = bdm.attach("mcSkull",DP_FRONT);
				mc._y = -height*0.5;
				mc._xscale = mc._yscale = size*100;
				mc.blendMode = "add";

			case _LAcid:
				var max = 12;
				for( i in 0...max ) {
					var p = new sp.Acid( bdm.attach("partAcid",Fighter.DP_FRONT) );
					p.x = (Math.random()*2-1)*ray;
					p.y = -(height+5+Math.random()*16);
					p.ty = -((Math.random()*0.5+0.5)*height);
					p.weight = 0.2+Math.random()*0.2;
				}

			case _LFire:		fxBurn(14,20);
			case _LWood:		fxLeaf(10);
			case _LWater:		fxWater(20);
			case _LLightning:	fxLightning(16);
			case _LAir:		fxAir(14);

			default:
		}
	}
	
	public function fxJump() {
		mcOndeFront._visible = false;
		mcOndeBack._visible = false;
	}
	
	public function fxLand(max,?speed,?cr) {
		playAnim("land");
		mode = Anim;
		if(cr == null) cr = 8;
		if(speed == null) speed = 3;

		mcOndeFront._visible = true;
		mcOndeBack._visible = true;
		for( i in 0...max ) {
			var a = (i+Math.random())/max *6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var coef = Math.random();
			var sp = 0.5+Math.random()*speed;
			Scene.me.genGroundPart( x+ca*sp*cr, y+sa*sp*cr, ca*sp, sa*sp, null, true );
		}
	}

	public function fxAttach(link,dx=0,dy=0) {
		var sp = new Phys( Scene.me.dm.attach(link,Scene.DP_FIGHTER) );
		sp.x = x - dx*sens*intSide;
		sp.y = y + dy;
		sp.root._xscale = -sens*intSide*100;
		sp.updatePos();
	}
	
	public function fxAttachInside(link,x=0,y=0,flBack=false) {
		var dp = DP_FRONT;
		if( flBack )dp = DP_BACK;
		var mc = bdm.attach(link,dp);
		mc._x = x;
		mc._y = y;
		return mc;
	}
	
	public function fxAttachScene(link,dx=0,dy=0,dp=5) {
		var mc = Scene.me.dm.attach(link,dp);
		mc._x = root._x - dx*sens*intSide;
		mc._y = root._y + dy;
		mc._xscale = -sens*intSide*100;
		return mc;
	}


	// SKIN
	public function setSkin() {
		skin = cast sbdm.empty(1);
		var mcLoader = new flash.MovieClipLoader() ;
		var me = this;
		var f = function(mc) {
			if(++me.skinLoaded==2)me.initSkin();
		}
		mcLoader.onLoadInit = f ;
		mcLoader.onLoadComplete = f ;
		var urlSkin = isDino?Main.DATA._sdino:Main.DATA._smonster;
		mcLoader.loadClip(urlSkin, skin) ;
		skinLoaded = 0;

		skin._x = intSide* 20 ;
		skin._y = -31 ;
		skin._xscale = -intSide * 100 ;
		skin._yscale = 100 ;

		friction = 0.9 ;
	}
	
	public function applySkin() {
		if( isDino) {
			skin._init(gfx, 0, true) ;
		}
		skin._p0._s._visible = false ;
		//
		if(haveProp(_PDark)) skinDark();
	}

	public function skinDark() {
		var m = new mt.flash.ColorMatrix();
		m.adjustBrightness(-0.57);
		m.adjustContrast(0.17);
		m.adjustSaturation(-0.83);

		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = m.matrix;

		var a:Array<flash.MovieClip> = [ cast skin._p0, cast slot.root.skin ];
		for( mc in a  )	mc.filters = [fl];

	}

	// RESURECT
	public function resurect() {
		if( mode != Dead ) return;
		mode = Waiting;
		backToDefault();
	}

	function initSkin() {
		var data = if( Main.me.dinoData != null) Main.me.dinoData else gfx ;
		gfx = data ;
		//body.onPress = traceInfo ;
		//body.onRollOver = showLife ;
		//body.onRollOut = hideLife ;
		// NE FONCTIONNE PAS ?
		if( isDino ) {
			skin._p0.stop();
			skin._p0._p1.gotoAndStop(1);
			skin._init(data, 0, true);
		} else {
			skin._p0.stop() ;
			skin._p0.gotoAndStop(gfx) ;
		}
		skin._visible = false;
		registerBox();
		playAnim(currentAnim);
	}
	
	function registerBox() {
		var box:flash.MovieClip = (cast skin._p0)._box;
		box._visible = false;

		skinBox._xscale = size*100;
		skinBox._yscale = size*100;

		ray = box._width*0.5*size;
		height = box._height;
		shadeType = box._alpha == 100 ? 0 : 1;

		dropShadow() ;

		// BIND FX FUNC
		Reflect.setField( skin,"_fxAttach",fxAttach );
		Reflect.setField( skin,"_fxAttachInside",fxAttachInside );
		Reflect.setField( skin,"_fxAttachScene",fxAttachScene );


		switch(Scene.me.groundType) {
			case "water":
				var h = -5;
				mcOndeFront = bdm.attach("mcWaterOnde",DP_FRONT);
				mcOndeFront._xscale = ray*2;
				mcOndeFront._yscale = ray;
				mcOndeFront._y = h;
				mcOndeBack = bdm.attach("mcWaterOnde",DP_BACK);
				mcOndeBack._xscale = mcOndeFront._xscale;
				mcOndeBack._yscale = -mcOndeFront._yscale;
				mcOndeBack._y = h;

			default:

		}
		fxJump();
	}
	
	public function bind(f, str) {
		Reflect.setField( skin, str, f );
	}

	// TOOLS
	public function flip() {
		backToDefault();
		side = !side ;
		intSide = if( side) 1 else -1 ;
		skin._xscale *= -1;
		skin._x = intSide * 20 ;
	}

	public var sens:Int;
	public function setSens(sens:Int) {
		this.sens = sens;
		body._xscale = sens * 100;
	}
	
	public function getBrawlPos( f:Fighter, ?sens:Int ) {
		if(sens==null)sens = 1;
		var x = f.x + (range + ray + ray) * f.intSide * sens;
		var y = f.y+2;		// WTF -0.1 +0.1

		return {x:x, y:y};
	}
	
	public function showName() {
		var p = new mt.bumdum.Phys(Scene.me.dm.attach( "partTitle", Scene.DP_INTER ));
		p.x = x;
		p.y = Scene.getY(y) - height;
		p.vy = -3;
		p.timer = 40;
		p.frict = 0.8;
		var field:flash.TextField = cast(p.root).field;
		field.text = name.toUpperCase();
	}

	public function haveProp(pr) {
		for(p in props) if( pr == p ) return true;
		return false;
	}

	// INTERFACE
	/*
	public function showLife() {
		if( lifeBar != null || mode == Dead)
			return ;
		lifeBar = cast dm.attach("mcLifeBar",1) ;

		//### TODO : adapter une fois le bon mc chargé
		lifeBar._y = -35 ;
		lifeBar._x = -15 ;
		updateLifeBar() ;
		mcName = lifeBar.createTextField("mc_" + this.name, 2, -3, -20, 80, 20) ;

		var format = new flash.TextFormat() ;
		format.font = "Trebuchet MS";
		format.bold = true ;
		format.color = 0xFFFFFF  ;
		format.size = 12;

		mcName.setNewTextFormat(format) ;
		mcName.selectable = false ;
		mcName.text = name ;
	}
	function updateLifeBar() {
		lifeBar.fg._xscale = 100 * life / 100 ;
	}
	public function hideLife() {
		if( lifeBar == null)
			return ;
		lifeBar.removeMovieClip() ;
		lifeBar = null ;
	}
	*/

	// KILL
	public override function kill() {
		Main.me.fighters.remove(this) ;
		super.kill();
	}

	// DEBUG
	public function traceInfo() {
		trace(fid + "# " + name +  " (" + life + ") " + " :: " + Std.int(x) + ", " + Std.int(y)  + ", " + Std.int(z) + " ") ;
	}


	public function tr(str) {
		if(fid==2)trace(str);
	}

}