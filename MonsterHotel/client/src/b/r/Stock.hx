package b.r;

import com.Protocol;
import com.*;
import mt.data.GetText;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;
import h2d.SpriteBatch;

class Stock extends b.Room {
	var crates				: Array<BatchElement>;
	var shelf				: BatchElement;
	var machine				: HSpriteBE;

	public function new(x,y) {
		super(x,y);
		crates = [];
	}

	override public function finalize() {
		super.finalize();
	}

	override function clearContent() {
		super.clearContent();

		if( shelf!=null ) {
			shelf.remove();
			shelf = null;

			machine.remove();
			machine = null;
		}
	}

	override function renderContent() {
		super.renderContent();

		shelf = Assets.tiles.addBatchElement(Game.ME.tilesSb, "stockShelf",0);
		shelf.tile.setCenterRatio(0, 1);
		shelf.setPos(globalLeft+45, globalBottom-padding);
		shelf.visible = type!=R_StockBoost;

		machine = Assets.tiles.hbe_get(Game.ME.tilesSb, "stockMachine");
		machine.setCenterRatio(0.5, 1);
		machine.visible = false;
		machine.y = globalBottom-padding+1;
		machine.a.setGeneralSpeed(0.3);
	}

	override function renderWall() {
		super.renderWall();
		refreshWall();
	}

	function refreshWall() {
		wall.tile = Assets.rooms.getTile(switch( type ) {
			case R_StockBeer : "roomBeer";
			case R_StockPaper : "roomPq";
			case R_StockSoap : "roomSoap";
			case R_StockBoost : data<=0 ? "roomBoostEmpty" : "roomBoost";
			default : "roomNew";
		});
	}

	override function onDispose() {
		super.onDispose();

		for(e in crates)
			e.remove();
		crates = null;
	}

	override public function updateData() {
		super.updateData();

		refreshWall();

		for(e in crates)
			e.remove();
		crates = [];

		var max = stockMax();
		var margin = 6;
		var wid = 90;
		var hei = 53;
		var x = 0;
		var y = 0;
		var dy = 15;
		var rseed = new mt.Rand(0);
		var cols = max<=6 ? 2 : 3;
		var seed = rx+ry*99;
		var k = Assets.getStockIconId(type, true);

		if( type==R_StockBoost ) {
			wid = 80;
			hei = Std.int(wid*(180/145));
			cols = 3;
			margin = 20;
			dy = 0;
		}

		for(i in 0...max) {
			var emptySlot = i>=data;
			rseed.initSeed(seed + y);
			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, k,0, 0.5, 1);
			crates.push(e);
			e.width = wid;
			e.height = hei;
			e.x = shelf.x + 115 + x*(wid+margin) + rseed.irange(0,margin,true) + (y%2==0?15:0);
			e.y = globalBottom - padding - dy - y*(hei+18);
			if( emptySlot )
				e.color = h3d.Vector.fromColor(alpha(0, 0.35));
			else if( type!=R_StockBoost )
				e.rotation = rseed.range(0, 0.05, true);
			x++;
			if( x>=cols ) {
				x = 0;
				y++;
			}
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

	//override function updateRoomButton(id:String, iconId:String, idx:Int, ?active=true, cb:Void->Void, ?confirm:LocaleString) {
		//super.updateRoomButton(id,iconId,idx,active,cb,confirm);
//
		//if( roomButtons.exists(id) ) {
			//var b = roomButtons.get(id);
			//b.bg.y = globalTop + 20 + b.bg.height*0.5;
			//b.i.y = b.bg.y;
		//}
	//}


	//function onClickUpgrade() {
		//var q = new ui.Question();
		//q.addText(Lang.t._("TODO stock upgrade explanation"));
		//q.addButton( Lang.t._("Upgrade stock capacity (::cost:: GOLD)", {cost:GameData.getRoomUpgradeCost(type, sroom.level)}), "moneyGold", function() {
			//Game.ME.runSolverCommand( DoUpgradeRoom(rx,ry) );
		//});
		//q.addCancel();
	//}

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

		requireGrooms(isWorking()?1:0);
		for(e in getGroomsInside()) {
			e.activity = G_Clean;
			e.iaWander();
		}

		updateRoomButton(
			"refillBoost",
			"moneyGem",
			!isUnderConstruction() && type==R_StockBoost && !sroom.isDamaged() && sroom.getMissingStock()!=0,
			onClickRefillBoosters
		);

		machine.visible = true;
		machine.x = globalLeft + 45;
		machine.y = MLib.fmin(globalBottom-padding+1, machine.y+3);
		machine.rotation = 0;
		if( data<stockMax() && !sroom.isDamaged() ) {
			if( !machine.a.isPlayingAnim("stockMachine") )
				machine.a.playAndLoop("stockMachine");

			if( !sroom.hasBoost() ) {
				if( !cd.hasSet("jump", 8) )
					machine.y -= rnd(3,6);
				machine.rotation += rnd(0, 0.02, true);
				machine.a.setGeneralSpeed(0.6);
			}
			else {
				machine.x += rnd(0,2,true);
				machine.rotation += rnd(0, 0.05, true);
				machine.a.setGeneralSpeed(1);

				if( !cd.hasSet("jump", 6) )
					machine.y -= rnd(6,10);

				if( !cd.has("smoke")) {
					cd.set("smoke", rnd(10,30));
					var p = Assets.tiles.hbe_getAndPlay(Game.ME.tilesSb, "smokeMachine", 1, true);
					p.setCenterRatio(0.2, 0.9);
					p.x = machine.x + rnd(10,40);
					p.y = machine.y-rnd(10,50);
					p.setScale(rnd(0.5, 2));
					p.rotation = rnd(0,0.2,true);
				}
			}
		}
		else {
			if( machine.a.isPlayingAnim("stockMachine") )
				machine.a.stop();
			machine.a.setGeneralSpeed(0.2);
		}

		// Crates fade in/out
		for(e in crates)
			if( isWorking() )
				e.alpha*=0.8;
			else if( e.alpha<1 )
				e.alpha = MLib.fmin(e.alpha+0.1, 1);
	}
}
