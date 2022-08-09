import Protocole;
import mt.bumdum.Lib;

class Human extends Ent {//}

	public var flCrouch:Bool;
	public var flJumpUp:Bool;
	var anim:String;

	public var state:State;

	var climbDir:Int;
	var climbSpeed:Float;
	var coef:Float;
	public var knockOutTimer:Float;
	public var life:mt.flash.Volatile<Float>;

	// SCRIPT
	var flAutoTurn:Bool;
	var script:Array<Command>;
	var scriptWalk:Float;
	var scriptTimer:Float;


	public function new(mc){
		super(mc);
		climbSpeed = 0.1;
		knockOutTimer = 0;
	}

	override function update(){
		Col.setPercentColor(root,0,0xFF0000);
		switch(state){
			case Script:		updateScript();
			case Ladder:		updateLadder();
			case KnockOut :		updateKnockOut();
			case Fall :		updateFall();
			case Fly:		updateFly();
			default:
		}

		super.update();
	}

	// WALKING ENGINE
	function walk(ws,?walkInEmptyGround,?walkToEmptyGround,?walkInWall){

		if( walkInEmptyGround == null ) walkInEmptyGround = fall;

		var sens = Std.int(ws/Math.abs(ws));

		var next = 		Game.me.getSq(px+sens,py);
		var curGround = 	Game.me.getSq(px,py+1);
		var nextGround = 	Game.me.getSq(px+sens,py+1);

		ox += ws;


		var odx = Math.abs( ox+0.5*sens - 0.5 );
		if( odx > 0.5 ){
			if( next.type == BLOCK ||(state==Hang && next.type == EMPTY) ){
				ox = 0.5;
				walkInWall();
			}else if( nextGround.type == EMPTY ){
				walkToEmptyGround();
			}
		}
		if( odx > 0.25 ){
			if( curGround.type == EMPTY ){
				walkInEmptyGround();
			}
		}




		if( ox >= 1 )	swapSquare(0);
		if( ox < 0 )	swapSquare(2);
		
		if( ox >= 1 || ox < 0 ) ox = 0.5;
		
	}
	function fall(){
		interrupt();
		jump();
		vy=0;
	}


	// PHYS
	override function onCollision(sx,sy){
		//var impact = Math.sqrt(vx*vx+vy*vy)*2;
		super.onCollision(sx,sy);
		switch(state){
			case KnockOut :
				if( sx!=0 || sy == -1)Game.me.fxBrickDust(sq,sx,sy);
			default :

		}



	}
	function updateFall(){

		var y = Cs.getY(py+oy);
		var lim = Game.me.gry;
		var x = Cs.getX(px+ox);
		var bd = 42;

		vx *= 0.95;

		if( x < -bd || x > Cs.mcw+bd )lim += 4;
		if( y > lim ){
			state = null;
			stopPhys();
			root._y = lim-Cs.CS*0.5;
			updatePos = function(){};
			playAnim("crash");
			life = 0;
			Game.me.updateLifeBar();
			Game.me.initGameOver();
			for( i in 0...3 ){
				var mc = fxBleed();
				mc._y = root._y + Cs.CS*0.6;
			}

		}

	}

	// ANIMvm
	public function playAnim(str){
		anim = str;
		root.gotoAndStop(str);
	}
	function nextFrame(){
		if(root.smc._currentframe==root.smc._totalframes)root.smc.gotoAndStop(1);
		else root.smc.nextFrame();
	}

	// LADDER
	function grabLadder(dir=0){
		state = Ladder;
		playAnim("ladder");
		root.smc.smc.stop();
		climbDir = dir;
	}
	function updateLadder(){

		var dx = 0.5-ox;
		ox += dx*0.5;

		if( climbDir!= 0 )nextFrame();

		oy += climbDir*climbSpeed;
		var next = Game.me.getSq(px,py+climbDir);

		var ody = Math.abs( oy+0.5*climbDir - 0.5 );
		if( ody > 0.5 ){
			if( !next.ladder ){
				if(climbDir==1){
					if( Game.me.isGround(next.type)  ){
						oy = 0.5;
						backToNormal();
					}else{
						fall();
					}
				}
			}
		}
		if( ody > 0.25 ){
			if( !sq.ladder ){
				oy = 0.5;
				playAnim("crouch");
				root.smc.gotoAndStop(4);
				scr( backToNormal, 6);

			}
		}

		if( oy >= 1 )	swapSquare(1);
		if( oy < 0 )	swapSquare(3);
	}


	// KNOCKOUT
	public function knockOut(vx,vy,?dam,?fr){
		interrupt();

		var sx = Std.int(vx/Math.abs(vx));
		if( vx == 0 )sx = 1;
		setSens(sx);

		state = KnockOut;
		playAnim("knockOut");
		initPhys();
		this.vx = vx;
		this.vy = vy;
		weight = 0.25;
		//if(fr!=null)root.smc.gotoAndPlay(fr);
		if(dam!=null)damage(dam);

	}
	function updateKnockOut(){

	}



	// DAMAGE
	public function damage(n){
		life -= n;
		Col.setPercentColor(root,100,0xFF0000);
		if( state == KnockOut || state == Crash ){
			knockOutTimer = 30;
		}

	}


	// JUMP
	public function jump(){
		flJumpUp = true;
		state = Fly;
		initPhys();
		//vy = -6.8;
		weight = 0.6;
		playAnim("jump");
	}
	function updateFly(){
		if( flJumpUp && vy>-0.5 ){
			flJumpUp = false;
			if(anim=="jump")playAnim("jumpDown");
		}

	}

	// FX
	public function fxBleed(){
		var ec = 4;
		var mc = Game.me.fxAttach("mcBlood",root._x+(Math.random()*2-1)*3,  root._y+(Math.random()*2-1)*5  );
		mc._rotation = Std.random(4)*90;
		return mc;
	}


	// SCRIPT
	public function scr(f,n){
		state = Script;
		if(script==null){
			script = [];
			scriptTimer = 0;
		}

		var t = n;
		if(script.length>0)t += script[script.length-1].t;
		script.push({f:f,t:t});

	}
	public function updateScript(){
		scriptTimer += mt.Timer.tmod;
		var action = script[0];
		var to = 0;
		while(scriptTimer> action.t ){
			action.f();
			script.shift();
			if( script.length == 0 ){
				script = null;
				scriptWalk = null;
				break;
			}else{
				action = script[0];
			}
			if(to++>100){
				trace("SCRIPT ERROR");
				break;
			}
		}
		if( scriptWalk!=null )walk(scriptWalk);

		if( flAutoTurn && Game.me.hero!=null && sens != getSens(Game.me.hero) )setSens(-sens);


	}
	public function interrupt(){
		state = null;
		script = null;
		flCrouch = false;
	}
	public function gotoState(st){
		state = st;
	}
	public function backToNormal(){

	}

	// IS
	public function isTouchingGround(){
		switch(state){
			case Crash, Wheel, KneeGrabbed, Ground, Stand, Grapple, Crouch :	return true;
			case Script: 	return false;
			case Held :	return false;
			default : 	return false;


		}
	}

//{
}




















