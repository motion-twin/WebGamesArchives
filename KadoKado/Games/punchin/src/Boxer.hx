import Common;
import Game;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import flash.Key;

enum BoxerStep {
	Stand;
	Attack;
	Defense;
	Ouch;
	GameOver;
}

enum BoxerMove {
	Left;
	Center;
	Right;
}


class Boxer extends Sprite{//}
	var isFalling:Bool;

	var staOuch:Int;
	var staHit:Int;
	var staMissed:Int;

	public var nbCombo:mt.flash.Volatile<Int>;


	private static var ATKCOOLDOWN = 4;
	private static var MVCOOLDOWN = 30;

	public static var ANIM = [
		{ name:"stand",				start: 0,		end: 19		},
		{ name:"attack",			start: 20,		end: 24		},
		{ name:"attack_missed",		start: 25,		end: 29		},
		{ name:"attack_hit",		start: 30,		end: 42		},
		{ name:"hook",				start: 50,		end: 51		},
		{ name:"hook_missed",		start: 55,		end: 59		},
		{ name:"hook_hit",			start: 60,		end: 72		},
		{ name:"ouch",				start: 80,		end: 86		},
		{ name:"move2side",			start: 90,		end: 92		},
		{ name:"move2center",		start: 100,		end: 103	},
		{ name:"side_stand",		start: 110,		end: 119	}
	];

	public var step	:BoxerStep;
	public var move	:BoxerMove;
	public var nextMove:BoxerMove;

	public var reversed		: Bool;
	public var flLeft		: Bool;
	public var flRight		: Bool;
	public var flAtk		: Bool;
	public var flHit		: Bool;
	public var flMissed		: Bool;
	public var flWeak		: Bool;
	public var flBonus		: Bool;

	var label 		: String;
	var atkType		: String;
	public var mvLock 		: Bool;
	var atkLock		: Bool;
	var hitLock		: Bool;

	var cFrame 		: Float;
	var moveCool	: Float;
	var atkCool		: Float;


	public function new(mc){
		super(mc);
		x = Cs.w*0.5;
		y = Cs.h + 20;

		move = Center;
		mvLock = false;
		hitLock = false;

		flHit = false;
		flMissed = false;
		flBonus = false;
		moveCool = 0;
		atkCool = 0;

		step = Stand;
		label = "";
		this.root.gotoAndStop("stand");

		staOuch = 20;
		staHit = 5;
		staMissed = 2;
		reversed = false;
		nbCombo = 0;

		//Col.setPercentColor(this.root,40,0xFF6600);
		//Col.setPercentColor(this.root,40,0xB3FD02);
		//Col.setPercentColor(this.root,40,0x02CBFD);

	}

	override function update(){
		super.update();
		if( !Game.me.isPlaying() )return;
		flLeft = Key.isDown(Key.LEFT);
		flRight = Key.isDown(Key.RIGHT);
		flAtk = Key.isDown(Key.SPACE);

		control();
	}


	// MOVE
	function control(){
		switch (step){
			case Stand:
				if (!mvLock){
					if (!atkLock) {
						if (moveCool <= 0) {
							if ((flRight)&&(move!=Left)&&(move!=Right)) {
								mvLock = true;
								nextMove = Right;
								initAnim("move2side");
								playMove();

							} else if ((flLeft)&&(move!=Right)&&(move!=Left)){
								mvLock = true;
								nextMove = Left;
								initAnim("move2side",true);
								playMove();

							} else {
								if ((move==Right)&&(!flRight)){
									mvLock = true;
									nextMove = Center;
									initAnim("move2center");
									playMove();
								}else if ((move==Left)&&(!flLeft)){
									mvLock = true;
									nextMove = Center;
									initAnim("move2center",true);
									playMove();
								}else{
									playStand();
								}
							}
							if (atkCool > 0){
								atkCool -= mt.Timer.tmod;
							}else {
								if ( (flAtk) && (!flRight) && (!flLeft) ){
									playAtk();
								}
							}
						}else {
							moveCool -= mt.Timer.tmod;
							playStand();
						}
					}else {
						animAtk();
					}
				}else {
					playMove();
				}

			case Attack:
			case Defense:
			case Ouch:
				playOuch();
			case GameOver:
				this.root.gotoAndStop(85);
				this.y +=10;
				this.x +=5;
				if (this.y > (Cs.h + 220)){ Game.me.initGameOver();}

		}
	}

	function playStand(){
		switch (move){
			case Left:
				if (label != "side_stand"){
					initAnim("side_stand",true);
				}
			case Center:
				if (label != "stand"){
					initAnim("stand",reversed);
				}
			case Right:
				if (label != "side_stand"){
					initAnim("side_stand");
				}
		}

		if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
		}else {
			this.root.gotoAndStop(label);
			cFrame = this.root._currentframe;
		}
	}

	function playMove(){
		switch (nextMove){
			case Left:

				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					move = nextMove;
				}
			case Center:

				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					move = nextMove;
				}
			case Right:

				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					move = nextMove;
				}
		}
	}

	function playAtk(){
		atkLock = true;
		atkCool = ATKCOOLDOWN;
		Game.afro.willBeAttacked();
		switch (Game.afro.afroMove){
			case Left:
				initAnim("hook", true);
				atkType = "hookreverse";
			case Center:
				if (Std.random(2) == 1){reversed = true;}
				else{reversed = false;}
				initAnim("attack",reversed);
				atkType = "attack";

			case Right:
				initAnim("hook");
				atkType = "hook";
		}
	}


	function hit(){
		if (Game.me.st.mask._xscale >staHit+1) {
			Game.me.decStamina(staHit);
		}

		switch (flash.Lib._global.bonusCol){
			case 1:
				if (flWeak){
					Game.me.newMsg("Contre Attaque",15);
					KKApi.addScore(Cs.SCORE_COUNTER);
				}else{
					nbCombo++;
					if (nbCombo>=2){
					Game.me.newMsg(nbCombo+" COMBO",15);
					}
					var pts = Cs.SCORE_PUNCH[nbCombo];
					if( pts == null )
						pts = Cs.SCORE_PUNCH_BIG;
					KKApi.addScore(pts);
				}
			case 2:
				Game.me.newMsg("1000pts !",15);
				KKApi.addScore(Cs.SCORE_BONUS[0]);
				flash.Lib._global.bonusCol = 1;
			case 3:
				Game.me.newMsg("3000pts !!!",15);
				KKApi.addScore(Cs.SCORE_BONUS[1]);
				flash.Lib._global.bonusCol = 1;
			case 4:
				Game.me.newMsg("6000pts !!!",15);
				KKApi.addScore(Cs.SCORE_BONUS[2]);
				flash.Lib._global.bonusCol = 1;
		}

	}

	function miss(){
		Game.me.decStamina(staMissed);
		Game.afro.defMe();
	}

	public function fall(){
		playOuch();
		isFalling = true;
	}

	function animAtk(){
		if (flHit){
			if (!hitLock){

				if (atkType == "hookreverse"){
					initAnim("hook_hit", true);
				}else if (atkType == "attack"){
					initAnim("attack_hit",reversed);

				}else{
					initAnim("hook_hit");
				}
				hitLock = true;
				hit();

			}else{
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					hitLock = false;
					flHit = false;
					atkLock = false;
				}
			}

		}else if (flMissed){
			if (!hitLock){
				if (atkType == "hookreverse"){
					initAnim("hook_missed", true);
				}else if (atkType == "attack"){
					initAnim("attack_missed");
				}else{
					initAnim("hook_missed");
				}
				hitLock = true;
				miss();
			}else{
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					hitLock = false;
					flMissed = false;
					atkLock = false;
				}
			}
		}else{
			if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
			}else {
				if (Game.afro.couldBeTouched(reversed)) {
					flHit = true;
					flWeak = Game.afro.isWeak();
				}
				else flMissed = true;
			}
		}
	}

	function isTouched(){

		switch (Game.afro.afroStep){
			case Wait:
				flHit = true;
			case Attack:
				flHit = true;
			case Defense:
				flMissed = true;
			case Ouch:
				flMissed = true;
		}

	}

	public function initOuch(reverse:Bool){
		step = Ouch;
		reversed = reverse;
		Game.me.decStamina(staOuch);
		nbCombo = 0;
		initAnim("ouch",reversed);
		atkLock = false;
		mvLock = false;
	}

	function playOuch(){
		if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
			}else {
				step = Stand;
				if (isFalling) {
					Game.me.initGameOver;
					trace("t mort");
				}
			}
			if (isFalling) {
				y += 10;
		}

	}
	//ANIM mng

	function initAnim(labelname:String,?reverse:Bool){
		label = labelname;
		if (reverse) this.root._xscale = -100;
		else this.root._xscale = 100;
		this.root.gotoAndStop(label);
		cFrame = this.root._currentframe;
	}

	function prevFrame(){
		cFrame -= mt.Timer.tmod;
		this.root.gotoAndStop(Math.ceil(cFrame));
	}

	function nextFrame(){
		cFrame += 1;
		this.root.gotoAndStop(Math.ceil(cFrame));
	}

	function getStartAnim(anim:String){
		for( a in ANIM ){
			if(a.name == anim)return a.start;
		}
		return null;
	}

	function getEndAnim(anim:String){
		for( a in ANIM ){
			if(a.name == anim)return a.end;
		}
		return null;
	}

	function getRandAnim(){
		return ANIM[Std.random(ANIM.length)].name;
	}
//{
}






