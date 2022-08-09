package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class VipCall extends b.Room {

	public function new(x,y) {
		super(x,y);
	}

	override function clearContent() {
		super.clearContent();
	}

	override function renderContent() {
		super.renderContent();
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("roomReseller");
	}

	//override function getGiftBaseX() return globalLeft + innerWid*0.26;

	override function onDispose() {
		super.onDispose();
	}

	//override function canBeBoostedNow() {
		//return true;
	//}

	function onClickCallVip() {
		Game.ME.runSolverCommand( DoActivateRoom(rx, ry, null) );
	}

	override function update() {
		super.update();


		updateRoomButton(
			"callVip",
			"iconVip",
			!isWorking() && !isUnderConstruction() && !sroom.isDamaged(),
			onClickCallVip
		);

	}
}
