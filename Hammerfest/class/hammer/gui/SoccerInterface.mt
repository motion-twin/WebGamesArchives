class gui.SoccerInterface
{
	static var GLOW_COLOR	= gui.GameInterface.GLOW_COLOR;

	var mc				: MovieClip;

	var game			: mode.GameMode;
	var scores			: Array<TextField>;
	var time			: TextField;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(game) {
		this.game	= game;
		init();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		mc		= game.depthMan.attach("hammer_interf_game",Data.DP_TOP);
		mc._x	= -game.xOffset;
		mc._y	= Data.DOC_HEIGHT;
		mc.gotoAndStop("3");
		mc.cacheAsBitmap = true;

		scores		= [ downcast(mc).score0, downcast(mc).score1 ];
		time		= downcast(mc).time;

		FxManager.addGlow( downcast(scores[0]), GLOW_COLOR, 2);
		FxManager.addGlow( downcast(scores[1]), GLOW_COLOR, 2);
		FxManager.addGlow( downcast(time), GLOW_COLOR, 2);

		setScore(0, 0);
		setScore(1, 0);
	}


	/*------------------------------------------------------------------------
	MET À JOUR UN SCORE
	------------------------------------------------------------------------*/
	function setScore(pid,n:int) {
		scores[pid].text = ""+n;
	}


	/*------------------------------------------------------------------------
	MET À JOUR LE TEMPS
	------------------------------------------------------------------------*/
	function setTime(str:String) {
		time.text = str;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		mc.removeMovieClip();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
	}

}
