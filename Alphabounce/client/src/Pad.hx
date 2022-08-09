import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;
import mt.bumdum.Part;

class Pad extends PadSkin{//}

	static var X_KEY = "X".charCodeAt(0);
	
	public static var SIDE = 12;
	public static var SPEED = 10;
	public static var HEIGHT = 10;
	static var DY = 1;

	public var drones:Array<ev.Drone>;

	public var flIce:Bool;
	public var flTransform:Bool;
	public var flAutoMissile:Bool;
	public var flGuardian:Bool;

	public var ty:Float;
	public var moveFactor:Float;
	public var freeze:Int;
	public var insect:Int;
	public var opx:Int;
	public var glueCount:Int;

	/*
	public var missileType:Int;
	public var missileCadence:Float;
	public var missileTurnSpeed:Float;
	*/
	public var missileCoef:Float;
	public var missileCooldown:Float;

	public var flStop:Bool;
	public var flAttract:Bool;
	public var flMouse:Bool;
	public var padec:Float;
	public var tpadec:Float;
	public var flh:Float;

	public var power:Float;
	public var recovery:Float;
	public var chargeTimer:Float;

	var selectedBlocks:Array<Block>;
	var trg:Block;


	var mcCharge:flash.MovieClip;


	public function new(mc){
		super(mc);
		skin = cast root;


		ty = Cs.getY(Cs.YMAX+DY);
		x = Cs.mcw*0.5;
		y = ty+50;
		freeze = 0;
		glueCount = 0;

		insect = 0;

		flMouse = false;
		drones = [];
		flGuardian = false;

		//
		var max = 1;
		if(Cs.pi.gotItem(MissionInfo.BALL_DOUBLE))max++;
		for(i in 0...max )initStartBall();
		Game.me.flFirstBall = true;



	}
	public function initStartBall(){

		var b = Game.me.newBall();
		var rnd = (Math.random()*2-1)*0.5;
		if(Game.PLAY_AUTO)rnd = 0.5;
		b.gluePoint = rnd*20;
		b.moveTo(x,y);
		b.vx=0;
		b.vy=1;
		b.update();
		b.colPad(rnd);
		b.flReady = false;
		return b;
	}

	public function init(){
		flStop = false;
		power = null;
		moveFactor = 0.5;
		if(skinId==1)moveFactor = 1;
		if( Game.me.level.zid == ZoneInfo.SPIGNYSOS ){
			moveFactor *= 0.1;
			flIce = true;
		}


		setRay( Cs.pi.getRay() ); // 36
		setType(Cs.PAD_STANDARD);
	}

	override public function update(){

		moveHeight();
		if( !checkMissiles() && !flGuardian )updatePlay();
		//
		updateFlash();
		if(chargeTimer!=null)updateCharge();

		//
		super.update();

	}
	function updatePlay(){

		// MOVE
		move();

		// SALVE
		if(Game.me.flPress)salve();

		// TYPE
		switch(type){
			case Cs.PAD_SHAKE:
				x += (Math.random()*2-1)*14;
				queue("mcPinkBar",15);

		}

		// POWER
		if(power!=null)updatePower();
	}

	function move(){

		if(freeze>0){
			x += (Math.random()*2-1)*2;
			return;
		}

		var dx = null;

		// CONTROL
		if( Game.PLAY_AUTO ){
			if(padec==null){
				newPadec();
				padec = tpadec;
			}
			padec += (tpadec-padec)*0.1;

			var b = Game.me.getLowestBall();
			dx = (b.x+padec*ray)-x;
			if( !(b.x>0) )dx = 0;

			// MAXIMISATION
			var dist = Math.min(Math.abs(dx),40);
			var sens = Math.abs(dx)/dx;
			if(dx==0)sens = 1;
			dx = sens*dist;

		}else{

			if(Cs.PREF_BOOLS[0]){

				dx = 0;
				var speed =  20;
				if( mt.flash.Key.isDown(37) ) dx = -speed;
				if( mt.flash.Key.isDown(39) ) dx = speed;
				if( mt.flash.Key.isDown(16) ) dx *= 2;	// SHIFT
				// fullspeed is not cool with keyboard
				if (moveFactor == 1) dx *= 0.9;
				
				if( Game.me.flPress ){
					if( !mt.flash.Key.isDown(17) )Game.me.mouseUp();
				}else{
					if( mt.flash.Key.isDown(17) )Game.me.mouseDown();
				}



			}else{
				dx = getPadX() - x;
			}


		}

		x += dx*moveFactor;
		x += (Math.random()*2-1)*insect*4;


		if(flIce || glueCount > 0 ){
			var max = Std.int(Math.min( Math.abs(dx*0.02),5 ) );
			for( i in 0...max ){
				var link = "partIce";
				var sc = 100.0;
				if( glueCount>0 ){
					link = "mcGlue";
					sc = 10+Math.random()*20;
				}
				var p = new Phys(Game.me.dm.attach(link,Game.DP_PARTS));
				p.x = x + (Math.random()*2-1)*ray;
				p.y = y + Math.random()*10;
				p.vr = (Math.random()*2-1)*10;
				p.root._rotation = Math.random()*360;
				p.fadeType = 0;
				p.timer = 10+Math.random()*10;
				p.weight = 0.1+Math.random()*0.1;
				p.vx = dx*Math.random()*0.02;
				p.vy = -Math.random()*Math.abs(dx)*0.02;
				p.setScale(sc);
			}

		}


	}
	function moveHeight(){
		// TY
		if( ty !=null ){
			var dy = ty-y;
			y += dy*0.2*mt.Timer.tmod;
			/*
			if(Math.abs(dy)<1){
				y = ty;
				ty = null;
			}
			*/
		}


	}
	public function newPadec(){
		tpadec = (Math.random()*2-1)*0.5;
	}

	//
	function initPower(){
		power = 1;
		displayPowerBar();
		skin.mid.bar._alpha = 100;
	}
	function updatePower(){
		if(power<1){
			power = Math.min(power+recovery*mt.Timer.tmod,1);
			displayPowerBar();
			if(power==1)skin.mid.bar._alpha = 100;
		}
	}
	function displayPowerBar(){
		skin.mid.bar._xscale = 100*power;

	}
	//
	// ACTION
	public function action(){

		if(chargeTimer!=null)launchCharge();

		switch( type ){
			case Cs.PAD_TIME :
				if(power>0.2)flTransform=true;
			case Cs.PAD_LASER :
				var cost = 0.2;
				if(power>cost){
					power-=cost;
					for( i in 0...2 ){
						var shot = new el.shot.Laser( Game.me.dm.attach("mcLaser",Game.DP_PARTS) );
						shot.moveTo( x+(i*2-1)*(ray-9), y);
						shot.setVit(18);
						shot.updatePos();
					}
				}
			case Cs.PAD_GENERATOR :
				if( power == 1 ){
					skin.mid.bar._alpha = 60;
					power = 0;
					var b = initStartBall();
					//b.fxLight();
					Game.me.flPress = false;
					setFlash();
				}


		}


	}
	public function release(){
		switch( type ){
			case Cs.PAD_TIME :
				trg = null;
				flTransform = false;

		}
	}
	public function salve(){
		if( y < Cs.mch )for( b in Game.me.balls )b.unglue();
		switch( type ){
			case Cs.PAD_AIMANT :
				var dec = 0.04;
				if(power>dec*2){
					power = Math.max(power-dec,0);
					for( b in Game.me.balls ){
						if(  b.type!=Cs.BALL_KAMIKAZE && b.type!=Cs.BALL_SHADE && b.y<y ){
							var a = Math.atan2(b.vy,b.vx);
							if(b.pdec==null)b.pdec = (Math.random()*2-1)*0.5;
							var dx = x+b.pdec*ray - b.x;
							var dy = y - b.y;
							var ta = Math.atan2(dy,dx);
							var dist = Math.sqrt(dx*dx+dy*dy);
							var cca = Num.mm(0.25,(b.speed/5)*0.25,0.5);
							a +=  Num.hMod(ta-a,3.14)*cca;
							b.vx = Math.cos(a)*b.speed;
							b.vy = Math.sin(a)*b.speed;
							if( dist<250 && Math.random()*dist<30 ){
								var p = new fx.Attract(Game.me.dm.attach("partLine",Game.DP_PARTS));
								var ec = 12;
								p.x = b.x+(Math.random()*2-1)*ec;
								p.y = b.y+(Math.random()*2-1)*ec;
								p.dx = (Math.random()*2-1)*ray;
								Filt.glow(p.root,8,2,0xFFFFFF);
							}
						}
					}
				}



			case Cs.PAD_TIME :

				if( flTransform && power > 0){

					if(trg==null){
						trg = findTransformTrg();
					}


					if( trg!=null ){


						//
						power = Math.max(power-0.04,0);
						trg.incTransform(0.035,0);
						trg.fxFrout(2);

						// FX
						var mc = Game.me.dm.empty(0);
						var dm =  new mt.DepthManager(mc);
						var mmc = dm.empty(0);
						var dm2 =  new mt.DepthManager(mmc);
						mmc.lineStyle(1,0xFFFFFF,100);
						for( i in 0...2 ){
							var sens = i*2-1;
							var m = 0.15;
							var bx =  Cs.getX(trg.x+m+(Math.random()*(1-2*m)));
							var by =  Cs.getY(trg.y+m+(Math.random()*(1-2*m)));
							mmc.moveTo( x+(ray-4)*sens, y );
							mmc.lineTo( bx, by );

							var mmmc = dm2.attach("mcTransformerImpact",0);
							mmmc._x = bx;
							mmmc._y = by;


						}
						Filt.glow( mmc,10,2,0xFF8800);
						//mc.blendMode = "screen";
						Game.me.plasmaDraw(mc);
						mc.removeMovieClip();


						//
						if( trg.type == 0 ||trg.flDeath )trg = null;
						displayPowerBar();
						if(power==0)release();
					}





				}
				/*
				if(flStop){
					power = Math.max(power-0.03,0);
					displayPowerBar();
					if(power==0)release();
				}
				*/



		}
	}
	function findTransformTrg(){
		for( n in 0...3 ){
			for( k in 0...2 ){
				var sens = k*2-1;
				var px = Cs.getPX(x)+sens*n;
				for( i in 0...Cs.YMAX ){
					var py = Cs.YMAX-(i+1);
					var bl = Game.me.grid[px][py];
					if( bl!= null && bl.type!=0 ){
						return bl;
					}
				}
			}
		}
		return null;

	}

	// TYPE
	override public function setType(n:Int){

		//
		switch(type){
			case Cs.PAD_GLUE:
				for( b in Game.me.balls )b.unglue();

			case Cs.PAD_TIME:
				//flStop = false;

			case Cs.PAD_AIMANT:
				flAttract = false;

			case Cs.PAD_GENERATOR:

		}

		super.setType(n);

		//
		switch(type){
			case Cs.PAD_GLUE:
			case Cs.PAD_TIME :
				recovery = 0.01;
				initPower();
			case Cs.PAD_LASER :
				recovery = 0.007;
				initPower();
			case Cs.PAD_SHAKE :
			case Cs.PAD_GENERATOR:
				recovery = 0.005;
				initPower();
			case Cs.PAD_AIMANT:
				recovery = 0.005;
				initPower();

		}


	}


	// BOUNCE BALL
	public function bounceBall(ball:el.Ball){
		checkDrone(ball.x,ball.y);
		y += Math.min(ball.speed*0.5,10);
		updatePos();
		onBounce();
	}
	public function onBounce(){

	}

	// CHARGE
	public function initCharge(){
		chargeTimer = 0;
		if(mcCharge==null){
			mcCharge = new mt.DepthManager(root).attach("fxFlurch",2);
			mcCharge._x = 0;
			mcCharge._xscale = ray*2;
			mcCharge._yscale = 0;
		}
	}
	function updateCharge(){
		chargeTimer+=mt.Timer.tmod;

		flh = Math.min((chargeTimer/40),1);
		mcCharge._yscale = chargeTimer*0.5;
		var ma = 30;
		for( i in 0...2 ){
			var p = new fx.Attract(Game.me.dm.attach("partLine",Game.DP_PARTS));
			var ec = 12;
			var cx = (Math.random()*2-1);
			var cy = Math.random();
			if(i==1)cx *= 0.25;


			p.x = x+cx*(ray+ma);
			p.y = y+cy*(10+2*ma)-ma;
			p.dx = cx*ray;
			p.dy = cy*10;
			Filt.glow(p.root,8,2,0xFFFFFF);

			if(i==1){
				p.y -= (1-cx*4)*chargeTimer;
			};

		}

		if(chargeTimer>120)launchCharge();


		// SURLIGNE
		var px = Cs.getPX(x);
		if( px != opx )unSelectBlocks();
		for( py in 0...Cs.YMAX ){
			var bl = Game.me.grid[px][py];
			Col.setColor(bl.root,0,50);
			selectedBlocks.push(bl);
		}



		opx = px;


	}
	function launchCharge(){
		unSelectBlocks();
		new ev.Javelot();
		chargeTimer = null;
		mcCharge.removeMovieClip();
		mcCharge = null;

	}
	function unSelectBlocks(){
		while( selectedBlocks.length>0 )Col.setColor( selectedBlocks.pop().root ,0,0);
		selectedBlocks = [];
		opx = null;
	}

	// MISSILE
	function launchMissile(){

		flAutoMissile = false;

		fxExplosion(x-5,y-(ray+5));

		var shot = new el.shot.Missile(Game.me.dm.attach("mcMissile",Game.DP_PARTS));
		shot.moveTo(x-5,y-ray);
		shot.root._rotation = -90;
		shot.setType(Game.me.missileType);
		shot.updatePos();
		shot.vy = -5;

		y+=40;
		ty = Cs.getY(Cs.YMAX+DY);

		Game.me.incMissile(-1);




	}
	function checkMissiles(){

		var flTest = false;


		if( Game.PLAY_AUTO && Game.me.balls.length < 3 ){

			var flOk = false;
			var x =  Cs.getPX(x);
			for( i in 0...Game.me.level.ymax ){
				var y = Game.me.level.ymax-i;
				var bl = Game.me.grid[x][y];
				if( bl != null ){
					flOk = Block.isSoft(bl.type);
					break;
				}

			}
			if( flOk ){

				var lb = Game.me.getLowestBall();
				if( lb.y<Cs.mch-100 || lb.vy<0 ){
					if( flAutoMissile ){
						flTest = true;
					}else{
						flAutoMissile = Std.random(Std.int(200*Game.me.balls.length/Cs.pi.missile)) == 0;
					}
				}
			}
		}else{
			//flTest = flash.Key.isDown(flash.Key.SPACE);
			flTest = mt.flash.Key.isDown(flash.Key.SPACE) || mt.flash.Key.isDown(X_KEY);
		}

		if(  flTest &&  Game.me.missile.get() > 0 ){



				if(missileCoef==null)missileCoef=0;
				missileCoef = Math.min( missileCoef+Game.me.missileTurnSpeed*mt.Timer.tmod, 1);

		}else{
			if(missileCoef!=null){
				missileCoef = Math.max(0,missileCoef-Game.me.missileTurnSpeed*mt.Timer.tmod);
				if(missileCoef==0){
					root._rotation = 0;
					missileCoef=null;
					missileCooldown = null;
				}
			}
		}



		if(missileCoef!=null){
			for( b in Game.me.balls )b.unglue();
			root._rotation = 90*missileCoef;

			if(missileCoef==1){
				if( missileCooldown == null ){
					missileCooldown = 5;
					// CHECK GUARDIAN
					if(missileCoef>0.5){
						for( bl in Game.me.blocks ){
							if(bl.type==Block.GUARDIAN){
								bl.explode();
								flGuardian = true;
								break;
							}
						}
					}

				}
				missileCooldown -= mt.Timer.tmod;
				if(missileCooldown<=0){
					missileCooldown += Game.me.missileCadence;
					launchMissile();
				}
			}



			return true;

		}else{
			return false;
		}


	}

	// DRONE
	function checkDrone(sx,sy){

		if( drones.length < Cs.pi.drone && ev.Drone.getBlock()!=null ){
			var drone = new ev.Drone();
			drone.root._x = sx;
			drone.root._y = sy;
			drones.push(drone);
			drone.sparkTimer = 10;

			/*
			var mc = Game.me.dm.attach("mcOndeAnim",Game.DP_UNDERPARTS);
			mc._x = sx;
			mc._y = sy;
			mc._xscale = mc._yscale = 40;
			*/

		}



	}

	// EXPLODE
	override public function explode(mc){


		Game.me.setFlash(1,-0.15);

		// SELECTED BLOCKS
		unSelectBlocks();

		// KILL
		while(drones.length>0)drones.pop().explode();

		//
		super.explode(mc);

	}

	// FX
	function fxExplosion(x:Float,y:Float){

		var eray = 70;
		var pq = 1;

		// COLOR TRANSFORM
		var inc = -10;
		var mult = 0.8;
		var ct = new flash.geom.ColorTransform( 0.95, mult, mult, 1, inc, inc*2, inc*2, -10);

		// BLUR
		var bfl = new flash.filters.BlurFilter();
		var blp = Math.max(10*pq*mt.Timer.tmod,1);
		bfl.blurX = blp;
		bfl.blurY = blp	;


		// SPRITE
		var sp = new Phys( Game.me.dm.empty(Game.DP_PARTS) );
		sp.x = x-eray;
		sp.y = y-eray;
		sp.updatePos();
		sp.timer = 20;

		// DM
		var dm = new mt.DepthManager(sp.root);

		// INIT PLASMA
		var pl = new Plasma( dm.empty(0),Std.int(eray*2),Std.int(eray*2), 1 );
		pl.ct =  ct;
		pl.filters =  [cast bfl];


		// PARTS
		var max = 4;
		for( i in 0...max ){
			var a  = (i/max)*6.28 + (Math.random()*2-1)*0.3;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var speed = 0.5+Math.random()*3;
			var cr = 5;
			var p = new Part( dm.attach("mcExploPart",0) );
			p.x = eray+ca*speed*cr;
			p.y = eray+sa*speed*cr;
			p.vx = ca*speed;
			p.vy = sa*speed - 2;
			p.fadeType = 0;
			p.timer = 10+Math.random()*10;
			p.root._rotation = Math.random()*360;
			p.bmp = pl;
			p.updatePos();
			p.setScale( 50+Math.random()*50);
		}


		// EXPLO
		var mc = Game.me.dm.attach("mcExplo",0);
		for( i in 0...3 ){
			mc._x = eray+(Math.random()*2-1)*10;
			mc._y = eray+(Math.random()*2-1)*10;
			mc._xscale = mc._yscale = eray*2;
			mc._rotation = Math.random()*360;
			mc.blendMode.add = true;
			pl.drawMc(mc);

			/*
			mc._x = x;
			mc._y = y;
			mc._rotation = Math.random()*360;
			mc._xscale = 10*eray;
			Game.me.plasmaDraw(mc,0);
			*/
		}
		mc.removeMovieClip();


		// KILL
		//kill();

	}
	public function powerUp(){
		// PARTS
		var max= Std.int(18*Cs.PREF_GFX);
		for( i in 0...max ){
			var p = new fx.LineUp(Game.me.dm.attach("partLineUp",Game.DP_PARTS));
			p.x = x + (Math.random()*2-1)*ray;
			p.y = y;
			p.sleep = Math.random()*5;
			p.timer = 10+Math.random()*20;
			p.weight = -(0.1+Math.random()*0.3);
			p.root.blendMode = "add";
			p.factor = 3;
			Filt.glow(p.root,10,2,0xFFFFFF);
		}
	}
	public function setFlash(?n){
		if(n==null)n=1;
		flh = n;
		updateFlash();
	}
	function updateFlash(){
		var c = Math.min(flh,1);
		flh *= 0.7;
		if( flh<0.1 ){
			flh == null;
			c = 0;
		}
		Col.setColor(root,0,Std.int(c*255));
		//
		root.filters = [];
		if(c>0)Filt.glow(root,16*c,2*c,0xFFFFFF);

	}
	public function queue(link,alpha){
		var  brush = Game.me.dm.attach(link,0);
		brush._height = 12;
		brush._width = ray*2;
		brush._x = x-ray;
		brush._y = y;
		brush._alpha = alpha;
		Game.me.plasmaDraw(brush);
		brush.removeMovieClip();
	}


	//
	public static function getPadX(){
		var c = ((Cs.MX/Cs.mcw)*2-1)*(1+Cs.PREF_MOUSE);
		return Cs.mcw*(0.5+c*0.5) ;
	}

//{
}













