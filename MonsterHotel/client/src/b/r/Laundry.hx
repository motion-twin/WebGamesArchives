package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class Laundry extends b.Room {
	var machine			: HSpriteBE;
	var rotor			: HSpriteBE;
	var dx				: Float;
	var dy				: Float;
	var offsetX			: Float;

	public function new(x,y) {
		super(x,y);

		dx = 0;
		dy = 0;

		offsetX = innerWid*rseed.range(0.4, 0.6);


		rotor = Assets.tiles.hbe_get(Game.ME.tilesSb, "laundryRotorEmpty", 0);
		rotor.setCenterRatio(0.5,0.5);
		rotor.visible = false;

		machine = Assets.tiles.hbe_get(Game.ME.tilesSb, "laundryMachine", 0);
		machine.setCenterRatio(0.5,1);
		machine.visible = false;
	}

	override function clearContent() {
		super.clearContent();
	}

	override function renderContent() {
		super.renderContent();
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("roomLaundry");
	}


	override function onDispose() {
		super.onDispose();

		machine.dispose();
		machine = null;

		rotor.dispose();
		rotor = null;
	}


	override function update() {
		super.update();
		var mx = Std.int( globalLeft + offsetX );
		var my = Std.int( globalBottom-padding );

		if( !machine.visible ) {
			// Init
			machine.setPos(mx,my);
			machine.visible = rotor.visible = true;
		}

		if( !isUnderConstruction() ) {
			if( isWorking() ) {
				setBarWorking();

				if( sroom.isDamaged() ) {
					// Repairing
					requireGrooms(1);
					for(e in getGroomsInside()) {
						e.activity = G_Clean;
						e.iaWander();
					}
				}
				else {
					// Washing
					requireGrooms(0);
					if( machine.y<my )
						dy+=0.7;
					dx*=0.94;
					dy*=0.94;
					machine.rotation*=0.9;

					if( machine.y>my ) {
						dx = 0;
						dy = 0;
						machine.rotation = 0;
						machine.y = my;
					}
					else if( machine.y==my && Std.random(100)<20 ) {
						dx = rnd(0,2);
						dy = -rnd(1,3);
						if( machine.x>mx )
							dx*=-1;
					}

					machine.rotation = rnd(0, 0.03, true);
					machine.x += dx + rnd(0,2,true);
					machine.y += dy;

					if( rotor.groupName!="laundryRotorFull" )
						rotor.set("laundryRotorFull");
					rotor.rotation += 0.7;
				}

			}
			else {
				requireGrooms(0);
				dx = 0;
				dy = 0;
				machine.x = mx;
				machine.y = my;
				machine.rotation = 0;
				clearBar();
				if( rotor.groupName!="laundryRotorEmpty" )
					rotor.set("laundryRotorEmpty");
			}
		}

		rotor.setPos( machine.x, machine.y-50 );
	}
}
