package en.mob;

import mt.MLib;

class Lock extends en.Mob {
	public static var ACTIVATION_ORDER : Array<Lock> = [];
	public static var ALL : Array<Lock> = [];

	var lockId			: Int;

	private function new(x,y) {
		super(x,y);

		lockId = ALL.length;

		countAsMob = false;
		canBeHit = false;
		repelOnHit = false;

		slamImmune = true;
		speed = 0;
		weight = 999;
		radius = 8;
		barY -= 15;
		ALL.push(this);

		sprite.visible = false;

		initLife(10);
	}

	public static function prepareActionOrder() {
		ACTIVATION_ORDER = [];
		for(t in Mode.ME.level.lgen.targets)
			for(e in ALL)
				if( e.cx==t.cx && e.cy==t.cy ) {
					ACTIVATION_ORDER.push(e);
					break;
				}
	}


	public static function activateNext() {
		// Last one?
		if( ACTIVATION_ORDER.length==0 ) {
			var remain = getRemainings();
			if( remain.length==1 )
				Fx.ME.pop(remain[0].xx, remain[0].yy, Lang.LastLock);
			return;
		}

		ACTIVATION_ORDER.shift().activate();
	}

	public static function getRemainings() {
		return ALL.filter( function(e) return !e.isDead() );
	}

	public function activate() {
		canBeHit = true;
		sprite.visible = true;
		sprite.alpha = 1;
		fx.lockActivation(this);
	}


	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	override function onDie() {
		super.onDie();

		var remain = getRemainings().length;

		en.it.KPoint.spawn( remain<=2 );

		activateNext();
		fx.explosion(xx,yy, 2);

		if( remain==0 ) {
			fx.rocks();
			mode.asProgression().unlockExit();
		}
	}

}


