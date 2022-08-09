package fight.skills;

import Fight;
import fight.Manager;
import fight.Fighter;

class Amazonie extends EnvSkill
{
	override function getFrame(){
		return 3;
	}
	override function getElement():Int {
		return Data.WOOD;
	}
	
	override function apply(fighters:Array<Fighter>) {
		for( l in fighters ) {
			mlist.push(l);
			m.status(l,_SSleep, DInfinite);
		}
	}

	override public function cancel() {
		if(  mlist != null )
			for ( l in mlist )
				m.cancelStatus(l, _SSleep);	
		super.cancel();
	}
}