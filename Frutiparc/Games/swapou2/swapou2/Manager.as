import swapou2.RotatorButton;
import swapou2.RotatorFace;
import swapou2.Face;
import swapou2.SimpleButton;
import swapou2.Fruit;
import swapou2.Sounds;
import swapou2.Data;
import asml.FPS;

class swapou2.Manager {

	static var mc = null;
	static var mode = null;
	public static var start_menu = true;
	public static var client : swapou2.Client = null;

	static function init( root_mc : MovieClip ) {
		mc = root_mc;
		registerSymphony();
		Sounds.init(root_mc);
		Sounds.enableSoundMusic(false,false);
		start_menu = true;
		startMenu();
		start_menu = false;
		Std.cast(mode).netLock();
		client = new swapou2.Client();
		client.serviceConnect();
	}

	static function main() {
		// la boucle qui fait rammer
		// for(var j = 0; j<50000;j++) {  }	

		Sounds.main();
		mode.main();
	}

	static function startChallenge() {
		Std.cast(mode).netLock();
		client.startGame();
	}

	static function startDuel() {
		mode.destroy();
		mode = new swapou2.Duel(mc);
	}

	static function startHistoryMap() {
		mode.destroy();
		mode = new swapou2.HistoMap(mc);
	}

	static function startHistory() {
		startDuel();
	}

	static function startClassic() {
		mode.destroy();
		mode = new swapou2.Classic(mc);
	}

	static function startMenu() {
		mode.destroy();
		Data.histoPhase = 0;		
		mode = new swapou2.Menu(mc);
	}

	static function error() {
		mode.destroy();
		mode = null; // TODO : run mode error
	}

	static function started() {
		mode.destroy();
		mode = new swapou2.Challenge(mc);
	}

	static function connected() {
		Std.cast(mode).netUnlock();
	}

	static function endGame(wins) {
		if( Data.gameMode == Data.HISTORY ) {			
			if( wins ) {
				client.unlockCharacter(Data.players[1]);
				Data.histoPhase++;
				startHistoryMap();		
			} else {
				var m = new swapou2.Menu(mc);
				m.showVersus(false,startMenu);
				mode.destroy();
				mode = Std.cast(m);
			}
			return;
		}
		if( client.isWhite() )
			startMenu();
		else		
			client.closeService();
	}

	static function gameOver(score) {
		var wins = (score != 0);
		var g = new swapou2.GameOver(mc,mode);
		mode = Std.cast(g);
		switch( Data.gameMode ) {
		case Data.CLASSIC:
			var oldScore = client.saveClassicScore(score);
			g.scoreSaved(score,oldScore,0,0);
			break;
		case Data.CHALLENGE:
			g.connecting();			
			g.netLock();
			client.doEndGame(score);
			break;
		case Data.DUEL:
			g.wins(wins);
			break;
		case Data.HISTORY:
			var pid = Data.players[1];
			if( wins && !Data.chars[pid] )
				g.unlockCharacter(pid);
			else
				g.wins(wins);
			break;
		}
		return g;
	}

	static function scoreSaved(score,oldScore,oldRank,newRank) {		
		Std.cast(mode).scoreSaved(score,oldScore,oldRank,newRank);
	}

	static function registerSymphony() {
		registerClass("swapou2_faceFull",Face);
		registerClass("swapou2_menuButton",RotatorButton);
		registerClass("swapou2_simpleButton",SimpleButton);
		registerClass("swapou2_faceButton",RotatorFace);
		registerClass("swapou2_fruit",Fruit);
	}

}