import snake3.Manager;
import snake3.Const;
import snake3.Encyclo;
import frusion.gameclient.GameClient;

class snake3.SnakeClient extends GameClient {

	var mc;

	public static var STANDALONE = false;

	function SnakeClient() {
		super();
		function gfi(fname) {
			return { name : fname, size : 0 };
		};
		function f_true() {
			return true;
		};
		if( STANDALONE ) {
			this.getFileInfos = gfi;
			this.isBlack = f_true;
		}
	}

	public function serviceConnect() {
		super.serviceConnect();
		if( STANDALONE ) {
			slots = Std.cast([{ $fruits : [0,12,3,45,4] }]);
			onServiceConnect();
		}
	}

	public function startGame() {
		super.startGame();
		if( STANDALONE )
			onStartGame();
	}

	public function savePrefs() {
		slots[1] = Std.cast({
			$music : Manager.music,
			$sounds : Manager.sounds,
			$keys : Manager.keys.config
		});
		saveSlot(1,undefined);
	}

	public function saveScore(score,data) {
		super.saveScore(score,data);
		if( STANDALONE ) {
			ranking = Std.cast({ rankingScore : score, rankingData : data, oldScore : undefined, oldPos : undefined, bestScorePos : undefined });
			if( isWhite() )
				onSaveScoreFruticard();
			onSaveScore();
		}
	}

	/// -------------- CALLBACKS ------------------------------------

	public function onStartGame() {
		Manager.startGame();
	}

	public function onServiceConnect() {
		var s0 = Std.cast(slots[0]);
		var s = s0.$fruits;
		if( s == undefined && isWhite() )
			s = [];
		Encyclo.fruits = s;

		var k = Std.cast(slots[1]);
		if( k == undefined )
			k = { $keys : Const.DEFAULT_KEYS, $music : true, $sounds : true };
		Manager.music = !k.$music;
		Manager.sounds = !k.$sounds;
		Manager.toggleMusic();
		Manager.toggleSounds();
		Manager.keys.config = k.$keys;
		Manager.connected();
	}

	public function onSaveScore() {

		var score = ranking.rankingScore;		
		var record = Std.cast(slots[0]).$record;
		if( record == undefined )
			record = 0;
		var old_record = record;
		if( score > record )
			record = score;

		if( Encyclo.fruits != undefined ) {
			slots[0] = Std.cast({ $fruits : Encyclo.fruits, $record : record });
			saveSlot(0,undefined);
		}

		if( ranking.oldScore == undefined )
			ranking.oldScore = old_record;

		Manager.scoreSaved(ranking.rankingScore,ranking.oldScore,ranking.oldPos,ranking.bestScorePos);
	}

	public function onGameReset() {
		super.onGameReset();
		if( isWhite() || !gameRunning )
			Manager.forceNextMode(0);
	}

}