package game.viewer;

class Round {
	public var text : String;
	var batterIndex : Int;
	var strikes : Int;
	var attempt : Int;
	var faults : Int;
	var bats : Int;

	public function new(){
		reset();
	}

	public function reset(){
		batterIndex = 0;
		attempt = 0;
		strikes = 0;
		faults = 0;
		bats = 0;
		render();
	}

	function render(){
		text = "BAT "+batterIndex+"/3 -- ATTEMPT "+attempt+"/3 -- STRIKES "+strikes+"/3 -- FAULTS "+faults+"/3  -- TOT_BATS="+bats;
	}

	public function onEvent( e:game.Event ){
		switch (e){
			case DefStart:
				reset();

			case RoundStart:
				batterIndex = 0;
				attempt = 0;
				strikes = 0;
				faults = 0;

			case PhaseStart(x,r,p):
				batterIndex = 0;
				attempt = 0;
				strikes = 0;
				faults = 0;

			case NextBattler(x):
				batterIndex++;
				attempt = 0;
				faults = 0;
				strikes = 0;

			case NextAttempt(r,p,b,a):
				attempt++;
				faults = 0;
				strikes = 0;

			case ThrowFault:
				faults++;

			case Strike:
				strikes++;

			case PicoStar,AttFailed:
				bats++;

			case PicoPaf(id):
				bats++;

			default:

		}
		render();
	}
}