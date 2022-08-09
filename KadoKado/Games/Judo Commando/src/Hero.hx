import Protocole;
import mt.bumdum.Lib;




typedef SortMon = {ent:Ent,dist:Float};


class Hero extends Human {//}

	public var flEndLevelOk:mt.flash.Volatile<Bool>;
	public var flSkipNextGGrab:mt.flash.Volatile<Bool>;

	var left:Bool;
	var right:Bool;
	var up:Bool;
	var down:Bool;
	var fire:Bool;
	var lockUp:Bool;
	var lockRight:Bool;
	var lockDown:Bool;
	var lockLeft:Bool;
	var lockFire:Bool;
	var walkSpeed:Float;
	var runSpeed:Float;


	var crouchTimer:Int;
	var jumpBoostTimer:Int;


	var holdSens:Int;
	public var hold:Mon;
	public var holdStyle:HoldMode;


	public function new(){

		haxe.Log.setColor(0xffffff);

		var mc = Game.me.dm.attach("mcHero",Game.DP_ENT);
		mc.stop();
		super(mc);
		type = HERO;

		flSkipNextGGrab = false;

		runSpeed = 0.2;
		walkSpeed = 0.04;

		life = 10;

		Game.me.focus = this;

		state = Stand;


	}
	override function update(){
		control();
		switch(state){
			case Ground:		updateGround();
			case Stand:		updateStand();


			case Crouch:		updateCrouch();
			case Grapple:		updateGrapple();
			case KneeGrab:		updateKneeGrab();

			case AirDrop:		updateAirDrop();
			case Hang:		updateHang();
			default :
		}

		super.update();
		if( hold!=null && holdStyle!=GRAPPLE && holdStyle!=KNEE ){
			hold.copyPos(this);
			hold.setSens(sens*holdSens);

			var hd:flash.MovieClip = cast (root.smc).hold;
			if( hd!=null ){
				hold.root._x += hd._x*sens;
				hold.root._y += hd._y;
				hold.root._rotation = hd._rotation*sens;
				//if( sens == -1 ) hold.root._rotation = hd._rotation-180;
			}

		}



		// BONUS
		var a = getNears(8,BONUS);
		for( e in a ){
			var p:PowerUp =  cast e;
			p.activate();
		}

		// END SPARK
		if(flEndLevelOk)fxSpark();

		// SECURITY
		if(hold!=null){

			var flBreak = !hold.root._visible;
			if( hold.state != Held && hold.state != KneeGrabbed  && hold.state != Script && hold.state != null )flBreak = true;
			if( flBreak ){
				if(Game.FL_TEST)trace("SECURITY RELEASE! ["+hold.state+"]");
				switch(holdStyle){
					case KNEE:
						jump();
						vy = 0;
					default:

				}

				interrupt();
				backToNormal();
			}

		}

	}

	function control(){
		left = flash.Key.isDown( flash.Key.LEFT );
		right = flash.Key.isDown( flash.Key.RIGHT );
		up = flash.Key.isDown( flash.Key.UP );
		down = flash.Key.isDown( flash.Key.DOWN );
		fire = flash.Key.isDown( flash.Key.SPACE );

		if( lockUp ){
			if( !up )lockUp = false;
			up = false;
		}
		if( lockDown ){
			if( !down )lockDown = false;
			down = false;
		}
		if( lockLeft ){
			if( !left )lockLeft = false;
			left = false;
		}
		if( lockRight ){
			if( !right )lockRight = false;
			right = false;
		}
		if( lockFire ){
			if( !fire )lockFire = false;
			fire  = false;
		}
	}
	function lockAll(){
		lockUp = true;
		lockDown = true;
		lockLeft = true;
		lockRight = true;
	}

	// STAND
	public function initStand(){
		state = Stand;
		flCrouch = false;
	}
	function updateStand(){

		// RUN
		var runAmmount = 0;
		if(left)		runAmmount = -1;
		else if(right)		runAmmount = 1;
		if(runAmmount!=0){
			run(runAmmount);
		}else if(anim=="run" || anim=="walk" || anim=="hold" || anim=="walk_lift" ){
			backToStand();
		}

		// SECURITY BREAK
		if(state!=Stand)return;

		// JUMP / CROUCH / LADDER
		if( hold == null ){

			if(fire){
				if( flEndLevelOk){
					endJump();
				}else{
					lockFire = true;
					jump();
				}
			}else if(up){
				if(sq.ladder){
					//lockFire = true;
					grabLadder();
				}
			}else if( down ){
				crouch();

			}else{
				var a = getNears(7,MONSTER);
				for( mon in a ){
					if( mon.isGrappable()  )grapple(mon);
					return;
				}
			}
		}else{
			if( holdStyle==LIFT ){
				if( down && !lockDown )				throwBackward();
				else if( fire || lockFire )					hitBody();
				else if( up && !lockUp )			chandelle();
			}else{
				if( up )	liftBody();
				else if( down )	dropBody();
				else if( fire )	throwBody();
			}
		}


	}

	function run(n){
		setSens(n);
		var inc = runSpeed;
		if(hold!=null){
			playAnim(holdStyle==LIFT?"walk_lift":"hold");
			inc = walkSpeed;
		}else{
			playAnim("run");
		}
		var me = this;
		walk(inc*sens);
	}
	override function jump(){
		super.jump();
		//vy = -6.8;
		vy = -3;
		jumpBoostTimer = 4;
		lockUp = true;
	}
	function jumpDown(){
		jump();
		vy = -0.5;
		missLine = py+1;
	}
	/*
	override function walkInEmptyGround(){
		jump();
		vy = 0;
	}
	*/

	// FLY
	override function updateFly(){
		super.updateFly();

		// BOOST
		if( jumpBoostTimer-->0 && lockFire ){
			vy -= 1.1;
		}

		// DECALAGE

		var flySpeed = 3;
		if( left ) 		vx = -flySpeed;
		else if( right )	vx = flySpeed;
		else			vx *= 0.5;

		if(vx!=0)setSens();

		/*
		var move = 0;
		if( left )move = -1;
		if( right )move = 1;



		ox += move*runSpeed;
		if(move!=0)setSens(move);
		var next = Game.me.getSq(px+move,py);
		if( Math.abs( ox+0.5*move - 0.5 ) > 0.5 ){
			if( next.type == BLOCK ){
				ox = 0.5;
			}
		}
		if( ox >= 1 )	swapSquare(0);
		if( ox < 0 )	swapSquare(2);
		*/




		// LADDER
		if( up  && sq.ladder ){
			lockFire = true;
			stopPhys();
			grabLadder();
			return;
		}

		// AIR/KNEE GRAB
		var a = getNears(12,MONSTER);
		for( mon in a ){
			if( mon.life>0 ){
				switch(mon.state){

					case KnockOut :
						if( jumpBoostTimer<3 )airGrab(mon);
						return;

					case Normal,Script:
						if( mon.py>py && vy > 0 && mon.isGrappable()){
							kneeGrab(mon);
							return;
						}


					default:
				}
			}

		}

		// CLIMB
		var csx = 0;
		if( left ) csx = -1;
		if( right ) csx = 1;
		if( ox == 0.5 && oy< 0.5 && csx != 0 && vy>0 ){
			var nsq = Game.me.getSq(px+csx,py);
			var above = Game.me.getSq(px+csx,py-1);
			if( nsq.type == BLOCK && above.type == EMPTY ){
				climb(csx);
			}
		}

		// HANG
		if( !down && oy< 0.5 && vy>0 && Game.me.isHangable(px,py) ){
			hangOn();
		}


		// FATAL FALL
		if( py > Cs.YMAX ){
			state = Fall;
			Game.me.initFall();
		}


	}
	override function land(){
		if(py==Cs.YMAX-2 && oy>0.5 )trace("!!!");

		playAnim("land");
		stopPhys();
		initStand();

		if( life <= 0 ){
			state = Crash;
			playAnim("crash");
			Game.me.initGameOver();
			return;
		}


		if( hold!=null ){
			hold.mtag(PILEDRIVER);
			hold.flSafe = true;
			hold.oy = 0.8;
			releaseBody(sens,-2.5,Cs.DAMAGE_PILEDRIVER);
			scr(backToNormal,14);
			playAnim("heavyLand");

			blast(Cs.CS,Cs.DAMAGE_PILEDRIVER_SIDE);


			var gr =  Game.me.getSq(px,py+1);
			if( gr.type == BLOCK )Game.me.fxBrickDust(gr,0,-1);
			Game.me.fxShake(gr.type==BLOCK?40:20);

		}


	}
	override function updateKnockOut(){
		super.updateKnockOut();
		// FATAL FALL
		if( py > Cs.YMAX ){
			state = Fall;
			Game.me.initFall();
		}
	}

	override function confirmCol(sx,sy){
		var sq = Game.me.getSq(px+sx,py+sy);
		if( sq.type == PLAT && state == AirDrop && Std.random(3)==0){
			Game.me.explodeSquare(px+sx,py+sy);
			vy*=0.33;
			hold.damage(1);
			return false;
		}

		return true;
	}

	// HANG ON
	function hangOn(){
		lockUp = true;
		stopPhys();
		state = Hang;
		playAnim("hangOn");
		root.smc.stop();
		oy = 0.5;
	}
	function updateHang(){
		if(down){
			jump();
			vy = 0;
		}else if( up && !lockUp ){
			oy -= 1;
			swapSquare(3);
			updatePos();
			playAnim("hangClimb");
			scr(backToNormal,14);

		}else{
			var inc = 0;
			if(left)		inc = -1;
			else if(right)		inc = 1;

			if(inc!=0){
				nextFrame();
				walk(inc*0.025,function(){},null);
			}
		}

	}

	// AIRDROP
	function airGrab(mon){

		vx= 0;
		if( hold!= null ){
			trace("double hold ->airGrab()");
			Col.setColor(hold.root,0x00FF00);
		}
		hold = mon;
		holdBody();
		playAnim("airGrab");
		state = AirDrop;
		vy -= 1;
	}
	function updateAirDrop(){


	}

	// CROUCH
	function crouch(){
		flCrouch = true;
		state = Crouch;
		playAnim("crouch");
		crouchTimer = 0;
	}
	function updateCrouch(){
		if(!down){

			flCrouch = false;

			// HOLD
			if( flSkipNextGGrab )flSkipNextGGrab= false;
			else{

				var mon = getNearGroundBody();
				if(mon!=null){
					hold = mon;
					holdBody(-mon.sens);
					playAnim("holdBody");
					scr(backToNormal,4);
					return;
				}
			}

			// STAND
 			playAnim("stand");
			initStand();
			return;
		}
		if( fire ){

			// ARM LOCK
			var mon = getNearGroundBody();
			if(mon!=null){


			 	var ax = (mon.root._x - mon.sens*6) -sens*2 ;
				setPos( ax, root._y );
				mon.knockOutTimer = 80;
				mon.mtag(ARMLOCK);
				playAnim("armLock");
				mon.playAnim("crashCustom");
				scr(callback(mon.groundDamage,2),11);
				scr(callback(Game.me.fxShake,15),0);
				scr(callback(Game.me.fxFlash,1),0);
				scr(callback(mon.playAnim,"groundHitCustom"),0);
				scr(backToNormal,16);
				(cast root)._afr = Type.enumIndex(mon.mtype)+1;


				return;
			}

			// JUMP DONW PLAT
			var ground = Game.me.getSq(px,py+1);
			switch(ground.type){
				case PLAT :
					jumpDown();
					return;
				default:
			}
		}


		crouchTimer++;
		if(  crouchTimer>4 && down && Game.me.getSq(px,py+1).ladder ){
			lockFire = true;
			swapSquare(1);
			oy = 0;
			grabLadder();
		}

	}
	function getNearGroundBody(){
		var a = getNears(Cs.CS*0.5,MONSTER);
		for( e in a ){
			var mon:Mon =cast e;
			if( mon.state == Crash && mon.life>0 )return mon;
		}
		return null;
	}


	// CLIMB
	function climb(sx){
		stopPhys();
		setSens(sx);
		swapSquare(sx,-1);
		playAnim("climb");
		scr(backToNormal,20);
		ox = 0.5-sens*0.4;
		oy = 0.5;
		updatePos();
	}

	// GROUND
	function initGround(){
		state = Ground;
		playAnim("ground");
	}
	function updateGround(){

	}

	// HIT
	public function hit(sens,damage){
		fxBleed();
		knockOut(2*sens,-1,damage);
	}
	public function incLife(n){
		life += n;
		if(life>10)life = 10;
		Game.me.updateLifeBar();
	}

	// LADDER
	override function updateLadder(){
		climbDir = 0;
		if( up ||lockUp )climbDir = -1;
		if( down )climbDir = 1;

		if( Game.me.isFree(px,py) && fire ){
			jump();
			vy = -1;
		}

		// CHECK MONSTERS
		var a = getNears(Cs.CS*0.5,MONSTER);
		for( e in a ){
			var mon:Mon = cast e;
			if(mon.state == Ladder ){
				var sens = Std.random(2)*2-1;
				mon.knockOut( sens*1.5, -1 );
			}

		}


		/*
		if( Game.me.isFree(px,py) && fire ){
			if( (left && !lockLeft) || (right && !lockRight) ){
				jump();
				vy = -1;
			}
		}
		*/
		/*
		if( Game.me.isFree(px,py) ){
			var dec = 0.15;
			if( left )ox -= dec;
			if( right )ox += dec;
		}
		*/


		super.updateLadder();
	}

	// GRAPPLING
	function grapple(mon:Mon){


		if( hold!= null ){
			trace("double hold -> grapple()");
			Col.setColor(hold.root,0x00FF00);
		}


		if( mon.state == KnockOut ){

			if(mon.vy>0){
				hold = mon;
				holdBody();
				playAnim("holdBody");
				scr(backToNormal,4);

			}
			return;
		}
		hold = mon;



		state = Grapple;


		playAnim("grapple");

		var dx = (mon.px+mon.ox) - (px+ox);
		var sx = Std.int(dx/Math.abs(dx));
		if( dx == 0 )sx = 1;

		setSens( sx );

		var rdx = Math.abs(dx)-0.4;
		//trace(rdx*Cs.CS);
		ox += 		rdx*0.5*sens;
		mon.ox -= 	rdx*0.5*sens;

		mon.grappled();


		holdStyle = GRAPPLE;

		lockAll();

	}
	function updateGrapple(){
		if( up && !lockUp ){
			scoreTec();
			playAnim("tomoeNage");
			scr( callback(releaseBody,-sens,-6,Cs.DAMAGE_TOMOENAGE,null), 4 );
			scr( rollBack, 10 );
			hold.fkoTimer = 8;
			hold.mtag(TOMOENAGE);


			return;
		}else if( down && !lockDown ) {
			lockDown = true;
			holdBody(-1);
			playAnim("kataGuruma");
			scr( backToNormal, 8 );
			scriptWalk = 0.02*sens;
			return;
		}

		var tec = 0;
		if( left && !lockLeft )		tec = sens;
		if( right && !lockRight )	tec = -sens;

		//trace(tec);

		if( tec == 1 ){
			scoreTec();
			playAnim("ipponSeoi");
			hold.fkoTimer = 8;
			scr( callback(releaseBody,-sens*4,-2,Cs.DAMAGE_IPPONSEOI,null), 4 );
			scr( backToNormal, 15 );
			hold.mtag(IPPONSEOI);


		}else if( tec == -1 ){
			scoreTec();
			playAnim("osotogari");
			scriptWalk = 0.016*sens;
			scr( callback(releaseBody,sens*2,0,Cs.DAMAGE_OSOTOGARI,7),6 );
			scr( backToNormal, 9 );
			hold.mtag(OSOTOGARI);
		}

	}

	// HOLD
	function holdBody(sens=1){

		holdStyle = SHOULDER;
		holdSens = sens;
		hold.held();
	}
	public function releaseBody( ?vvx, ?vvy, ?dam, ?fr ){

		hold.root._rotation = 0;
		if(vvx!=null){
			hold.knockOut(vvx,vvy,dam,fr);
			hold.knockOutTimer = 20;

		}else{
			hold.interrupt();
			hold.backToNormal();
		}
		hold = null;
		holdStyle = null;


	}
	function throwBody(){
		lockFire = true;
		scoreTec();
		hold.fkoTimer = 4;
		scr( callback(releaseBody,sens*5,-2,Cs.DAMAGE_KATAGURUMA,null),4);
		scr( backToNormal,4);
		playAnim("throwBody");
		hold.mtag(KATAGURUMA);
	}
	function liftBody(){
		holdSens = 1;
		playAnim("lift");
		scr( callback( hold.playAnim, "lifted"), 7 );
		scr( backToNormal, 5 );
		holdStyle = LIFT;
	}
	function dropBody(){
		flSkipNextGGrab = true;
		hold.setSens(-sens);
		releaseBody(0,0);
		backToNormal();
	}

	// LIFT
	function hitBody(){
		lockFire = true;
		if(hold.life<=Cs.DAMAGE_LIFT_KICK){
			hold.damage(Cs.DAMAGE_LIFT_KICK);
			throwBackward();
			return;
		}
		playAnim("hitBody");
		hold.playAnim("walk");
		hold.playAnim("lifted");
		hold.damage(Cs.DAMAGE_LIFT_KICK);
		Game.me.fxScore(root._x+sens*7,root._y-17,Cs.SCORE_HIT);
		hold.mtag(STROKE);

		scr( backToNormal,6);
	}
	function throwBackward(){
		playAnim("throwBackward");
		releaseBody(-sens*3,-0.5);
		scr(backToNormal,8);
	}
	function chandelle(){
		hold.playAnim("knockOut");
		playAnim("throwUpward");
		scr( callback(releaseBody,sens*2.3,-5,Cs.DAMAGE_CHANDELLE,null), 4 );
		scr(backToNormal,8);

	}
	public function bodyShieldImpact(dam){

		hold.playAnim("walk");
		hold.playAnim("lifted");
		hold.damage(dam);
		if( hold.life<=0 )bodyShieldDrop();
	}
	public function bodyShieldDrop(){
		hold.fxBleed();
		hold.flSafe = true;
		releaseBody(-sens*2,-1.5,Cs.DAMAGE_PUNCH);
		backToNormal();
	}

	// KNEE
	function kneeGrab(mon){
		if( hold!= null ){
			trace("double hold -> kneeGrab()");
			Col.setColor(hold.root,0x00FF00);
		}

		oy = 1/Cs.CS;
		hold = mon;
		holdStyle = KNEE;
		stopPhys();
		playAnim("kneeGrab");
		state = KneeGrab;
		//scr( callback(gotoState,KneeGrab), 6 );

		mon.kneeGrabbed();

	}
	function updateKneeGrab(){

		// FIST
		if( fire ){

			if(hold.life<=Cs.DAMAGE_FIST_HEAD){

				releaseBody(0,0,Cs.DAMAGE_FIST_HEAD);
				jump();
				vy = -1;
				return;
			}
			playAnim("kneeGrab");
			playAnim("hitHead");

			scr( callback(hold.damage,Cs.DAMAGE_FIST_HEAD), 4 );
			scr( callback(Game.me.fxScore,root._x,root._y-14,Cs.SCORE_HIT), 0 );
			scr( callback(gotoState,KneeGrab), 3 );
			hold.mtag(STROKE);

			return;
		}

		// BUMP JUMP
		if( up && !lockUp ){
			releaseBody();
			jump();
			vy += 1;
			return;
		}

		// HEAD CRUSHER
		if( down && !lockDown ){


			var nsq = Game.me.getSq(hold.px+sens,hold.py);
			var nsqg = Game.me.getSq(hold.px+sens,hold.py+1);
			if( nsq.type == BLOCK || nsqg.type == EMPTY )return;

			oy = 0.5;

			hold.state = null;
			hold.setSens(sens);
			playAnim("headCrush");

			scr( callback(hold.playAnim,"grappling"), 3 );
			scr( callback(releaseBody,sens*4,-2,Cs.DAMAGE_HEAD_CRUSHER,null), 7 );
			scr( callback(moveTo, px+sens,py), 12 );
			scr( callback(setOffset, ox, oy), 0 );
			scr( backToNormal, 0 );
			hold.mtag(HEADCRUSHER);
			return;

		}



		/*
		//walk(sens*0.02);
		if( Std.random(3000)==0 ){
			setSens(-sens);
			hold.setSens(sens);
		}
		*/

	}

	// DAMAGE
	override function damage(n){
		super.damage(n);
		Game.me.updateLifeBar();
	}

	// FATALITY
	public function fatalityGrabbed(e:Ent){
		Game.me.focus = e;
		interrupt();
		stopPhys();
		kill();
	}

	// SCRIPT
	override function interrupt(){
		super.interrupt();
		var h = hold;
		if( hold!=null ){
			hold.fkoTimer = null;
			switch(holdStyle){
				case GRAPPLE,KNEE :
					releaseBody();
				case SHOULDER,LIFT :
					releaseBody(0,0);
					h.flSafe = true;
				default :
					trace("HoldStyle unknown !");
			}
		}


		/*
		if( victim!=null ){
			victim.backToNormal();
			victim = null;

		}
		*/
	}
	function rollBack(){
		playAnim("groundRoll");
		scriptWalk = -sens*0.02;
		scr( backToNormal, 6);
	}
	override function backToNormal(){
		super.backToNormal();
		initStand();
		backToStand();
	}

	// ANIM
	function backToStand(){
		var fr = "stand";
		if( holdStyle==LIFT ) fr = "stand_lift";
		if( holdStyle==SHOULDER ) fr = "standQuiet";
		playAnim(fr);
	}

	// FX
	public function endJump(){
		setSens(1);
		flEndLevelOk = false;
		Game.me.endLevel();

		var max = 16;
		var cr = 4;
		for( i in 0...max ){
			var a = i/max * 6.28;
			var speed = 2 + i%2;
			var ca = Math.cos(a)*speed;
			var sa = Math.sin(a)*speed;
			var p = new mt.bumdum.Phys(Game.me.dm.attach("fxSpark2",Game.DP_FX));
			p.x = root._x+ca*cr;
			p.y = root._y+sa*cr;
			p.vx = ca;
			p.vy = sa;
			p.timer = 50;
			p.frict = 0.95;

		}

	}
	public function fxSpark(){

		var p = new mt.bumdum.Phys(Game.me.dm.attach("fxSpark",Game.DP_FX));
		var ec = 8;
		p.x = root._x + (Math.random()*2-1)*ec;
		p.y = root._y + (Math.random()*2-1)*ec;
		p.weight= -(0.05+Math.random()*0.1);

		var col = Col.objToCol( Col.getRainbow(Math.random()) );
		Col.setPercentColor(p.root,20,col);
		//p.root.blendMode = "add";


	}

	// IS
	public function isTargetable(){
		return state != KnockOut && state!=Crash;
	}

	// score
	public function scoreTec(){
		Game.me.fxScore(root._x,root._y-12,Cs.SCORE_TEC);
	}


	override function kill(){
		Game.me.hero = null;
		super.kill();
	}





//{
}











