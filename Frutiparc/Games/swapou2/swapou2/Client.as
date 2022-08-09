import swapou2.Manager;
import swapou2.Data;
import swapou2.Sounds;
import frusion.gameclient.GameClient;

class swapou2.Client extends GameClient {

	var mc;
	public var nswaps;

	public static var STANDALONE = false;

	function Client() {
		super();
		function gfi(fname) {
			return { name : fname, size : 0 };
		};
		function f_true() {
			return true;
		};
		if( STANDALONE ) {
			this.slots = [];
			this.getFileInfos = gfi;
			this.isWhite = f_true;
		}
	}

	public function serviceConnect() {
		super.serviceConnect();
		if( STANDALONE )
			onServiceConnect();
	}

	public function startGame() {
		super.startGame();
		if( STANDALONE )
			onStartGame();		
	}

	public function savePrefs() {
		slots[1] = Std.cast({
			$sound : Sounds.soundEnabled(),
			$music : Sounds.musicEnabled(),
			$lod : Data.lod
		});
		saveSlot(1,undefined);
	}

	public function saveClassicScore(score) {
		var s = Std.cast(slots[0]);
		var old = s.$classic_record;
		if( score > old )
			s.$classic_record = score;
		s.$swap = nswaps;
		saveSlot(0,undefined);
		return old;
	}

	public function saveScore(score,data) {
		super.saveScore(score,data);
		if( STANDALONE ) {
			var r = { rankingScore : score, rankingData : data, oldPos : 56, bestScorePos : 13, bestScore : score, oldScore : score - 5 };
			ranking = r;
			onSaveScore();
		}
	}

	public function unlockCharacter(ch) {
		var s = Std.cast(slots[0]);
		if( !s.$chars[ch] ) {
			s.$chars[ch] = true;
			saveSlot(0,undefined);
		}
	}

	/// -------------- CALLBACKS ------------------------------------

	public function doEndGame(score) {		
		if( isWhite() ) {
			var record = Std.cast(slots[0]).$record;
			var old_record = record;
			var s = Std.cast(slots[0]);
			if( score > record ) {
				record = score;
				s.$record = record;
			}
			s.$swap = nswaps;
			saveSlot(0,undefined);
			Manager.scoreSaved(score,old_record,0,0);
		}
		else			
			saveScore(score,string(Data.players[0]));		
	}

	public function onStartGame() {
		Manager.started();
	}

	public function onServiceConnect() {
		var k = Std.cast(slots[1]);
		if( k == undefined ) {
			k = { $sound : true, $music : true, $lod : Data.HIGH }; // DEFAULT PREFS
			//k = { $sound : false, $music : false, $lod : Data.HIGH }; // xxx
			slots[1] = Std.cast(k);
		}
		// LOAD PREFS
		Data.lod = k.$lod;
		Sounds.enableSoundMusic(k.$sound,k.$music);

		var s = Std.cast(slots[0]);
		if( s == undefined ) {
			s = { $chars : [true,true,false,false,false,false,false,false,false], $record : 0, $classic_record : 0, $swap : 0, $items : [] };
			// s = { $chars : [true,true,true,true,true,true,true,true,true], $record : 0, $classic_record : 0, $swap : 0, $items : [] }; // HACK
			if( isWhite() )
				Std.cast(s).$combos = [];
			slots[0] = Std.cast(s);
		}
		nswaps = s.$swap;
		if( nswaps == undefined )
			nswaps = 0;
		Data.chars = s.$chars;

		Manager.connected();
	}

	public function onSaveScore() {
		Manager.scoreSaved(ranking.rankingScore,ranking.oldScore,ranking.oldPos,ranking.bestScorePos);
	}

	public function onGameReset() {
		if( isWhite() || !gameRunning )
			Manager.startMenu();
		else
			closeService();
	}

}