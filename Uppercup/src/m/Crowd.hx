package m;

import mt.deepnight.Lib;
import mt.flash.Sfx;

class Crowd extends mt.deepnight.Process {
	public static var CHANNEL = 2;

	public static var ME : Crowd;
	var loop			: Sfx;
	var cid				: Int;
	var reaction		: Sfx;
	var ballTakenId		: Int;

	public function new() {
		super();
		ME = this;
		cid = CHANNEL;
		ballTakenId = 1;

		loop = m.Global.SBANK.public_loop();
		loop.setChannel(cid);

		cd.set("ambiant", Const.seconds(rnd(0,2)));
	}

	//inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	//inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }

	public function start() {
		loop.playLoop(9999);
	}

	override function onActivate() {
		super.onActivate();
		loop.playLoop(9999, 1, Lib.rnd(0, loop.getSoundDuration()*0.5));
	}

	override function onDeactivate() {
		super.onDeactivate();
		loop.stop();
	}

	override function unregister() {
		super.unregister();
		Sfx.clearChannelWithFadeOut(cid, 1500);
		ME = null;
	}

	function hasAnyEventLock() {
		for(i in 0...20)
			if( cd.has("lock"+i) )
				return true;
		return false;
	}

	function eventLock(prio:Int) {
		for(i in prio...21)
			if( cd.has("lock"+i) )
				return false;
		cd.set("lock"+prio, Const.seconds(4));
		return true;
	}

	public function onBattle(winnerSide:Int) {
		if( winnerSide==1 && eventLock(2) )
			Global.SBANK.public_faute().playOnChannel(cid);
	}


	public function onGoal(side:Int) {
		if( eventLock(10) )
			Global.SBANK.public_but().playOnChannel(cid);
	}

	public function onFault(side:Int, red:Bool) {
		if( !red && eventLock(5) )
			Global.SBANK.public_carton_jaune().playOnChannel(cid);

		if( red && eventLock(10) )
			Global.SBANK.public_carton_rouge().playOnChannel(cid);
	}

	public function onGoalBarHit(side:Int) {
		if( eventLock(9) )
			Global.SBANK.public_tir_rat_().playOnChannel(cid);
	}

	public function onLeaveField(side:Int) {
		if( eventLock(9) )
			Global.SBANK.public_tir_rat_().playOnChannel(cid);
	}


	public function onGoalInterception(side:Int) {
		if( side==1 && eventLock(5) )
			Global.SBANK.public_tir_rat_().playOnChannel(cid);
	}


	public function onBallTaken(side:Int, xr:Float,yr:Float) {
		if( side==0 && xr>=0.4 && eventLock(3) ) {
			switch( ballTakenId ) {
				case 1 : Global.SBANK.public_content1().playOnChannel(cid);
				case 2 : Global.SBANK.public_content2().playOnChannel(cid);
				case 3 : Global.SBANK.public_content3().playOnChannel(cid);
			}
			ballTakenId++;
			if( ballTakenId>3 )
				ballTakenId = 1;
		}
	}


	override function update() {
		super.update();

		if( !hasAnyEventLock() ) {
			if( !cd.has("ambiant") ) {
				cd.set("ambiant", Const.seconds(rnd(10,15)));
				var s = Sfx.playOne([
					Global.SBANK.public_chante,
					Global.SBANK.public_corne,
					Global.SBANK.public_corne2,
					Global.SBANK.public_corne3,
					Global.SBANK.public_music1,
					Global.SBANK.public_music2,
				]);
				s.setChannel(cid);
			}
		}

		if( Game.ME!=null ) {
			var pr = Game.ME.ball.getPositionRatio();
			var v = pr.x>=0.7 ? 1 : (pr.x>=0.5 ? 0.7 : 0.5);
			loop.setVolume( loop.getTheoricalVolume() + (v-loop.getTheoricalVolume())*0.1 );
		}
	}
}