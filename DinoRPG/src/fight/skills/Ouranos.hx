package fight.skills;

import Fight;
import fight.Manager;
import fight.Fighter;

class Ouranos extends EnvSkill
{
	override function getFrame(){
		return 5;
	}
	override function getElement():Int {
		return Data.AIR;
	}
	
	override function apply(fighters:Array<Fighter>) {
		for( l in fighters ) {
			mlist.push(l);
			l.timeMultiplier *= 2;
		}
	}

	override public function cancel() {
		if( mlist != null ) {
			for (l in mlist ) {
				l.timeMultiplier *= .5;
			}
			mlist = null;
		}
		super.cancel();
	}
}