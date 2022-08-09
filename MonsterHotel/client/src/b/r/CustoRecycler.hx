package b.r;

import Data;
import com.Protocol;
import com.*;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;
import h2d.SpriteBatch;

class CustoRecycler extends b.Room {
	var base		: HSpriteBE;
	var saw			: HSpriteBE;
	var icons		: Array<HSpriteBE>;
	var speed		: Float;
	var isize = 45;

	public function new(x,y) {
		super(x,y);
		icons = [];
		speed = 0;
	}

	override function clearContent() {
		super.clearContent();
		if( base!=null ) {
			base.dispose();
			base = null;

			saw.dispose();
			saw = null;
		}
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("roomMenuisier");
	}


	override function renderContent() {
		super.renderContent();

		saw = Assets.tiles.hbe_get(Game.ME.tilesSb, "circularSaw",0, 0.5,0.5);
		saw.scaleX = -1;

		base = Assets.tiles.hbe_get(Game.ME.tilesSb, "sawcisse",0, 0,1);
		base.x = globalLeft + innerWid*0.2;
		base.y = globalBottom;

		updateSaw();
		updateData();
	}

	override public function updateData() {
		super.updateData();

		for(e in icons)
			e.dispose();
		icons = [];

		var max = GameData.CUSTO_RECYCLING_COST;

		for(i in 0...max) {
			if( i<sroom.data )
				continue;
			var e = Assets.tiles.hbe_get(Game.ME.tilesSb, "whiteCircle",0, 0,1);
			icons.push(e);
			e.constraintSize(isize*0.6);
			e.colorize(Const.BLUE, 0.5);
			e.setPos(globalCenterX-max*isize*0.5 + isize*i, globalTop + 60);
		}
		for(i in 0...sroom.data) {
			var e = Assets.tiles.hbe_get(Game.ME.tilesSb, "gift",0, 0, 0.92);
			icons.push(e);
			e.constraintSize(isize);
			e.setPos(globalCenterX-max*isize*0.5 + isize*i, globalTop + 60);
		}
	}

	override public function onStockAdded() {
		super.onStockAdded();

		if( sroom.data>=GameData.CUSTO_RECYCLING_COST ) {
			delayer.add( function() {
				cd.set("running", Const.seconds(3));
			},400);
			Game.ME.fx.roomUpgrade(this);
		}
		else {
			var x = globalCenterX - GameData.CUSTO_RECYCLING_COST*isize*0.5 + sroom.data*isize - isize*0.5;
			var y = globalTop+60 - isize*0.5;
			Game.ME.fx.stockAdded(x, y);
			Game.ME.fx.popIcon("gift", x,y);
			delayer.add( function() {
				cd.set("running", Const.seconds(3));
				Game.ME.fx.roomValidated(this);
			},400);
			delayer.add( function() {
				if( !destroyed && sroom!=null )
					ui.SceneNotification.onRoom( this, Lang.t._("Recycled items: ::n::/::max::", {n:sroom.data, max:GameData.CUSTO_RECYCLING_COST}) );
			},1000);
		}
	}


	override function getGiftBaseX() {
		return globalRight - innerWid*0.25;
	}

	override function onDispose() {
		super.onDispose();
		icons = null;
	}

	function updateSaw() {
		if( cd.has("running") ) {
			Game.ME.fx.saw(this, saw.x, saw.y+saw.tile.height*0.4);
			base.scaleX = 1 + Math.cos(ftime*0.3)*0.009;
			base.scaleY = 1 + Math.cos(ftime*0.5)*0.018;
		}
		else {
			base.scaleY = 1 + Math.cos(ftime*0.1)*0.015;
		}

		saw.x = base.x + 165*base.scaleX;
		saw.y = base.y - 85*base.scaleY;

		if( cd.has("running") )
			speed+=0.03;
		speed*=0.94;
		saw.rotation+=speed;
	}

	override function update() {
		super.update();
		updateSaw();
	}
}
