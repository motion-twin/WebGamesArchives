package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class Trash extends b.Room {
	var tcan		: HSpriteBE;
	public function new(x,y) {
		super(x,y);

		tcan = Assets.tiles.hbe_get(Game.ME.tilesSb, "monsterTrashIdle");
		tcan.setCenterRatio(0.5,1);
		tcan.visible = false;
		tcan.a.setGeneralSpeed(0.75);
	}

	override function clearContent() {
		super.clearContent();
	}

	override function renderContent() {
		super.renderContent();
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("roomTrash");
	}

	override function onClientUse(c:en.Client) {
		super.onClientUse(c);

		c.say( Lang.t._("That's not a bedroom, is it?") );
		c.goToRoomTemporarily(this);
		openDoor(true);
		c.setPos(globalLeft+70, globalBottom);

		delayer.add( function() {
			tcan.a.playAndLoop("monsterTrashChew");
			Assets.SBANK.trash(0.6);
			delayer.add( function() {
				tcan.a.stopWith("monsterTrashIdle");
			}, 3000);
		}, 600);

		createChildProcess( function(p) {
			if( c.destroyAsked ) {
				p.destroy();
				return;
			}

			c.iaGoto(wid*0.55, 1);
		});
	}

	override function onDispose() {
		super.onDispose();

		tcan.dispose();
		tcan = null;
	}

	override function update() {
		super.update();

		if( !isWorking() )
			clearBar();

		tcan.visible = !isUnderConstruction();
		if( tcan.a.isPlayingAnim("monsterTrashChew") ) {
			tcan.rotation = Math.cos(ftime*0.2)*0.10;
			tcan.scaleX = 1 + Math.sin(ftime*0.2)*0.07;
			tcan.scaleY = 1 + Math.sin(ftime*0.3)*0.05;
			tcan.x = globalCenterX+50 + Math.sin(ftime*0.3)*10;
			tcan.y = globalBottom - padding - MLib.fabs(Math.cos(ftime*0.3)*30);
			Game.ME.fx.bloodDots(tcan.x, tcan.y-130, this);
		}
		else {
			tcan.x = globalCenterX+50 + Math.cos(ftime*0.1)*10;
			tcan.y = globalBottom - padding - MLib.fabs( Math.cos(ftime*0.2)*10 );
			tcan.rotation = Math.cos(ftime*0.1)*0.04;
			tcan.setScale(1);
			tcan.alpha = isWorking() ? 0.8 : 1;
		}
	}
}
