import mb2.Manager;
import mb2.Const;
import mb2.Sound;
import mb2.Prefs;
import frusion.gameclient.GameClient;

class mb2.Client extends GameClient {

	var mc;
	var fcard : mb2.Card;

	static var STANDALONE = true;

	function Client() {
		super();
		if( STANDALONE ) {
			this.getFileInfos = function(fname) {
				return { name : fname, size : 0 };
			};
			this.isBlack = function() {
				return true;
			};
		}
	}


	public function isChallengeDisc() {
		return isBlack() || isGrey();
	}

	public function serviceConnect() {
		super.serviceConnect();
		if( STANDALONE ) {
			slots = [];
			onServiceConnect();
		}
	}

	public function startGame() {
		super.startGame();
		if( STANDALONE ) {
			error = false;
			onStartGame("");
		}
	}

	public function endGame() {
		super.endGame();
		if( STANDALONE )
			onEndGame("");
	}

	public function savePrefs() {
		slots[1] = Std.cast({
			$music : Prefs.music_enabled,
			$sounds : Prefs.sound_enabled
		});
		saveSlot(1,undefined);
	}

	public function saveScore(score,data) {
		super.saveScore(score,data);
		if( STANDALONE ) {
			var r = { rankingScore : score, rankingData : data };
			ranking = r;
			onSaveScore();
		}
	}

	public function saveClassicScore(score) {
		var record = slots[0].$classic_score;
		if( score > record ) {
			record = score;
			slots[0].$classic_score = record;
			saveSlot(0,undefined);
		}
		return record;
	}

	/// -------------- CALLBACKS ------------------------------------

	public function onStartGame() {
		Manager.started();
	}

	public function onServiceConnect() {
		var k = slots[1];
		if( k == undefined ) {
			k = { $music : true, $sounds : true };
			slots[1] = k;
		}

		fcard = slots[0];
		if( fcard == undefined ) {
			fcard = new mb2.Card();
			slots[0] = fcard;
		}

		Prefs.challenge_mode_enabled = fcard.$challenge;
		Prefs.classic_mode_enabled = fcard.$classic;
		Prefs.courses = fcard.$courses;
		Prefs.dungeons = fcard.$dungeons;

		Prefs.music_enabled = !k.$music;
		Prefs.sound_enabled = !k.$sounds;
		Prefs.toggleMusic();
		Prefs.toggleSounds();
		Manager.connected();
	}

	public function onSaveScore() {
		Manager.scoreSaved(ranking.rankingScore,ranking.oldScore,ranking.oldPos,ranking.bestScorePos);
	}

	public function onGameReset() {
		if( isWhite() || !gameRunning ) {
			Sound.stopMix();
			Manager.forceNextMode(0);
		} else
			closeService();
	}

}
