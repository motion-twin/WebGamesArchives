package fight.skills;

import fight.Manager;
import fight.Fighter;

class Cendres extends EnvSkill
{
	var mEvts:Array < Array < Event < Void->Void, EventNotify >>> ;
	var mAtts:Array < Array < Event < Void->Void, data.Skill >>> ;
		
	public function new(f, m) {
		super(f, m);
		mEvts = new Array();
		mAtts = new Array();
	}
	
	override function getFrame(){
		return 1;
	}
	
	override function getElement():Int {
		return Data.FIRE;
	}
	
	override function apply(fighters:Array<Fighter>) {
		for( l in fighters ) {
			mlist.push(l);
		}
		
		for( i in 0...mlist.length ) {
			if( mEvts[i] == null ) mEvts[i] = [];
			if( mAtts[i] == null ) mAtts[i] = [];
			//
			if( mlist[i].events.length > 0 ) {
				
				var ev = new Array();
				for( e in mlist[i].events )
					switch( e.notify ) {
					case NSkill(_): mEvts[i].push(e);
					case NObject(_): ev.push(e);
					}
				mlist[i].events = ev;
			}
			//
			if( mlist[i].attacks.length > 0 ) {
				mAtts[i] = mAtts[i].concat( mlist[i].attacks );
			}
			mlist[i].attacks = [];
		}
	}

	override public function cancel() {
		if( mlist != null && mEvts != null && mAtts != null ) {
			for ( i in 0...mlist.length ) {
				mlist[i].events = mlist[i].events.concat( mEvts[i] );
				mlist[i].attacks = mlist[i].attacks.concat( mAtts[i] );
			}
			mEvts = null;
			mAtts = null;
		}
		super.cancel();
	}
}
