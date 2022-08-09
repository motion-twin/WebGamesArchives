package fight.skills;
import Fight;
import fight.Manager;
import fight.Fighter;

class EnvSkill
{
	inline static var MIN_ELEMENT = 10;
	inline static var TIMEOUT = 10 * Manager.TIMECOEF;

	public var playing(default, null) : Bool;
	public var f(default, null) : Fighter;
	var m : Manager;
	var frame : Int;
	var turns : Int;
	var mlist:Array<Fighter>;
	public var timeout : Int;
	
	public function new( f : Fighter, m : Manager ) {
		this.f = f;
		this.m = m;
		//
		mlist = [];
		turns = 3;
		playing = false;
	}
	
	public function init() {
		playing = true;
		timeout = TIMEOUT;
		m.effect( _SFEnv7(getFrame(), false) );
		var me = this;
		f.onKill.add( function() {
			me.cancel();
			return true;
		});
		m.onNextTurn.add( function(f2) {
			if( me.playing && f2 == me.f )
				me.turns --;
		});
		execute();
	}

	public function execute() {
		if( !playing ) return;
		//
		var tl = new Array();
		for( l in m.side(!f.side) )
			if( l != null && l.life > 0 && l.elements[getElement()] < MIN_ELEMENT && !Lambda.has(mlist,l) && !l.isBoss() )
				tl.push(l);
				
		for( l in m.side(f.side) )
			if(  l != null && l.life > 0 && l.elements[getElement()] < MIN_ELEMENT && !Lambda.has(mlist,l) && !l.isBoss() )
				tl.push(l);
		//
		apply(tl);
		//
		if( turns == 0 ) {
			cancel();
		}
	}

	public function cancel() {
		if( playing ) {
			m.effect( _SFEnv7(getFrame(), true) );
			playing = false;
			m.setEnv(null);
			m = null;
			f = null;
			mlist = null;
		}
	}
	
	public function getCaster():Fighter {
		return this.f;
	}
	
	/*********************************
	 *         TO OVERRIDE
	 *********************************/
		
	function getFrame():Int {
		throw "frame muse be defined for environment skill";
		return 0;
	}
	function getElement():Int {
		throw "element muse be defined for environment skill";
		return 0;
	}
	function apply(a:Array<Fighter>) {
		throw "apply should be overriden in child EnvSkill";
	}
}
