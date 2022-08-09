import Datas;
import Api;
import mt.bumdum.Lib;
import BuildingLogic;
import ShipLogic;
import inter.mod.Chat ;

typedef SData = {
	gid:Int,
	mapWidth:Int,
	mapHeight:Int,
	plmax:Int,
}

class Game {//}

	#if prod
		public static var flDebug = false;
		public static var flViewFuturBuild = false;
	#else
		public static var flDebug = true;
		public static var flViewFuturBuild = false;
	#end

	public static var gameId : Int;
	public var raceId:Int;
	public var playerId:Int;
	public var playerMax:Int;
	public var planets:Array<Planet>;

	public var timeDif:Float;

	public var mapWidth:Int;
	public var mapHeight:Int;

	public var units:Int;
	public var unitMax:Int;
	public var tickMaterial:Int;
	public var tickEther:Int;

	public var pathAvatar:String;

	public var res:_Cost;
	public var tec:Array<_Tec>;
	public var disabledTecs:Array<_Tec>;
	public var research:Array<DataResearch>;
	public var searchRate:Float;


	public var world:World;
	public var data:DataGame;

	public static var me:Game;
	public var inter:Inter;


	public function new( mc:flash.MovieClip ){
		me = this;

		// VARIABLES ROOTS;
		flDebug = Reflect.field(flash.Lib._root,"debug")!=null;
		pathAvatar =  Reflect.field(flash.Lib._root,"pathAvatar");
		raceId =  Std.int( Reflect.field(flash.Lib._root,"raceId") );
		gameId = Std.parseInt(Reflect.field(flash.Lib._root,"game"));
		Api.VERSION = Std.parseInt(Reflect.field(flash.Lib._root,"version"));
		Cs.initColors();

		inter = new Inter(mc);



		Param.load();

		haxe.Log.setColor(0xFFFFFF);

		#if tracer
			haxe.Log.trace = Inter.me.trace;
		#end

		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();

		timeDif = 0;
		if(pathAvatar==null) pathAvatar = "../../../web/www/swf/avatar.swf";

		Api.getDataGame(gameId);
		initKeyListener();



	}
	public function init(data:DataGame){
		this.data = data;
		playerId = data._playerId;
		playerMax = data._plMax;

		// PLANETS
		planets = [];
		var o = Tools.buildMap2( data._id, data._plMax );
		mapWidth = o.width;
		mapHeight = o.height;

		var id = 0;
		for( o in o.list ){
			new Planet(id,o.x,o.y,o.seed);
			id++;
		}

		#if prod
			id = 0;
			for (p in data._world._planets){
				planets[id].id = p._id;
				planets[id].owner = p._owner;
				++id;
			}
		#end

		// PLANETS
		var id = 0;
		for( o in data._world._planets ){
			var pl = planets[id];
			pl.id = o._id;
			pl.owner = o._owner;
			id++;
		}


		//



		// WORLD
		world = new World();
		world.load(data._world);
		Inter.me.launchModule(0);
		Inter.me.map.maj();

		// RES
		loadStatus(data._status);

		// RACE
		var pl =this.getPlayer(playerId);
		raceId = pl._race;

		// PARAM
		Param.tecModels = data._tecModels;


	}

	public static var frameCounter = 0;

	// UPDATE
	public function update(){
		for( pl in planets )
			pl.update();
		Chat.updateLogic();
		inter.update();
	}

	// TIMER
	public function getCounterInfo(c:Counter):{c:Float,run:Float}{
		if(c._start==null)	return{c:0.0,run:c._end};
		if(timeDif==null)	return{c:0.0,run:0.0};

		var n = now();

		var length = c._end - c._start;
		var act = n - c._start;

		if( act > length ) return { c:1.0, run:0.0 };

		return {c:act/length, run:length-act };
	}

	public function now(){
		return Date.now().getTime() + timeDif;
	}

	// LOAD
	public function loadStatus(data:DataStatus){
		units = data._units;
		unitMax = data._unitMax;
		tickMaterial = data._tickMaterial;
		tickEther= data._tickEther;
		res = data._res;
		tec = data._tec;
		searchRate = data._searchRate;
		research = data._research;
		disabledTecs = data._disabledTec;
		inter.loadBar(data);
	}

	public function setTimeDif(t:Float){
		timeDif = t -  (Date.now().getTime()+1000);
		if( Chat.lastUpdate == null )	Chat.lastUpdate = now();
	}

	// GET
	public function getPlayer(?id){
		if(id == null) id = playerId;
		for( pl in world.data._players )if(pl._id==id)return pl;
		trace("player["+id+"] not found !!!");
		return null;
	}

	public function getPlayerName(id){
		return getPlayer(id)._name;
	}

	public function getPlanetId(pid){
		var id = 0;
		for( pl in planets ){
			if(pl.id==pid)return id;
			id++;
		}
		return null;
	}

	public function getPlanetName(pid){
		return Lang.ISLANDS[getPlanetId(pid)];
	}

	public function getDefaultPlanet(){
		var a = [];
		for (pl in planets)
			if (pl.owner == playerId)
				a.push(pl);
		for (pl in a)
			for (b in pl.bld)
				if (b._type == _Bld.TEMPLE || b._type == _Bld.TOWNHALL)
					return pl;
		return if (a.length > 0) a[0] else null;
		/*
		var a = [];
		for( pl in planets ){
			if(pl.owner == playerId )
				a.push(pl);
		}
		var f = function(a:Planet,b:Planet){
			if(a.bld.length>b.bld.length)
				return -1;
			return 1;
		}
		a.sort(f);
		return a[0];
		*/
	}

	// IS
	public function isResearchable(t:_Tec){
		for( res in research )if( res._type == t ) return true;
		return false;
	}

	public function isTecEnabled(t:_Tec){
		return !Lambda.has(disabledTecs, t);
	}

	//
	public function getPlanet(id){
		for( pl in planets )if(pl.id==id)return pl;
		trace("planets["+id+"] not found !!! ");
		return null;
	}

	// PERSO
	public function haveTechno(t){
		for( t2 in tec )if(Type.enumEq(t,t2))return true;
		return false;
	}

	// KEY
	function initKeyListener(){
		var kl = {};
		Reflect.setField(kl,"onKeyDown",onKeyDown );
		flash.Key.addListener(cast kl);
	}

	function onKeyDown(){
		var n = flash.Key.getCode();
		switch(n){
			#if tracer
			case flash.Key.PGUP: Inter.me.toggleTracer();
			#end
		}
	}

	public static function fixTextField( f:flash.TextField, ?size:Int ){
		var fmt = new flash.TextFormat("Verdana", size);
		f.setTextFormat(fmt);
		//		f.setNewTextFormat(fmt);
		f.embedFonts = false;
	}

	// DEBUG / TRACE
//{
}




/// BEN - IMP
// COMBAT : voir effet fleur
// COMBAT : voir tir popuplation
// COLOR : message confirm
// COLOR : loas/save TECH

// BEN - BUG
// X news sur planète constructibles
// drag de la carte sur move de flotte


// BEN VIS
// gerer etat de la partie ( finie );

// BEN - new features
// Priorité des batiments
// Fuite du général
// FLEET : pouvoir selectionner une liste de destination
//- systeme de ruines
//- Panel parametres
//- scrolling de la carte à la fleche clavier


// PREFERENCE - cookies
// - stack Ship construction 	true / false;
// - autoskip construction


// - mode simple :
//	o seul les batiments actuellement disponibles apparaissent dans la liste
// - mode avancé :
//	o les batiments qui seront disponible une fois le chantier fini sont disponible dans la liste
//	o possibilité de préparer une construction sur une ile non possédée.
// - mode expert :
//	o Tous les batiments apparaissent dans la liste de construction
//



/*
[g]----- VERSION 1.0 -----[/g]

[g]UNITE :[/g]
- :ether: des polpide passe a 400 ( anciennement 420 )
- :sword: des hydrons passe a 12 ( anciennement 14 )
- :sword: des Veneflict passe a 25 ( anciennement 20 )
- La capacité ciblage des arpenteur celeste passe a 40
- :materiau: des Atlas passe a 220 ( anciennement 240 )
- :love: des Gaïa passe a 400 ( anciennement 300 )


[g]----- VERSION 0.95 -----[/g]

[g]GENERAL :[/g]
- Le bombardement s'effectue apres toutes les actions. Seules les unités survivantes peuvent bombarder.

[g]BATIMENTS :[/g]
- :love: du poirier scintillant passe a 30 ( anciennement 80 )
- le poirier scintillant n'est plus unique par ile
- L'effet du [g]Pulvérisateur[/g] devient : Les troupes attaquants l'île perdent la capacité stealth, Les priorités de ciblage des flottes attaquant l'ilot sont divisées par 2.
- Le temps de construction du [g]Pulvérisateur[/g] devient 75 ( anciennement 100 )
- :ether: des [g]fleurs de solimène[/g] devient 20 ( anciennement 25 )
- la foret n'est plus nécessaire a la construction des [g]fleurs de solimène[/g]

[g]UNITE :[/g]
- Le temps de construction des dragons passe a 550 ( anciennement 600 )

[g]TECHNO:[/g]
- temps de construction de [g]Vernis alvéolé[/g] passe a 1800 ( anciennement 1200 )
- temps de construction de [g]Dryades[/g] passe a 1800 ( anciennement 1400 )
- L'effet de [g]Communication[/g] devient : +30 max units ( anciennement 20 )

[g]----- VERSION 0.94 -----[/g]

[g]BATIMENTS :[/g]
- le palais et le temple passent a 300 pts de structures ( anciennement 400 )
- L'aciether n'est plus nécessaire a la construction des bunker
- La fonderie est nécéssaire à la construction des bunker

[g]UNITE :[/g]
- :ether: des polpide passe a 420 ( anciennement 450 )
- :shield: des polpide passe a -2 ( anciennement -1 )
- :pop: des gorgre géant passe a 2 ( anciennement 3 )
- :shield: des [g]Condor[/g] passe a 4 ( anciennement 3 )
- :materiau: des [g]Condor[/g] passe a 110 ( anciennement 120 )
- temps de construction des [g]Condor[/g] passe a 90 ( anciennement 130 )

[g]TECHNO:[/g]
- L'effet de [g]Graine fossile d'Arcadie[/g] re-devient : Le temps de construction des forets est divisé par 2.
- L'effet de [g]Héritage Dangrën[/g] devient : Vous obtenez 200 ma.
- L'effet de [g]H]Double hélice[/g] devient : Augmente de 20 points la vitesse de tous les appareils, augmente de 100 point la vitesse des apicopters
- temps de construction de [g]Héritage Dangrën[/g] passe a 240 ( anciennement 360 )
- temps de construction de [g]Dryade[/g] passe a 1400 ( anciennement 1200 )
- temps de construction de [g]Graine fossile d'Arcadie[/g] passe a 240 ( anciennement 360 )
- temps de construction de [g]Double hélice[/g] passe a 240 ( anciennement 360 )
- temps de construction de [g]Fusion cubique[/g] passe a 2200 ( anciennement 2800 )
- temps de construction de [g]Tissus fortifiés[/g] passe a 240 ( anciennement 360 )
- temps de construction de [g]Service Militaire[/g] passe a 240 ( anciennement 540 )


[g]----- VERSION 0.93 -----[/g]

[g]GENERAL :[/g]
Ajout de deux nouvelles cibles pour les flottes :
- commandement : pour viser directement le palais/temple adverse.
- special : pour classer tous les trucs qui logent pas dans les 7 autres categories.

[g]ERGONOMIE :[/g]
- mode ile : possibilité de naviguer d'un ilot vers les ilots voisins.
- mode carte : possibilité de passer d'une flotte a l'autre de la carte ( flèche en haut du panel de selection de flotte )
- apparition d'une estimation du temps de voyage lors de la selection de la destination d'une flotte.
- système de scroll de la carte en drag'n'drop

[g]BATIMENTS :[/g]
- :materiau: du golem passe a 40 ( anciennement 75 )
- :ether: du golem passe a 20 ( anciennement 50 )
- le temps de construction des golems passe a 400 ( anciennement 300 )
- les dégats des golems passe a 10. ( anciennement 5 )
- Le sculpteur n'est plus nécessaire a la construction du golem
- :ether: du sculpteur passe a 0 ( anciennement 20 )
- l'effet du sculpteur devient : Le temps de construction des golem est réduit de 50%, Le temps de construction des unité non-organique est réduit de 10%
- :materiau: des champs passe a 40 (anciennement 50)
- Le sculpteur est desormais nécessaire a la construction du poirier scintillant.
- le poirier scintillant devient unique par ile.
- :materiau: du menhir passe a 120 ( precedemment 150 )
- :ether: du menhir passe a 30 ( precedemment 50 )
- :armure: du golem passe a 3 ( precedemment 0 )
- nouveau batiment "Canon" : Les hoplite et goliath qui se déplacent depuis cette îlot gagnent 200 pt de portée et 100 point de vitesse

[g]UNITE :[/g]
- la vitesse des condors passe a 300 ( anciennement 200 )
- la vitesse des harpies passe a 200 ( anciennement 300 )
- temps de construction des arpenteurs celeste devient 40 ( anciennement 50 )
- :sword: des arpenteurs celeste passe a 2 ( anciennement 3 )
- les caracs du hoplite deviennent 20:sword: 80:love: 1:shield: ( anciennement 30:sword: 80:love: 2:shield:  )
- les caracs du goliath deviennent 30:sword: 120:love: 3:shield: ( anciennement 50:sword: 165:love: 3:shield:  )
- le cout du hoplite devient 110:materiau: 30:ether: ( anciennement 140:materiau: 50:ether: )
- le cout du goliath devient 160:materiau: 100:ether: ( anciennement 200:materiau: 150:ether: )
- les arpenteurs celestes gagnent la capacité ciblage(50) leur permettant d'ajouter une cible a 50% dans la liste des objectifs de leur flotte.

[g]TECHNO:[/g]
- L'effet de [g]art martial[/g] devient : Vos dojos gagne +3 Att, les hydrons et les arpenteurs celestes gagne +3 pts d'attaque
- L'effet de [g]Voile extensible[/g] devient : La vitesse des drakkars est augmentée de 100 points.
- L'effet de [g]Double-Hélice[/g]  devient : Augmente de 20 points la vitesse de tous les appareils
- L'effet de [g]Pistons flexibles[/g]  devient : Augmente de 100 point la vitesse des Harpie, Condor et Gaïa
- temps de construction de [g]Double-Hélice[/g] passe a  360 ( anciennement 720 )
- temps de construction de [g]Vernis alvéolé[/g] passe a 1200 ( anciennement 720 )
- temps de construction de [g]Dryade[/g] passe a 1200 ( anciennement 1080 )


[g]----- VERSION 0.92 -----[/g]

[g]GENERAL :[/g]
- L'abandon d'un joueur ne détruit plus ses batiments et ses troupes. (seule les chaines de productions et recherches sont stoppées).

[g]ERGONOMIE :[/g]
- Possibilité de voir le temps d'un voyage avant de valider ce voyage
- Mode chat/diplomatie : distinction des avatars actifs, abandon et morts

[g]BATIMENTS :[/g]
- :materiaux: du dojo devient 100 ( anciennement 80 )
- :ether: du dojo devient 0 ( anciennement 30 )
- :love: du gardener devient 50 ( anciennement 100 )
- :love: du dojo devient 150 ( anciennement 100 )
- :love: des huttes devient 75 ( anciennement 50 )
- :love: des crystaux devient 30 ( anciennement 100 )
- L'effet de la forge devient : Répare 2pts/cyc d'une troupe non-organique, Répare 10pt/cyc d'un bat
- La forge ne nécessite plus la construction du sculpteur.
- La forge n'est plus unique par ile.
- Apparition du "poirier scintillant" : Répare un point de vie d'une troupe organique a chaque tour.

[g]UNITE :[/g]
- :sword: des ghosts passe a 20 ( anicennement 25 )
- :sword: des drakkars passe a 15 ( anicennement 14 )
- la portée des drakkars passe a 400 ( anicennement 300 )
- la portée des hydrons passe a 300 ( anciennement 400 )
- La portée des arpenteurs célestes passe a 400 ( anciennement 300);
- :ether: des polpides devient 450 ( anciennement 400 )
- :shield: des polpides devient -1 ( anciennement 0 )
- temps de construction des polpide devient 320 ( anciennement 260 )
- temps de construction des dragons devient 600 ( anciennement 320 )
- :armor: des dragons passent a 1 ( anciennement 3 )
- :love: des poissons passe a 15 ( anciennement 10 )
- :ether: des goliath a 150 ( anciennement 160 )
- :materiaux: des hoplite a 140 ( anciennement 150 )

[g]TECHNO:[/g]
- Le temps de dev de "fusion cubique" passe a 2800 ( anciennement 4080 )
- Le temps de dev des dryades passe a 1080 ( anciennement 720 )
- Le temps de dev des de pilon passe 360 ( anciennement 720 )
- Le temps de dev des de souffle de feu passe à 2400 ( anciennement 1800 )
- Le temps de dev d'avoine anabolysant passe a 1400 ( anciennement 1080 )
- Le temps de dev de pieu urticant passe a 540 ( anciennement 360 )
- L'effet de "peau de granit" devient : Les golems, hoplites et Goliath gagnent 3 points d'armure
- L'effet de ethero-poing devient : Les golems, hoplites et Goliath gagnent : +10 degats
- L'effet de la techno "pieu urticant" devient : lorsqu'une de vos île est ciblée par une attaque, chaque unité attaquante subit 5 dégats a la fin du combat.
- Disparition de la techno "Camouflage"
- Apparition de la techno "Golemissaire" : Si vous attaquez avec un seul Hoplite ou un seul Goliath, doublez les dégat qu'il effectue.
- Apparition de la techno "Missile clairvoyant" : Les Condors et Ghost gagnent 5 points d'attaque



[g]----- VERSION 0.91-----[/g]

[g]ERGONOMIE :[/g]
- Possibilité de supprimer une ou plusieurs unités sélétionnées avec la touche supprime.
- Message d'avertissement si la pile de construction n'est pas logique ( moulin avant tisserand etc. )
- Possibilité de préparer une liste de constructions sur une ile qui n'appartient a personne

[g]BATIMENTS :[/g]
- le prix de construction du crystal devient 0: materiaux: 30 :ether:
- Les prerequis pour la source sacrée deviennent menhir + dojo ( anciennement orb + mine )
- Le temps de construction des fontaines passe a 75 ( anciennement 100 )
- Le temps de construction du chaudron passe a 75( anciennement 100 )
- Le temps de construction de la forge passe a 75 ( anciennement 150 )
- Le temps de construction du vaporisateur devient 75 ( anciennement 100 )
- La foret est desormais nécéssaire pour constuire les fleurs de solimène.
- le Dojo apporte +5 aux unités maximum ( anciennement + 3 )
- On ne peut desormais construire qu'une mine par ile

[g]UNITE :[/g]
- :ether: des hydron passe a 40. (anciennement 60)
- :love: des hydron passe a 40. (anciennement 20)
- le temps de construction des hydrons passe a 80 ( anciennement 100 )
- Les degats des Hoplite passe a 30 ( anciennement 25 )
- :ether: des goliath passe a 160 ( anciennement 200 )

[g]TECHNO:[/g]
- L'effet du cimetierre devient Lorsqu'une de vos unités et détruite dans un combat, vous gagnez 20% de son cout en ether
- L'effet de la graine fossile d'arcadie devient : Le temps de construction des forets est divisé par 3.
- L'effet de la pierre de Zoreth devient : Vos temps de recherches sont diminués de 25% ( anciennement 20 )
- Apparition de la techno "Dryade" : Vos forêts apportent 1ether a chaque cycle.
- Apparition de la techno "Eruption miraculeuse" : Vos sources sacrées apportent 4eth / cycle supplémentaire


[g]----- VERSION 0.9-----[/g]

[g]GENERAL :[/g]
- Apparition de la caracteristique "vitesse" dans les infos contextuelle de flotte.
- la capacité meutte ne fonctionne plus sur les batiments.
- la capacité répartition fonctionne desormais sur les batiments.

[g]UNITE :[/g]
- :love: des poissons passe a 10 ( anciennement 20 )
- le temps de construction des arpenteurs celestes passe a 50 ( anciennement 100 )

[g]BATIMENTS :[/g]
- :love: des fleurs passe à 10 ( anciennement 30 );
- Le temps de construction du crystal passe a 50 ( anciennement 100 );
- Le temps de construction des huttes passe a 50 ( anciennement 100 );
- :ether: du dojo passe a 30 (anciennement 50 );
- le Dojo apporte +3 en attaque ( anciennement +4 )
- le Dojo apporte +3 aux unités maximum
- La graine fossile d'arcadie est désormais nécessaire a la construction des fleurs de Solimènes

[g]TECHNO:[/g]
- L'effet de la graine fossile d'arcadie devient : Le temps de construction des forets est divisé par 2. Vous pouvez consruire des fleurs des Solimène
- La recherche Pierre de Zoreth passe a 540 minutes ( anciennement 720 )
- La techno vernis alvéolé devient : " Tous vos vaisseaux gagnent 10 pts de structure, vos vaisseaux sont immunisés aux effets des parasites."
- Apparition de la techno "Truelles libellules" : Le temps de construction des batiments est réduit de 30%
- Apparition de la techno "Bain purificateur" : A chaque cycle et pour chaque fontaine que vous possedez sur une ile, retirez un status négatif sur une unité stationnant sur cette ile.




[g]----- VERSION 0.8-----[/g]

[g]GENERAL :[/g]
- Possiblité de sauvegarder/charger, l'ordre des technologies
- Augmentation de 50% de toutes les durée de voyages.
- Passage a la vitesse normale du jeu x1 ( anciennement x1.5 )

[g]UNITE :[/g]
- :ether: des Ballons passe a 20 ( anciennement 15 )
- :materiau: des Bombardiers passe a 40 ( anciennement 50 )
- :ether: des Bombardiers passe a 20 ( anciennement 15 )
- :material: des Mires passe a 150 ( anciennement 180 )
- :ether: des Mires passe a 80 ( anciennement 40 )
- :ether: des Atlas passe a 160 ( ancienement 100 )
- :material: des Atlas passe a 240 ( ancienement 250 )
- :ether: des Gaïa passe a 200 ( anciennement 100 )
- Le temps de construction des ballons et et bombardiers est réduit de 20%.

[g]TECHNO:[/g]
- La recherche Tissus fortifiés passe a 360 minutes ( anciennement 720 )
- La recherche Service militaire passe a 540 minutes ( anciennement 720 )
- La recherche Pistons flexibles passe a 720 minutes ( anciennement 1200 )
- La recherche Tracteur a passe a 2160 minutes ( anciennement 2800 )
- La recherche Communications passe a 720 minutes ( anciennement 1400 )
- La recherche Etheroduc passe a 720 minutes ( anciennement 540 )
- La recherche Fusion cubique passe a 4080 minutes ( anciennement 5100 )
- L'effet de Aciether devient : Augmente l'armure des Gaia, Condor et Fantome de 3 points, permet de construire les bunker, permet de construire les Gaia (1/2)
- L'effet de Fusion cubique devient : Augmente de 100 point la vitesse des Atlas et des Mires, permet de construire les Gaia (1/2)


[g]BATIMENTS :[/g]
- :material: des pompes passe à 60 ( anciennement 100 )
- :sword: du fort passe a 60 ( anciennement 50 )
- La manufacture ne réduit plus les temps de constructions des appareils volant de 10%
- L'effet de l'architect devient : -30% temps de construction batiments, -20% temps de construction des vaisseaux
- pv des pompes passent à 50.

[g]CORRECTION BUG :[/g]
- plus de chargement pendant un drag'n'drop



[g]----- VERSION 0.7-----[/g]

[g]GENERAL :[/g]
- les unités en cours de construction ne sont plus empilées.
- Les batiments dans la liste de construction sont ordonnés par ordre d'importance.
- possibilité de selectionner toutes les troupes d'un type particulier avec shift+click .
- Ajout d'un msg de confirmation sur le retour et l'atterrisage des flottes

[g]UNITE :[/g]
- :shield du condor passe a 3 points ( anciennement 4 )

[g]BATIMENTS :[/g]
- le fonctionnement de la fonderie devient : +2 :materiau: par cycle
- La fonderie doit desormais être construite sur un puit d'ether

[g]CORRECTION BUG :[/g]
- bug de la scrollbar qui revient en haut a chaque selection/click/chargement corrigé.
- bug du retour dans le passé ( pointeur de cycle ) a chaque zoom arriere vers la carte fixé
- lorsqu'un joueur est viré d'une ile son nom est desormais retiré correctement.
- Correction de calcul du temps total.
- Le message "batiment déjà construit" apparait desormais correctement.
- Correction du bug de la touche control
- Bug permettant d'envoyer une mauvaise position pour le palais de départ corrigé.
- Bug permettant de construire des batiments larges les uns sur les autres corrigé.



[g]----- VERSION 0.6-----[/g]

[g]GENERAL :[/g]
- la population est dépensé a la fin d'une construction et non au début.
- Il n'est desormais plus possible d'avoir plus de 3 chantiers commencés dans la liste ( unités + batiments )

[g]UNITE :[/g]
- Le cout en :bonom: des Atlas passe a 4 ( anciennement 3 )
- Le cout en :materiau: des Condor passe a 120 ( anciennement 140 )
- La capacité raid des condors passe a 20 ( anciennement 15 )
- Le cout en :materiau: des harpies passe a 60 ( anciennement 80 )
- La capacité bombardier des bombardier (wtf?) passe a 40 ( anciennement 35 )
- Le cout en :materiau: des harpies passe a 60 ( anciennement 80 )
- Le cout en :ether: des ghost passe -pour de vrai- a 50 ( anciennement 60 )
- Le cout en :materiau: des ghost passe a 50 ( anciennement 60 )

[g]TECHNO:[/g]
- L'effet de l'acieter devient : Augmente l'armure des Gaia, Golgoth et Fantome de 3 points ( anciennement 2 )
- L'etheroduc passe à 540 minutes ( anciennement 3500 )
- La recherche piston flexible passe a 1200 minutes ( anciennement 2800)
- La recherche Aciethere passe a 1200 minutes ( anciennement 1400)

[g]BATIMENTS :[/g]
- les puits d'ether ne rapportent plus que 1 ether / tours
- le fonctionnement de la fonderie devient : +1 :materiau: par cycle
- le prix de la fonderie devient : 60x :materiau: 60x :ether:
- La tour de guet est limité a une construction par ile
- les :materiau: du tisserand repasse à  120 ( precedemment 150 )
- les :materiau: de la pompe passe 100 ( precedemment 150 )

[g]CORRECTION BUG :[/g]
- bug du message d'erreur "batiment déjà construit" non-justifié dans le chantier corrigé.
- les temps de construction lorsqu'il ne reste plus qu'un seul habitant ont été réduits ( anciennement 1x :bonom: = 2x:bonom: )
- Plus de temps abérants dans le chantier lorsque la population passe à zero ( -> "infini" )



[g]----- VERSION 0.5-----[/g]

[g]GENERAL :[/g]
- la limite d'unité concerne desormais le cout en :bonom: des unités. ( ex : 2 drakkar + 1 api = 5 )
- la limite d'unité totale ( apres bonus ) ne peut dépasser 100 par joueurs.
- Il est désormais possible de visualiser un combat en cliquant sur la news du combat dans l'îlot concernée.

[g]UNITE :[/g]
- L'université est désormais nécessaire à la construction des gaïa
- Le cout en :ether: des ghost repasse a 50 ( anciennement 60 )
- Le capacité assault des harpies passe a 8 ( anciennement 6 )

[g]TECHNO:[/g]
- La propulsion etherale passe a 2800 minutes ( anciennement 3500 )

[g]BATIMENTS :[/g]
- Les école et université sont de nouveaux constructible sur toutes les iles.
- Le bonus de l'ecole passe a 25% ( anciennement 20 ). Il n'est pas cumulable
- Le bonus de l'université passe a 40% ( anciennement 40 ). Il n'est pas cumulable
- La techno "poudre a canon" entre dans les prérecquis pour la construction du fort.
- Le fort n'augmente plus la limite de 5 unités
- :sword: du fort passe à 50 ( anciennement 40 )
- la caserne augmente la limite de 2 unités.
- :shield: des caserne passe à 0 ( anciennement 1 )
- :materiau: du tisserand passe a 150 ( anciennement 100)
- le tisserand est desormais nécessaire pour construire des atlas
- le temps de construction de l'atelier est augmenté de 50%
- le temps de construction du tisserand est augmenté de 50%

[g]CORRECTION BUG :[/g]
- Les upgrades de champs fonctionennent correctement ( engrais + tracteur )
- Bug du panel de droite qui reste scotchée apres l'instalation sur une ile corrigé.
- Bug de l'ile qui ne se colorie pas directement apres l'installation corrigé.
- Bug d'atterrisage des Apicopters corrigé ( -kRet )
- Les mises a jour automatiques de l'île doivent desormais s'effectuer correctement lorsque :
--- la population augmente
--- un chantier est fini
--- une attaque arrive sur l'île

----- VERSION 0.4 -----

[g]GENERAL :[/g]
- Les règles de combats ont été modifiées :
--- Un appareil ne peut plus être pris pour cible dès que ces pv sont < 0
--- Seul les appareils qui n'ont pas tiré lors de la phase aerienne participent a la phase terrestre.
- Vitesse de jeu : les cycles passent 450 secondes  ( anciennement 300 secondes )


[g]UNITE :[/g]
- la vitesse des Harpie passe a 300
- :shield: des Condor passe a 4 ( anciennement 3)
- La caserne entre dans les prérecquis pour la construction du condor.
- :shield: des Gaia passe a 4 ( anciennement 5 )
- :bonom: des Gaia passe  6 ( anciennement 4 )
- :ether: des mires passe a 40 ( anciennement 30 )
- :sword: des mires passe a 30

[g]TECHNOS :[/g]
- La fusion Cubique passe a 5100 minutes ( anciennement 4200 )
- l'etheroduc passe à 3500 minutes ( anciennement 4200 )

[g]BATIMENTS :[/g]
- :materiau: des canons passe à 60





*/




// NEXT RACE

// [TEC][BAT] les trouppes défendantes gagne +1 armure.












