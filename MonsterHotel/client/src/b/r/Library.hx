package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class Library extends b.Room {

	var staff		: HSpriteBE;
	var tx			: Float;
	var spd			: Float;

	public function new(x,y) {
		super(x,y);
		staff = Assets.monsters2.hbe_getAndPlay(Game.ME.monstersSb2, "monsterExclamation");
		staff.setCenterRatio(0.5,1);
		spd = 1;
		cd.set("idle", rnd(20,30));
	}

	override function clearContent() {
		super.clearContent();
	}

	override function renderContent() {
		super.renderContent();
		staff.setPos(globalLeft+100, globalBottom-padding);
		tx = staff.x;
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("questRoom");
	}

	override function onDispose() {
		super.onDispose();
		staff.dispose();
		staff = null;
	}

	override function update() {
		super.update();

		if( MLib.fabs(staff.x-tx)<=10 ) {
			tx = globalLeft + padding + rnd(50,400);
			cd.set("idle", Const.seconds(rnd(1,3)));
			spd = rnd(2,3);
		}

		if( cd.has("idle") ) {
			staff.rotation += (Math.cos(ftime*0.1)*0.09 - staff.rotation)*0.2;
			staff.y = globalBottom-padding - MLib.fabs( Math.sin(ftime*0.1)*15 );
		}
		else {
			if( staff.x>tx ) {
				staff.scaleX = -1;
				staff.x -= spd;
			}
			else {
				staff.scaleX = 1;
				staff.x += spd;
			}
			staff.rotation += (Math.cos(ftime*0.25)*0.06 - staff.rotation)*0.2;
			staff.y = globalBottom-padding - MLib.fabs( Math.sin(ftime*0.3)*10 );
		}
	}
}
