import MissionInfo;
import Protocol;
import mt.OldRandom;

class PlayerInfo{//}


	static public var FL_RESET = false;

	public var flAdmin:Bool;
	public var flEditor:Bool;

	public var pid:Int;

	public var ox:Int;
	public var oy:Int;

	public var x:Int;
	public var y:Int;

	public var chl:Int;
	public var chs:Int;
	public var minerai:Int;
	public var missions:Array<Int>;
	public var square:Array<Int>;
	public var missile:Int;
	public var missileMax:Int;

	var life:Int;
	public var engine:Int;
	public var radar:Int;
	public var drone:Int;

	public var pendingLevels:Int;

	public var fog:Array<Int>;
	public var items:Array<Int>;
	public var shopItems:Array<Int>;
	public var comp:Array<Int>;

	public var travel:Array<_Travel>;
	public var houseDone:Array<Array<Int>>;

	public static var DEFAULT_X = 0;
	public static var DEFAULT_Y = 0;



	public function new(){


		fog = [];


		// DEFOG


		var max  = 20*20;
		for( i in 0...max ){
			//var n = null;
			//if(Std.random(10)==0)n=1;
			//fog.push(n);
			fog.push(1);
		}




	}

	public function parseInfo(str){

		var pc = new mt.PersistCodec();
		pc.crc = true;
		var info : _PlayerData = pc.decode(str);

		flAdmin = 		info._flAdmin;
		flEditor = 		info._flEditor;

		pid =			info._pid;
		x = 			info._x;
		y = 			info._y;
		ox = 			info._ox;
		oy = 			info._oy;

		chl = 			info._chl;
		chs = 			info._chs;
		minerai = 		info._minerai;
		missions = 		info._missions;
		missile = 		info._missile;
		missileMax = 		info._missileMax;

		engine = 		info._engine;
		radar = 		info._radar;
		life = 			info._life;
		drone = 		info._drone;
		pendingLevels =		info._pendingLevels;
		square = 		info._square;

		items = 		info._items;
		shopItems = 		info._shopItems;
		fog = 			info._fog;
		comp = 			info._comp;

		travel =		info._travel;



	}
	public function setToDefault(){

		/*
		Cs.log("---------");
		Cs.log("RESET ALL");
		Cs.log("---------");
		*/

		flAdmin = false;
		flEditor = false;

		pid = Std.random(200);
		x = DEFAULT_X;
		y = DEFAULT_Y;
		ox = DEFAULT_X;
		oy = DEFAULT_Y;

		chl=2;
		chs=0;
		minerai=0;
		missions=[0];
		missile = 0;
		missileMax = 0;
		square = null;

		engine=1;
		radar = 1;
		life=3;
		drone=0;
		pendingLevels=0;

		items = [MissionInfo.TRIGGER];
		shopItems = [];
		comp = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

		travel = [];
		houseDone = [];



	}

	// TOOLS
	public function getLife(){
		return life - travel.length;
	}

	public function getRay(){
		var sr = 32;
		#if test
		return 32;
		#end
		if( gotItem(MissionInfo.EXTENSION)) 	sr += 10;
		if( gotItem(MissionInfo.EXTENSION_2)) 	sr += 8;
		if( gotItem(MissionInfo.EXTENSION_3)) 	sr += 10;
		if( gotItem(MissionInfo.EVASION)) 	sr -= 10;

		return sr;
	}
	public function getMissileType(){
		var n = 0;
		if( gotItem(MissionInfo.MISSILE_BLUE ))		n=1;
		if( gotItem(MissionInfo.MISSILE_BLACK ))	n=2;
		if( gotItem(MissionInfo.MISSILE_RED )	)	n=3;
		return n;
	}
	public function getMissileCadence(){
		var n = 16;
		if( shopItems[ShopInfo.COOLER] == 1 )n=8;
		return n;
	}
	public function getMissileTurnSpeed(){
		var n = 0.2;
		if( shopItems[ShopInfo.LATERAL] == 1 )n=0.35;
		return n;
	}

	// IS ?
	public function gotItem(n){
		var n = items[n];
		return n == MissionInfo.COLLECTED || n == MissionInfo.COLLECTED_INV;
	}

#if inventory
#else

	public function loadCache(?so){

		if(so==null){
			so = flash.SharedObject.getLocal("info");
			if( so.data.x==null || FL_RESET  || so.data.missions.length==0 ){
				setToDefault();
				saveCache();
				return;
			}
		}

		flAdmin = 	true;
		flEditor = 	false;

		pid = 			0;
		x = 			so.data.x;
		y = 			so.data.y;
		ox = 			x;
		oy = 			y;

		chl = 			so.data.chl;
		chs =		 	so.data.chs;
		minerai =		so.data.minerai;
		missions = 		so.data.missions;

		missile = 		so.data.missile;
		missileMax = 		so.data.missileMax;

		engine = 		so.data.engine;
		radar = 		so.data.radar;
		life = 			so.data.life;
		drone = 		so.data.drone;
		square = 		so.data.square;

		items =  		so.data.items;
		shopItems =  		so.data.shopItems;
		comp = 			so.data.comp;

		travel =		so.data.travel;
		houseDone =		so.data.houseDone;

		//shopItems[ShopInfo.SUNGLASSES] = null ;
		//items[MissionInfo.MODE_DIF] = 2 ;

		items[MissionInfo.MINES] = null;

		/*
		if(flAdmin){
			for( i in 0...130) items[i] = 2;
			for( i in 0...50) shopItems[i] = 1;
			missile = 50;
			missileMax = 50;


		}
		//*/



		/*
		items[MissionInfo.MINES] = 	2;
		shopItems[ShopInfo.MINE_0] = 	0;
		shopItems[ShopInfo.MINE_1] = 	0;
		shopItems[ShopInfo.MINE_2] = 	0;
		/*/


		/*
		var so = flash.SharedObject.getLocal("pendingLevels");
		var px = x+Api.CACHE_GRID_MARGIN;
		var py = y+Api.CACHE_GRID_MARGIN;
		pendingLevels = so.data.grid[px][py].length;
		if( pendingLevels == 0 ){
			var so2 = flash.SharedObject.getLocal("baseNiveaux");
			if( so2.data.grid[px][py]!=null ){
				pendingLevels = -1;
			}
		}
		*/



		/* HACK
		shopItems[ShopInfo.SUNGLASSES] = 	1;
		shopItems[ShopInfo.PODS] = 		1;

		shopItems[ShopInfo.LANDER_REACTOR_0] =	0;

		shopItems[ShopInfo.PODS_EXTEND_0] =	0;
		shopItems[ShopInfo.PODS_EXTEND_1] =	0;
		shopItems[ShopInfo.PODS_EXTEND_2] =	0;


		items[MissionInfo.LANDER_REACTOR] = 	2;


		items[MissionInfo.EXTENSION] = 		2;
		items[MissionInfo.COMBINAISON] = 	2;
		items[MissionInfo.MISSILE_BLACK] = 	2;
		//*/


		/* TRACE ITEMS
		var id = 0;
		while(true){
			var str = "";
			for( i in 0...3){
				str += id+">"+missions[id]+"  ";
				id++;
			}
			trace(str);
			if(id>=missions.length)break;
		}
		*/

	}

	public function saveCache(?so){

		if(so==null)so = flash.SharedObject.getLocal("info");


		//trace(saveCache)

		//if(minerai<=0)minerai=1000;
		//shopItems=[];*
		//items[MissionInfo.MAP_SHOP] = MissionInfo.COLLECTED_INV;
		//Cs.log("save--->"+items);

		so.data.flAdmin =		flAdmin;
		so.data.flEditor = 		flEditor;

		so.data.pid =			pid;
		so.data.x = 			x;
		so.data.y = 			y;

		so.data.chl = 			chl;
		so.data.chs =		 	chs;
		so.data.minerai =		minerai;

		so.data.missions = 		missions;
		so.data.missile = 		missile;
		so.data.missileMax = 		missileMax;

		so.data.engine = 		engine;
		so.data.radar = 		radar;
		so.data.life = 			life;
		so.data.drone = 		drone;
		so.data.square = 		[0,5,3];

		so.data.items =  		items;
		so.data.shopItems =  		shopItems;
		so.data.comp = 			comp;

		so.data.travel =		travel;
		so.data.houseDone =		houseDone;

		//trace( (so.data.x==null)+" || "+(FL_RESET)+" || "+(so.data.missions.length==0) );

		so.flush();

		//trace( (so.data.x==null)+" || "+(FL_RESET)+" || "+(so.data.missions.length==0) );

	}

	// EMULATION SERVEUR
	// - Fonctions destinées au devellopement, a réécrire coté serveur.

	// Ajoute un item au joueur
	public function addItem(id){
		if(id==null)return;

		// VALIDE L'ITEM
		var n = items[id];
		if( n == MissionInfo.TRIGGER ){
			items[id] = MissionInfo.COLLECTED_INV;
		}else{
			items[id] = MissionInfo.COLLECTED;
		}

		// MISSILES
		if( id >= MissionInfo.MISSILE && id < MissionInfo.MISSILE+MissionInfo.MISSILE_MAX ){
			missileMax++;
			missile = missileMax;
		}

		//
		switch(id){
			case MissionInfo.SUPER_RADAR : radar++;
		}

	}

	// Achete un shopItem.
	public function buyShopItem(id){
		var info = ShopInfo.ITEMS[id];

		// ADD ITEM
		switch(id){
			case ShopInfo.CHS :		chs++;
			case ShopInfo.AMMO :
				missile = missileMax;
				//navi.Map.me.game.missile.set(new mt.flash.VarSecure(missileMax));
			default :
				shopItems[id] = 1;
				if( id==ShopInfo.LIFE )	life++;
				if( id==ShopInfo.DRONE )drone++;
				if( id==ShopInfo.RADAR ){
					radar++;
					addItem(MissionInfo.RADAR_OK);
				}
				if( id>=ShopInfo.ENGINE && id<ShopInfo.ENGINE+ShopInfo.ENGINE_MAX ){
					var pw = 2+id-ShopInfo.ENGINE;
					if(pw>engine)engine = pw;
				}
				if( id>=ShopInfo.MISSILE &&  id<ShopInfo.MISSILE+3){
					missileMax++;
					missile = missileMax;
				}
		}

		// APPLY PRICE
		minerai -= getPrice(id);


	}

	// Calcul le prix d'un élément en boutique
	public function getPrice(id){
		/*
		var item = ShopInfo.ITEMS[id];
		var p = item.price;

		switch(id){
			case ShopInfo.AMMO: 	p = missileMax-missile;A
			case ShopInfo.DRONE: 	p =  Std.int( Math.pow(drone+6,4)/100 )*100;
		}

		var seed = new mt.OldRandom( x*10000 + y + id*20 );
		var sens = seed.random(2)*2-1;
		var c = Math.pow(seed.rand(),4);
		p += Std.int(p*0.5*c*sens);
		*/
		var p = switch(id){
			case ShopInfo.AMMO: missileMax - missile;
			case ShopInfo.DRONE: Std.int( Math.pow(drone+6,4)/100 )*100;
			default: ShopInfo.ITEMS[id].price;
		}

		var seed = new mt.OldRandom( Std.int( Math.abs(x)*10000 ) + Std.int( Math.abs(y) + id*20 ) );
		var sens = seed.random(2)*2-1;
		var c = Math.pow(seed.rand(),4);
		p += Std.int(p*0.5*c*sens);


		return p ;
	}

	// Vérifie les missions - a appeler apres chaque endGame
	public function checkMission(){

		//trace("checkMission"+missions);

		// CHECK FINISH
		for( n in 0...MissionInfo.LIST.length ){
			var mi = MissionInfo.LIST[n];
			if( missions[n]==0 && isAllConditionsOk(mi.conditions) ){

				missions[n] = 1;
				for( a in mi.endItem )addStuff(a);
			}
		}

		// CHECK NEW
		for( n in 0...MissionInfo.LIST.length ){
			var mi = MissionInfo.LIST[n];
			if( missions[n]==null && isAllConditionsOk(mi.startConditions) ){
				missions[n] = 0;
				for( a in mi.startItem )addStuff(a);
				//trace("new["+n+"]");

			}
		}

		//trace(missions);


	}

	// Vérifie si les conditions sont remplies
	public function isAllConditionsOk(list:Array<Array<Int>>){
		for( a in list ){
			if( !isConditionOk(a) )return false;
		}
		return true;
	}

	public function isConditionOk(a){
		switch(a[0]){
			case MissionInfo.GOT_ITEM :
				for( n in 1...a.length ) if( !gotItem(a[n]) ) return false;

			case MissionInfo.NOT_ITEM :
				return !gotItem(a[1]);

			case MissionInfo.GOT_SHOPITEM :
				for( n in 1...a.length ) if( shopItems[a[n]] != 1 ) return false;

			case MissionInfo.GOT_PLANET :
				return comp[a[1]] >= 100 ;

			case MissionInfo.GOT_MINERAI :
				return a[1] <= minerai ;

			case MissionInfo.ENTER_ZONE :
				var dx = a[1] - x;
				var dy = a[2] - y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				return dist <= a[3];

			case MissionInfo.LEAVE_ZONE :
				var dx = a[1] - x;
				var dy = a[2] - y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				return dist > a[3];

			case MissionInfo.GOT_MISSION :
				return missions[a[1]] == 1;

			case MissionInfo.IS_LEVEL :
				return false; // TODO SERVER



		}
		return true;
	}


	// ajoute au joueur les recompenses d'une mission
	public function addStuff(a){
		switch(a[0]){
			case MissionInfo.MINERAI :		minerai += a[1];
			case MissionInfo.NEW_LIFE :		life++;
			case MissionInfo.LOSS_LIFE :		life--;
			case MissionInfo.NEW_RADAR :		radar++;
			case MissionInfo.LOSS_RADAR :		radar--;
			case MissionInfo.RESET_MISSION :	missions[a[1]] = null;
			default :				items[a[0]] = a[1];

		}
	}

#end
//{
}


/*
Je vais apporter quelques précisions pour qu'on se comprenne mieux :

Le mode nightmare est un mode difficile.
Par difficile j'entend que même les joueurs les plus expérimentés auront besoins de plusieurs tentative pour finir certains niveaux.
C'est un mecanisme de jeu-video plutot standard : je rate -> je recommence.

Le problème en ce qui concerne alphabounce est que le jeu de départ ne respecte pas réellement ce principe afin d'etre accessible au plus grand nombre et ne pas





*/
















