package b.r;

import com.Protocol;
import com.*;
import mt.data.GetText;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;
import h2d.SpriteBatch;

class Generator extends b.Room {
	var crates				: Array<BatchElement>;

	public function new(x,y) {
		super(x,y);
		crates = [];
	}

	override public function finalize() {
		super.finalize();
	}

	override function clearContent() {
		super.clearContent();
	}

	override function renderContent() {
		super.renderContent();
	}

	override function renderWall() {
		super.renderWall();
		updateWall();
	}

	override function onDispose() {
		super.onDispose();

		for(e in crates)
			e.remove();
		crates = null;
	}

	function updateWall() {
		wall.tile = Assets.rooms.getTile(data<=0 ? "roomBoostEmpty" : "roomBoost");
	}

	override public function updateData() {
		super.updateData();

		updateWall();

		for(e in crates)
			e.remove();
		crates = [];

		var max = stockMax();
		var x = 0;
		var w = 95;

		for(i in 0...max) {
			var emptySlot = i>=data;
			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, emptySlot ? "batteryEmpty" : Assets.getStockIconId(type, true),0, 0.5, 1);
			crates.push(e);
			e.setScale(0.8);
			e.x = globalCenterX - w*GameData.getStockMax(type, sroom.level)*0.5 + x*w;
			e.y = globalBottom - padding;
			e.alpha = emptySlot ? 0.5 : 1;
			x++;
		}
	}

	override public function updateConstruction() {
		super.updateConstruction();

		if( !isUnderConstruction() ) {
			updateData();
			for(e in crates)
				e.alpha = 0;
		}
	}

	function onClickRefillBoosters() {
		Game.ME.runSolverCommand( DoActivateRoom(rx,ry) );
	}

	override function canBeBoostedNow() {
		return sroom.getMissingStock()>0;
	}

	inline function stockMax() return GameData.getStockMax(type, sroom.level);


	override function update() {
		super.update();

		if( !isWorking() && !isUnderConstruction() ) {
			var t = getTaskTimer();
			if( t!=null )
				setBarDuration(t.start, t.end);
			else
				clearBar();
		}

		updateRoomButton(
			"refillBoost",
			"moneyGem",
			!isUnderConstruction() && !sroom.isDamaged() && sroom.data==0,
			onClickRefillBoosters,
			Main.ME.settings.confirmGems ? Lang.t._("Refill all boosters immediatly?") : null
		);

		// Crates fade in/out
		for(e in crates)
			if( isWorking() )
				e.alpha*=0.8;
			else if( e.alpha<1 )
				e.alpha = MLib.fmin(e.alpha+0.1, 1);
	}
}
