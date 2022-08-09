import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import flash.Key;

enum AfroStep {
	Wait;
	Attack;
	Defense;
	Ouch;
}

enum AfroMove {
	Left;
	Center;
	Right;
}

class Afro extends Sprite{//}
	private static var MVCOOLDOWN = 50;
	private static var ATKCOOLDOWN = 50;
	private static var DEFCOOLDOWN = 50;

	private static var DEFLVLMIN = 20;
	private static var ATKLVLMIN = 20;
	private static var MOVLVLMIN = 20;

	var defLevel : Float;
	var atkLevel : Int;
	var movLevel : Int;

	public var afroStep : AfroStep;
	public var afroMove : AfroMove;
	public var afroNextMove : AfroMove;
	public var afroPrevMove : AfroMove;

	var moveCool 		: Float;
	var defTimer 		: Float;
	var defCool 		: Float;
	var atkCool 		: Float;

	var weak 			: Float;
	var danger 			: Float;
	var invert 			: Bool;

	var cFrame 			: Float;

	var label 			: String;
	var nLabel 			: String;
	var defState 		: String;
	var nbDef 			: Int;

	public var flHit	: Bool;
	public var flMissed	: Bool;
	public var flAttacked	: Bool;
	public var flCounter	: Bool;
	public var reverse	: Bool;

	public var atkLock 	: Bool;
	public var mvLock 	: Bool;
	public var defLock 	: Bool;
	public var ouchLock : Bool;
	public var hitLock	: Bool;

	var sequence 		: List<String>;

	public var player:flash.MovieClip;

	public static var ANIM = [
		{ name:"stand",			start:1,		end: 19		},
		{ name:"attack",		start:20,		end: 26		},
		{ name:"attack_missed",	start:27,		end: 37		},
		{ name:"attack_hit",	start:38,		end: 45		},
		{ name:"def",			start:58,		end: 62		},
		{ name:"def_anim",		start:63,		end: 67		},
		{ name:"def_end",		start:68,		end: 71		},
		{ name:"ouch",			start:78,		end: 85		},
		{ name:"move2side",		start:91,		end: 95		},
		{ name:"move2center",	start:98,		end: 105	},
		{ name:"side_stand",	start:108,		end: 117	},
		{ name:"side_ouch",		start:118,		end: 123	},
		{ name:"side_def",		start:138,		end: 141	},
		{ name:"side_def_anim",	start:143,		end: 146	},
		{ name:"side_def_end",	start:148,		end: 152	}
	];



	public function new(mc){
		super(mc);
		invert = false;
		x = Cs.w*0.5;
		y = Cs.h -10;

		atkLevel = ATKLVLMIN*2;
		defLevel = DEFLVLMIN*2;
		movLevel = MOVLVLMIN*2;

		moveCool = 20;
		defTimer = 10;
		defCool = 20;
		atkCool = 20;

		setScale(100);
		defState = "";
		nbDef = 0;

		flHit = false;
		flMissed = false;
		flAttacked = false;
		cFrame = 0;
		afroStep = Wait;
		afroMove = Center;

		atkLock = false;
		mvLock = false;
		defLock = false;
		ouchLock = false;
		reverse = false;
		sequence = new List();

		this.root.gotoAndStop("stand");
		}


	override function update(){
		super.update();

		defLevel += mt.Timer.tmod;
		//trace(defLevel);
		switch (afroStep){
			case Wait:
			 //reaction

			 //cooldown --
			if (defCool > 0) defCool -= mt.Timer.tmod;
			if (moveCool > 0) moveCool -= mt.Timer.tmod;
			if (atkCool > 0)atkCool -= mt.Timer.tmod;

			if (weak > 0) weak -= mt.Timer.tmod;
			 //random

			if (!mvLock) {
				//trace(flAttacked);
				if (flAttacked){
					if ((defLevel/5900) > Math.random()){
						afroStep = Defense;
						if ((defLevel/5900) > Math.random()){ flCounter = true;}
						//trace("AUTO defense  "+defLevel+"  Couter : "+flCounter+"  defLevel : "+defLevel);
					}

				}else{
					switch (Std.random(3)){
						case 0:
							//---------------------------------------------------------------DEF
							if ((defCool <= 0) && (Std.random(DEFLVLMIN) > DEFLVLMIN/2 )){
								afroStep = Defense;
							}else{
								playStand();
							}

						case 1:
							//---------------------------------------------------------------MOV
							if ((moveCool <= 0)){
								randomMove();
								weak = 5;
							}else{
								playStand();
							}
						case 2:
							//---------------------------------------------------------------ATK
							if ((atkCool <= 0) && (Std.random(ATKLVLMIN) > ATKLVLMIN/2 )){
								 playAtk();
								 weak = 10;
							}else{
								playStand();
							}
						}
					}
				}else {
						playMove();
				}

			case Attack:
				animAtk();

			case Defense:

				if (defTimer > 0){
					defTimer -= mt.Timer.tmod;
				}
				defend();

			case Ouch:
				playOuch();
		}
	}

	public function playAtk(){
		afroStep = Attack;
		atkLock = true;
		afroMove = Center;
		atkCool = ATKCOOLDOWN + Std.random(2);
		initAnim("attack",reverse);
	}



	function animAtk(){
		if (flHit){
			if (!hitLock){
				initAnim("attack_hit",reverse);
				hitLock = true;
				Game.boxer.initOuch(reverse);
			}else{
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					hitLock = false;
					flHit = false;
					afroStep = Wait;
				}
			}

		}else if (flMissed){
			if (!hitLock){
				initAnim("attack_missed",reverse);
				hitLock = true;
			}else{
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					hitLock = false;
					flMissed = false;
					afroStep = Wait;
				}
			}
		}else{
			if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
			}else {
				isTouched();
			}
		}
	}

	function isTouched(){
		if (!Game.boxer.mvLock){
			switch (Game.boxer.move){
				case Left:
					flMissed = true;
				case Center:
					flHit = true;
				case Right:
					flMissed = true;
			}
		}else{
			flMissed = true;
		}
	}

	function defend(){
		if (defState == "defending"){
			if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
			}else {
				if (defTimer < 0){
					defState = "end";
				}
			}
		}else if (defState == "encaisse"){
			if (this.root._currentframe < getEndAnim(label) ){
				nextFrame();
			}else {
				if (defTimer < 0){
					defState = "end";

					switch (afroMove){
						case Left:
							initAnim("side_def_end", true);
						case Center:
							initAnim("def_end",reverse);
						case Right:
							initAnim("side_def_end");
					}
				}
			}
		}else if (defState == "end"){

					if (flCounter){
						playAtk();
						flCounter = false;

					}else{
						if (this.root._currentframe < getEndAnim(label) ){
							nextFrame();
						}else {
							if (defTimer < 0){
								defState = "";
								afroStep = Wait;
								defLock = false;
								defCool = DEFCOOLDOWN;
								flAttacked=false;
							}
						}
					}
		}else {
			switch (afroMove){
				case Left:
					initAnim("side_def", true);
				case Center:
					initAnim("def",reverse);
				case Right:
					initAnim("side_def");
			}

			defTimer= Std.random(DEFLVLMIN) + DEFLVLMIN;
			defState = "defending";
		}

	}

	public function defMe(){
		Game.boxer.nbCombo = 0;
		defState = "encaisse";

		switch (afroMove){
			case Left:
				initAnim("side_def_anim", true);
			case Center:
				initAnim("def_anim");
			case Right:
				initAnim("side_def_anim");
		}

	}

	function randomMove(){
		mvLock = true;
		switch (afroMove){
			case Left:
				afroNextMove = Center;
				initAnim("move2center", true);

			case Center:
				if (Std.random(2)== 0) {
					afroNextMove = Left;
					initAnim("move2side", true);
				}else {
					afroNextMove = Right;
					initAnim("move2side");
				}
			case Right:
				afroNextMove = Center;
				initAnim("move2center");
		}

		moveCool= Std.random(MVCOOLDOWN);
	}

	function playMove(){
		mvLock = true;
		switch (afroNextMove){
			case Left:
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					afroMove = afroNextMove;
				}
			case Center:
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					afroMove = afroNextMove;
				}
			case Right:
				if (this.root._currentframe < getEndAnim(label) ){
					nextFrame();
				}else {
					mvLock = false;
					afroMove = afroNextMove;
				}
		}
	}

	function playStand(){
		switch (afroMove){
			case Left:
				if (label != "side_stand"){
					initAnim("side_stand",true);
				}

			case Center:
				if (label != "stand"){
					initAnim("stand",reverse);
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

	public function willBeAttacked(){
		afroPrevMove = afroMove;
		flAttacked = true;
	}

	public function couldBeTouched(atkReversed:Bool){
		var touched = null;
		if ( afroPrevMove == afroMove){
			switch (afroStep){
				case Wait:
					//trace("Wait!"+label);
					touched = true;
					mvLock = false;
				case Attack:
					//todo
				case Defense:
					touched = false;
					defMe();
				case Ouch:
					touched = false;
			}
		}else{
			touched = false;
		}

		if (touched) initOuch(atkReversed);
		flAttacked=false;
		return touched;
	}

	public function isWeak(){
		return (weak > 0);
	}

	public function initOuch(atkReversed){
		afroStep = Ouch;
		reverse = atkReversed;
		switch (afroMove){
			case Left:
				Game.me.moveBg("left");
				initAnim("side_ouch", true);
			case Center:
				initAnim("ouch",atkReversed);
				Game.me.moveBg("center");
			case Right:
				initAnim("side_ouch");
				Game.me.moveBg("right");
		}
	}

	function playOuch(){
		if (this.root._currentframe < getEndAnim(label) ){
			nextFrame();
		}else {
			afroStep = Wait;
			ouchLock = false;
			flAttacked=false;
			playStand();
		}
	}

	function playAnim(?invert:Bool){
		if (this.root._currentframe < getEndAnim(label) ){
			nextFrame();
		}else {

		}
	}

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
		cFrame +=  1;
		this.root.gotoAndStop(Math.ceil(cFrame));
		//trace(mt.Timer.tmod);
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






