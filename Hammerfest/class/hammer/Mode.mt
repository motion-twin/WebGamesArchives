class Mode
{

	var root			: MovieClip ;
	var mc				: MovieClip ;

	var xFriction		: float ;
	var yFriction		: float ;

	var manager			: GameManager ;
	var depthMan		: DepthManager ;
	var soundMan		: SoundManager;

	var fl_music		: bool;
	var currentTrack	: int;
	var fl_mute			: bool;

	var fl_lock			: bool;
	var fl_switch		: bool;
	var fl_hide			: bool;
	var fl_runAsChild	: bool;

	var cycle			: float ;
	var uniqId			: int ;

	var xOffset			: float ; // décalage du mc du jeu
	var yOffset			: float ;

	var _name			: String ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		manager = m ;
		root = manager.root ;
		mc = Std.createEmptyMC(root,manager.uniq++) ;
		depthMan = new DepthManager(mc) ;
		soundMan = manager.soundMan;

		lock() ;

		fl_switch		= false;
		fl_music		= false;
		fl_mute			= false;
		fl_runAsChild	=false;
		currentTrack	= null;
		xOffset			= 0 ;
		yOffset			= 0 ;
		uniqId			= 1 ;
		cycle			= 0 ;

		_name = "$abstractMode" ;
		show();
	}


	/*------------------------------------------------------------------------
	AFFICHE / MASQUE LE MC ROOT DU MODE
	------------------------------------------------------------------------*/
	function show() {
		mc._visible = true;
		fl_hide = false;
	}

	function hide() {
		mc._visible = false;
		fl_hide = true;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		mc._x = xOffset ;
		mc._y = yOffset ;
	}


	/*------------------------------------------------------------------------
	RENVOIE UN ID UNIQUE INCRÉMENTAL
	------------------------------------------------------------------------*/
	function getUniqId() : int {
		return uniqId++ ;
	}


	/*------------------------------------------------------------------------
	VERROUILLE / DÉVERROUILLE LE MODE
	------------------------------------------------------------------------*/
	function lock() {
		fl_lock = true ;
	}
	function unlock() {
		fl_lock = false ;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE NOM DU MODE
	------------------------------------------------------------------------*/
	function short() {
		return _name ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		depthMan.destroy() ;
		lock() ;
	}


	/*------------------------------------------------------------------------
	update des valeurs constantes diverses
	------------------------------------------------------------------------*/
	function updateConstants() {
		if (fl_lock) {
			return ;
		}

		// Variables
		xFriction = Math.pow(Data.FRICTION_X, Timer.tmod) ; // x
		yFriction = Math.pow(Data.FRICTION_Y, Timer.tmod) ; // y
		cycle += Timer.tmod ;
	}


	/*------------------------------------------------------------------------
	SAISIE DES CONTROLES DE DEBUG
	------------------------------------------------------------------------*/
	function getDebugControls() {
		// Clear debug
		if ( Key.isDown(Key.BACKSPACE) ) {
			Log.clear() ;
		}
	}

	function getControls() {
		// do nothing yet
	}


	/*------------------------------------------------------------------------
	EVENT: LE MODE EST MIS EN ATTENTE PAR LE MANAGER (MODE ENFANT LANCÉ)
	------------------------------------------------------------------------*/
	function onSleep() {
		// do nothing
	}

	function onWakeUp(modeName:String, data:'a) //'
	{
		// do nothing
	}

	/*------------------------------------------------------------------------
	MUSICS MANAGEMENT
	------------------------------------------------------------------------*/
	function playMusic(id) {
		if ( !GameManager.CONFIG.hasMusic() ) {
			return;
		}
		playMusicAt(id,0);
	}

	function playMusicAt(id,pos) {
		if ( !GameManager.CONFIG.hasMusic() ) {
			return;
		}
		if ( fl_music ) {
			stopMusic();
		}
		currentTrack = id;
		manager.musics[currentTrack].start(pos/1000,99999);
		fl_music = true;
		if ( fl_mute ) {
			setMusicVolume(0);
		}
		else {
			setMusicVolume(1);
		}
	}

	function stopMusic() {
		if ( !GameManager.CONFIG.hasMusic() ) {
			return;
		}

		manager.musics[currentTrack].stop();
		fl_music = false;
	}

	function setMusicVolume(n:float) {
		if ( !fl_music || !GameManager.CONFIG.hasMusic() ) {
			return;
		}
		n *= GameManager.CONFIG.musicVolume*100;
		manager.musics[currentTrack].setVolume( Math.round(n) );

	}


	/*------------------------------------------------------------------------
	FIN DU MODE DE JEU
	------------------------------------------------------------------------*/
	function endMode() {
		stopMusic();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		// Debug
		if ( manager.fl_debug ) {
			getDebugControls() ;
		}
		getControls();

		updateConstants() ;
	}

}
