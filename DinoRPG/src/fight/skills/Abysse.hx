package fight.skills;

import fight.Manager;
import fight.Fighter;

class Abysse extends EnvSkill
{
	override function getFrame(){
		return 2;
	}
	
	override function getElement():Int {
		return Data.WATER;
	}
	
	override function apply(fighters:Array<Fighter>) {
		for( l in fighters ) {
			mlist.push(l);
		}
		for ( t in mlist ) {
			t.nextAssaultMultiplier = 0.75;
		}
	}

}