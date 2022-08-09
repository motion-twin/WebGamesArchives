package en;

import com.gen.LevelGenerator;

class Mob extends Entity {
	static var JUMP_DX = 0.03;
	public static var ALL : Array<Mob> = [];

	public var type			: Null<MobType>;
	var floor				: Int;
	public var slamImmune	: Bool;
	var stunDir				: Int;
	public var canBeHit		: Bool;
	public var countAsMob	: Bool;

	public function new(x,y) {
		super();
		ALL.push(this);
		setPos(x,y);

		countAsMob = true;
		type = null;
		canBeHit = true;
		stunDir = 1;
		initLife(3);
		stable = true;
		slamImmune = false;
		floor = -1;
		dir = rseed.sign();

		mode.dm.add(sprite, Const.DP_MOB);
	}

	public function onHeroAttack() {
	}


	function onBeginFloor() {
		floor = getFloor();
	}

	override function setPos(x,y) {
		super.setPos(x,y);
		floor = -1;
		stable = false;
	}

	override function ignoreFloors(n) {
		if( canBeHit )
			super.ignoreFloors(n);
	}

	override public function hit(ox,oy,d) {
		if( !canBeHit )
			return;

		super.hit(ox,oy, d);

		stunDir = ox>xx ? 1 : -1;
	}


	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	function dropGold(n:Int) {
		if( !mode.isLeague() )
			return;

		for(i in 0...n) {
			var e = new en.it.Gold(cx,cy, getFloor());
			e.push( i>=8 ? 3 : (i>=4 ? 2 : 1) );
		}
	}

	override function onReachBottom() {
		super.onReachBottom();

		hit(xx,yy+10, 9999);
		fx.bottomDeathMob(xx);
		//trace(this);
	}

	function loot() {
	}

	override function onDie() {
		super.onDie();
		fx.explosion(xx,yy);
		destroy();
		loot();
		canBeHit = true;
		if( mode.isProgression() )
			mode.asProgression().onMobKill();
	}

	override function onLand() {
		super.onLand();

		if( getFloor()!=floor )
			onBeginFloor();
	}



	override function update() {
		super.update();

		if( cd.has("stun") )
			sprite.scaleX = stunDir;

		#if debug
		sprite.graphics.clear();
		sprite.graphics.lineStyle(1, 0xFFFF00, 0.5);
		sprite.graphics.drawCircle(0,-radius, radius);
		#end
	}
}

