import b.Room;
import b.*;

import mt.deepnight.slb.*;
import mt.deepnight.Lib;
import mt.MLib;
import h2d.SpriteBatch;

class Entity {
	public static var ALL : Array<Entity> = [];
	static var GC : Array<Entity> = [];

	var time(get,null)					: Float;
	public var game(get,null)			: Null<Game>;
	public var hotel(get,null)			: Null<Hotel>;
	public var shotel(get,null)			: Null<com.SHotel>;
	public var room(default,set)		: Null<Room>;
	public var cd						: mt.Cooldown;

	public var destroyAsked(default,null): Bool;
	public var spr						: HSpriteBE;
	var handIcon						: Null<BatchElement>;
	public var dir(default,set)			: Int;
	public var scale					: Float;
	public var gravity					: Float;

	public var xx						: Float;
	public var yy						: Float;

	public var dx						: Float;
	public var dy						: Float;

	public var offset					: Float;
	public var frict					: Float;

	//public var xMin(get,null)			: Float;
	//public var xMax(get,null)			: Float;
//
	//public var yMin(get,null)			: Float;
	//public var yMax(get,null)			: Float;

	public var centerX(get,null)		: Float;
	public var centerY(get,null)		: Float;
	public var wid						: Int;
	public var hei						: Int;

	public var baseSpeed				: Float;
	public var walkSpeed(get,null)		: Float;
	public var runSpeed(get,null)		: Float;

	public var physics					: Bool;
	public var stable(get,null)			: Bool;

	public var handX(get,never)			: Float;
	public var handY(get,never)			: Float;


	public function new(?r:b.Room) {
		ALL.push(this);

		xx = yy = 0;
		dx = dy = 0;
		frict = 0.8;
		offset = rnd(0,10);
		baseSpeed = 0.4;
		wid = 50;
		hei = 100;
		dir = 1;
		physics = true;
		destroyAsked = false;
		scale = 1;
		gravity = 8;

		initSprite();
		spr.setCenterRatio(0.5, 1);

		cd = new mt.Cooldown();

		room = r;
	}

	function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb0, Assets.monsters0, "monsterEyeIdle");
	}

	inline function set_dir(v) {
		return dir = v==-1 ? -1 : 1;
	}

	inline function get_time() return Game.ME.itime;
	inline function get_hotel() return Hotel.ME;
	inline function get_shotel() return Game.ME.shotel;
	inline function get_game() return Game.ME;

	inline function get_stable() return !physics || room!=null && yy==room.globalBottom-room.padding;

	inline function get_walkSpeed() return baseSpeed;
	inline function get_runSpeed() return baseSpeed*6;

	inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

	function get_handX() return xx + dir*40;
	function get_handY() return yy - hei*0.4;
	function get_centerX() return xx;
	function get_centerY() return yy-hei*0.5;


	function set_room(r) {
		var old = room;
		room = r;

		if( room!=null ) {
			dx = 0;
			dy = 0;
		}

		return room;
	}

	public function setPos(x,y) {
		xx = x;
		yy = y;
		//updateCoords();
	}


	public inline function destroy() {
		if( !destroyAsked ) {
			destroyAsked = true;
			GC.push(this);
		}
	}

	public static function garbageCollector() {
		while( GC.length>0 )
			GC.shift().unregister();
	}

	public function unregister() {
		ALL.remove(this);

		spr.dispose();
		spr = null;

		if( handIcon!=null ) {
			handIcon.remove();
			handIcon = null;
		}

		room = null;
	}

	public function forceHandIconRefresh() {
		if( handIcon!=null ) {
			handIcon.remove();
			handIcon = null;
		}
		updateHandIcon();
	}

	public function updateHandIcon() {
	}

	public function postUpdate() {
		spr.x = Std.int(xx);
		spr.y = Std.int(yy);

		spr.scaleY = scale * (isDragged()?1.5:1);
		spr.scaleX = spr.scaleY * dir;
	}

	public inline function isDragged() return cd.has("dragged");

	public function update() {
		cd.update();

		// X component
		xx+=dx;
		dx*=frict;
		if( MLib.fabs(dx)<=0.001 )
			dx = 0;

		// Gravity
		if( physics && !stable )
			dy+=gravity;

		// Y component
		yy+=dy;
		dy*=frict;
		if( MLib.fabs(dy)<=0.001 )
			dy = 0;

		// Direction
		if( dir==1 && dx<=-0.1 )
			dir = -1;

		if( dir==-1 && dx>=0.1 )
			dir = 1;

		// Capping
		if( room!=null && !isDragged() ) {
			if( xx<room.globalLeft + 60  )
				xx = room.globalLeft + 60;

			if( room.cappedRight && xx>room.globalRight-60 )
				xx = room.globalRight-60;

			if( yy<room.globalTop )
				yy = room.globalTop;

			if( yy>room.globalBottom-room.padding ) {
				dy = 0;
				yy = room.globalBottom-room.padding;
			}
		}
	}
}

