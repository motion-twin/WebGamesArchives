package iso;

import Iso;
import mt.deepnight.Lib;

enum TeacherAnim {
	TA_Point;
	TA_PointCool;
	TA_Palm;
	TA_DoublePalm;
	TA_WriteBoard;
	TA_Hit;
	TA_Walk;
	TA_Coffee1;
	TA_Coffee2;
	TA_Throw;
	TA_Type;
	TA_Listen;
	TA_Explain;
	TA_Good;
	TA_Wait;
	TA_Charge;
	TA_ChargeFloat;
	TA_ChargeStand;
	TA_Tie;
	TA_SitSofa;
	TA_UpSofa;
	TA_DrinkHeal1;
	TA_DrinkHeal2;
	TA_DrinkHeal3;
	TA_PickUp;
	TA_Pocket;
	TA_Shock;
	TA_WriteDesk;
	TA_WalkPyjama;
	TA_Bed;
	TA_Crazy;
	TA_CrazyPose;
	TA_WalkCrazy;
	TA_Sick;
	TA_SuperWakeUp;
	TA_Twinoid;
	TA_Gun;
	TA_WTF;
	TA_Slap;
	TA_Phone;
	TA_PhoneOff;
}

class Teacher extends Iso {
	public var mc			: lib.James;
	
	public var data			: logic.Teacher;
	
	var dir					: Int;
	var anim				: Null<TeacherAnim>;
	var walkAnimTimer		: Float;
	public var onArriveCB	: Null<Void->Void>;
	var tired				: Bool;
	var suitCase			: Bool;
	var buffed				: Bool;
	var pyjama				: Bool;
	var crazy				: Bool; // petage de plomb du gameover
	var lastSaying			: Null<String>;
	public var hat(default,null)	: Int;
	
	var inCasePos			: Hash<{xr:Float, yr:Float}>;
	
	public function new(d) {
		data = d;
		//super( Manager.ME.tiles.getSprite("cursor") );
		super();
		
		dir = 1;
		tired = false;
		suitCase = false;
		buffed = false;
		pyjama = false;
		crazy = false;
		hat = 0;
		
		fl_static = false;
		speed = 0.15;
		minSpeed = 0.05;
		headY = 6;
		walkAnimTimer = 0;
		inCasePos = new Hash();
		
		yOffset = 0;
		
		mc = new lib.James();
		mc.y = 22;
		mc.gotoAndStop(1);
		sprite.addChild(mc);
		speechColor = 0xE8E8E8;
		setAnim();
		setShadow(true);
	}
	
	public inline function hasHats() {
		return getAvailableHats().length>1;
	}
	
	inline function getAvailableHats() {
		#if debug
		return [0,1,2,3,4,5,6,7,8,9,10,11];
		#else
		return man.cinit._hat._av;
		#end
	}
	
	
	public function nextHat() {
		var h = hat;
		var useNext = h==0 ? true : false;
		for(av in getAvailableHats()) {
			if( h==av )
				useNext = true;
			else
				if( useNext )  {
					setHat(av);
					return;
				}
		}
		if( useNext )
			setHat(0);
	}
	
	
	public function setHat(h:Int) {
		var ok = false;
		for(h2 in getAvailableHats() )
			if( h==h2 ) {
				ok = true;
				break;
			}
			
		if( ok ) {
			mc.gotoAndStop( mc.currentFrame==1 ? 2 : 1 );
			hat = h;
		}
		updateMC();
	}

	
	
	public inline function syncData() {
		man.solver.teacher.solver = null;
		data = man.createCopy(man.solver.teacher);
		man.solver.teacher.solver = man.solver;
		data.solver = man.solver;
	}

	
	public function initData() {
		data = new logic.Teacher(man.cinit._solverInit._teacherData, man.solver, man.cinit._gold, man.cinit._hp);
		setHat( man.cinit._hat._h );
	}
	
	
	
	public function setPyjama(b:Bool) {
		pyjama = b;
		setAnim(anim);
	}
	
	public inline function hasPyjama() {
		return pyjama;
	}
	
	public function setCrazy(b:Bool) {
		crazy = b;
		setAnim(anim);
	}
	
	public function back(?s) {
		goto(Const.BOARD, s);
	}
	
	override function getPath(from,to) {
		return man.getTeacherPath(from,to);
	}
	
	//override function getFeet() {
		//var pt = super.getFeet();
		//pt.y
	//}
	
	override public function goto(pt,?s:Float) {
		onArriveCB = null;
		if( crazy )
			setAnim(TA_WalkCrazy);
		else if( pyjama )
			setAnim(TA_WalkPyjama);
		else
			setAnim(TA_Walk);
		super.goto(pt,s);
		if( crazy )
			tmpSpeedMul *= 2;
		else if( tired )
			tmpSpeedMul*=0.7;
	}
	
	
	override function onArrive() {
		super.onArrive();
		man.cm.signal("teacher");
		setAnim();
		if( man.at(Class) && waitingAt(Const.BOARD) ) {
			setDir(2);
			setAnim(TA_WriteBoard);
		}
		if( man.at(Class) && waitingAt(Const.EXIT) )
			fl_visible = false;
			
		for( i in man.isos )
			if( i!=this && waitingAt( i.getStandPoint() ) ) {
				setDir( i.getStandDir() );
				break;
			}
			
		if( onArriveCB!=null ) {
			var cb = onArriveCB;
			onArriveCB = null;
			cb();
		}
	}
	
	public function setInCasePos(pt:Point, xr:Float,yr:Float) {
		inCasePos.set(pt.x+";"+pt.y, {xr:xr, yr:yr});
	}
	
	public function getInCasePosExtern(cx:Int,cy:Int) {
		return
			if( inCasePos.exists(cx+";"+cy) )
				inCasePos.get(cx+";"+cy);
			else
				{xr:0.5, yr:0.5}
	}
	
	override function getInCasePos() {
		return
			if( inCasePos.exists(cx+";"+cy) )
				inCasePos.get(cx+";"+cy);
			else
				super.getInCasePos();
	}
	
	function getAnimSub() : flash.display.MovieClip {
		return Reflect.field(mc._sub, "_sub");
	}
	
	function getMouth() : flash.display.MovieClip {
		var smc = getAnimSub();
		if( smc!=null )
			return Reflect.field(smc, "_sub");
		else
			return null;
	}
	
	public function setTired(b:Bool) {
		tired = b;
		updateMC();
	}
	
	public function setSuitcase(b:Bool) {
		suitCase = b;
		if( man.furns.exists("case") )
			man.furns.get("case").fl_visible = !b;
		updateMC();
	}
	
	public function setThermometer(b:Bool) {
		var smc : flash.display.MovieClip = Reflect.field(getAnimSub(), "_thermo");
		smc.visible = b;
	}
	
	public inline function setBuff(b:Bool) {
		buffed = b;
		if( !b )
			sprite.filters = [];
	}
	
	public inline function hasAnim(a:TeacherAnim) {
		return anim==a;
	}
	
	public function setAnim(?a:TeacherAnim) {
		anim = a;
		updateMC();
	}
	
	
	public inline function setDirTo(i:Iso) {
		setDir( getDirTo(i) );
	}
	
	public function setDir(d) {
		dir = d;
		switch(dir) {
			case 0,1 : sprite.scaleX = -1;
			case 2,3 : sprite.scaleX = 1;
		}
		updateMC();
	}
	
	public inline function getDir() {
		return dir;
	}
	
	function updateMC() {
		switch( dir ) {
			case 0, 3	: mc.gotoAndStop(2);
			case 1, 2	: mc.gotoAndStop(1);
		}
		if( anim!=null ) {
			var f = switch( anim ) {
				case TA_Point		: "finger";
				case TA_PointCool	: "fingerCool";
				case TA_Palm		: "handBlock";
				case TA_WriteBoard	: "scribe";
				case TA_WriteDesk	: "correct";
				case TA_Hit			: "poc";
				case TA_Walk		: "walk";
				case TA_Coffee1		: "boit";
				case TA_Coffee2		: "cafe";
				case TA_Throw		: "lance";
				case TA_Type		: "ordi";
				case TA_Listen		: "wait";
				case TA_Explain		: "talk";
				case TA_Good		: "good";
				case TA_Wait		: "croise";
				case TA_Tie			: "cravate";
				case TA_Charge		: "charge";
				case TA_ChargeFloat	: "charge2";
				case TA_ChargeStand	: "hit";
				case TA_DoublePalm	: "shoot";
				case TA_SitSofa		: "relax";
				case TA_UpSofa		: "up";
				case TA_DrinkHeal1	: "heal1";
				case TA_DrinkHeal2	: "heal2";
				case TA_DrinkHeal3	: "heal3";
				case TA_PickUp		: "ramasse";
				case TA_Pocket		: "colis";
				case TA_Shock		: "spark";
				case TA_WalkPyjama	: "pijama";
				case TA_Bed			: "bed";
				case TA_Crazy		: "furax";
				case TA_CrazyPose	: "bad";
				case TA_WalkCrazy	: "furaxRun";
				case TA_Sick		: "malade";
				case TA_SuperWakeUp	: "superPij";
				case TA_Twinoid		: "twinoide";
				case TA_Gun			: "fusil";
				case TA_WTF			: "goutte";
				case TA_Slap		: "baffe";
				case TA_Phone		: "tel";
				case TA_PhoneOff	: "tel2";
			}
			try {
				mc._sub.gotoAndStop( f );
			} catch(e:Dynamic) {
				#if debug
				man.warning("missing frame '"+f+"' for dir "+dir);
				#end
			}
		}
		else
			mc._sub.gotoAndStop(pyjama ? "standPij" : "stand");
			
		var v : flash.display.MovieClip = (cast getAnimSub())._case;
		if( v!=null )
			v.visible = suitCase;

		var v : flash.display.MovieClip = (cast getAnimSub())._vrac;
		if( v!=null )
			v.visible = tired;
			
		var v : flash.display.MovieClip = (cast getAnimSub())._hat;
		if( v!=null )
			if( hat>0 ) {
				v.visible = true;
				v.gotoAndStop(hat);
			}
			else {
				v.visible = false;
				v.stop();
			}
			
		var v : flash.display.MovieClip = (cast getAnimSub())._mask;
		if( v!=null )
			if( hat==0 ) {
				v.stop();
				v.mask = null;
				v.visible = false;
			}
			else {
				v.gotoAndStop(hat);
			}
	}
	
	override function updateDir(dx,dy) {
		super.updateDir(dx,dy);
		var old = dir;
		if( dx<0 ) dir = 3;
		else if( dx>0 ) dir = 1;
		if( dy<0 ) dir = 0;
		else if( dy>0 ) dir = 2;
		if( old!=dir )
			updateMC();
	}
	
	//function splitMany(str:String, separators:Array<String>) {
		//if( separators.length==0 )
			//return [];
		//var parts : Array<String> = [];
		//for(s in separators) {
			//for(p in parts)
				//p.split(s);
		//}
		//return parts;
	//}
	
	override function distortSpeech(str:String) {
		if( str!=null && hat==3 ) {
			var word = "";
			var out = "";
			for(c in str.split("")) {
				if( c!=" " && c!="." && c!="," && c!="!" && c!="?" )
					word+=c;
				else {
					if( word.length>1 )
						out += (word.length>=4 ? man.tg.m_mpfLong() : man.tg.m_mpfShort()) + c;
					else
						out += c;
					word = "";
				}
			}
			return out;
		}
		else
			return str;
	}
	
	public function initAmbiantSaying(?first=true) {
		if( first )
			cd.set("saying", 70 + Std.random(45));
		else
			cd.set("saying", 30 * Lib.irnd(9,14));
			
		cd.onComplete("saying", function() {
			var str = "";
			var tries = 10;
			do {
				str = switch( man.subject ) {
					//case S_NativeLang : man.tg.m_native();
					case S_Math : man.tg.m_maths();
					case S_Science : man.tg.m_science();
					//case S_ForeignLang : man.tg.m_foreign();
					case S_History : man.tg.m_history();
				}
			} while( tries-->0 && str==lastSaying );
			ambiant(str);
			lastSaying = str;
			initAmbiantSaying(false);
		});
	}
	
	public function stopAmbiantSaying() {
		cd.set("saying", 99999);
	}
	
	override public function update() {
		super.update();
		
		if( buffed && man.time%4==0 )
			man.fx.buff(this);
			
		if( man.at(Home) && cx==5 && cy==Const.RHEI-3 )
			zpriority = yr<0.5 ? 0 : 99;
			
		if( man.sick ) {
			if( !man.interfaceLocked() && !cd.has("agony") ) {
				say( man.tg.m_agony() );
				cd.set("agony", 30*Lib.rnd(10,25));
			}
			if( !man.interfaceLocked() && !cd.has("bubbles") ) {
				cd.set("bubbles", 30*Lib.rnd(1,3));
				man.fx.bubbles(this, 6, 0.6);
			}
		}
		
		if( move!=null ) {
			var s = getSpeed();
			walkAnimTimer += 0.3 * (0.75 + s);
			var sub = getAnimSub();
			// Bruit de pas
			if( man.time%6==0 ) {
				var pt = getGlobalCoords();
				var d = Lib.distance(cx,cy, Const.RWID*0.5, Const.RHEI*0.5);
				var v = 0.6 * Math.max(0, 1-d/20);
				var panning = Math.min(1, Math.max(-1, pt.x/(Const.WID*0.5) - 1));
				if( Std.random(100)<60 )
					Manager.SBANK.footstep01().play(v, panning);
				else
					Manager.SBANK.footstep02().play(v, panning);
			}
			
			if( crazy && man.time%6==0 )
				man.fx.dustGround(getFeet().x, getFeet().y, 5);
			
			if( sub!=null ) {
				sub.stop();
				while( walkAnimTimer>1 ) {
					if( sub.currentFrame==sub.totalFrames )
						sub.gotoAndStop(0);
					else
						sub.nextFrame();
					walkAnimTimer--;
				}
			}
		}

		// Anim de bouche
		var m = getMouth();
		if( m!=null ) {
			if( cd.has("talking") && !cd.has("mouth") ) {
				m.gotoAndStop(Std.random(m.totalFrames)+1);
				cd.set("mouth", Lib.irnd(2,3));
			}
			if( !cd.has("talking")  )
				m.gotoAndStop(1);
		}
		
		// Bruit de la parole
		//if( bubbles.length>0 && !cd.has("speech") ) {
			//var v = 0.08;
			//var s = [Manager.SBANK.speech01, Manager.SBANK.speech02, Manager.SBANK.speech03];
			//s[Std.random(s.length)]().play(v);
			//cd.set("speech", Lib.rnd(3,7));
		//}
	}
}