import Datas;
import mt.bumdum.Lib;

class Planet {//}

	public var id:Int;
	public var owner:Int;
	public var lastUpdate:Float;

	public var pop:Int;
	public var food:Int;

	public var bld:Array<DataBuilding>;
	public var shp:Array<DataShip>;
	public var yard:Array<DataConstruct>;
	public var availableShp:Array<_Shp>;
	public var availableBld:Array<_Bld>;
	public var news:Array<DataNews>;

	public var attributes:List<_PlanetAttribute>;

	public var popMax:Int;
	public var breed:Counter;

	public var att:Int;
	public var def:Int;

	public var cz:Float;
	public var x:Int;
	public var y:Int;
	public var bs:Int;

	public function new( id, px, py, s ){
		this.id = id;

		x = px;
		y = py;
		bs = s;
		Game.me.planets.push(this);
		var seed = new mt.Rand(bs);
		cz = seed.rand();

		//ressources = [0,0,0,0];
		shp = [];
		bld = [];

	}


	public function incTime(n){

	}

	// PUBLIC
	public function getSeed(){
		return new mt.Rand(bs);
	}
	public function getGrid(){
		return Tools.buildIsle(bs);
	}

	//
	public function update(){

	}

	// TOOLS

	public function isMine(){
		return owner == Game.me.playerId;
	}

	// AVAILABLES
	public function updateAvailables(){
		// FUTUR
		var world = getFutur();

		// CHECK AVAILABLE BLD
		availableBld = [];
		var a = BuildingLogic.ALL;
		for( b in a ){
			if (b.race == Game.me.raceId){
				var ok = true;
				var lacks = b.requirementsMet(world.bld, world.tec);
				for (lack in lacks){
					switch (lack){
						case _LackTec(tec):
							if (Param.is(_ParamFlag.PAR_TECHNO_MASK))
								ok = false;
							else
								ok = ok && Game.me.isResearchable(tec);
							
						default:
							ok = false;
					}
				}
				if (ok)
					availableBld.push(b.kind);
			}
		}

		// CHECK AVAILABLE SHP
		availableShp = [];
		for (ship in ShipLogic.ALL){
			var flOk = true;
			var lacks = ship.requirementsMet(world.bld, world.tec);
			for( lack in lacks ){
				switch(lack){
					case _LackTec(b):
						if( Param.is(_ParamFlag.PAR_TECHNO_MASK) ){
							flOk = false;
						}else{
							flOk = flOk && Game.me.isResearchable(b);
						}

					default :
						flOk = false;
				}
			}
			if(flOk)
				availableShp.push(ship.kind);
		}

	}

	public function getPresent(){
		var blds = new List();
		for( db in bld )blds.push(db._type);
		var tec = Lambda.list( Game.me.tec );

		return { bld:blds, tec:tec };

	}

	function getFutur(){
		// FUTUR BLDS LIST
		var blds = new List();
		for( db in bld ){
			blds.push(db._type);
		}
		for( dc in yard){
			switch(dc._type){
				case Building(type):
					blds.push(type);
				default:
			}
		}
		// SIMPLIFY BLDS
		var a = [];
		for( b in blds){
			var bid = Type.enumIndex(b);
			if( a[bid] )blds.remove(b);
			a[bid] = true;
		}
		// TECS
		var tec = Lambda.list( Game.me.tec );
		// for( t in research )tec.push(t._type); // TODO
		return  { bld:blds, tec:tec };

	}
	public function getRes():_Cost{

		return {
			_material:	Game.me.res._material,
			_cloth:		Game.me.res._cloth,
			_ether:		Game.me.res._ether,
			_pop:		pop,
		}

	}

	// TOOLS
	public function getBuildings(){
		var a = [];
		for( db in bld )a.push(db._type);
		return a;
	}

	// DATAS TRANSFER
	public function loadData(data:DataPlanet){

		lastUpdate = Game.me.now();

		breed = data._breed;
		owner = data._owner;
		pop = data._pop;
		food = data._food;
		att = data._att;
		def = data._def;

		bld = data._bld;
		shp = data._ship;
		yard = data._yard;

		news = data._news;

		updateAvailables();

	}
	public function loadYard(a){
		yard = a;
		updateAvailables();
	}

	//
	public function isOld(){
		if( lastUpdate == null )return true;
		if( Game.me.now()-lastUpdate > Cs.AUTO_UPDATE_PLANET_IN )return true;


		if(Game.me.world.data._mode == _GameMode.MODE_PLAY ){
			if( breed!=null && Game.me.getCounterInfo(breed).c >=1  )return true;

			if( yard.length>0 ){
				var counter = yard[0]._counter;
				if( counter!=null && Game.me.getCounterInfo(counter).c >=1  ){
					var flWait = false;
					switch( yard[0]._type ){
						case Building(b): flWait = Tools.getBldCost(b).population < this.pop;
						case Ship(s):
						flWait = Tools.getShpCost(s).population > this.pop;
					}

					if(!flWait){
						Game.me.world.lastUpdate = null;
						return true;
					}else{

					}
				}
			}



		}

		return false;



	}
	public function secureLaunch(f){
		if( isOld() ){
			Api.getDataPlanet(id, f);
		}else{
			f();
		}

	}


//{
}



/*
120
108
97
87
78
70

90
81
73
65
59
53

90
72
57
46
36


* /


/*
[Player]
Id:Int
Res:Array<Int>
Tec:Array<Tec>


[Planet]
owner:Int
pop:Int
food:Int
*/











