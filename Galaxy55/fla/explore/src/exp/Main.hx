package exp;

@:bitmap("texture.png") class GfxTexture extends flash.display.BitmapData {}
import ExploreProtocol;

class Main {//}
	
	static function generateSector(id,seed) : SectorInfos {
		return {
			id		: id,
			seed	: seed,
			width	: 50,
			height	: 50,
			name	: "Sector "+id,
		}
	}
	
	static function generateSolarSystem(id, seed, status:SystemStatus) : SystemInfos {
		var rseed = new mt.Rand(seed);
		var infos : SystemInfos = {
			id		: id,
			seed	: seed,
			name	: "System "+id,
			planets	: new Array(),
			x		: 20 + id*3,
			y		: 25,
			status	: status,
		}
		
		var biomes = [ Common.BiomeKind.BIAutumn, Common.BiomeKind.BIMars, Common.BiomeKind.BIMoon, Common.BiomeKind.BIWinterPeaks ];
		//var biomes = [ Common.BiomeKind.BIMoon ];
		
		switch( status ) {
			case SystemStatus.SOpen :
				for(i in 0...rseed.random(3) + 2) {
					var biome = biomes[rseed.random(biomes.length)];
					var p : SystemPlanetInfos = {
						id		: i,
						seed	: seed+i,
						size	: rseed.random(4)+1,
						distance: i,
						name	: "Planet "+i,
						status	: Type.createEnumIndex(SystemPlanetStatus, Std.random(2)),
						//status	: SystemPlanetStatus.PUnexplored,
						kind	: SystemPlanetKind.SPlanet,
						biome	: biome,
						bname 	: Std.string(biome),
						//kind	: SystemPlanetKind.SGas,
					}
					infos.planets.push(p);
				}
				
			case SystemStatus.SLocked(cost) :
		}
		return infos;
	}
	
	static function getInfos() : ExploreInfos {
		var seed = Std.random(999999);
		seed = 253725;
		var d : ExploreInfos = {
			url		: null,
			ship	: {data:null, pos:ShipPosition.PInSector(30,30), energy:100},
			sector	: generateSector(0,seed),
			systems	: new Array(),
			holes	: new Array(),
			freeLicense : true,
			//planets : [null, null, null],
			texts : { var h = new Hash(); h.set("loading", "Chargement..."); h; },
		}
		
		var rseed = new mt.Rand(seed);
		for( i in 0...10 ) {
			var status = if( rseed.random(100)<33 ) SystemStatus.SLocked(1500) else SystemStatus.SOpen;
			d.systems.push( generateSolarSystem(i, seed+i, status) );
		}

		rseed.initSeed(seed);
		for(s in d.systems) {
			s.x+=rseed.random(2);
			s.y+=rseed.random(20);
		}
			
		return d;
	}
		
	static function main() {
		Common.Data.TEXTURE = new GfxTexture(0,0);
		var m = new Manager(flash.Lib.current,getInfos(),true);
	}
	
}
