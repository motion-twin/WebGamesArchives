class Manager{//}


	static var fruitList:Array<MovieClip>
	
	static var queue:Array<{link:String,infoList:Array<int>}>
	
	static var dm:DepthManager;
	static var root:MovieClip;
	
	static var client:Client;
	
	static var slot:Slot;
	static var oldSlot:Slot;
	
	
	
	
	static function init(r : MovieClip) {
		
		root = r
		registerSymphony()
		
		//Cs.init();
		dm = new DepthManager(root);
		fruitList = new Array();
		
		
		//
		queue = new Array();
		
		/*
		client = new Client();
		client.serviceConnect()		
		genSlot("loading");		
		/*/
		genSlot("baseFever")
				
		//*/
		slot.init();
		
	}
	
	static function registerSymphony(){
		Std.registerClass( "baseArcade",	base.Arcade		);
		Std.registerClass( "baseFever",		base.Fever		);
		Std.registerClass( "baseChrono",	base.Chrono		);
		Std.registerClass( "baseTrain",		base.Train		);
		
		Std.registerClass( "menu",		Menu			);
		Std.registerClass( "congrat",		Congrat			);
		Std.registerClass( "gameOver",		GameOver		);
		
		Std.registerClass( "gameBasket",	game.Basket		);
		Std.registerClass( "gameLander",	game.Lander		);
		Std.registerClass( "gameGobelet",	game.Gobelet		);
		Std.registerClass( "gameFlower",	game.Flower		);
		Std.registerClass( "gameGather",	game.Gather		);
		Std.registerClass( "gameParachute",	game.Parachute		);
		Std.registerClass( "gameCliff",		game.Cliff		);
		Std.registerClass( "gameChain",		game.Chain		);
		Std.registerClass( "gameAstero",	game.Astero		);
		Std.registerClass( "gamePong",		game.Pong		);
		Std.registerClass( "gameGhost",		game.Ghost		);
		Std.registerClass( "gameBalance",	game.Balance		);
		Std.registerClass( "gamePicture",	game.Picture		);
		Std.registerClass( "gamePatate",	game.Patate		);
		Std.registerClass( "gameApple",		game.Apple		);
		Std.registerClass( "gameTubulo",	game.Tubulo		);
		Std.registerClass( "gameMarmite",	game.Marmite		);
		Std.registerClass( "gameJumpFish",	game.JumpFish		);
		Std.registerClass( "gameTrampoline",	game.Trampoline		);
		Std.registerClass( "gameOrbital",	game.Orbital		);
		Std.registerClass( "gamePlate",		game.Plate		);
		Std.registerClass( "gamePoint",		game.Point		);
		Std.registerClass( "gameBomb",		game.Bomb		);
		Std.registerClass( "gameFrog",		game.Frog		);
		Std.registerClass( "gameSpaceDodge",	game.SpaceDodge		);
		Std.registerClass( "gameHammer",	game.Hammer		);
		Std.registerClass( "gameTaquin",	game.Taquin		);
		Std.registerClass( "gameBeetle",	game.Beetle		);
		Std.registerClass( "gameHide",		game.Hide		);
		Std.registerClass( "gameHerb",		game.Herb		);
		Std.registerClass( "gameRace",		game.Race		);
		Std.registerClass( "gameGemTurn",	game.GemTurn		);
		Std.registerClass( "gameShakeTree",	game.ShakeTree		);
		Std.registerClass( "gameEgg",		game.Egg		);
		Std.registerClass( "gameMaximum",	game.Maximum		);
		Std.registerClass( "gameMirror",	game.Mirror		);
		Std.registerClass( "gameShield",	game.Shield		);
		Std.registerClass( "gameDart",		game.Dart		);
		Std.registerClass( "gameGeyser",	game.Geyser		);
		Std.registerClass( "gameWalkFlower",	game.WalkFlower		);
		Std.registerClass( "gameRay",		game.Ray		);
		Std.registerClass( "gamePair",		game.Pair		);
		Std.registerClass( "gameNest",		game.Nest		);
		Std.registerClass( "gameHamburger",	game.Hamburger		);
		Std.registerClass( "gameIntruder",	game.Intruder		);
		Std.registerClass( "gameHole",		game.Hole		);
		Std.registerClass( "gameShell",		game.Shell		);
		Std.registerClass( "gameKey",		game.Key		);
		Std.registerClass( "gameOctopus",	game.Octopus		);
		Std.registerClass( "gamePang",		game.Pang		);
		Std.registerClass( "gameCrossLazer",	game.CrossLazer		);
		Std.registerClass( "gameTree",		game.Tree		);
		Std.registerClass( "gameSheep",		game.Sheep		);
		Std.registerClass( "gameSource",	game.Source		);
		Std.registerClass( "gameOlive",		game.Olive		);
		Std.registerClass( "gameRempart",	game.Rempart		);
		Std.registerClass( "gamePilul",		game.Pilul		);
		Std.registerClass( "gameBallSeeker",	game.BallSeeker		);
		Std.registerClass( "gameSlider",	game.Slider		);
		Std.registerClass( "gameTitanic",	game.Titanic		);
		Std.registerClass( "gameRollBlock",	game.RollBlock		);
		Std.registerClass( "gameGuardian",	game.Guardian		);
		Std.registerClass( "gameToupie",	game.Toupie		);
		Std.registerClass( "gameHedgeHog",	game.HedgeHog		);
		Std.registerClass( "gameJumpCar",	game.JumpCar		);
		Std.registerClass( "gameFallApple",	game.FallApple		);
		Std.registerClass( "gamePuzzle",	game.Puzzle		);
		Std.registerClass( "gameScud",		game.Scud		);
		Std.registerClass( "gamePopBalloon",	game.PopBalloon		);
		Std.registerClass( "gameSplashPiou",	game.SplashPiou		);
		Std.registerClass( "gameFlyEater",	game.FlyEater		);
		Std.registerClass( "gameColline",	game.Colline		);
		Std.registerClass( "gameBalloonKid",	game.BalloonKid		);
		Std.registerClass( "gameFlyingDeer",	game.FlyingDeer		);
		Std.registerClass( "gameAcrobate",	game.Acrobate		);
		Std.registerClass( "gameWheel",		game.Wheel		);
		Std.registerClass( "gameZibal",		game.Zibal		);
		Std.registerClass( "gameTapette",	game.Tapette		);
		Std.registerClass( "gameGlass",		game.Glass		);
		Std.registerClass( "gamePlatJump",	game.PlatJump		);
		Std.registerClass( "gameBrochette",	game.Brochette		);
		Std.registerClass( "gamePelican",	game.Pelican		);
		Std.registerClass( "gameClou",		game.Clou		);
		Std.registerClass( "gamePierce",	game.Pierce		);
		Std.registerClass( "gameColorBall",	game.ColorBall		);
		Std.registerClass( "gameSolitaire",	game.Solitaire		);
		Std.registerClass( "gameBibli",		game.Bibli		);
		Std.registerClass( "gameBossRound",	game.BossRound		);
		Std.registerClass( "gameRope",		game.Rope		);

	}
	
	static function genSlot(link){
		oldSlot = slot;
		slot = downcast( dm.attach( link, 10 ) );
	}
		
	static function main(){
		Timer.update();
		
		if(oldSlot!=null)oldSlot.kill();
		
		slot.update();
		Manager.moveFruit();
	}
	
	
	// FRUIT FX
	static function genFruit(){
		//Log.trace("genFruit!")
		var mc = downcast( dm.attach( "mcFruit", 12 ) )
		
		mc._x = Std.random(Cs.mcw)
		mc._y = Cs.mch + mc._height*0.5 + 10
		
		var tx = Cs.mcw*0.25 +Std.random(Math.round(Cs.mcw*0.5))
		var ty = Cs.mch*0.25 +Std.random(Math.round(Cs.mch*0.5))
		var dx = tx - mc._x
		var dy = ty - mc._y
		
		var a = Math.atan2(dy,dx)
		var dist = Math.sqrt(dx*dx+dy*dy)
		var power = dist*0.1

		mc.vitx = Math.cos(a)*power
		mc.vity = Math.sin(a)*power
		mc.vitr = Math.random()*32//6
		
		mc._xscale = (Std.random(2)*2-1)*100
		
		
		var frame = string(Std.random(mc._totalframes)+1)
		mc.gotoAndStop(frame);
		
		fruitList.push(Std.cast(mc))
		
		
		
		//mc._x = 
		
	}
	
	static function moveFruit(){
		var frict = Math.pow(0.99,Timer.tmod)
		var grav = 0.5
		for( var i=0; i<fruitList.length; i++ ){
			var mc =  downcast( fruitList[i] )
			mc.vity += grav;
			
			mc.vitx *= frict;
			mc.vity *= frict;
			//mc.vitr *= frict;
			mc.vitr *= Math.pow(0.95,1);
			
			mc._x += mc.vitx * Timer.tmod
			mc._y += mc.vity * Timer.tmod
			mc._rotation += mc.vitr * Timer.tmod
			
			if( mc.vity>0 && mc._y-mc._height > Cs.mch ){
				mc.removeMovieClip();
				fruitList.splice(i,1)
				i--
			}
			
			for( var n=0; n<fruitList.length; n++){
				var mc2 = downcast( fruitList[n] )
				var dx = mc._x - mc2._x
				var dy = mc._y - mc2._y
				var d = Math.sqrt(dx*dx+dy*dy)
				var lim = 60
				if( d<lim ){
					//Log.trace("col!")
					var a = Math.atan2(dy,dx)//mc.getAng(mc2)
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var c = 1-d/lim
					var p = 2
					
					mc.vitx += ca*c*p
					mc.vity += sa*c*p
					
					mc2.vitx -= ca*c*p
					mc2.vity -= sa*c*p
					
					
				}
			}
		}
	}
	
	// COMMUNICATION

	static function connected(){
		
		Manager.log("[Mng] Connected!")
		
		Cm.loadFruticard();

		genSlot("menu")
		slot.init();
	}
	
	static function backToMenu(){

	}
	
	static function setPause(flag){
	
	}
	
	// DEBUG
	static function log(str){
	
	}
	
	
		
	/* GAMEPLAY
	
		ARCADE
		- Base de 5 vies.
		- FACILE 	40 niv	0-40%
		- NORMAL	80 niv 0-60%
		- DIFFICILE	100 niv 0-100%		( +1 jeu dédiés )
		- INFERNAL	100 niv 50-100%		( +1 jeu dédiés)
		- Le mode normal se débloque en finissant le mode facile etc.

	
		FEVER						( +5 jeu dédiés )
		- une seule vie
		- pas de Base ->>> TRES TRES rapide
		- difficulté croissante de 20% a 50%
		- Jeu sans fin le but est d'atteindre le niveau le plus haut
		- enregistrement du meilleur niveau.
		> evenement aleatoire sous forme de messages
			-> 20 Titems a gagner


		TIME-ATTAQUE	-> 1 Casquette Mini-fever
		- Tous les jeux en desordre
		- difficulté a 50% //+10% a chaque victoire -20% par defaite
		- Finir en moins de X minutes facile. -> +1 TITEM ( sur 20 )
		- Finir en moins de X minutes difficle. -> 1 Wallpaper a gagner
		- Enregistrement du meilleur temps.
		
		Se debloque en ayant joué au moins une fois a tous les jeux standard

		ENTRAINEMENT	-> 100 Titems
		- Jouer sur les jeux débloqués pour s'entrainer
		- Un jeu est débloqué une fois qu'on a joué 200 fois dessus.
	
		JEUX SECRET	-> 5 titems
		- Version ameliorée avec enregistrement des scores de 3 à 4 jeux standard.
		- Chaque jeu s'obtient en terminant 500 fois son jeu standard
		- Chaque jeu secret a un objectif a atteindre, cet objectif remplie permet de gagner un titem
	
		TITEM SECRET
		- Prendre en photo le poisson Dorée = 1 Titem poisson doré
		- Passage secret dans bubble ghost = 1 Titem trésor
	
		OPTION
		- son on/off
		- musique on/off
		- barre de temps on/off
	*/
	
	/* IDEES JEUX
		x basket
		x gobelet
		- canon cote droit tire pioupiou
		x parachute landing
		x bubble ghost
		- jeux de crenaux
		x lander
		x trouver l'intrus (l'entourer)
		x pousse fleur
		x asteroid souris
		x rassembler dans un cercle au milieu
		x jeu de course profil - saut click ( deplacmeent lateral souris ?)
		- mini-arkanoid
		x mini-tubulo
		- tapis roulant = click saute
		x chaine de symbole a trouver dans une tableau
		- balle poussé par poire soufflante ( click sur poire ) doit passer 2 blocs qu'on peut tirer avec des poulis+manivelle ( = tir souris )
		x mini pong
		x monsieur patate
		x mange-pomme = clique sur une pomme pour la manger
		x flechette bizarres ( 2x viseurs, dont un rebond, l'autre souris, rebond au centre)
		x marmite + recette
		x photo poisson
		- corde a sauter
		- rugby-hamtaro
		x blob trampoline
		x terre+missile contre orbite
		- cannette secouée partir loin ciel
		- decolle en skate + doit atterir
		x nettoyer qqc gauche-droite souris
		x particule d'eau eteigne feu ( skin bombe + pipette )
		x relier les points pour faire un dessin
		x grenouille + kaluga au bout d'une canne a peche
		x shoot'em up turret = shot dodge
		- bille couleur a replacer dans une ligne -> combo
		x mar-taupe
		x taquin
		- chaine de robot ( = timing click )
		x trouver truc qui flip de plus en plus vite
		x jeu du hero qui peut pas repasser sur les cases deja visité.
		- jeu de ring autour d'un axe
		- utilisation du moteur lemming ?
		- ping-pong
		x fontaine de particule == attraper avec epuisette
		x circuit automobile ( monotouche )
		x Jeu des hexas qui tourne autour d'un pion central
		x satellite qui tu un gorille
		- avion en papier
		- goeland attrape poisson
		x defender - missile
		- eviter verre qui tombe
		- morpion --> grille bouge
		x taêtte a mouche defonce mouche
		
		// SAISONNIER
		- Noel
		- St Valentin
		- Haloween
		
		
	*/
	
	/* TODO
		
		GAMEPLAY
		x gerer le temps dans les jeux
		- revoir gampelay fourmi
		x pause au depart de asteroid
		x pause au depart du pong
		- reparer taquin
		- vider root
		
		
		// GFX
		- gerer les bulles dans la marmite
		- gerer le plouf et le mask dans marmite
		- gerer les images differentes dans pictures
		- ajouter une explosion dans orbital
		
		BUG
		x tubulo retour des tubes pas a la meme hauteur
		x picture ; 2x la meme image dans les propositions ?!
		
	
	*/

	
	
//{
}




















