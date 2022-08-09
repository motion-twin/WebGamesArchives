package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;
import h2d.SpriteBatch;

class FillerStructs extends b.Room {
	var structs			: Array<HSpriteBE>;

	public function new(x,y) {
		super(x,y);

		structs = [];
	}

	override function clearContent() {
		super.clearContent();

		for(e in structs)
			e.remove();
		structs = [];
	}

	override function renderContent() {
		super.renderContent();

		leftPadding.visible = false;
		topPadding.visible = false;
		bottomPadding.visible = false;
		rightPadding.visible = false;
		dark.visible = false;
		var centerX = globalCenterX;
		var centerY = globalCenterY;

		// Right
		if( shotel.hasRoom(rx+1,ry) )
			if( shotel.getRoom(rx+1, ry).type!=R_FillerStructs ) {
				var e = addStruct("filletFacade", globalCenterX, globalCenterY, 0, 0.5);
				e.width+=13;
			}
			else
				addStruct("horizontal", globalRight, centerY, 1, 0.5);

		// Right + above
		var e = addStruct("junction", centerX, centerY, 0,1);
		e.rotation = MLib.PI;

		// Left + above
		var e = addStruct("junction", centerX, centerY, 0,1);
		e.rotation = MLib.PI*0.5;

		// Right + under
		var e = addStruct("junction", centerX, centerY, 0,1);
		e.rotation = -MLib.PI*0.5;

		// Left + under
		addStruct("junction", centerX, centerY, 0,1);

		// Above
		if( shotel.hasRoom(rx,ry+1) )
			addStruct("vertical", centerX, globalTop, 0.5, 0);

		// Under
		if( shotel.hasRoom(rx,ry-1) )
			addStruct("vertical", centerX, globalBottom, 0.5, 1);

		// Left
		if( shotel.hasRoom(rx-1,ry) )
			addStruct("horizontal", globalLeft, centerY, 0, 0.5);
	}

	function addStruct(k:String, x:Float, y:Float, xr:Float, yr:Float) {
		var e = Assets.bg.hbe_get(Game.ME.bgSb, k, Assets.bg.getRandomFrame(k), xr,yr);
		structs.push(e);
		e.changePriority(-2);
		e.setPos(x,y);
		e.setScale( Assets.SCALE );
		return e;
	}

	override public function fadeIn() {}

	override function renderWall() {
		super.renderWall();
		wall.visible = false;
	}

	override function onWorkStart() {
		super.onWorkStart();
	}
}
