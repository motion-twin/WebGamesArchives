package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class Bar extends b.Room {

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
		wall.tile = Assets.rooms.getTile("roomBar");
	}


	override function onWorkStart() {
		super.onWorkStart();
		//cd.set("cleanUp", Const.seconds(2));
	}

	override function onClientUse(c:en.Client) {
		super.onClientUse(c);

		var rlist = new mt.RandList();
		rlist.add( Lang.t._("Soda time!"), 100 );
		rlist.add( Lang.t._("Ahhh... \"PEGI-16\", my favourite soda."), 8 );
		c.goToRoomTemporarily(this);
		c.setPos(globalLeft+70, globalBottom);
		delayer.add( openDoor.bind(false), 800 );
		openDoor(true);

		var arriving = Const.seconds(0.8);
		createChildProcess( function(p) {
			var c = getClientInside();
			if( c!=null ) {
				if( arriving-->0 )
					c.iaGoto(160, 1, true);
				else
					c.iaGoto(70, -1, true);
			}
			else
				p.destroy();
		});
	}

	override function onDispose() {
		super.onDispose();
	}

	override function getProblem() {
		if( !shotel.hasRoomType(R_StockBeer,true) )
			return {
				icon	: Assets.getStockIconId(R_StockBeer),
				desc	: Lang.t._("The bar needs SODA to work! Build a dedicated STOCK room."),
			}
		else
			return super.getProblem();
	}

	override function update() {
		super.update();

		if( !isWorking() )
			clearBar();

		requireGrooms(isWorking() && !cd.has("cleanUp")?1:0);
		for( e in getGroomsInside() ) {
			e.activity = G_Clean;
			e.iaWander();
		}
	}
}
