package game.viewer;

class Board {

	var js : haxe.remoting.Connection;
	public var currentRound : Null<Int>;
	public var currentAttacker : Null<Int>;

	public function new( jsConnect:haxe.remoting.Connection ){
		js = jsConnect;
		reset();
	}

	function reset(){
		currentAttacker = null;
		currentRound = null;
		js.listener.board_reset.call([]);
	}

	function setCurrentRound( newAttacker:Null<Int>, newRound:Null<Int> ){
		js.listener.board_setCurrentRound.call([newAttacker, newRound]);
		currentAttacker = newAttacker;
		currentRound = newRound;
	}

	function incScore(){
		js.listener.board_score.call([]);
	}

	function end(){
		js.listener.board_end.call([]);
	}

	function koBonus(team){
		js.listener.board_ko_bonus.call([team, game.Resolver.FORFAIT_POINTS]);
	}

	public function onEvent( e:game.Event ){
		switch (e){
			case DefStart:
				reset();

			case RoundStart:
				var newRound = if (currentRound == null) 0 else currentRound+1;
				setCurrentRound(null, newRound);

			case PhaseStart(team,r,p):
				setCurrentRound(team.id, currentRound);

			case TooMuchKo(team):
				koBonus(1-team.id);

			case AttScore:
				incScore();

			case Draw:
				end();

			case Winner(idx):
				end();

			default:
		}
	}
}