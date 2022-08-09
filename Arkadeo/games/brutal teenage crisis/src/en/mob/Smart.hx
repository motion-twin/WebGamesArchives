package en.mob;

class Smart extends Walker {

	public function new(x,y) {
		super(x,y);

		type = MT_Smart;
		animBaseKey = "mob_a";
		speed*=0.37;
		radius = 13;
		initLife(3);
		decideDir();
	}

	override function resetIgnoreLadder() {
		cd.unset("ignoreLadder");
	}

	function decideDir() {
		// Left check
		var leftDist = 0;
		var x = cx;
		var gap = 0;
		while( x>=0 && !mode.level.hasLadder(x,cy) ) {
			if( !mode.level.hasCollision(x,cy+1) ) {
				if( ++gap>2 ) {
					leftDist = 999;
					break;
				}
			}
			else
				gap = 0;
			leftDist++;
			x--;
		}
		if( x<0 )
			leftDist = 999;

		// Right check
		var rightDist = 0;
		var x = cx;
		var gap = 0;
		while( x<Const.LWID && !mode.level.hasLadder(x,cy) ) {
			if( !mode.level.hasCollision(x,cy+1) ) {
				if( ++gap>2 ) {
					rightDist = 999;
					break;
				}
			}
			else
				gap = 0;
			rightDist++;
			x++;
		}
		if( x>=Const.LWID )
			rightDist = 999;

		if( mt.MLib.iabs(leftDist-rightDist)<=2 )
			dir = rseed.sign();
		else
			dir = leftDist<rightDist ? -1 : 1;
	}

	override function onBeginFloor() {
		super.onBeginFloor();
		decideDir();
	}

	override function loot() {
		dropGold(10);
	}
}

