import mt.bumdum.Lib;
import Fighter;

class State {

	public var endCall:Void->Void;
	var castingWait:Bool;
	var coef:Float;
	var spc:Float;
	var timer:Float;
	var endTimer:Float;
	var casting:Array<Fighter>;
	public var tids:List<{t : Fighter, life : Int}>;

	public function new() {
		Main.me.states.push(this);
		coef = 0;
		spc = 0.1;
		castingWait = true;
	}
	
	public function toString() {
		return Type.getClassName( Type.getClass( this ) );
	}

	public function update() {
		if( castingWait ) {
			checkCasting();
			return;
		}
		coef = Num.mm(0, coef + spc * mt.Timer.tmod, 1);
		if(endTimer != null) {
			endTimer -= mt.Timer.tmod;
			if(endTimer <= 0) {
				endCall();
				endTimer = null;
			}
		}
	}

	// casting
	public function addActor(f:Fighter) {
		if( casting == null ) casting = [];
		casting.push(f);
		castingWait = true;
	}
	
	function checkCasting() {
		for( f in casting ) {
			if( !f.setFocus(this) ) {
				return;
			}
		}
		castingWait = false;
		init();
	}
	
	function releaseCasting(?n) {
		for( f in casting ) {
			f.unfocus();
			if( n != null ) f.lockTimer = n;
		}
		casting = null;
	}

	function init() {
		//trace("init " + Type.getClassName( Type.getClass( this ) ) );
	}

	public function end() {
		//trace("end : "+toString());
		kill();
		endCall();
	}

	public function kill() {
		//trace("kill " + Type.getClassName( Type.getClass( this ) ) );
		Main.me.states.remove(this);
		if(casting != null && casting.length > 0) releaseCasting();
	}
}
