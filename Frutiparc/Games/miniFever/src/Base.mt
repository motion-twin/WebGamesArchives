class Base extends Slot{//}

	var flPress:bool;
	var flWin:bool;
	var flTimer:bool;
	var gameFreqMax:int;
	var dif:int
	var gameTimer:float;
	var gameTimerMax:float;

	var gameList:Array<{link:String,freq:int,id:int}>
	var fade:{col:int,prc:float,trg:float}
	var nextGame:{link:String,id:int}
	//ar info:Array<int>


	// MC
	var game:Game;
	var tbar:MovieClip;

	function new(){
		super();
	}

	function init(){
		//Log.trace( "[BASE]init()\n" );
		super.init();
		initMouse();
		fade = {
			col:0xFFFFFF,
			prc:100,
			trg:null
		}
		dif = 0;
	}

	function initMouse(){
		var me = this;
		var listener = {
			onMouseDown : fun()  {
			   if( !me.flPress )me.click();
			   me.flPress = true
			},
			onMouseUp : fun() {
				if( me.flPress )me.release();
				me.flPress = false
			},
			onMouseMove : null,
			onMouseWheel: null
		}
		Mouse.addListener(listener);
	}

	function click(){
		game.click();
	}

	function release(){
		game.release();
	}

	//
	function update(){
		super.update();
		game.update();
		if(fade.trg!=null)updateFade();
		if(flTimer){
			gameTimer -= Timer.tmod;
			if( gameTimer < 0 ){
				game.outOfTime();
				gameTimer = 0;
			}
			updateGameTimer();
		}

	}
	//
	function genGame(link){
		if(game!=null)game.kill();
		//Log.trace( "[BASE]genGame("+link+")\n" );
		game = downcast( dm.attach( link, 10 ) );
		game.dif = dif
		game.base = this;
		game.init();
		game.startGame();
		//Log.trace( "[BASE]genGame("+Std.cast(dm)+")\n" );
	}

	function setWin(flag){
		flWin = flag
		if(flag){
			fadeOut(0xFFFFFF)
		}else{
			fadeOut(0xFF0000)
		}
	}

	function setNext(){
		fadeIn();
	};

	function fadeOut(col){
		fade.col = col
		fade.trg = 0
	}

	function fadeIn(){
		fade.trg = 100;
	}

	function updateFade(){
		var dif = fade.trg - fade.prc
		fade.prc += dif*0.4*Timer.tmod//fade.prc*0.5 + fade.trg*0.5
		if( Math.abs(fade.prc - fade.trg) < 1 ){
			fade.prc = fade.trg
			fade.trg = null;
			if( fade.prc == 0 ){
				setNext();
			}
		}
		Mc.setPColor(Std.cast(this),fade.col,fade.prc)
	}
	//
	function newGame(){
		genGame(nextGame.link);
		Cm.incPlay(nextGame.id)
		initGameTimer(game.gameTime);
	}
	//

	// TIMER
	function initGameTimer(t){
		tbar = dm.attach( "mcTimerBar", 12 )
		tbar._alpha = 50
		flTimer = true;
		setTimer(t)
	}

	function removeGameTimer(){
		tbar.removeMovieClip();
		flTimer = false;
	}

	function updateGameTimer(){
		var c = gameTimer/gameTimerMax
		downcast(tbar).b._yscale = c*100
	}

	function setTimer(t){
		gameTimerMax  = t;
		gameTimer = gameTimerMax;
	}

	function genGameList(){

		gameList = [
			{ link:"gameBasket",		freq:10,	id:0		}	// 1
			{ link:"gameLander",		freq:10,	id:1		}	// 2
			{ link:"gameGobelet",		freq:10,	id:2		}	// 3
			{ link:"gameFlower",		freq:10,	id:3		}	// 4
			{ link:"gameGather",		freq:10,	id:4 		}	// 5
			{ link:"gameParachute",		freq:10,	id:5		}	// 6
			{ link:"gameCliff",			freq:10,	id:6		}	// 7
			{ link:"gameChain",			freq:10,	id:7		}	// 8
			{ link:"gameAstero",		freq:10,	id:8		}	// 9
			{ link:"gamePong",			freq:10,	id:9		}	// 10
			{ link:"gameGhost",			freq:10,	id:10		}	// 11
			{ link:"gameBalance",		freq:10,	id:11		}	// 12
			{ link:"gamePicture",		freq:10,	id:12		}	// 13
			{ link:"gamePatate",		freq:10,	id:13		}	// 14
			{ link:"gameApple",			freq:10,	id:14		}	// 15
			{ link:"gameTubulo",		freq:10,	id:15		}	// 16
			{ link:"gameMarmite",		freq:10,	id:16		}	// 17
			{ link:"gameJumpFish",		freq:10,	id:17		}	// 18
			{ link:"gameTrampoline",	freq:10,	id:18		}	// 19
			{ link:"gameOrbital",		freq:10,	id:19		}	// 20
			{ link:"gamePlate",			freq:10,	id:20		}	// 21
			{ link:"gamePoint",			freq:10,	id:21		}	// 22
			{ link:"gameBomb",			freq:10,	id:22		}	// 23
			{ link:"gameFrog",			freq:10,	id:23		}	// 24
			{ link:"gameSpaceDodge",	freq:10,	id:24		}	// 25
			{ link:"gameHammer",		freq:10,	id:25		}	// 26
			{ link:"gameTaquin",		freq:10,	id:26		}	// 27
			{ link:"gameBeetle",		freq:10,	id:27		}	// 28
			{ link:"gameHide",			freq:10,	id:28		}	// 29
			{ link:"gameHerb",			freq:10,	id:29		}	// 30
			{ link:"gameRace",			freq:10,	id:30		}	// 31
			{ link:"gameGemTurn",		freq:10,	id:31		}	// 32
			{ link:"gameShakeTree",		freq:10,	id:32		}	// 33
			{ link:"gameEgg",			freq:10,	id:33		}	// 34
			{ link:"gameMaximum",		freq:10,	id:34		}	// 35
			{ link:"gameMirror",		freq:10,	id:35		}	// 36
			{ link:"gameShield",		freq:10,	id:36		}	// 37
			{ link:"gameDart",			freq:10,	id:37		}	// 38
			{ link:"gameGeyser",		freq:10,	id:38		}	// 39
			{ link:"gameWalkFlower",	freq:10,	id:39		}	// 40
			{ link:"gameRay",			freq:10,	id:40		}	// 41
			{ link:"gamePair",			freq:10,	id:41		}	// 42
			{ link:"gameNest",			freq:10,	id:42		}	// 43
			{ link:"gameHamburger",		freq:10,	id:43		}	// 44
			{ link:"gameIntruder",		freq:10,	id:44		}	// 45		// REMI 4 eme DESSIN ELEPHANT A FAIRE + 3 illus ?
			{ link:"gameHole",			freq:10,	id:45		}	// 46
			{ link:"gameShell",			freq:10,	id:46		}	// 47
			{ link:"gameKey",			freq:10,	id:47		}	// 48		A revoir complement
			{ link:"gameOctopus",		freq:10,	id:48		}	// 49
			{ link:"gamePang",			freq:10,	id:49		}	// 50
			{ link:"gameCrossLazer",	freq:10,	id:50		}	// 51
			{ link:"gameTree",			freq:10,	id:51		}	// 52
			{ link:"gameSheep",			freq:10,	id:52		}	// 53
			{ link:"gameSource",		freq:10,	id:53		}	// 54
			{ link:"gameOlive",			freq:10,	id:54		}	// 55
			{ link:"gameRempart",		freq:10,	id:55		}	// 56
			{ link:"gamePilul",			freq:10,	id:56		}	// 57
			{ link:"gameBallSeeker",	freq:10,	id:57		}	// 58
			{ link:"gameSlider",		freq:10,	id:58		}	// 59
			{ link:"gameTitanic",		freq:10,	id:59		}	// 60
			{ link:"gameRollBlock",		freq:10,	id:60		}	// 61
			{ link:"gameGuardian",		freq:10,	id:61		}	// 62
			{ link:"gameToupie",		freq:10,	id:62		}	// 63
			{ link:"gameHedgeHog",		freq:10,	id:63		}	// 64
			{ link:"gameJumpCar",		freq:10,	id:64		}	// 65
			{ link:"gameFallApple",		freq:10,	id:65		}	// 66
			{ link:"gamePuzzle",		freq:10,	id:66		}	// 67
			{ link:"gameScud",			freq:10,	id:67		}	// 68
			{ link:"gamePopBalloon",	freq:10,	id:68		}	// 69
			{ link:"gameSplashPiou",	freq:10,	id:69		}	// 70
			{ link:"gameFlyEater",		freq:10,	id:70		}	// 71
			{ link:"gameColline",		freq:10,	id:71		}	// 72
			{ link:"gameBalloonKid",	freq:10,	id:72		}	// 73
			{ link:"gameFlyingDeer",	freq:10,	id:73		}	// 74
			{ link:"gameAcrobate",		freq:10,	id:74		}	// 75
			{ link:"gameWheel",			freq:10,	id:75		}	// 76		// REMI 2 dessins sup a realiser
			{ link:"gameZibal",			freq:10,	id:76		}	// 77		// REMI Level a dessiner
			{ link:"gameTapette",		freq:10,	id:77		}	// 78
			{ link:"gameGlass",			freq:10,	id:78		}	// 79
			{ link:"gamePlatJump",		freq:10,	id:79		}	// 80
			{ link:"gameBrochette",		freq:10,	id:80		}	// 81		// REMI Elements brochette a dessiner
			{ link:"gamePelican",		freq:10,	id:81		}	// 82		// REMI PLOUF
			{ link:"gameClou",			freq:10,	id:82		}	// 83
			{ link:"gamePierce",		freq:10,	id:83		}	// 84
			{ link:"gameColorBall",		freq:10,	id:84		}	// 85		// REMI reskin ?
			{ link:"gameSolitaire",		freq:10,	id:85		}	// 86		// REMI reskin ?
			{ link:"gameBibli",			freq:10,	id:86		}	// 87		// REMI reskin ?		//BEN CODE PERDU
			{ link:"gameBossRound",		freq:10,	id:87		}	// 88		// REMI decor ( rapide )
			{ link:"gameRope",			freq:10,	id:88		}	// 89


		]
	}

	// TOOLS
	function getGameLink(id){
		for( var i=0; i<gameList.length; i++ ){
			var game = gameList[i]
			if(id==game.id){
				return game.link;
			}
		}
		return "error "
	}






//{
}
















