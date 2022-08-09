package fight.skills;

import Fight;
import fight.Manager;
import fight.Fighter;

class StElme extends EnvSkill
{
	override function getFrame(){
		return 4;
	}
	
	override function getElement():Int {
		return Data.THUNDER;
	}
	
	override function apply(fighters:Array<Fighter>) {
		for( l in fighters ) {
			mlist.push(l);
		}
		for ( t in mlist )
			m.lost(t, _LSkull(1.0), Math.ceil(t.life * 0.05));
	}

}