class gui.GameInterface
{
	static var GLOW_COLOR	= 0x70658d;

	static var BASE_X		= 92; // lives
	static var BASE_X_RIGHT	= 300;
	static var BASE_WIDTH	= 20;

	static var MAX_LIVES	= 8;


	var mc				: MovieClip;

	var game			: mode.GameMode;
	var currentLives	: Array<int>;
	var level			: TextField;
	var scores			: Array<TextField>;

	var realScores		: Array<int>;
	var fakeScores		: Array<int>;

	var fl_light		: bool;
	var fl_print		: bool;
	var fl_multi		: bool;

	var lives			: Array<Array<MovieClip>>;
	var letters			: Array<Array<MovieClip>>;
	var more			: Array<MovieClip>;

	var baseColor		: int;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(game) {
		this.game = game;
		more = new Array();

		if ( game._name=="$time" || game._name=="$timeMulti" ) {
			initTime();
		}
		else {
			if ( game.countList(Data.PLAYER) == 1 ) {
				initSingle();
			}
			else {
				initMulti();
			}
		}

		FxManager.addGlow( downcast(level), GLOW_COLOR, 2);

		setLevel(game.world.currentId);
		fl_light		= false;
		fl_print		= false;
		baseColor		= Data.BASE_COLORS[0];

		update();
	}


	/*------------------------------------------------------------------------
	INIT: INTERFACE SOLO
	------------------------------------------------------------------------*/
	function initSingle() {
		fl_multi = false;

		// skin
		mc = game.depthMan.attach("hammer_interf_game",Data.DP_TOP);
		mc._x = -game.xOffset;
		mc._y = Data.DOC_HEIGHT;
		mc.gotoAndStop("1");
		mc.cacheAsBitmap = true;
		scores	= [ downcast(mc).score0 ];
		level	= downcast(mc).level;


		// Lettres Extend
		letters = new Array();
		letters[0] = new Array();
		letters[0].push( downcast(mc).letter0_0 );
		letters[0].push( downcast(mc).letter0_1 );
		letters[0].push( downcast(mc).letter0_2 );
		letters[0].push( downcast(mc).letter0_3 );
		letters[0].push( downcast(mc).letter0_4 );
		letters[0].push( downcast(mc).letter0_5 );
		letters[0].push( downcast(mc).letter0_6 );

		fakeScores		= [0];
		realScores		= [0];
		currentLives	= [0];
		lives			= [[]];

		var p = game.getPlayerList()[0];
		setScore(0, p.score);
		setLives(0, p.lives);
		clearExtends(0);

		scores[0].textColor = Data.BASE_COLORS[0];
		FxManager.addGlow( downcast(scores[0]), GLOW_COLOR, 2);
	}


	/*------------------------------------------------------------------------
	INIT: INTERFACE MULTIPLAYER
	------------------------------------------------------------------------*/
	function initMulti() {
		fl_multi = true;

		// skin
		mc = game.depthMan.attach("hammer_interf_game",Data.DP_TOP);
		mc._x = -game.xOffset;
		mc._y = Data.DOC_HEIGHT;
		mc.gotoAndStop("2");
		mc.cacheAsBitmap = true;
		scores	= [ downcast(mc).score0, downcast(mc).score1 ];
		level	= downcast(mc).level;


		// Lettres Extend
		letters = new Array();
		letters[0] = new Array();
		letters[0].push( downcast(mc).letter0_0 );
		letters[0].push( downcast(mc).letter0_1 );
		letters[0].push( downcast(mc).letter0_2 );
		letters[0].push( downcast(mc).letter0_3 );
		letters[0].push( downcast(mc).letter0_4 );
		letters[0].push( downcast(mc).letter0_5 );
		letters[0].push( downcast(mc).letter0_6 );

		letters[1] = new Array();
		letters[1].push( downcast(mc).letter1_0 );
		letters[1].push( downcast(mc).letter1_1 );
		letters[1].push( downcast(mc).letter1_2 );
		letters[1].push( downcast(mc).letter1_3 );
		letters[1].push( downcast(mc).letter1_4 );
		letters[1].push( downcast(mc).letter1_5 );
		letters[1].push( downcast(mc).letter1_6 );


		// Init spécifiques aux players
		fakeScores		= new Array();
		realScores		= new Array();
		currentLives	= new Array();
		lives			= new Array();
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			var pid = p.pid;

			fakeScores[pid]		= 0;
			realScores[pid]		= 0;
			currentLives[pid]	= 0;
			lives[pid]			= new Array();

			setScore(pid, p.score);
			setLives(pid, p.lives);

			clearExtends(pid);
			scores[pid].textColor = Data.BASE_COLORS[0];
			FxManager.addGlow( downcast(scores[pid]), GLOW_COLOR, 2);
		}

	}


	/*------------------------------------------------------------------------
	INIT: INTERFACE TIME ATTACK
	------------------------------------------------------------------------*/
	function initTime() {
		BASE_X = 8;
		BASE_X_RIGHT = 386;
		BASE_WIDTH *= 0.75;

		// skin
		mc = game.depthMan.attach("hammer_interf_game",Data.DP_TOP);
		mc._x = -game.xOffset;
		mc._y = Data.DOC_HEIGHT;
		mc.gotoAndStop("3");
		mc.cacheAsBitmap = true;
		scores	= [ downcast(mc).time ];
		level	= downcast(mc).level;


		// Lettres Extend
		letters = new Array();

		fakeScores		= [0,0];
		realScores		= [0,0];
		currentLives	= [0,0];
		lives			= [[],[]];

		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			var pid = p.pid;

			fakeScores[pid]		= 0;
			realScores[pid]		= 0;
			currentLives[pid]	= 0;
			lives[pid]			= new Array();

			setScore(pid, p.score);
			setLives(pid, p.lives);
		}
		clearExtends(0);
		scores[0].textColor = Data.BASE_COLORS[0];
		FxManager.addGlow( downcast(scores[0]), GLOW_COLOR, 2);
	}


	/*------------------------------------------------------------------------
	MODE MINIMALISTE
	------------------------------------------------------------------------*/
	function lightMode() {
		scores[0]._visible = false;
		setLives(0,0);
		more[0].removeMovieClip();
		more[1].removeMovieClip();
		fl_light = true;
	}


	/*------------------------------------------------------------------------
	MODIFIE LE SCORE
	------------------------------------------------------------------------*/
	function setScore(pid,v:int) {
		realScores[pid] = v;
	}


	function getScoreTxt(v:int) {
		var tab=(v+"").split("");
		for (var i=tab.length-3;i>=0;i-=3) {
			tab.insert(i," ");
		}
		return tab.join("");
	}

	/*------------------------------------------------------------------------
	MODIFIE LE LEVEL COURANT
	------------------------------------------------------------------------*/
	function setLevel(id:int) {
		level.text = ""+id;
		level.textColor = baseColor;
	}

	function hideLevel() {
		level.text = "?";
		level.textColor = baseColor;
	}

	/*------------------------------------------------------------------------
	MODIFIE LE NOMBRE DE VIES
	------------------------------------------------------------------------*/
	function setLives(pid:int,v:int) {
		var baseX	= BASE_X;
		var baseWid	= BASE_WIDTH;
		if ( fl_multi ) {
			baseWid	= 0.6 * BASE_WIDTH;
		}
		if ( pid==1 ) {
			baseWid	*= -1;
			baseX	= BASE_X_RIGHT;
		}

		var plives		= lives[pid];
		if ( fl_light ) {
			return;
		}
		if ( currentLives[pid]>v ) {
			game.manager.logAction("$LL");
			while ( currentLives[pid]>v ) {
				plives[currentLives[pid]-1].removeMovieClip();
				currentLives[pid]--;
			}
		}
		else {
			while ( currentLives[pid]<v && currentLives[pid]<MAX_LIVES ) {
				var mc = Std.attachMC(mc, "hammer_interf_life", game.manager.uniq++);
				mc._x = baseX+currentLives[pid]*baseWid;
				mc._y = -19;
				plives[currentLives[pid]]=mc;
				currentLives[pid]++;
			}
			if ( v>MAX_LIVES && more[pid]._name==null ) {
				more[pid] = Std.attachMC(mc,"hammer_interf_more", game.manager.uniq++);
				more[pid]._x = baseX + baseWid*MAX_LIVES - 4;
				if ( pid>0 ) {
					more[pid]._x-=baseWid;
				}
				more[pid]._y = -25;
			}
			if ( v<=MAX_LIVES && more[pid]._name!=null ) {
				more[pid].removeMovieClip();
			}
		}
	}


	/*------------------------------------------------------------------------
	AFFICHE UN TEXTE FORCÉ DANS LE CHAMP SCORE
	------------------------------------------------------------------------*/
	function print(pid,s:String) {
		scores[pid].text	= s;
		fl_print			= true;
	}

	function cls() {
		fl_print	= false;
	}


	/*------------------------------------------------------------------------
	GESTION EXTEND LETTERS
	------------------------------------------------------------------------*/
	function getExtend(pid,id) {
		var l = letters[pid][id];
		if ( !l._visible ) {
			var fx = Std.attachMC(mc, "hammer_fx_letter_pop", game.manager.uniq++);
			fx._x = l._x+l._width*0.5;
			fx._y = l._y;
			l._visible = true;
		}
	}

	function clearExtends(pid) {
		for (var i=0;i<letters[pid].length;i++) {
			letters[pid][i]._visible = false;
		}
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
		if ( !fl_print ) {
			for (var pid=0;pid<scores.length;pid++) {
				if( scores[pid]!=null ) {
					if ( fakeScores[pid]<realScores[pid] ) {
						fakeScores[pid] += Math.round( Math.max(90, (realScores[pid]-fakeScores[pid])/5 ) );
					}
					if ( fakeScores[pid]>realScores[pid] ) {
						fakeScores[pid] = realScores[pid];
					}
					scores[pid].text = getScoreTxt(fakeScores[pid]);
				}
			}
		}

		// Couleurs
//		for (var pid=0;pid<2;pid++) {
//			scores[pid].textColor = Data.BASE_COLORS[pid];
//			FxManager.addGlow( downcast(scores[pid]), Data.DARK_COLORS[pid], 2);
//		}
//		FxManager.addGlow( downcast(level), 0x4f4763, 2);
	}

}
