package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.slb.*;
import mt.deepnight.Color;
import mt.deepnight.Cinematic;
import mt.deepnight.Lib;
import mt.flash.Sfx;
import mt.flash.DepthManager;
import mt.flash.Key;
import mt.MLib;
import mt.Metrics;
import flash.ui.Multitouch;

import TeamInfos;
import Const;

#if !v120
#error "Not available"
#end

class Multiplayer extends Game {

	public function new() {
		super(TeamInfos.makeMultiplayer(), Hard);
	}

	override function startGame() {
		super.startGame();
		Multitouch.inputMode = flash.ui.MultitouchInputMode.TOUCH_POINT;
		root.stage.addEventListener(flash.events.TouchEvent.TOUCH_BEGIN, onTouchBegin);
		root.stage.addEventListener(flash.events.TouchEvent.TOUCH_END, onTouchEnd);
	}

	override function unregister() {
		root.stage.removeEventListener(flash.events.TouchEvent.TOUCH_BEGIN, onTouchBegin);
		root.stage.removeEventListener(flash.events.TouchEvent.TOUCH_END, onTouchEnd);
		super.unregister();
	}

	override function createPlayers() {
		var n = oppTeam.playerCount;

		for(i in 0...n)
			new en.Player(playerTeam);

		for(i in 0...n)
			new en.Player(oppTeam);
	}

	override function makePlayerTeam() {
		var t = new TeamInfos(0);
		t.pantColor = t.shirtColor = t.stripeColor = 0x51A8FF;
		t.hairFrame = 106;
		return t;
	}

	override function isMulti() {
		return true;
	}

	inline function inActiveZone(side:Int, x:Float,y:Float) {
		return side==0 && x<=Const.WID*0.4 || side==1 && x>=Const.WID*0.6;
	}


	function onTouchBegin(e:flash.events.TouchEvent) {
		if( !isPlaying() )
			return;

		var x = e.stageX;
		var y = e.stageY;

		clickStart(x,y);
	}

	function onTouchEnd(e:flash.events.TouchEvent) {
		if( !isPlaying() )
			return;

		var x = e.stageX;
		var y = e.stageY;

		clickEnd(x,y);
	}

	function clickStart(x,y) {
		if( inActiveZone(0, x, y) )
			beginCharge(0);

		if( inActiveZone(1, x, y) )
			beginCharge(1);
	}

	function clickEnd(x,y) {
		if( inActiveZone(0, x, y) )
			endCharge(0);

		if( inActiveZone(1, x, y) )
			endCharge(1);
	}

	override function onMouseDown(e) {
		if( !Lib.isAir() )
			clickStart(getMouse().gx, getMouse().gy);
	}

	override function onMouseUp(e) {
		if( !Lib.isAir() )
			clickEnd(getMouse().gx, getMouse().gy);
	}


	override function update() {
		super.update();

		if( ball.hasOwner() && !cd.has("autoPickDefender") ) {
			var side = ball.owner.side;
			var oside = side==0 ? 1 : 0;
			if( !en.Player.hasActive(oside) )
				ball.owner.activateDefender(oside);
		}
	}
}




