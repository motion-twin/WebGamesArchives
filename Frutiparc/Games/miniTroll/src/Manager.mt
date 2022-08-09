class Manager{//}

	// base
	
	static var FLDEBUG = false;
	static var CHEAT = 2	// 0 - 1 - 2
	
	static var PAUSE_FADE = 90;
	static var flPress:bool;
	
	static var control:{type:int,key:Array<int>}
	static var dm:DepthManager;
	static var root:MovieClip;
	
	static var flPause:bool;
	static var flReleasePause:bool;
	static var flNewDay:bool;
	static var flFirst:bool;
	static var step:int;
	static var fadePrc:float;
	static var pauseAlpha:float;
	static var date:Date;

	static var slotMask:{>MovieClip,x:float,y:float}
	static var slotMaskLight:MovieClip;
	
	static var slot:Slot;
	static var oldSlot:Slot;
	static var client:Client;
	
	
	static var msg:{flView:bool,list:Array<{d:int,txt:String}>}
	
	static var mask:MovieClip;
	
	static var debugPanel:{>MovieClip,txt:String};
	//e8f0b6c6cc77c615964ef5500c719b2d
	
	// DEBUG
	static var so:SharedObject
	static var impList:Array<int>
	
	static var mcPause:MovieClip;
	

	
	
	static function init(r : MovieClip) {
		
		KeyName.init();
		
		root = r
		registerSymphony()
		//
		Item.initItemList();
		//
		dm = new DepthManager(root);
		
		flPause = false;
		flReleasePause = true;
		flNewDay = false;
		flFirst = true;

		if( FLDEBUG ){
			debugPanel =  downcast( dm.attach( "debugPanel", 11 ))
			debugPanel.txt = "--\ MINIPIXIZ v"+Cm.VERSION+" /--\n"
		}

		//*
		client = new Client();
		client.serviceConnect()		
		genSlot("loading");
		
		
		/*/
		client = new Client();
		formatFruticard();
		genSlot("baseDungeon")		
		//*/
		initControl();
		

	}

	static function registerSymphony(){
		
		Std.registerClass( "game",		Game			);
		Std.registerClass( "menu",		Menu			);
		Std.registerClass( "loading",		Loading			);
		Std.registerClass( "inventory",		Inventory		);
		Std.registerClass( "frog",		Frog			);
		Std.registerClass( "option",		Option			);
		Std.registerClass( "mission",		Mission			);
		Std.registerClass( "news",		News			);
		Std.registerClass( "baseForest",	base.Forest		);
		Std.registerClass( "baseDungeon",	base.Dungeon		);
		Std.registerClass( "baseFountain",	base.Fountain		);
		Std.registerClass( "baseRainbow",	base.Rainbow		);
		Std.registerClass( "baseTree",		base.Tree		);
		Std.registerClass( "invSlot",		inv.Slot		);
		Std.registerClass( "invHand",		inv.Hand		);

	}
	
	static function genSlot(link){
	
		slot = downcast( dm.attach( link, 10 ) );
		slot.init();

	}
	
	static function fadeSlot(link,x,y){
		if(x==null)x=Cs.mcw*0.5
		if(y==null)y=Cs.mch*0.5
		if( slot != null ){
			oldSlot = slot
		}
		slotMaskLight = dm.attach("slotMaskLight",10)
		genSlot(link)
		
		slotMask = downcast(dm.attach("slotMask",10))
		slotMask.x = x;
		slotMask.y = y;
		slotMask._x = x;
		slotMask._y = y;
		slot.setMask(slotMask)
		
		initStep(1)
	}

	static function initStep(n){
		step = n;
		switch(step){
			case 1:
				slotMask._xscale = 0	
				slotMask._yscale = 0
				slotMaskLight._xscale = 0	
				slotMaskLight._yscale = 0
				fadePrc = 0;
				break;
		}
	}

	//
	static function update(){
		Timer.update();
		//Log.print(">>>"+Math.round(400/Timer.tmod)/10)
		Cs.frict = Math.pow(0.95,Timer.tmod)
		
		
		if( Key.isDown(80) || Key.isDown(27) ){
			if( flReleasePause && !client.forcePause ){
				setPause(null);
				flReleasePause = false;
			}
		}else{
			flReleasePause = true;
		}
				
		if(!flPause){
			slot.update();
			switch(step){
				case 1:
					checkFade();
					break;
			}
		}else{
			pauseAlpha *= 0.5
			Mc.setPercentColor( slot, PAUSE_FADE+pauseAlpha, 0x938DC3 )
			Mc.setPercentColor( oldSlot, PAUSE_FADE+pauseAlpha, 0x938DC3 )
			Mc.setPercentColor( slotMaskLight, PAUSE_FADE+pauseAlpha, 0x938DC3 )
		}	
		
		

	
		
		
		if( FLDEBUG ){
			debugPanel._visible = Key.isDown( Key.BACKSPACE )
		}
		
		
		
	}
	//
	
	//
	static function checkFade(){
			fadePrc += 0.2*Timer.tmod
			fadePrc *= Math.pow(1.2,Timer.tmod)
			var tx =  Cs.mcw*0.5
			var ty =  Cs.mch*0.5
			var c = fadePrc/100
			slotMask._x = tx*c + slotMask.x*(1-c)
			slotMask._y = ty*c + slotMask.y*(1-c)
			slotMask._xscale = fadePrc;
			slotMask._yscale = fadePrc;
		
			slotMaskLight._x = slotMask._x
			slotMaskLight._y = slotMask._y
			slotMaskLight._xscale = slotMask._xscale
			slotMaskLight._yscale = slotMask._yscale
			if(fadePrc > 100 ){
				slotMask.removeMovieClip();
				slotMaskLight.removeMovieClip();
				oldSlot.kill();
				oldSlot = null
				slot.maskInit();
				initStep(0)
			}
					
	}
	
	static function initControl(){
		var listener = { 
			onMouseDown : fun()  {
			   if( Manager.flPress )Manager.click();
			   Manager.flPress = true
			},
			onMouseUp : fun() {
				if( Manager.flPress )Manager.release();
				Manager.flPress = false
			},
			onMouseMove : null,	
			onMouseWheel : null	
		} 
		Mouse.addListener(listener);
		control = {
			type:0,
			key:[Key.LEFT,Key.RIGHT,Key.SPACE,Key.DOWN,Key.UP]
		}
				
	}
	
	static function click(){

	}
	
	static function release(){

	}

	static function addMsg(txt){
		if(msg==null)msg = {flView:false,list:[]};
		msg.list.push( { d:Cm.card.$time.$d, txt:txt } )
		msg.flView = false;
	}
	
	
	// CLIENT<
	static function connected(){

		Manager.log("[Mng] Connected!")
		
		Cm.loadFruticard();
		Cm.updateTime();

		if(FLDEBUG){
			Cm.logStat()
		}
		
		
		
		fadeSlot("menu",120,120);
		//fadeSlot("baseAventure",120,120);
		
	}

	static function backToMenu(){
		if(oldSlot==null){
			fadeSlot("menu",Cs.mcw*0.5,Cs.mch*0.5);
		}
	}
	
	static function setPause(flag){
		if(flag==null) flag = !flPause;
		flPause = flag;
		
		if(flPause){
			if(mcPause==null)mcPause = dm.attach("mcPause",12);
			pauseAlpha = -PAUSE_FADE
		}else{
			mcPause.removeMovieClip();
			mcPause = null;
			Mc.setPercentColor( slot, 0, 0x000000 )
			Mc.setPercentColor( oldSlot, 0, 0x000000 )
			Mc.setPercentColor( slotMaskLight, 0, 0x000000 )
		}
	}	

	static function reStart(){
		msg = null;
		slot.kill();
		oldSlot.kill();
		genSlot("loading");
		client.onServiceConnect()
	}
	
	// OTHER
	static function setNightMask(link){
		mask = dm.attach(link,10)
		slot.setMask(mask)
	}
	
	static function removeNightMask(){
		slot.setMask(null)
		mask.removeMovieClip();
		mask = null;
	}	
	
	// DEBUG
	static function log(txt){
		if(FLDEBUG){
			debugPanel.txt += txt+"\n"
		}
		
	}
	
	static function logClear(){
		debugPanel.txt = ""
	}
	
	/* GAMEPLAY
	
	- MODES
		- AVENTURE ( cout : gratuit )
			- génération aleatoire.
			- fée utilisable.
			- niveau a vider completement.
			- piece qui tombent basiques.
			- elimination des couleurs.
			- items a gagner.
			- gain d'experience pour la fée.
		
		- SURVIE
		
		- SAUVETAGE ( donjon de Samosa )
			- fée non utilisable
			- permet de sauver une fée
			- 5 niveaux de difficulté ( aleatoire ) : chaque niveau de difficulté supplémentaire donne 1xp de plus a la fée sauvée.

		- OPTIONS
			- son on/off
			- musique on/off
			- clavier/souris
			- touches
			- gestion des fées.	
	
	- ITEM AVENTURES 
		uniques : 
		- 6x bocal : permet de conserver une fée supplémentaire ( 9 bocaux supplémentaires ) 
		- 3x scroll :^permet d'apprendre un sort ( contenu sur le scroll )
		
		périssable : ( 1ere acquisition = titem )
		- Abeille : permet de jouer une partie en mode survie ( elle guide le joueur dans le donjon de samosa )
		- Sachet de poudre : permet de jouer avec une fée en aventure, sauvetage ou survie
		- 
		speciaux :
		- Sac a dos : niv 2 et niv 3
		
	
	- FAERIES 
		caracteristiques :
			intelligence :
			concentration : 
			mana :
			vitesse : 
			force :
			resistance :
			
	
	- SORTS
		- Faerie
		1-I Poing-de-Dimitri : la fée prend un token et le positionne a la place d'un autre juste a coté
		2-I Foudre Alterique : la fée détruit un element.
		1-E Stase : La fée ralentie le rythme de chute des X prochaines pieces
		2-E Simplification : Les X prochain.es pieces ont une taille de 2
		4-I Diamant : Toutes les gems d'une couleur unique explosent
		1-I Lame : Une lame trace un trait et detruit toutes les pieces au dessus de ce trait ( le nombre de pieces -- > Concentration )
		
		
		- Demons
	
	- ELEMENTS SPECIAUX
		- Token ( = colorés ) 
			pointés : ne comptent pas dans le decompte nécessaires pour l'explosion
			armure : doit etre blasté pour etre reliables.
	
	
	
	*/
	
	/* BUG
		- alpha pause sur les petites barres
		- masque décalé par rapport a la piece dans penombre
		- 2x simplification marche po ? ( pas de dispa de couleur )
		- perte de culeur ( -> new ) + grosse grosse peice sort
	
	*/
	
	/* TODO

	
		// BUG
		- fleche gauche deconne
		- checker pour les briques etoiles
		- message quand on a battu son meilleur level foret
		- verifier les maladie psychos

		// FRUTICARD
		
		// ERGONOMIE
		- +de textes d'ambience ( grenouille, donjons finis etc. )
		
		// TEXTE
		- liberatio nde fée génére un message dans le mail !
		
		// POWERUP
		
		// SORTS
			// FEE
				- (2) Tir ciblé : Detruit une case.
			// IMP
				- Tourelle : Change une bille en générateur de bille.



		// STATS
		- compter la plus grosse combo !

		// GAMEPLAY
		- rajouter les $name dans la plupart des dialogues
		- voir la barre pour la mana se remplir
		- changeur de nom

		// GFX
		- clé
		- picto diamant
		
		
		// IMPROVE
		- Ornegon parle
		x ajout d'une resistance a la fée proportionelle a son niveau.
		- Trouver des avantages exceptionnels
		- plus de billes 
		- phrase quand on tue demon
		

	
	*/
	
	// IDEE SUPERPOUVOIR
	
	// SATELLITE
	
	
	/* GAMEPLAY OLD
	
	- BASE
		- choix 1 :
			PUYO-PUYO : 4 couleurs - 4 chaine - malus = air
		- choix 2 :
			STANDARD : 3 couleur - 4 chaines - malus = blindage
	
	- PROGRESSION
		- choix 1 :
			STANDARD : les briques a placer sont de plus en plus compliquées
			AVATAR : mechant fait tomber des malus ( > Wario's Wood )
		- choix 2 :
			Affrontement --> Pas assez de place
		- choix 3 :
			Creuser :
				- choix 1 :
					mode continue, l'ecran scroll si ligne du bas entamée + 2 ligne du haut libre
				- choix 2 :
					mode tableau : le troll doit atteindre le bas de l'ecran pour tomber au tableau suivant
	
	- TROLLS
		- choix 1 :
			choix au depart = "choix de perso"
		- choix 2 :
			invocation en court de partie. ( = runes )
		- choix 3 :
			hasard.
		
		--->
/		Joueur gagne des runes en cours de partie. les runes peuvent etre dépensées en début de oartie pour créer un troll.
		
	
	*/
	
	/* VERSION CHANGE
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.32 :
	- Baisse de la difficulté du mode fontaine ( Les nouvelles couleurs arrivent 2x moins vite ).
	- Les fées générées a partir de cette version pourront utiliser normalement leur slot d'inventaire.
	- Augmentation de la probabilité d'apparation d'objet a chaque niveau de la foret (  +33%  ).
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.34:
	- Ajout de message d'aide et d'ambiance ( entrée dans le jeu + premiere fée ).
	- Diminution de la difficulté dans le mode foret ( elle augmente 2x moins vite ).
	- Ajout d'un systeme de checkpoint dans la foret ( tous les 20 levels ).
	- Les démons s'enfuient desormais apres avoir envoyé une dizaine de sorts.
	- Correction du bug des sorts qui survivent a la mort de leur lanceur.
	- Les démons lancent leurs sorts négatifs 3 fois moins vite tant qu'une fée est en jeu.
	- Augmentation du gain d'experience des fée a chaque niveau de foret terminé.
	- Sheme de Dimitri réparé. ( = plus de freeze de la fée et du jeu en phase de sort )
	- Bug du levelUp en chaine (multiclick) réparé
	- Ajout d'un système d'infobulle pour... ben informer.
	- Le controle de l'acceleration de la chute des pieces est reinitialisé a chaque piece
	- En mode souris, le controle de la chute des pieces a été legerement modifé.
	- Noms des fruits bugués corrigé
	- Il est desormais impossible de jeter un bocal contenant une fée
	- Il n'est desormais plus possible d'enfermer une fee dans un bocal de la liste exterieur ( a tester )
	- Eradication du bug qui freeze le jeu au demarrage ( bug de l'anim de la fleur )
	- Le max de mana prend desormais en compte les objets modificateurs
	- Diminution du nombre de parties necessaires pour faire apparaitre les donjons
	- Augmentation de la proba d'apparition des potions de vies.
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.35:
	- Patch du mode checkpoint pour les personnes n'ayant pas encore formaté leur fruticard
	- Plus de zap du choix d'item lorsque l'on debloque un checkpoint
	- Ajout du bouton quitter dans la selection des checkpoints
	- Reparation du sort Smoke qui detruisait son lanceur ( disparition prématurées des demons )
	- Diminution de la puissance du sort démon Wall .
	- Augmentation des probas de tirage du sort shield dans les choix de sorts de la fée.
	- Ajout de plusieurs etiquettes d'explication ( moulin, evolution, etc. )
	- Aout d'un systeme de dialogue pour les fée en jeu ( sera étendue au menu plus tard )
	- Le level-up fait egalement gagner du moral desormais.
	- Laisser votre fait en liberté lui permet de regagner du moral ( pas plus de 50% du max ) ( Attention une fée trop déprimée en liberté peut également s'enfuir )
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.36:
	- Diminution de la fréquence des dialogues de fées d'ambiance ( non-liés a des evenements )
	- Obligation de ranger ses items avant de quitter l'ecran d'inventaire a la fin d'une partie ( > bouton quitter desactivé )
	- On sort desormais de la foret tous les 20 niveau que le checkpoint soit acquis ou non
	- Les checkpoints sont acquis aux niveaux 20 40 60 les parties commences aux niveau 21 41 61 etc.
	- La niveau max de la foret est mis a a jour a la fin de chaque partie ( plus uniquement en cas de game over )
	- Ajout des dialogues de fées dans le menu.
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.37:
	- Ajout du mode arbre creux.
	- Poutrer du démons rapporte désormais de l'xp aux fées
	- Le level max de la foret enregistré correspond desormais au level ou l'on a perdu.
	- Les tirs des démons bas niveau font moins de degat ( -50% pour les niv.1, -25% pour les niv2 )
	- Les bonus de force lors d'une charge ont été multipliés par 2 pour les fées.
	- Les fées avec un taux de force plus élevé tentent plus souvent des charges ( comme au rugby )
	- Le commentaire du bocak est mis a jour correctement desormais.
	- Baisse des chances d'apparition de dialogues d'ambience ( = dialogues non-liés a des evenements )
	- Probabilités accrues de tirage de clés, potions petite et moyennes.
	- Bug affreux qui annihilait les fées dans leur bocal lorsqu'on les ecrasait avec un objet, corrigé.
	- Les fées gagnent de l'experience 50% plus vite
	- Ajouts d'explications pour Ornegon
	- Bug des fées qui font 'undefined" dans le bocal resolue ( elles avaient trop le moral, un vrai papa poule ce Keyser :) )
	- Les fées timides ne disent plus "null"
	- +2 Nouveau caracteres de fée made in KT ( la fée pressées et la fée-boulet )
	- Modifications de quelques illustrations ( checkPoint, game-over )
	- Faible augmentation de la durée d'affichage des dialogues
	- bug graphique du pain bloqué au seocnd etat corrigé.
	- Nouvel affichage des descriptions de sorts dans l'inventaire.
	- Clignotement en survol du bouton quit losqu'on a vidé les objets a classer, corrigé.
	- Ajout de la totoche l'objet magique ultime pour les fée trop bavarde
	- Vitesse de recuperatio nde mana 20% plus rapide
	- Correction du mouvement de la piece sur les machines qui rament ( 2x mouvements pour le prix d'un )
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.38:
	- Correction du pépin qui lors d'une fuite de fée, provoque differents effets desagreable genre fée qui disparaissent, impossibilité de réutiliser le bassin etc.
	- Les fées mortes ne parlent plus ( a tester )
	- Retentative de correction des fées-qui-disent-null ( Knight-who-say-ni ? )
	- Retentative de correction des démons qui font pouf-c'est-tout.
	- Ajout des titems
	
	PS1: Pour les titems seuls les nouveaux objets acquvis seront pris en compte.
	PS2: Les corrections sur Fruticard seront mise en ligne en fin de beta.
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.39:
	- Augmentation légère des probas d'apparitions des aliments semi-rares ( gouda brioche glace etc. )
	- Ajout du sympathique générateur de bille.
	- Ajout de la fonctionnalité "foutu-pour-foutu" (TM) qui ordonne aux démons de ne plus lancer de sorts lorque le niveau est remplie a moins de 10%.	
	- Augmentation de la durée minimale d'apparition d'un dialogue
	- Augmentation du plafond de niveau de la fée --> niv.50
	- Les status de la fée ( bulle ) ne disparaisse plus quand son equipement change dans la partie inventaire.
	
	Le générateur de bille a été ajouté au mode forët pour que l'augmentation de la difficulté ne repose pas uniquement sur les démons. 
	Le nombre et la profondeur des generateurs de billes entrent en compte dans le calcul de difficulté du level.
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.40:
	- correction du pepin des generateur de bille ( non prise en charge des couleurs restantes )
	- impossible d'appuyer tres vite sur retour alors que l'anim de transition n'est pas finie ( peut etre a l'origine du screen de gael )
	- Nombre de clés plafonnées a 9;
	- augmentation du coef de difficulté liés a la hauteur du niveau. ( = les niveaux haut ont encore moins de chance d'avoir des couleurs, demons ou generateur supplementaires )
	- Augmentation du temps de latence entre les sorts des démons ( +100% )
	- Debug de la fonctionnalité "foutu-pour-foutu" qui était inversé ( sorts que si -de 10% de billes )
 	- Baisse des probas d'apparition des sac niv.2 et niv.3
	- Correction du bug de la cloche d'immunité qui reste en place

	--------------------------------------------------------------------------
	MiniPixiz V 0.41:
	- sauvegarde directe de la fruticard en cas d'obtention d'un objet
	- réactivation du bouton retour sur certaine pages
	- légère diminution de la difficulté du mode arc-en-ciel ( = les blocs eteignent les flammes plus vites +15% )

	--------------------------------------------------------------------------
	MiniPixiz V 0.5: SPECIAL
	- Correction d'un bug qui stoppait le jeu apres une evolution sur les PC lent
	- Ajout des boutons de test-accélérés.
	
	Voici la descriptions des fonctionnalités dans l'ordre
	
	- touche soleil : permet de passer 1 jour *
	- touche manette : permet de simuler des parties de jeu *
	- touche clé : permet de rajouter des clés ( valide a la prochaine entrée dans le menu ) *
	- touche baluchon : vous permet de recuperer un objet ***
	- touche demon : Fait apparaitre un demon a la pochaine partie ( peut etre utilisé plusieurs fois) **
	- touche format : format votre carte
	- touche nouvelle fée : fait apparaitre une nouvelle fée de niveau 1, si aucune fée n'est selectionnée.
	- touche barbarella : Invoque barbarella, si aucune fée n'est selectionnée.
	- touche Ornegon : Fait apparaitre Ornegon.
	- touche arc-en-ciel : Fait apparaitre l'arc en ciel.
	
	Pendant le jeu :
	- Appuyz sur ENTER pour passer un niveau *
	
	* : En utilisant les touches du pavé numerique avant d'effectuer l'action vous pourrez multiplier le resultat, les touches de nombres normales multiplie par 10,20,30...
	** : Les touches du pavé numerique vous permettront de selectionner le niveau du demon invoqué. ( pas au dela de 5 de preference... )
	*** : En laissant appuyé sur controle, vous pourrez selectionner plusieurs objets d'affilé.
	
	Ces boutons :
	- sont des boutons de debug,ils ne sont pas crées pour etre ergonomiques ou facile a utilisés.
	- doivent vous permettrent de recréer des situations de jeu réaliste, Les pépin liées a une utilisations excessive ne seront pas traités.
	- vous gacheront surement le plaisir du jeu, cela n'est pas un problème pour les beta-testeurs, mais en revanche je comprendrai si des moderateurs ne desirent pas tester cette version.

	--------------------------------------------------------------------------
	MiniPixiz V 0.51:

	- Ajout du mode mission --> La cabane de gromelin
	- Ajout d'une résistance (faible) aux degats, proportionnelle au niveau des fées
	- Réeditions de certains textes de sorts qui depassaient du cadre
	- Correction du pepin qui rendait muette les fées qui n'aimaient ou ne detestaient aucun aliment
	
	--------------------------------------------------------------------------
	MiniPixiz V 0.52:
	- la récuperation d'objet tel que clé ou sac en mission est desormais fonctionelle.
	- plus de multiclics possibles sur le bouton valider
	- Ajout des titems de diamant lorsque l'on finit un donjon.
	- Correction du pepin de décalage d'un jour entre les messages de debut de journée et les messges en temps réél.

	--------------------------------------------------------------------------
	MiniPixiz V 1.1:
	- Le bouton retour n'apparait plus pendant le jeu dans le mode forêt
	- Les trois premiers levels de chaque checkpoint ne contiennent jamais d'objets
	- Apparition des fées dans le bassin : elle sera automatique a minuit, si le joueur ne possède pas de fée.
	*/ 
	
	
//{
}




















