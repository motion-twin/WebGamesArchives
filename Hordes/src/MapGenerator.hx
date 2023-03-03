import Common;
import db.Map;
import db.Zone;
import data.Explo;
import mt.MLib;

using Lambda;
class MapGenerator {

	public static function generate( map : Map, rnd:neko.Random ) : Array<Zone> {
		// Création des Zones
		var zz : Array<Zone> = new Array();
		var y = 0;
		//
		for( i in 0...map.width ) {
			var x = 0;
			for( j in 0...map.width ) {
				var z = new Zone();
				z.map = map;
				z.fillWithItems();//Should be seeded as well ?
				z.x = x;
				z.y = y;
				zz.push( z );
				x++;
			}
			y++;
		}
		// Création de la ville
		var radius = 	if ( map.isBig() ) Math.round(Const.get.CityMinSpawnRadius * 1.5) 
						else Const.get.CityMinSpawnRadius;

		var zza =  zz.filter( function(z : Zone) {
								if( z.x < radius ||  z.x > Std.int( map.width - radius - 1  ) || z.y < radius || z.y > Std.int( map.width - radius - 1 ) )
									return false;
								return true;
							} ).array();
		var city = zza[rnd.int(zza.length)];
		city.type = Zone.TYPE_CITY;
		city.checked = true;
		city.tempChecked = true;

		// calcul des infos relatives à la ville (level, direction)
		var maxZoneLevel = 0;
		for( z in zz ) {
			z.direction = Cron.getDirection( {x:city.x, y:city.y}, {x:z.x, y:z.y} );
			
			var zoneLevel = Cron.getZoneLevel( {x:city.x, y:city.y}, {x:z.x, y:z.y} );
			if( zoneLevel > maxZoneLevel )
				maxZoneLevel = zoneLevel;
			
			z.level = 	if ( zoneLevel == 0 ) 1 
						else zoneLevel;
		}
		// Ajout des batîments
		addOutsideBuildings(map, zz, {x:city.x, y:city.y}, rnd.int);
		// Ajout des fontaines de Zombies
		createZombieFountains( map, zz, rnd.int );
		// Insertion en base
		for( z in zz )
			z.insert();
		// MAJ Map
		map.maxZoneLevel = maxZoneLevel;
		map.cityId = city.id;
		map.update();
		return zz;
	}
	
	/**
	 * Note, appelée à l'initialisation de la ville, car le générateur doit savoir si la ville est pandémonium ou non.
	 * Cela ne peut PAS se savoir à la génération car modifié ultérieurement (update des maps)
	 */
	public static function addExploBuildings( map:Map, zones:Iterable<Zone>, ?rnd:Int->Int ) {
		if( rnd == null ) rnd = Std.random;
		//
		if( !map.hasMod("EXPLORATION") ) return;
		
		var eVar = db.MapVar.manager.getVar(map, "explorations" );
		if ( eVar != null && eVar.value != 0 )
			return;
			
		if( eVar != null ) {
			eVar = db.MapVar.manager.get(eVar.id, true);
			if( eVar.value > 0 ) return;
		} else {
			eVar = new db.MapVar(map, "explorations", 0);
			eVar.insert();
		}
		
		
		var zza = if ( !map.isHardcore() ) {
			var maxLevelForBuildingRNE = 10;//TODO mettre ds const.xml
			Lambda.filter( zones, function(z) return z.type == 0 && z.level >= Const.get.ExploMinSpawnRadius && z.level <= maxLevelForBuildingRNE ).array();
		} else {
			Lambda.filter( zones, function(z) return z.type == 0 && z.level >= Const.get.ExploMinSpawnRadius ).array();
		}
		
		var exploTypes = [ExploKind.Bunker, ExploKind.Hospital, ExploKind.Hotel];
		var count = 0;
		
		function dropExplo( zones ) {
			if( zza.length == 0 ) return;
			var kind = exploTypes[rnd(exploTypes.length)];
			exploTypes.remove(kind);
			//
			try {
				var z = zza[rnd(zza.length)];
				z = Zone.manager.get(z.id, true);
				z.type = Const.get.MaxNormalOutsideBuilding + Type.enumIndex(kind);
				z.zombies = Std.int(z.level / 2);
				z.update();
				var explo = new db.Explo(kind, z);
				var zombiesCount = z.zombies;
				var roomsCount = Const.get.ExploRoomCount;
				explo.data = explo.generateExplo( map, 15, 15, roomsCount, zombiesCount );
				explo.insert();
				//
				zza.remove(z);
				count ++;
			} catch( e:Dynamic ) {}
		}
		
		dropExplo(zza);
		if( map.isHardcore() ) {
			zza = Lambda.filter( zza, function(z) return z.type == 0 && (z.level >= 8 || z.level <= 10 ) ).array();
			if( zza.length > 0 )
				dropExplo(zza);
		}
		//
		eVar.value = count;
		eVar.update();
	}
	
	static function addOutsideBuildings( map:Map, zones : Array<Zone>, center: {x:Int,y:Int}, ?rnd:Int->Int ) {
		if( rnd == null ) rnd = Std.random;
		//
		var pump = 0;
		var zl = zones.length;
		var found = false;
		var count = if ( map.isBig() ) Const.get.MaxOutsideBuildingsRE
					else Const.get.MaxOutsideBuildingsRNE;
		
		if( !map.isBig() ) {
			var minLevelForBuildingRNE = 3;//TODO mettre ds const.xml
			zones = Lambda.array(Lambda.filter(zones, function(z) return z.level >= minLevelForBuildingRNE));
		}
		
		var currentZone = null;
		var maxIter = 100;
		while( count > 0 && maxIter-- > 0) {
			currentZone = zones[Std.random(zl)];//ici vrai random, pour la position
			if( currentZone == null || currentZone.type != 0 )
				continue;
			
			//mais random seedé possible pour le type de batiment
			var all = XmlData.getOutsideBuildings();
			// préparation d'une table de tirage (pondérée) entre level-3 et level+1
			var draw = new Array();
			var possibles = new List();
			var lbase = currentZone.level+1;
			do {
				lbase--;
				possibles = all.filter( function(b) { return b.level >= lbase - 3 && b.level < lbase + 1; } );
			} while( possibles.length == 0 && lbase > 0 );
			
			for( b in possibles ) {
				var mul = 	if(b.level == lbase) 6
							else if(b.level < lbase) 2
							else if(b.level > lbase) 1;
				for(i in 0...b.probaMap * mul)
					draw.push(b);
			}
			
			if( draw.length == 0 )
				throw "addOutsideBuildings failed : empty draw list";
			
			var b = draw[rnd(draw.length)];
			currentZone.type = b.id;
			if( rnd(100) < Const.get.BuriedChance )
				currentZone.diggers = rnd( Const.get.Diggers );
			else
				currentZone.diggers = 0;
			count --;
		}
	}
	
	public static function createZombieFountains( map:Map, baseZones : Array<Zone>, ?fl_update = false, ?rnd:Int->Int ) {
		if ( rnd == null )  rnd = Std.random;
		//
		if( baseZones.length <= 0 )
			return;
		//
		var minLevelForZonzons = map.isBig() ? 0 : 2;//TODO mettre ds const.xml
		var zi = baseZones.filter( function( z: Zone ) {
					if( z.isBuilding() || z.type == 1 || z.level <= minLevelForZonzons )
						return false;
					return true;
				} ).array();
		var hDone : IntHash<Zone> = new IntHash();
		// On ajoute des zombies en random sur la map...
		for( i in 0...Const.get.ZombieSeeds ) {
			var z = zi[rnd(zi.length)];
			z.zombies = rnd( 3 );
			if ( fl_update )
				z.update();
		}
		// On ajoute le nombre de zombies correspondant au niveau de la zone
		for( b in baseZones ) {
			if( b.type < 2 )
				continue;
			
			b.zombies = MLib.max(0, b.level + 1);
			if( fl_update )
				b.update();
		}
	}
}
