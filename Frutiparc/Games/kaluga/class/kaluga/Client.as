/*
import mb2.Manager;
import mb2.Const;
import mb2.Sound;
import mb2.Prefs;
*/
import frusion.gameclient.GameClient;

class kaluga.Client extends GameClient {//}

	var lockList:Array;
	
	var cid:Number;
	var mc;
	//var fcard : mb2.Card;
	var mng:kaluga.Manager
	
	//*
	static var STANDALONE = false;
	/*///*
		static var STANDALONE = true;
	//*/
	
	
	

	function Client() {
		super();
		//_root._alpha = 50
		this.lockList = new Array();
		
		function gfi(fname) {
			return { name : fname, size : 0 }; 
		};
		function f_true() {
			return true;
		};
		
		if( STANDALONE ) {
			this.getFileInfos = gfi;
			//this.isBlack = f_true;
			this.isWhite = f_true;
		}
	}

	public function isAutoDestruct() {
		return isBlack() || isGrey() || isRed();
	}

	public function serviceConnect() {
		// super.serviceConnect(); si je le laisse ça là, ça me pete ma page... -_-
		if( STANDALONE ) {
			this.slots = [];
			this.cid = setInterval(this,"onServiceConnect",1000)
			//this.onServiceConnect();
			return;
		}
		super.serviceConnect();
	}

	public function startGame() {
		//_root.test+="[Client] startGame()\n"
		if( STANDALONE ) {
			//onStartGame();
			this.cid = setInterval(this,"onStartGame",1000)
			return;
		}
		super.startGame()
	}

	public function endGame() {
		super.endGame();
		if( STANDALONE )
			onEndGame("");
	}
	
	public function saveScore(score,data) {
		//_root.test+="[Client] saveScore()\n"
		if( STANDALONE ) {
			var r = { rankingScore : score, rankingData : data, oldScore : undefined, oldPos : undefined, bestScorePos : undefined };
			ranking = r;
			if( isWhite() )
				onSaveScoreFruticard();
			onSaveScore();
			return;
		}
		super.saveScore(score,data);
		
	}
	
	/// -------------- CALLBACKS ------------------------------------

	public function onStartGame() {
		if(STANDALONE)clearInterval(this.cid);
		//_root.test+="[CLIENT]onStartGame()\n"
		mng.started();
	}

	public function onServiceConnect() {
		
		this.mng.card = this.slots[0]
		this.mng.pref = this.slots[1]
		this.mng.connected();
		
		// DEBUG
		if( STANDALONE ) {
			clearInterval(this.cid)
		}
		/*
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
		*/
	}

	public function onSaveScore() {		
		//_root.test+="[Client] onSaveScore()\n"
		mng.scoreSaved(ranking.rankingScore,ranking.oldScore,ranking.oldPos,ranking.bestScorePos);
	}

	public function onGameReset() {
		_root.test+="[CLIENT]onGameReset()\n"
		if( isWhite() ) {
			this.mng.backToMenu();
			//Sound.stopMix();
			//mng.forceNextMode(0);
		} else {
			closeService();
		}
	}
	
	public function onPause(){
		_root.test+="[CLIENT]onPause()\n"
		//this.mng.setPause(true)
		this.mng.current.onPause()
	}
	
	public function saveSlot(n,data){
		//_root.test+="[Client] saveSlot("+n+","+data+") \n"
		if(this.lockList[n]){
			//_rootp.test+="LOCK!\n"
			return;
		}
		super.saveSlot(n,data)
		
	}
	
	/*
	public function getFileInfos(f){
		//_root._alpha = 50
		if( STANDALONE ) {
			//_root.test+="map/"+f+"\n"
			return { name : "map/"+f, size : 0 };
		}
		//_root.test+="not STANDALONE\n"
		return super.getFileInfos(f);
	}
	//*/

	
//{
}


