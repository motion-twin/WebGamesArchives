package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class Bank extends b.Room {

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
		wall.tile = Assets.rooms.getTile("roomSafe");
	}

	override function getGiftBaseX() return globalLeft + innerWid*0.26;

	override function canBeBoostedNow() {
		return true;
	}
}
