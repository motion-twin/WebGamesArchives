import mt.deepnight.slb.*;
import mt.deepnight.Lib;
import mt.MLib;
import b.Room;

class MinorEntity {
	public static var ALL : Array<MinorEntity> = [];
	static var GC : Array<MinorEntity> = [];

	public var room						: b.Room;

	public var destroyed(default,null)	: Bool;
	public var spr						: HSpriteBE;

	public var xx						: Float;
	public var yy						: Float;

	public function new(r:b.Room, x,y) {
		ALL.push(this);

		room = r;

		spr = new mt.deepnight.slb.HSpriteBE(Game.ME.tilesFrontSb, Assets.tiles, "iconTodoRed");
		spr.setCenterRatio(0.5, 1);

		setPos(x,y);
	}

	public static function garbageCollector() {
		while( GC.length>0 )
			GC.shift().unregister();
	}

	public function setPos(x,y) {
		xx = x;
		yy = y;
		//updateCoords();
	}


	public inline function destroy() {
		if( !destroyed ) {
			destroyed = true;
			GC.push(this);
		}
	}

	public function unregister() {
		ALL.remove(this);

		spr.dispose();
		spr = null;

		room = null;
	}

	@:allow(Game) function postUpdate() {
		spr.x = Std.int(xx);
		spr.y = Std.int(yy);
	}

	public function update() {
	}
}

