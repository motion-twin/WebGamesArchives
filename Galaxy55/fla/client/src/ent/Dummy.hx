package ent;

//potentially lootable funnily spinning entity
class Dummy extends Entity {

	public var id : Null<Int>;
	public var loot : Protocol.LootContent;
	
	public var block : Block;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var time : Float;
	public var tlight : Float;
	public var light : Float;
	public var delay : Float;
	public var active : Bool;
	public var fixed : Bool;
	
	public function new(x,y,z,b) {
		super();
		this.x = x;
		this.y = y;
		this.z = z;
		this.vx = (Std.random(2)*2-1) * Math.random()*0.04;
		this.vy = (Std.random(2)*2-1) * Math.random()*0.04;
		this.vz = 0;
		this.block = b;
		time = game.getDefaultDummyTime();
		active = true;
		light = 0;
		delay = 0;
		updateLight();
		light = tlight;
	}
	
	public function feed(id,inf:Protocol.LootContent)
	{
		this.id =  id;
		this.loot = inf;
	}
	
	public dynamic function get() {
		return true;
	}
	
	public dynamic function onActive() {
	}
	
	public dynamic function canGet() {
		return game.interf.canAddBlock(block);
	}
	
	function updateLight() {
		tlight = game.level.getLightAt(x, y, z, game.planet.defaultLight);
		light = light * 0.95 + tlight * 0.05;
	}

	function updatePos(dt:Float) {
		if( !collide(x, y, z - 0.01) )
			vz -= 0.01 * dt;
		else {
			if( !active ) {
				active = true;
				onActive();
			}
			if( vz < 0 ) vz *= Math.pow(0.3, dt);
			var r = 0;
			while( r < 20 && (collide(x, y, z - 0.01) || collide(x, y, z + 0.3)) ) {
				z += 0.01 * dt;
				r++;
			}
		}
		x += vx * dt;
		y += vy * dt;
		
		// mini collision check
		if( collide(x, y, z) ) {
			x -= vx * dt;
			y -= vy * dt;
			vx *= -0.6;
			vy *= -0.6;
		}
		
		z += vz * dt;
		var p = Math.pow(0.93, dt);
		vx *= p;
		vy *= p;
		vz *= p;
	}
	
	public function update(dt:Float) {
		time -= dt / 30;
		
		if( !fixed )
			updatePos(dt);
		
		updateLight();

		var dx = realDist(game.hero.x - x);
		var dy = realDist(game.hero.y - y);

		var h = game.hero.viewZ * 0.5;
		
		var dz = (game.hero.z + h) - z;
		if( Math.abs(dz) > h ) {
			if( dz < 0 ) dz += h else dz -= h;
		} else
			dz = 0;
		
		var d = Math.sqrt(dx * dx + dy * dy + dz * dz);
		if( delay > 0 )
			delay -= dt;
		else if( d < 1.5 && active && canGet() ) {
			var s = 0.2 * dt / (d * d);
			x += dx * s;
			y += dy * s;
			z += dz * s;
			if( d < 0.4 )
				return get();
		}
		return time > 0;
	}
	
}