package b.r;

import com.Protocol;
import com.*;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;
import h2d.SpriteBatch;

class LevelUp extends b.Room {
	var boss			: BatchElement;
	var bossDesk		: BatchElement;
	var inspect			: BatchElement;
	var desks			: Array<BatchElement>;
	var stars			: Array<BatchElement>;
	var rightHands		: Array<BatchElement>;
	var leftHands		: Array<BatchElement>;

	public function new(x,y) {
		super(x,y);
		stars = [];
		desks = [];
		rightHands = [];
		leftHands = [];
	}

	override function clearContent() {
		super.clearContent();

		for( e in stars )
			e.remove();
		stars = [];

		for( e in desks )
			e.remove();
		desks = [];

		for( e in rightHands )
			e.remove();
		rightHands = [];

		for( e in leftHands )
			e.remove();
		leftHands = [];

		if( boss!=null ) {
			bossDesk.remove();
			bossDesk = null;

			boss.remove();
			boss = null;

			inspect.remove();
			inspect = null;
		}
	}

	override function renderContent() {
		super.renderContent();

		for(i in 0...3) {
			var x = 200 + i*100;
			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, "starMob",0, 0.5,1);
			e.setPos(globalLeft + x - 30 + irnd(0,3,true), globalBottom-padding - 50);
			stars.push(e);

			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, "handLeft",0, 0.5,1);
			e.setPos(globalLeft + x + 4 + irnd(0,1,true), globalBottom-padding - 50);
			e.rotation = 0.1;
			leftHands.push(e);

			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, "handRight",0, 0.5,1);
			e.setPos(globalLeft + x - 10 + irnd(0,1,true), globalBottom-padding - 50);
			e.rotation = -0.1;
			rightHands.push(e);

			var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, "bureau",0, 0.5,1);
			e.setPos(globalLeft + x, globalBottom-padding);
			desks.push(e);
		}


		inspect = Assets.monsters1.addBatchElement(Game.ME.monstersSb1, "monsterInspectorSleep",0, 0.5,1);
		inspect.x = globalCenterX + 85;
		inspect.y = globalBottom - padding - 37;

		var x = globalRight-200;
		boss = Assets.tiles.addBatchElement(Game.ME.tilesSb, "pyraMob",0, 0.5,1);
		boss.x = x+20;
		bossDesk = Assets.tiles.addBatchElement(Game.ME.tilesSb, "bureau",0, 0.5,1);
		bossDesk.setPos(x, globalBottom-padding);
		bossDesk.scaleX = -1;
	}

	override function renderWall() {
		super.renderWall();
		refreshWorkState();
	}

	override public function onWorkEnd() {
		super.onWorkEnd();
		refreshWorkState();
	}

	override public function onWorkStart() {
		super.onWorkStart();
		refreshWorkState();
	}

	function refreshWorkState() {
		wall.tile = Assets.rooms.getTile(isWorking() ? "administrativeOff" : "administrativeOn");

		var w = isWorking();
		for(e in desks)
			e.color = w ? h3d.Vector.fromColor(alpha(0x35266A), 1) : h3d.Vector.ONE;

		if( bossDesk!=null )
			bossDesk.color = w ? h3d.Vector.fromColor(alpha(0x35266A), 1) : h3d.Vector.ONE;
	}

	override function onDispose() {
		super.onDispose();

		stars = null;
		desks = null;
		rightHands = null;
		leftHands = null;
		boss = null;
		bossDesk = null;
		inspect = null;
	}

	function onClickUse() {
		Assets.SBANK.click1(1);
		//var e = new ui.Consortium();
	}

	override function update() {
		super.update();

		updateRoomButton(
			"use",
			"iconUse",
			!isUnderConstruction() && !isWorking() && !sroom.isDamaged() && shotel.featureUnlocked("levelUp"),
			onClickUse
		);

		var ready = !isWorking();

		var i = 0;
		for(e in stars) {
			e.visible = ready;
			e.scaleX = 1 + Math.cos(i + ftime*0.1)*0.05;
			e.scaleY = 1 + Math.sin(i*2 + ftime*0.25)*0.1;
			e.rotation = Math.cos(i+ftime*0.15)*0.1;
			i++;
		}

		var s = 0.7;
		var spd = 0.35;
		i = 0;
		for(e in rightHands) {
			var f = MLib.fabs( Math.cos(i*2+ftime*spd) );
			e.y = globalBottom-padding - 50 - f*11 ;
			e.scaleX = s;
			e.scaleY = s - f*0.1;
			e.visible = ready;
			i++;
		}

		i = 0;
		for(e in leftHands) {
			var f = MLib.fabs( Math.cos(1.57 + i*2+ftime*spd) );
			e.y = globalBottom-padding - 50 - f*10 ;
			e.scaleX = s;
			e.scaleY = s - f*0.1;
			e.visible = ready;
			i++;
		}

		i = 0;
		for(e in desks) {
			e.scaleX = 1;
			e.scaleY = 1.15-i*0.05;
			e.rotation = 0;
			if( ready ) {
				e.scaleX += -Math.sin(i*2+ftime*spd) * 0.005;
				e.scaleY += -MLib.fabs( Math.cos(i*2+ftime*spd) ) * 0.03;
				e.rotation = Math.cos(i+ftime*spd*1.25)*0.005;
			}
			i++;
		}

		boss.visible = ready;
		boss.scaleX = -1 + Math.cos(ftime*0.15)*0.05;
		boss.scaleY = 1 + Math.sin(ftime*0.35)*0.1;
		boss.y = globalBottom - padding - 46 - MLib.fabs( Math.cos(ftime*0.2)*3 );

		inspect.scaleX = 0.55 + Math.cos(ftime*0.1)*0.01;
		inspect.scaleY = 0.55 + Math.sin(ftime*0.08)*0.02;
		inspect.visible = ready && !shotel.hasClient(C_Inspector);
		if( cd.has("activated") )
			inspect.alpha -= 0.06;
		else
			inspect.alpha = 0.6;

		if( ready )
			Game.ME.fx.bubbles("blueDot", globalLeft+535, globalTop+75, globalLeft+678, globalTop+205);
	}
}
