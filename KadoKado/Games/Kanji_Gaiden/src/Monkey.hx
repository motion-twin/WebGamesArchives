import mt.bumdum.Lib;

enum MonkeyBehaviour {
	Wait;
	Break;
	Walk;
	Ouch;
	Jump;
	Stunted;
}

class Monkey extends Phys{

	public var mcMonkey 	: flash.MovieClip;
	public static var me	: Monkey;
	
	var target				: mt.flash.Volatile<Int>;
	var progress 			: Float;
	
	var mspeed				: mt.flash.Volatile<Int>;
	var diff				: mt.flash.Volatile<Int>;
	var life				: mt.flash.Volatile<Int>;
	var mtype				: mt.flash.Volatile<Int>;
	var btype				: mt.flash.Volatile<Int>;
	
	var coolDown			: Float;
	var coolJump			: mt.flash.Volatile<Float>;
	var z					: Float;
	var cz					: Float;	
	var stat				: MonkeyBehaviour;
	var bound				: mt.flash.Volatile<Int>;
	public var pl			: mt.flash.Volatile<Int>;
	
	public var protected	: Bool;
	var isSmart				: Bool;

	public function new( zemc : flash.MovieClip, czf:Float, zf:Float, nbPl : Int, ?itype : Int ,?ilife : Int, ?idiff: Int, ?bstype:Int){
		z = zf;
		cz= czf;
		me = this;
		pl = nbPl;
		stat = Wait;
		mspeed = Cs.MSPEED;
		
		mcMonkey = zemc;
		bound = Math.ceil((300+600*(1-cz)));
		
		mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
		protected = true;
		
		if (Std.random(100)+Game.me.diff < 20) isSmart = false;
		else isSmart = true;

		if (!isSmart){
			mcMonkey._x = Std.random(bound-Cs.mcw-50) +175;
		}else {
			if (Std.random(10) >4){
				var maxPos = Std.random( Math.floor(Game.me.pos*100) )/100;
				mcMonkey._x = Std.random( Math.floor(maxPos*(bound-150)) ) +180;

			}else{
				var maxPos = Game.me.pos+ (Std.random( Math.floor((1-Game.me.pos)*100))/100) ;
				mcMonkey._x = Math.floor( maxPos*bound + Std.random( Math.floor((1-maxPos)*bound ))) -180;
			}
		}
		
		super(zemc);
		
		if (ilife != null){ 
			life = ilife;
			diff = idiff;
		}
		else {
			var d = Std.random(50+Game.me.diff);
			if ( (Game.me.diff+d) > 50){
				diff = 3;
				life = 2;
			}else if ( (Game.me.diff+d) > 40){ 
				diff = 2;
				life = 2;
			}else {
				diff = 1;
				life = 1;
			}
		}
		
		if (itype != null) {
			btype = bstype;
			mtype = itype;
		}
		else {
			
			if (Std.random(100) > 87 ){
       				btype = Std.random(4);
				mtype = 4;
				
			}else{
				var t = Std.random(12000);
				
				if (t > 11000){
					if (t > 11500){
						if (t > 11750){
							mtype = 3;
						}else mtype = 2;
					}else mtype = 1;
				}else mtype = 0;
			}
		}
			
		mcMonkey._xscale = (cz*100);
		mcMonkey._yscale = mcMonkey._xscale ;
		
		vx = 0;
		coolDown = 10;
		coolJump = Std.random(4+pl) + 4 - diff ;
		if (coolJump <3) coolJump = 3   ;
		
		initMCs();
		mcMonkey.smc.gotoAndPlay("_land");
	}
	
	
	public override function update(){
		mspeed = Cs.MSPEED + Game.me.diff;
		super.update();
		
		if ((x > bound) || (x < 0 )){
			vx = -vx;
			mcMonkey._xscale = - mcMonkey._xscale;
		}
		
		switch (stat){
			case Wait :
				mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
				if (coolDown > 0) {
					coolDown -= mt.Timer.tmod;         
				}else{
					protected = false;
					coolDown = Std.random(Cs.mCool);
					destiny();
				}
			
			case Break :
				vx *= Math.pow(0.80,mt.Timer.tmod);
				mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
				if (vx < 0.05) {
					vx = 0;
					initWait();
				}
			
			case Walk :

				if (Math.abs(vx)< mspeed) vx *= Math.pow(1.05,mt.Timer.tmod);
				mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
				if ( (x < target+mspeed ) && ( x > target-mspeed) ){
					stat = Break;
					mcMonkey.smc.gotoAndPlay("_break");
					}

			case Ouch :
				mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
				if (coolDown > 0) {
					coolDown -= mt.Timer.tmod;
				}else{
					protected = false;
					coolDown = Std.random(Cs.mCool);
					destiny();
				}
				
			case Jump :
				if (Math.abs(vy)< (2*mspeed) ) vy *= Math.pow(1.1,mt.Timer.tmod);
				
				if (y <0) initSwapPlan();	
				
			case Stunted :
				mcMonkey._y = z - (Cs.SPHERATIO+5*(1-cz))*Math.sin(mcMonkey._x/bound*3.14);
				if (coolDown > 0) {
					coolDown -= mt.Timer.tmod;          
				}else{
					protected = false;
					coolDown = Std.random(Cs.mCool);
					destiny();
				}
				
		}
	}
	
	
	function destiny() {
		
		if (coolJump>1){
			initWalk();
			coolJump -= mt.Timer.tmod ;
		}else{
			initJump();
		}
	}

	
	function initMCs(){
		mcMonkey.gotoAndStop(diff);
		//mcMonkey.gotoAndStop(1);
		
		if (mtype !=4) mcMonkey.smc.smc.gotoAndStop(mtype+1);
		else mcMonkey.smc.smc.gotoAndStop(5+btype);
		
	}
	
	
	function initWait(){
		stat = Wait;
		vx = 0;
		coolDown = Std.random(Cs.mCool-Game.me.diff);
		protected = false;
		initMCs();
		//mcMonkey.smc.gotoAndPlay("_stand");
	}
	
	function initWalk(){
		progress = 0;
		stat = Walk;
		protected = false;
		var delta  = 0;
		var sens  = 1;
		
		if (isSmart){
			//left
			if (mcMonkey._x < (bound * Game.me.pos )) {
				while (Math.abs(delta) < 40){
					var maxPos = Std.random( Math.floor(Game.me.pos*100) )/100;
					target = Math.floor(maxPos*(bound-340)) +170;
					delta = Math.floor(target - mcMonkey._x);
					sens = Math.floor(delta/Math.abs(delta));	
				}
			}else{
				while (Math.abs(delta) < 40){
					var maxPos = Game.me.pos+ (Std.random( Math.floor((1-Game.me.pos)*100))/100) ;
					target = Math.floor( maxPos*(bound-340)) +170;
					delta = Math.floor(target - mcMonkey._x);
					sens = Math.floor(delta/Math.abs(delta));		
				}
			}
		}else{
			while (Math.abs(delta) < 40){
				target = Std.random(bound-Cs.mcw-100) +160;
				delta = Math.floor(target - mcMonkey._x);
				sens = Math.floor(delta/Math.abs(delta));	
			}
		}
		
		if (target< 170) target = 170;
		else if (target > (bound-170) ) target = bound-170;

		

		vx = sens*(mspeed*0.5);
		
		mcMonkey._xscale = -sens * Math.abs(mcMonkey._xscale);
		mcMonkey.smc.gotoAndPlay("_startrun");
		initMCs();
	}
	
	function initJump(){
		protected = true;
		stat = Jump;
		coolDown = Std.random(Cs.mCool);
		mcMonkey.smc.gotoAndPlay("_jump");
		initMCs();
		vy = -mspeed;
	}
	
	function initSwapPlan() {
		vy = 0;
		destroy();
		Game.me.addAMonkeySpecial(pl-1,mtype,life,diff,btype);
	}
	
	function initStunted(){
		stat = Stunted;
		vx = 0;
		coolDown = Std.random(150)+100;
		protected = false;
		mcMonkey.smc.gotoAndPlay("_stunted");
		initMCs();
	}
	                                 
	public function ouch(type:Int){
		if (type == 4) {
			if (stat == Stunted) {
				if (life <= 0){
					kill();
				}else{
					stat = Ouch;
					vx = 0;
					coolDown = 15;
					protected = true;
					mcMonkey.smc.gotoAndPlay("_ouch");
					initMCs();
				}
				
			}else{
				initStunted();
			}
		}else {
			if (type == 3) {
				life -= 2;
			}else life--;
			
			if (life <= 0){
				kill();
			}else{
				stat = Ouch;
				vx = 0;
				coolDown = 15;
				protected = true;
				mcMonkey.smc.gotoAndPlay("_ouch");
				initMCs();
			}
		}
	
	}
		
	public override function kill(){
		Game.me.monkeys.remove(this);
		if (mtype == 4) {
			Game.me.scoreIt(Cs.PTS[0]);
		}else if (mtype == 0) {
			Game.me.scoreIt(Cs.PTS[pl]);
		}else Game.me.scoreIt(Cs.BONUS[mtype]);
		
		mcMonkey.smc.gotoAndPlay("_die");
		initMCs();
		if (mtype ==4) Game.me.bonusMe(btype);
	}
	
	public function destroy(){
		mcMonkey.removeMovieClip();
		Game.me.monkeys.remove(this);
	}
	
}



