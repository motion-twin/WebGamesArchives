package en;

import mt.deepnight.retro.SpriteLibBitmap;

class Door extends Entity {
	public static var ALL : Array<Door> = [];
	static var FAST_ACCESS : Array<Array<Door>>;
	static var ROOM_ACCESS : IntHash<Array<Door>> = new IntHash();
	
	var dsprite				: BSprite;
	var openFrame			: Int;
	var closeFrame			: Int;
	public var armored		: Bool;
	public var broken		: Bool;
	public var locked		: Bool;
	
	var icon				: BSprite;
	
	//public var pathToDoors	: IntHash< Array<{x:Int, y:Int}> >;
	public var roomId1		: Int;
	public var roomId2		: Int;
	
	var closed				: Bool;
	public var horizontal(default, null): Bool;
	
	public function new(x,y, h:Bool, armor:Bool) {
		super();
		if( FAST_ACCESS==null )
			resetFastAccess();
		
		//pathToDoors = new IntHash();
		locked = false;
		armored = armor;
		broken = false;
		ALL.push(this);
		cx = x;
		cy = y;
		horizontal = h;
		weight = 0;
		collides = false;
		
		barSize = horizontal ? 30 : 20;
		barOffsetX = horizontal ? 10 : 0;
		barOffsetY = horizontal ? -27 : -38;
		initLife( armored ? 50 : 15);
		showBar = true;
		
		openFrame = armored ? 3 : 1;
		closeFrame = armored ? 2 : 0;
		
		dsprite = game.char.get(horizontal ? "doorH" : "doorV");
		dsprite.setCenter(0,0);
		if( horizontal ) {
			dsprite.x = Std.int(-Const.GRID*0.5);
			dsprite.y = Std.int(-Const.GRID);
		}
		else {
			dsprite.x = Std.int(-8);
			dsprite.y = -36;
		}
		sprite.addChild(dsprite);
		
		icon = game.char.get("icon", 1);
		icon.setCenter(0.5,0.5);
		sprite.addChild(icon);
		icon.blendMode = flash.display.BlendMode.ADD;
		icon.alpha = 0.8;
		if( horizontal ) {
			icon.x = -20;
			icon.y = 8;
		}
		else {
			icon.y = -35;
		}
		
		if( horizontal ) {
			roomId1 = game.currentLevel.getRoomId(cx,cy-1);
			roomId2 = game.currentLevel.getRoomId(cx,cy+1);
			for(dx in 0...2)
				for(dy in 0...4)
					FAST_ACCESS[cx+dx][cy-1+dy] = this;
		}
		else {
			roomId1 = game.currentLevel.getRoomId(cx-1,cy);
			roomId2 = game.currentLevel.getRoomId(cx+1,cy);
			for(dx in 0...3)
				for(dy in 0...2)
					FAST_ACCESS[cx-1+dx][cy+dy] = this;
			FAST_ACCESS[cx][cy-1] = this;
			FAST_ACCESS[cx][cy-2] = this;
		}
		//if( roomId1<0 || roomId2<0 )
			//throw "Door has invalid roomIds ("+roomId1+","+roomId2+")";
		if( !ROOM_ACCESS.exists(roomId1) )
			ROOM_ACCESS.set(roomId1, new Array());
		ROOM_ACCESS.get(roomId1).push(this);
		if( !ROOM_ACCESS.exists(roomId2) )
			ROOM_ACCESS.set(roomId2, new Array());
		ROOM_ACCESS.get(roomId2).push(this);
			
		set(true);
		cd.set("shield", 30);
	}
	
	public static inline function getDoors(r) {
		return ROOM_ACCESS.exists(r) ? ROOM_ACCESS.get(r) : [];
	}
	
	public static function getBetween(e:Entity, r1:Int,r2:Int) {
		var a = [];
		if( ROOM_ACCESS.get(r1)==null || ROOM_ACCESS.get(r2)==null ) {
			trace(e+" "+r1+","+r2+" > "+ROOM_ACCESS.get(r1));
			return a;
		}
		for(d in ROOM_ACCESS.get(r1)) // TODO : BUG null ?
			if( d.inRoom(r2) )
				a.push(d);
		return a;
	}
	
	public inline function inRoom(r) {
		return roomId1==r || roomId2==r;
	}
	public inline function getOtherRoom(r) {
		return roomId1==r ? roomId2 : roomId1;
	}
	
	public function getPointInRoom(r) {
		if( horizontal ) {
			if( game.currentLevel.getRoomId(cx,cy-1)==r )
				return {cx:cx, cy:cy-1};
			else
				return {cx:cx, cy:cy+1};
		}
		else {
			if( game.currentLevel.getRoomId(cx-1,cy)==r )
				return {cx:cx-1, cy:cy};
			else
				return {cx:cx+1, cy:cy};
		}
	}
	
	public function getPointNotInRoom(r) {
		if( horizontal ) {
			if( game.currentLevel.getRoomId(cx,cy-1)==r )
				return {cx:cx, cy:cy+1};
			else
				return {cx:cx, cy:cy-1};
		}
		else {
			if( game.currentLevel.getRoomId(cx-1,cy)==r )
				return {cx:cx+1, cy:cy};
			else
				return {cx:cx-1, cy:cy};
		}
	}
	
	public function toString() {
		return "Door"+(broken?"(broken)":"")+(locked?"(LOCKED)":"")+"["+roomId1+"<->"+roomId2+"]";
	}
	
	public static function resetFastAccess() {
		FAST_ACCESS = [];
		for(x in 0...mode.Play.ME.currentLevel.wid)
			FAST_ACCESS[x] = new Array();
	}
	
	override public function detach() {
		super.detach();
		ALL.remove(this);
	}
	
	override public function destroy() {
		super.destroy();
		
		set(false);
		
		ROOM_ACCESS.get(roomId1).remove(this);
		ROOM_ACCESS.get(roomId2).remove(this);
		
		if( horizontal ) {
			for(dx in 0...2)
				for(dy in 0...4)
					FAST_ACCESS[cx+dx][cy-1+dy] = null;
		}
		else {
			for(dx in 0...3)
				for(dy in 0...2)
					FAST_ACCESS[cx-1+dx][cy+dy] = null;
			FAST_ACCESS[cx][cy-1] = null;
			FAST_ACCESS[cx][cy-2] = null;
		}
	}
	
	public function canBeReachedBy(e:Entity) {
		return
			if( horizontal )
				e.cx>=cx-1 && e.cx<=cx+2 && e.cy>=cy-2 && e.cy<=cy+3;
			else
				e.cx>=cx-2 && e.cx<=cx+2 && e.cy>=cy-1 && e.cy<=cy+2;
	}
	
	public inline function isOverCase(ecx,ecy) {
		return
			if( horizontal )
				ecx>=cx && ecx<=cx+1 && ecy==cy+1;
			else
				ecx==cx && ecy>=cy-2 && ecy<=cy+1;
	}
	
	public override function hit(d) {
		if( !broken && !locked )
			super.hit(d);
	}
	
	public override function onDie() {
		set(false);
		broken = true;
		sprite.visible = false;
		play3dSound( S.BANK.doorExplode() );
		if( horizontal )
			fx.doorExplosion(xx+Const.GRID*0.5, yy+Const.GRID*1.25);
		else
			fx.doorExplosion(xx+Const.GRID*0.25, yy+Const.GRID*1);
		
		var s = game.char.get("brokenDoor"+(horizontal?"H":"V"), armored ? 1 : 0);
		s.setCenter(0,0);
		if( horizontal ) {
			s.x = xx-10;
			s.y = yy-15;
		}
		else {
			s.x = xx-35;
			s.y = yy-36;
		}
		game.currentLevel.ground.bitmapData.draw(s, s.transform.matrix);
		game.currentLevel.walls.bitmapData.draw(s, s.transform.matrix);
	}
	
	public function repair() {
		initLife(maxLife);
		broken = false;
		sprite.visible = true;
		set(true);
	}
	
	public inline function toggle() {
		if( !cd.has("toggle") ) {
			set(!closed);
			cd.set("toggle", 10);
		}
	}
	
	public inline function squish(e:Entity) {
		if( !e.isNeutral() ) {
			hit(1);
			e.hit(3);
			fx.hit(e.xx, e.yy-5, 0xFFAC00);
		}
	}
	
	public inline function isClosed() {
		return closed && !broken;
	}
	public inline function isOpen() {
		return !closed || broken;
	}
	
	public function forceOpen() {
		set(false);
		icon.visible = true;
	}
	
	public function set(cl:Bool) {
		if( killed || broken )
			return;
		
		if( locked )
			return;
			
		icon.visible = false;
		
		if( closed==cl )
			return;
		
		closed = cl;
		showBar = closed;
		
		var prefix = armored ? "metal" : "wood";
		var suffix = horizontal ? "H" : "V";
		if( closed )
			dsprite.playAnim(prefix+"Close"+suffix, 1);
		else
			dsprite.playAnim(prefix+"Open"+suffix, 1);
		zpriority = closed ? 20 : -999;
		
		if( !broken )
			if( closed )
				play3dSound( S.BANK.doorClose(), 0.25 );
			else
				play3dSound( S.BANK.doorOpen(), 0.5 );
		
		game.zsort();
		
		if( horizontal ) {
			for(x in cx...cx+2)
				for(y in cy...cy+2)
					game.currentLevel.setSoftCollision(x,y, closed);
		}
		else {
			for(y in cy...cy+2)
				game.currentLevel.setSoftCollision(cx,y, closed);
		}
		
		// Vire tout le monde dans le passage
		if( closed )
			for(e in Entity.ALL)
				if( e!=this && isOverCase(e.cx, e.cy) ) {
					if( horizontal ) {
						squish(e);
						if( e.yr<0.5 )
							e.cy--;
						else
							e.cy++;
					}
					else {
						squish(e);
						if( e.xr<0.5 )
							e.cx--;
						else
							e.cx++;
					}
				}
	}
	
	override public function update() {
		super.update();
		sprite.alpha = 1;
		sprite.visible = onScreen && !broken;
	}
}