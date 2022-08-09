package gen;
import Common;

class DetailsGenerator extends BiomeGenerator {

	static inline var HEIGHT = Generator.HEIGHT;
	static inline var EMPTY = Generator.EMPTY;
	static inline var ROCK = Generator.ROCK;
	static inline var SOIL = Generator.SOIL;
	static inline var WATER = Generator.WATER;
	static inline var BEDROCK = Generator.BEDROCK;
	static inline var CAVE = Generator.CAVE;
	
	public static var DETAILS = [];
	
	override function addHeightDetails() {
		// p(X) ~= 1 planete sur X
		var det = [
			{ f : hdetHole, p : 50 },
			{ f : hdetPilars, p : 20 },
			{ f : hdetPlateau, p : 10 },
			{ f : hdetNoise, p : 7 },
			{ f : hdetPilarField, p : 10 },
		];
		det.sort(function(d1, d2) return Reflect.compare(d2.p, d1.p));
		var surf = size / 128;
		for( i in 0...Math.ceil(surf*surf) ) {
			var found = null;
			for( d in det )
				if( rnd.random(d.p*4) == 0 ) {
					found = d;
					break;
				}
			if( found == null )
				continue;
			var ntry = 1000;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				if( found.f(x, y) ) {
					DETAILS.push( { x:x, y:y, z:0 } );
					break;
				}
			}
			if( found.p == 0 )
				break;
		}
	}
	
	override function addCaveDetails() {
		var det = [
			{ f : detCaveField, p : 3 },
			{ f : detCaveCeilPlant, p : 3 },
			{ f : detCaveSphere, p : 15 },
			{ f : detCaveBuilding, p : 15 },
			{ f : detCaveCascade, p : 1 },
			{ f : detCaveCeilCascade, p : 1 },
			{ f : detCaveMaterial, p : 3 },
			{ f : detCaveFrozen, p : 6 },
			{ f : detCaveToxicPlants, p : 4 },
			{ f : detCaveCeilCharges, p : 3 },
			{ f : detCaveWallDetails, p : 2 },
			{ f : detCaveHeal, p : 5 },
		];
		
		det.sort(function(d1, d2) return Reflect.compare(d2.p, d1.p));
		var surf = size / 128;
		for( i in 0...Math.ceil(surf*surf) ) {
			var found = null;
			for( d in det )
				if( rnd.random(d.p*4) == 0 ) {
					found = d.f;
					break;
				}
			if( found == null )
				continue;
			initStep();
			var ntry = 1000;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = rnd.random(height(x, y));
				if( get(x, y, z) != CAVE ) continue;
				while( get(x, y, z-1) == CAVE )
					z--;
				if( found(x, y, z) ) {
					DETAILS.push( { x:x, y:y, z:z } );
					break;
				}
			}
		}
		
		
		// CAVE BONUS
		initStep();
		var small = alloc(BBonusSmall);
		var medium = alloc(BBonusMedium);
		var large = alloc(BBonusLarge);
		
		// gros bonus
		var n = rnd.random(3);
		var tries = n*500;
		while(n>0 && tries-->0) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = rnd.random( height(x,y)-2 );
			if( get(x,y,z)!=CAVE )
				continue;
				while( z>0 && !isSolidAt(x,y,z-1) )
					z--;
				if( get(x,y,z)!=CAVE )
					continue;
				set(x,y,z, large);
				bonusHerb(x,y,z, CAVE);
				n--;
		}
		
		// packs
		var n = rnd.random(7)+3;
		var tries = n*500;
		while(n>0 && tries-->0) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = rnd.random( height(x,y)-2 );
			if( get(x,y,z)!=CAVE )
				continue;
				while( z>0 && !isSolidAt(x,y,z-1) )
					z--;
				if( get(x,y,z)!=CAVE )
					continue;
				elipse(4,4,5, function(dx,dy,dz) {
					var x=x+dx, y=y+dy, z=z+dz;
					if( rnd.random(100)<30 && get(x,y,z)==CAVE && isSolidAt(x,y,z-1) )
						set(x,y,z, rnd.random(100)<75 ? small: medium);
				});
				bonusHerb(x,y,z, CAVE);
				n--;
		}
	}
	
	override function addDetails() {
		// p(X) ~= 1 planete sur X
		var det = [
			{ f : detBigCrater, p : 100 },
			{ f : detSmallCrater, p : 10 },
			{ f : detStrangePilars, p : 200 },
			{ f : detHighBuilding, p : 40 },
			{ f : detGroundBuilding, p : 60 },
			{ f : detGroundArtifact, p : 20 },
			{ f : detFence, p : 15 },
			{ f : detCapsule, p : 250 },
			{ f : detBigChampi, p : 50 },
			{ f : detVolcano, p : 15 },
			{ f : detAlienRobot, p : 130 },
			{ f : detPyramid, p : 100 },
			{ f : detTree, p : 6 },
			{ f : detForest, p : 30 },
			{ f : detIce, p : 40 },
			{ f : detBurned, p : 6 },
			{ f : detField, p : 8 },
			{ f : detLargePit, p : 50 },
			{ f : detSmallPit, p : 20 },
			{ f : detRuin, p : 50 },
			{ f : detCascade, p : 7 },
			{ f : detHeal, p : 5 },
		];
		
		det.sort(function(d1, d2) return Reflect.compare(d2.p, d1.p));
		var surf = size / 128;
		for( i in 0...Math.ceil(surf*surf) ) {
			var found = null;
			for( d in det )
				if( rnd.random(d.p*4) == 0 ) {
					found = d.f;
					break;
				}
			if( found == null )
				continue;
			initStep();
			var ntry = 1000;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = height(x, y);
				if( found(x, y, z) ) {
					DETAILS.push( { x:x, y:y, z:z } );
					break;
				}
			}
		}
	}
	
	private function bonusHerb(x,y,z, ?empty=EMPTY) {
		var herb1 = alloc(BBonusHerb1);
		var herb2 = alloc(BBonusHerb2);
		elipse(4,4,3, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<40 && get(x,y,z)==empty && isSolidAt(x,y,z-1) )
				set(x,y,z, rnd.random(100)<50 ? herb1 : herb2);
		});
	}
	
	
	override function addBonus() {
		var small = alloc(BBonusSmall);
		var medium = alloc(BBonusMedium);

		// bonus isolés
		var n = 15;
		var tries = n*500;
		while(n>0 && tries-->0) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x,y);
			if( z<=waterLevel || get(x,y,z)!=EMPTY || !isSolidAt(x,y,z-1) )
				continue;
			set(x,y,z, rnd.random(100)<66 ? small : medium);
			//bonusHerb(x,y,z);
			n--;
		}
		
		// packs
		var n = rnd.random(6);
		var tries = n*500;
		while(n>0 && tries-->0) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x,y);
			if( z<=waterLevel || get(x,y,z)!=EMPTY || !isSolidAt(x,y,z-1) )
				continue;
			elipse(4,4,5, function(dx,dy,dz) {
				var x=x+dx, y=y+dy, z=z+dz;
				if( rnd.random(100)<30 && get(x,y,z)==EMPTY && isSolidAt(x,y,z-1) )
					set(x,y,z, rnd.random(100)<75 ? small: medium);
			});
			bonusHerb(x,y,z);
			n--;
		}
	}
	
	
	function detStrangePilars(x, y, z) {
		if( z > 85 )
			return false;
		var pilar = alloc(BAlienRock);
		var k = 3 + rnd.random(4);
		var h = 30 + rnd.random(30);
		var ray = 10;
		for( i in 0...k ) {
			var a = i * Math.PI * 2 / k;
			var x = x + Math.round(ray * Math.cos(a));
			var y = y + Math.round(ray * Math.sin(a));
			var z2 = height(x, y);
			while( z2 > 0 && get(x,y,z2) == EMPTY )
				z2--;
			if( Math.abs(z - z2) > 15 )
				continue;
			while( z2 < z + h )
				set(x, y, z2++, pilar);
		}
		return true;
	}
	
	function building(x,y,z, wx,wy,wz, hasRoof:Bool) {
		var wall = randomBlock( [BHardRockWall, BWoodPlank, BRockWall, BRockWallSquare, BWinterWall, BMarsWall, BAcidWall], [SOIL] );
		var ceil = randomBlock( [BWoodPlank, BWoodPlate, BShipPlate, BGreenLeaves], [ROCK] );
		
		// murs
		boxWalls(wx,wy,wz-(hasRoof ? 1 : 0), function(dx,dy,dz) {
			set(x+dx, y+dy, z+dz, wall);
		});
		
		// toit
		if( hasRoof )
			boxWalls(wx+2,wy+2,wz, function(dx,dy,dz) {
				if( dz==wz-1 && !isSolidAt(x-1+dx,y-1+dy,z+dz) )
					set(x-1+dx, y-1+dy, z+dz, ceil);
			});
		
		// fenêtres
		var wh = rnd.random(2);
		boxWalls(wx,wy,wz, function(dx,dy,dz) {
			if( (dz==2 || dz==2+wh) && (dx!=0 && dx!=wx-1 && dx%2==0 || dy!=0 && dy!=wy-1 && dy%2==0) )
				set(x+dx, y+dy, z+dz, EMPTY);
		});
					
		// intérieur
		var lamp = randomBlock( [BMoonLight,BChampiLight] );
		box(wx-2,wy-2,wz-2, function(dx,dy,dz) {
			dx++; dy++; dz++;
			var x=x+dx, y=y+dy, z=z+dz;
			set(x,y,z, EMPTY);
			if( dz==1 && rnd.random(12)==0 )
				set(x,y,z, lamp);
		});
		
		// parois internes X
		var w = 4;
		while(w<wx) {
			box( 1, Std.int(wy*rnd.rand()), wz-1, function(dx,dy,dz) set(x+dx+w, y+dy, z+dz, wall) );
			w+=3+rnd.random(3);
		}
		// parois internes Y
		var w = 4;
		while(w<wy) {
			box( Std.int(wx*rnd.rand()), 1, wz-1, function(dx,dy,dz) set(x+dx, y+dy+w, z+dz, wall) );
			w+=3+rnd.random(3);
		}
		
		// trésor
		if( rnd.random(3)==0 ) {
			var treasure = randomTreasure();
			var tries = 1000;
			while(--tries>0) {
				var tx = x+1+rnd.random(wx-2);
				var ty = y+1+rnd.random(wy-2);
				var tz = z+rnd.random(3);
				if( get(tx,ty,tz)==EMPTY && isSolidAt(tx,ty,tz-1) ) {
					set(tx,ty,tz, treasure);
					break;
				}
			}
		}
		
		return true;
	}

	function detHighBuilding(x, y, z) {
		var wx = rnd.random(10)+4;
		var wy = rnd.random(10)+4;
		var wz = rnd.random(4)+5;
		z = height(x,y);
		if( z<=waterLevel+10 )
			return false;
		if( isSolidAt(x,y,z-1) && (isSolidAt(x+wx-3,y,z-1) || isSolidAt(x,y+wy-3,z-1)) && z-height(x+wx,y+wy)>10 )
			if( building(x,y,z, wx,wy,wz, true) ) {
				// piliers
				var pilar = randomBlock([BWoodColumn, BHardRockColumn], [ROCK, SOIL]);
				function drawPilar(x,y,z) {
					while( !isSolidAt(x,y,z) ) {
						if( get(x,y,z)==WATER )
							set(x,y,z, ROCK);
						else
							set(x,y,z, pilar);
						z--;
					}
				}
				drawPilar(x+wx-1, y+wy-1, z-1);
				drawPilar(x, y+wy-1, z-1);
				drawPilar(x+wx-1, y, z-1);
				return true;
			}
		return false;
	}
	
	function detGroundBuilding(x, y, z) {
		z = height(x,y);
		if( z<=waterLevel )
			return false;
		var wx = rnd.random(7)+4;
		var wy = rnd.random(7)+4;
		var wz = rnd.random(9)+5;
		if( isSolidAt(x,y,z-1) && isSolidAt(x+wx,y,z-1) && isSolidAt(x,y+wy,z-1) && isSolidAt(x+wx,y+wy,z-1) )
			return building(x,y,z, wx,wy,wz, true);
		else
			return false;
	}
	
	function detGroundArtifact(x, y, z) {
		z = rnd.random(z >> 1) + (z >> 1);
		if( get(x, y, z) != EMPTY )
			return false;
		while( get(x, y, z) == EMPTY )
			z--;
		set(x, y, z + 1, randomTreasure());
		var b = randomBlock( [BMoonLight, BChampiLight] );
		boxCentered( 3,3,1,
			function(dx,dy,dz) if( dz==0 ) set(x+dx, y+dy, z+dz, b)
		);
		return true;
	}
	
	function detHeal(x, y, z) {
		if( get(x, y, z) != EMPTY || get(x,y,z-1)!=SOIL )
			return false;
		set(x, y, z, alloc(BHealPlant));
		var b = randomBlock( [BPlantSoil] );
		elipse(rnd.random(4)+2, rnd.random(4)+2, rnd.random(2)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( get(x,y,z)==SOIL )
				set(x,y,z, b);
			
		});
		return true;
	}
		
	function detBigCrater(x, y, z) {
		if( z <= waterLevel )
			return false;
		var size = max(max(rnd.random(size >> 2), rnd.random(size >> 2)), rnd.random(size >> 2));
		var ysize = size * (0.75 + rnd.rand() * 0.5);
		circle(size, ysize, function(dx, dy) {
			for( i in z...HEIGHT )
				set(x + dx, y + dy, i, EMPTY);
		});
		elipse(size, ysize, size / 3, function(dx, dy, dz) {
			set(x + dx, y + dy, z + dz, EMPTY);
		});
		
		var coal = alloc(BCoal);
		var hot = alloc(BCoalHot);
		elipse(size,size,4, function(dx,dy,dz) {
			var x = x +dx, y = y + dy, z = z +dz - Math.ceil(size/3);
			if( rnd.random(100)<100-1.5*(Math.abs(dx)+Math.abs(dy)) && get(x,y,z)!=EMPTY )
				set(x, y, z, rnd.random(100)<90 ? coal : hot );
		});
		
		if( rnd.random(2)==0 )
			elipse(1.9, 1.9, 1.5, function(dx, dy, dz) {
				var x = x +dx, y = y + dy, z = z +dz - Math.ceil(size/3);
				if( get(x,y,z-1) != EMPTY ) set(x, y, z, Generator.MINERAL_RARE);
			});
		
		return true;
	}
	
	function detCapsule(x, y, z) {
		z++;
		if( get(x,y,z-1) == EMPTY || get(x, y, z) != EMPTY )
			return false;
		var d = density(x, y, z, 3, 3, 3);
		if( d < 0.3 || d > 0.8 ) return false;
		
		elipse(4, 4, 3, function(dx, dy, dz) set(x + dx, y + dy, z + dz, EMPTY));
		
		addModel(x, y, z - 2, "s86:eNrt1KENACAMBMAOgGETQLH:ZJCARECCvHv3sp805xQAAAAAwEGZeen5qx7v3PcGt31Em8Eu:pg:BssASXoE2Q");
		
		return true;
	}
	
	function detBigChampi(x, y, z) {
		z = min(rnd.random(z), rnd.random(z));
		while( get(x, y, z) != EMPTY )
			z++;
		if( !putModel(x, y, z, "s79:eNrt1aENACAMRUEGwHR4mJcEXflJEHd1yL40VM0BAAAAALR26J3s:lNl9HrfZd3Rxb3gf:nHAUpNDjw") )
			return false;
		var mush = alloc(BMush);
		elipse(9,9,3, function(dx,dy,dz) {
			var x=x+dx, y=y+dy;
			var z=height(x,y);
			if( rnd.random(100)<8 && get(x,y,z)==EMPTY && isSolidAt(x,y,z-1) )
				set(x,y,z, mush);
		});
		return true;
	}
	
	function detAlienRobot(x, y, z) {
		return putModel(x, y, z, "s120:eNrt1bEJgDAQBdAbwCabpBRnEMlIju6JghC0VCzeuyYcqf4npJQhAAAA4OdazOep5vClPfkpp89%zlaufX24r603HTmPsXY5L7lvN:nrxXvB:wJAxAYVdA4P");
	}
	
	function detVolcano(x, y, z) {
		if( get(x, y, z) != EMPTY || get(x,y,z-1) != SOIL )
			return false;
		var h = 6 + rnd.random(10);
		while( rnd.random(2) == 0 && h < 50 )
			h += h >> 1;
		z += Std.int(h * 0.8);
		if( z > HEIGHT - 2 )
			return false;
		var f = 0.2 + Math.min(rnd.rand(), rnd.rand()) * 0.5;
		var lavaRock = alloc(BLavaRock);
		var lava = alloc(BLava);
		var lava2 = alloc(BLava2);
		for( i in 0...h ) {
			var c = Math.ceil(i * f);
			for( dx in -c...c + 1 )
				for( dy in -c...c + 1 )
					if( Math.abs(dx) != c && Math.abs(dy) != c || rnd.random(3) != 0 || get(x+dx,y+dy,z-i+1) == lavaRock ) {
						set(x + dx, y + dy, z - i, lavaRock);
						if( i == h - 1 ) {
							var k = z - i - 1;
							while( get(x + dx, y + dy, k) == EMPTY )
								set(x + dx, y + dy, k--, lavaRock);
						}
					}
		}
		
		function fillLava(x, y, z, k=30) {
			if( get(x, y, z) != lavaRock )
				return false;
			var empty = around(x, y, z, EMPTY);
			if( !empty || rnd.random(15) == 0 ) {
				set(x, y, z, empty ? lava : lava2);
				if( --k < 0 )
					return true;
				fillLava(x + 1, y, z, k);
				fillLava(x - 1, y, z, k);
				fillLava(x, y - 1, z, k);
				fillLava(x, y + 1, z, k);
			}
			return true;
		}
		
		var i = 1;
		while( fillLava(x, y, z-i) )
			i++;
		set(x, y, z, EMPTY);
		box(rnd.random(2)+1, rnd.random(2)+1, z, function(dx,dy,dz) {
			if( z+dz>0 )
				set(x+dx, y+dy, z-dz, EMPTY);
		});
		//boxCentered(rnd.random(2)+1,rnd.random(2)+1, 60, function(dx,dy,dz) if( dz<0 ) set(x+dx, y+dy, z+dz, EMPTY));
		set(x, y, z-20, lava);
		return true;
	}
	
	function hdetPlateau(x, y) {
		var wx = rnd.random(16)+40;
		var wy = rnd.random(16)+40;
		var sum = 0;
		var n = 0;
		circle(wx, wy, function(dx, dy) {
			var h = height(x+dx, y+dy);
			sum+=h;
			n++;
		});
		var z = sum/n + 8 + rnd.random(24);
		if( z>=HEIGHT )
			z = HEIGHT-1;
		var maxDist = wx*wx+wy*wy;
		circle(wx, wy, function(dx, dy) {
			var x = x + dx, y = y + dy;
			var h = height(x,y);
			var dr = (dx*dx+dy*dy) / maxDist;
			setHeight(x,y, Std.int(h + (z-h)*0.9 - dr*8) );
		});
		return true;
	}
	
	function hdetPilarField(x, y) {
		var w = rnd.random(24)+8;
		circle(w, w, function(dx, dy) {
			if( rnd.random(100)<97 )
				return;
			var x = x + dx, y = y + dy;
			var h = height(x,y) + 3 +rnd.random(5);
			circle(2+rnd.random(3), 2+rnd.random(3), function(dx, dy) {
				var x = x + dx, y = y + dy;
				//var h = Math.ceil((height(x, y) * 0.6 + 80));
				//if( h > 120 ) h = 120;
				if( h<HEIGHT )
					setHeight(x, y, h);
			});
		});
		return true;
	}
	
	function hdetNoise(x, y) {
		var w = 32;
		circle(w, w, function(dx, dy) {
			if( rnd.random(100)<70 )
				return;
			var x = x + dx, y = y + dy;
			var dr = 1 - Math.sqrt(dx*dx+dy*dy)/w;
			var h = height(x,y) + Std.int(rnd.random(6)*dr);
			setHeight(x, y, h);
		});
		return true;
	}
	
	function hdetPerlinWalls(x, y) {
		initPerlin(30);
		var w = 32;
		circle(w, w, function(dx, dy) {
			//if( rnd.random(100)<70 )
				//return;
			var x = x + dx, y = y + dy;
			if( perlin2D(x,y)>0 ) {
				var dr = 1 - Math.sqrt(dx*dx+dy*dy)/w;
				var h = height(x,y) + Std.int(16*dr);
				setHeight(x, y, h);
			}
		});
		return true;
	}
	
	function hdetHole(x, y) {
		var k = rnd.random(size >> 2) + (size >> 3);
		circle(k, k, function(dx, dy) {
			var x = x + dx, y = y + dy;
			var f = (dx * dx + dy * dy) / (k * k);
			setHeight(x, y, Std.int(height(x, y) * f));
			// prevent water
			if( f < 0.8 )
				setRealHeight(x, y, 1.0);
		});
		return true;
	}
	
	function hdetPilars(x, y) {
		circle(3, 3, function(dx, dy) {
			var x = x + dx, y = y + dy;
			var h = Math.ceil((height(x, y) * 0.6 + 80));
			if( h > 120 ) h = 120;
			setHeight(x, y, h);
		});
		return true;
	}

	function detPyramid(x, y, z) {
		var size = 10 + rnd.random(10);
		z -= size >> 2;
		if( z <= 0 ) z = 1;
		for( i in size...size+1 ) {
			if( !isSolid(get(x + i, y - size, z - 1)) || !isSolid(get(x + i, y + size, z - 1)) || !isSolid(get(x - size, y + i, z - 1)) || !isSolid(get(x + size, y + i, z - 1)) )
				return false;
		}
		if( !putModel(x, y, z + (size >> 2), "s80:eNrt07ENACAIBEAHsGF2B3AWN9PWRAsSO%:oyFdPiKgFAAA2bc047nN5Xt:l1n5P5PEvAAAAP5tIEwvc") )
			return false;
		while( size >= 0 ) {
			var b = size & 1 == 0 ? SOIL : ROCK;
			for( i in -size...size+1 ) {
				set(x + i, y - size, z, b);
				set(x + i, y + size, z, b);
				set(x - size, y + i, z, b);
				set(x + size, y + i, z, b);
			}
			size--;
			z++;
		}
		return true;
	}
	
	function detIce(x,y,z) {
		if( get(x,y,z-1) == EMPTY || get(x, y, z) != EMPTY )
			return false;
			
		var ice = alloc( rnd.random(100)<5 ? BBlackIce : BIce );
		var iceRock = alloc(BFrozenRock);
		
		elipse(rnd.random(10)+3, rnd.random(10)+3, rnd.random(6)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<70 ) {
				var b = get(x,y,z);
				if( b!=EMPTY ) {
					if( b==WATER )
						set(x, y, z, ice);
					else
						set(x, y, z, iceRock);
				}
				else {
					var u = get(x,y,z-1);
					if( get(x,y,z)==EMPTY && (around(x,y,z, SOIL) || around(x,y,z, ROCK)) )
						set(x, y, z, ice);
				}
			}
		});
		return true;
	}
	

	function detSmallCrater(x,y,z) {
		if( z <= waterLevel )
			return false;
		var coal = alloc(BCoal);
		var hot = alloc(BCoalHot);
		
		var rx = rnd.random(10)+4;
		var ry = rx + rnd.random(5);
		var h = 4 + rnd.random(3);
		
		elipse(rx, ry, h, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			set(x, y, z, EMPTY);
		});
		elipse(rx+2, ry+2, h+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<92 && get(x,y,z)!=EMPTY )
				set(x, y, z, rnd.random(100)<80 ? coal : hot );
		});
		
		var core = randomBlock( [BAlienRock, BLavaRock, BBlackLight, BPinkCharge, BArtiBomb] );
		set(x,y,z-h, coal);
		set(x,y,z-h+1, core);
		return true;
	}
	
	
	function detIceberg(x,y,z) {
		if( get(x,y,z)!=WATER )
			return false;
		
		z = waterLevel;
		var ice = randomBlock([BIce, BIce, BBlackIce]);
		
		for(i in 0...3) {
			elipse(rnd.random(7)+1, rnd.random(7)+1, rnd.random(10)+1, function(dx,dy,dz) {
				var x=x+dx, y=y+dy, z=z+dz;
				if( rnd.random(100)<50 && ( get(x,y,z)==WATER || around(x,y,z,ice) ) )
					set(x, y, z, ice );
			});
		}
		
		elipse(12, 12, 5, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<4 && get(x,y,z)==WATER && !around(x,y,z, ice) )
				set(x, y, z, ice );
		});
		return true;
	}
	
	
	function detBurned(x,y,z) {
		if( get(x,y,z-1) == EMPTY || !around(x, y, z, EMPTY) )
			return false;
		
		var coal = alloc(BCoal);
		var hot = alloc(BCoalHot);
		
		elipse(rnd.random(10)+3, rnd.random(10)+3, rnd.random(6)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<80 && get(x,y,z)!=EMPTY )
				set(x, y, z, rnd.random(100)<80 ? coal : hot );
		});
		return true;
	}
	
	
	function detFence(x,y,z) {
		var wx = rnd.random(12)+9;
		var wy = rnd.random(12)+9;
		if( z<=waterLevel+1 )
			return false;
		if( isSolidAt(x,y,z) || isSolidAt(x+wx,y,z) || isSolidAt(x,y+wy,z) || isSolidAt(x+wx,y+wy,z) )
			return false;
		if( !isSolidAt(x,y,z-1) || !isSolidAt(x+wx,y,z-1) || !isSolidAt(x,y+wy,z-1) || !isSolidAt(x+wx,y+wy,z-1) )
			return false;
			
		var fence = alloc(BWoodColumn);
		box(wx,wy,2, function(dx,dy,dz) {
			if( dx==0 || dx==wx-1 || dy==0 || dy==wy-1 ) {
				var x=x+dx, y=y+dy;
				var z = height(x,y);
				if( rnd.random(100)<50 && isSolidAt(x,y,z-1) && !isSolidAt(x,y,z) )
					set(x,y,z, fence);
			}
		});
		
		// intérieur
		var content = randomBlockSet([
			[BHighHerb1, BHighHerb2],
			[BHighHerb3, BHighHerb4],
			[BHighHerb5, BHighHerb6],
			[BRockWall, BWoodPlate],
			[BHardRockWall, BWoodPlate],
		]);
		initPerlin(10);
		box(wx,wy,1, function(dx,dy,dz) {
			var x=x+dx, y=y+dy;
			var z = height(x,y);
			if( perlin2D(x,y)>0 && isSolidAt(x,y,z-1) && get(x,y,z)==EMPTY )
				set(x,y,z, rnd.random(100)<50 ? content[0] : content[1]);
		});
		return true;
	}
	
	
	function detField(x,y,z) {
		if( z<=waterLevel || get(x,y,z-1) == EMPTY || get(x, y, z) != EMPTY )
			return false;
		
		var bset = randomBlockSet([
			[BHighHerb1, BHighHerb2],
			[BHighHerb3, BHighHerb4],
			[BHighHerb5, BHighHerb6],
			[BAcidHerb1, BAcidHerb2],
		]);
		var fruit = randomBlock([
			BMush, BBluePlant, BYellowPlant, BAcidHerb1, BHealPlant, BPinkFlower,
			BStainRed, BStainPurple, BStainOrange, BStainWhite, BStainEmpty
		]);
		var hsoil = alloc(BPlantSoil);
		if( rnd.random(100)==0 )
			fruit = alloc(BPinkCharge);
		
		elipse(rnd.random(20)+5, rnd.random(20)+5, rnd.random(6)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy;
			var z=z+dz;
			//var z = height(x,y);
			if( get(x,y,z-1)==SOIL )
				set(x,y,z-1, hsoil);
			//if( !isSolidAt(x,y,z) && get(x,y,z)!=WATER )
				//set(x,y,z, EMPTY);
			if( rnd.random(100)<45 && get(x,y,z)==EMPTY && get(x,y,z-1)==hsoil )
				if( rnd.random(10)==0 )
					set(x,y,z, fruit );
				else
					set(x,y,z, rnd.random(100)<50 ? bset[0] : bset[1] );
		});
		return true;
	}
	
	function detSmallPit(x,y,z) {
		if( z<=waterLevel || get(x,y,z)!=EMPTY || get(x,y,z-1)!=SOIL )
			return false;
			
		var wall = randomBlock([ BRockWall, BHardRockWall, BMarsWall ], [ROCK]);
		var wall2 = randomBlock([ BWoodPlank, BWood], [SOIL]);
		var light  = randomBlock([ BChampiLight, BMoonLight, BIce ]);
		var content = randomBlock([BIce, BBlackIce], [WATER,WATER,WATER,WATER]);
		var zfill = waterLevel;
		var sfill = Math.min( z, rnd.rand()*(zfill*2) );
		
		initPerlin(50);
		var step = rnd.random(3)+4;
		var w = rnd.random(5)+2;
		for(zz in 2...z+1) {
			squareWalls(w+2, w+2, function(dx,dy) {
				set(x+dx, y+dy, zz, zz%step==0 ? wall2 : wall );
			});
			square(w, w, function(dx,dy) {
				var x=x+dx, y=y+dy;
				if( zz<=sfill && perlin3D(x,y,zz)>0 )
					set(x,y,zz, rnd.random(100)<5 ? light : SOIL);
				else if( zz<=zfill )
					set(x,y,zz, content);
				else
					set(x,y,zz, EMPTY);
			});
		}
		return true;
	}
	
	
	function detLargePit(x,y,z) {
		if( get(x,y,z)!=EMPTY || get(x,y,z-1)!=SOIL )
			return false;
			
		var coal = alloc(BCoal);
		var hot = alloc(BCoalHot);
		var lava = alloc(BLava);
		//if( rnd.random(100)<35 ) {
			//coal = alloc(BIce);
			//hot = alloc(BBlackIce);
			//lava = alloc(BCascadeSource);
		//}
		
		var minRadius = 1 + rnd.random(3);
		var maxRadius = minRadius + 3 + rnd.random(8);
		for(zz in 2...HEIGHT) {
			var radius = minRadius + (maxRadius-minRadius)*(zz/z);
			circle(radius+rnd.random(2), radius+rnd.random(2), function(dx,dy) {
				set(x+dx, y+dy, zz, EMPTY);
			});
			circle(radius+2, radius+2, function(dx,dy) {
				if( lava!=null && rnd.random(250)==0 && get(x+dx,y+dy,zz)!=EMPTY )
					set(x+dx, y+dy, zz, lava);
				if( rnd.random(100)<85 && get(x+dx,y+dy,zz)!=EMPTY && get(x+dx,y+dy,zz)!=WATER )
					set(x+dx, y+dy, zz, rnd.random(20)==0 ? hot : coal);
			});
		}
		return true;
	}
	
	
	function tree(x,y,z, trunk:Int, leaves:Int, fruit:Null<Int>, flat:Bool) {
		if( get(x,y,z-1) == EMPTY || get(x, y, z) != EMPTY )
			return false;
			
		//var trunk = randomBlock([BWood, BWinterWood, BAcidWood]);
		//var leaves = randomBlock( [BGreenLeaves, BPinkLeaves, BPurpleLeaves, BBrownLeaves, BAcidLeaves, BAcidLeaves2, BWinterLeaves, BCoalHot] );
		//var fruit = randomBlock( [BChampiLight, BMinBauxite, BBlackIce, BMoonLight] );
		//if( rnd.random(30)==0 )
			//fruit = alloc(BCascadeSource);
		//var hasFruits = rnd.random(3)==0;
		//var flat = rnd.random(2)==0;
			
		var h = flat ? rnd.random(5)+4 : rnd.random(6)+5;
		for(i in 0...h) {
			set(x,y,z+i, trunk);
			if( rnd.random(4)==0 ) {
				if( rnd.random(2)==0 )
					oset(x+rnd.sign(),y,z+i, leaves);
				else
					oset(x,y+rnd.sign(),z+i, leaves);
			}
		}
		
		if( flat )
			// feuillage plat
			for(i in 0...rnd.random(3)+2)
				elipse(rnd.random(6)+4, rnd.random(6)+4, rnd.random(2)+1, function(dx,dy,dz) {
					var x=x+dx, y=y+dy, z=h+z+dz;
					if( rnd.random(100)<60 && get(x,y,z)== EMPTY )
						if( fruit!=null )
							set(x, y, z, (rnd.random(100)<93 ? leaves : fruit) );
						else
							set(x, y, z, leaves );
				});
		else
			// feuillage rond
			for(i in 0...rnd.random(3)+2)
				elipse(rnd.random(3)+3, rnd.random(3)+3, rnd.random(3)+2, function(dx,dy,dz) {
					var x=x+dx, y=y+dy, z=h+z+dz;
					if( rnd.random(100)<60 && get(x,y,z)== EMPTY )
						set(x, y, z, (rnd.random(100)<90 ? leaves : fruit) );
				});
			
		return true;
	}
	
	function detForest(x,y,z) {
		if( z<=waterLevel )
			return false;
			
		var trunk = randomBlock([BWood, BWinterWood, BAcidWood]);
		var leaves = randomBlockSet([
			[BGreenLeaves, BPinkLeaves],
			[BGreenLeaves, BBrownLeaves],
			[BBrownLeaves, BPinkLeaves],
			[BPinkLeaves, BPurpleLeaves],
			[BAcidLeaves, BAcidLeaves2],
			[BWinterLeaves, BWinterLeaves],
			[BCoal, BCoalHot],
		]);
		var fruit = rnd.random(3)>0 ? null : randomBlock( [BChampiLight, BChampiLight, BIce, BBlackIce, BMoonLight] );
		if( fruit!=null && rnd.random(30)==0 )
			fruit = alloc(BCascadeSource);
		var flat = rnd.random(2)==0;
		var herbs = randomBlockSet([
			[BHighHerb1, BHighHerb2],
			[BHighHerb3, BHighHerb4],
			[BHighHerb5, BHighHerb6],
			[BAcidHerb1, BAcidHerb2],
		]);

		initPerlin(20);
		circle(rnd.random(32)+8,rnd.random(32)+8, function(dx,dy) {
			var x=x+dx, y=y+dy, z=height(x,y);
			if( z>=waterLevel && get(x,y,z) == EMPTY && get(x,y,z-1)==SOIL )
				if( perlin2D(x,y)>0 && x%4==0 && y%3==0 )
					tree(x,y,z, trunk, rnd.random(100)<85 ? leaves[0] : leaves[1], fruit, flat);
				else if( rnd.random(100)<60 && perlin2D(x,y)<0  )
					set(x,y,z, herbs[rnd.random(2)] );
				if( rnd.random(100)<70 && perlin2D(x,y)<0.5  )
					set(x,y,z-1, alloc(BPlantSoil) );
		});
		return true;
	}
	
	function detTree(x,y,z) {
		var trunk = randomBlock([BWood, BWinterWood, BAcidWood]);
		var leaves = randomBlock( [BGreenLeaves, BPinkLeaves, BPurpleLeaves, BBrownLeaves, BAcidLeaves, BAcidLeaves2, BWinterLeaves, BCoalHot] );
		var fruit = rnd.random(3)>0 ? null : randomBlock( [BChampiLight, BMinIron, BMinAluminium, BBlackIce, BMoonLight] );
		if( fruit!=null && rnd.random(30)==0 )
			fruit = alloc(BCascadeSource);
		var flat = rnd.random(2)==0;
		
		return tree(x,y,z, trunk, leaves, fruit, flat);
	}
	
	
	function detRuin(x,y,z) {
		var wx = 6 + rnd.random(6);
		var wy = 6 + rnd.random(6);
		var h = 5+rnd.random(4);
		if( z<=waterLevel && !isSolid(get(x,y,z)) || !isSolid(get(x+wx,y,z)) || !isSolid(get(x,y+wy,z)) || !isSolid(get(x+wx,y+wy,z)) )
			return false;
		
		if( !isSolidAt(x,y,z-1) )
			return false;
			
		var wall = randomBlock([BHardRockWall, BRockWall, BRockWallSquare, BWinterWall, BMarsWall, BAcidWall]);
		var ceil = randomBlock([BShipPlate, BWoodPlate, BWoodPlank]);
		var coal = alloc(BCoal);
		
		function ruinBlock(dx:Int,dy:Int,dz:Int) {
			if( dz<h-1 ) {
				var c = dz<h*0.7 ? 85 : 50;
				if( rnd.random(100)<c && ( isSolidAt(x+dx,y+dy,z+dz-1) || around(x+dx, y+dy, z+dz, wall) || around(x+dx, y+dy, z+dz, coal) ) )
					//if( dx==0 || dx==wx-1 || dy==0 || dy==wy-1 )
					set( x+dx, y+dy, z+dz, wall );
			}
		}
		
		// murs
		boxWalls(wx,wy,h, ruinBlock);
		
		// plafond
		boxWalls(wx,wy,h, function(dx,dy,dz) {
			var xx=x+dx, yy=y+dy;
			if( dz==h-1 )
				if( dx%2==0 && rnd.random(100)<85 && (around(xx,yy,z+dz,wall) || around(xx,yy,z+dz,ceil)) )
					set( xx, yy, z+dz, ceil );
				else
					set( xx, yy, z+dz, EMPTY );
		});
		
		// vide intérieur
		box(wx-2,wy-2,h-2, function(dx,dy,dz) {
			if( dz>0 || rnd.random(100)<85 )
				set(x+1+dx, y+1+dy, z+1+dz, EMPTY);
		});
		
		// terrain brûlé
		elipse(wx+10, wy+10, 5, function(dx,dy,dz) {
			var x = Std.int(x+wx*0.5+dx);
			var y = Std.int(y+wy*0.5+dy);
			var z = Std.int(z+h*0.5+dz);
			var d = (Math.abs(dx)+Math.abs(dy)) / ((wx+wy)*0.5);
			if( rnd.random(100)<(1-d)*80 && get(x,y,z)!=ceil && isSolidAt(x,y,z) )
				set(x,y,z, coal);
		});
		
		// parois internes X
		var w = 4;
		while(w<wx) {
			box( 1, Std.int(wy*rnd.rand()), h, function(dx,dy,dz) ruinBlock(dx+w,dy,dz) );
			w+=3+rnd.random(2);
		}
		// parois internes Y
		var w = 4;
		while(w<wy) {
			box( Std.int(wx*rnd.rand()), 1, h, function(dx,dy,dz) ruinBlock(dx,dy+w,dz) );
			w+=3+rnd.random(2);
		}
		
		// trésor
		if( rnd.random(3)==0 ) {
			var tries = 1000;
			while(--tries>0) {
				var tx = x+1+rnd.random(wx-2);
				var ty = y+1+rnd.random(wy-2);
				var tz = z+rnd.random(3);
				if( get(tx,ty,tz)==EMPTY && isSolidAt(tx,ty,tz-1) ) {
					set(tx,ty,tz, randomTreasure());
					break;
				}
			}
		}
		
		return true;
	}
	
	
	function detCascade(x,y,z) {
		z-=2;
		if( z<=waterLevel+1 )
			return false;
		if( !around(x,y,z,EMPTY) )
			return false;
		var dx = rnd.random(2)==0 ? rnd.sign() : 0;
		var dy = dx==0 ? rnd.sign() : 0;
		var dx = 0;
		var dy = -1;
		if( z-height(x-dx*4, y-dy*4)<5 )
			return false;
		for(i in 1...5) {
			if( !isSolidAt(x+i*dx, y+i*dy, z) || around(x+i*dx, y+i*dy, z, EMPTY) )
				return false;
		}
		for(i in 0...5)
			set(x+i*dx, y+i*dy,z, EMPTY);
		var b = randomBlock([BCascadeSource, BLava]);
		set(x,y,z, b);
		set(x-dx*4,y-dy*4, height(x-dx*4,y-dy*4), b);
		return true;
	}
	
	
	function detCaveField(x,y,z) {
		var fruit = alloc(BHealPlant);
		for( i in 0...rnd.random(3) )
			placeAround(fruit, x,y,z, 10,10,3, function(x,y,z) {
				return get(x,y,z)==CAVE && get(x,y,z-1)==ROCK;
			});
			
		var herbs = randomBlockSet([
			[BHighHerb1, BHighHerb2],
			[BHighHerb3, BHighHerb4],
			[BHighHerb5, BHighHerb6],
			[BAcidHerb1, BAcidHerb2],
		]);
		var soil = alloc(BPlantSoil);
		elipse(10,10,5, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<70 && get(x,y,z)==CAVE && get(x,y,z-1)==ROCK ) {
				set(x,y,z, rnd.random(2)==0 ? herbs[0] : herbs[1]);
				set(x,y,z-1, soil);
			}
		});
		
		return true;
	}
	
	
	function detCaveCeilPlant(x,y,z) {
		var plant = randomBlock([BCavePlantCeil, BAcidHerbCeil]);
		var soil = alloc(BPlantSoil);
		
		elipse(32,32,16, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<60 && get(x,y,z-1)==CAVE && get(x,y,z)==CAVE && get(x,y,z+1)==ROCK ) {
				set(x,y,z, plant);
				set(x,y,z+1, soil);
			}
			
		});
		return true;
	}
	
	
	function detCaveWallDetails(x,y,z) {
		var detail = randomBlockSet([
			[BMarsRock, BMarsRockFossil],
			[BCoal, BCoalHot],
			[BPlantRock, BChampiLight],
			[BMoonLightDead, BMoonLight],
			[BGreenLeaves, BPlantRock],
			[BMarsCraterRock, BMarsBlueRock],
		]);
		
		var n = rnd.random(8)+1;
		var tries = 1000;
		var coords = [];
		while(n>0 && tries-->0) {
			var x = x+rnd.random(16)*rnd.sign();
			var y = y+rnd.random(16)*rnd.sign();
			var z = z+rnd.random(12);
			if( get(x,y,z)==ROCK && around(x,y,z, CAVE) ) {
				set(x,y,z, detail[1]);
				coords.push({x:x, y:y, z:z});
				n--;
			}
		}
		
		for(pt in coords)
			elipse(rnd.random(3)+2, rnd.random(3)+2, rnd.random(3)+2, function(dx,dy,dz) {
				var x=pt.x+dx, y=pt.y+dy, z=pt.z+dz;
				if( get(x,y,z)==ROCK )
					set(x,y,z, detail[0]);
				
			});
		return true;
	}
	
	
	function detCaveCascade(x,y,z) {
		var blocks = randomBlockSet([
			[BLavaRock, BLava],
			[BPlantRock, BCascadeSource],
		]);
		
		var coords = [];
		var n = rnd.random(3)+1;
		var tries = 1000;
		while(n>0 && tries-->0) {
			var x = x+rnd.random(16)*rnd.sign();
			var y = y+rnd.random(16)*rnd.sign();
			var z = z+rnd.random(12);
			if( get(x,y,z)==ROCK && around(x,y,z, CAVE) ) {
				set(x,y,z, blocks[1]);
				coords.push({x:x, y:y, z:z});
				n--;
			}
		}
		
		for(pt in coords)
			elipse(rnd.random(3)+2, rnd.random(3)+2, rnd.random(3)+2, function(dx,dy,dz) {
				var x=pt.x+dx, y=pt.y+dy, z=pt.z+dz;
				if( get(x,y,z)==ROCK )
					set(x,y,z, blocks[0]);
				
			});
		//var h = 5;
		//for(i in 1...h+1)
			//if( get(x, y, z+i)!=ROCK )
				//return false;
		//for(i in 0...h+1)
			//set(x,y,z+i, CAVE);
		//var b = randomBlock([BLava, BCascadeSource]);
		//set(x,y,z+h, b);
		return true;
	}
	
	
	function detCaveCeilCascade(x,y,z) {
		var h = 0;
		while( get(x,y,z)==CAVE ) {
			z++;
			h++;
		}
		if( h<5 )
			return false;
			
		var blocks = randomBlockSet([
			[BLavaRock, BLava],
			[BPlantRock, BCascadeSource],
		]);
		
		boxCentered( 3,3,1, function(dx,dy,dz) set(x+dx, y+dy, z+dz, blocks[0]) );
		set(x,y,z, blocks[1]);
		
		elipse(rnd.random(3)+2, rnd.random(3)+2, rnd.random(3)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( get(x,y,z)==ROCK || get(x,y,z)==SOIL )
				set(x,y,z, blocks[0]);
			
		});
		return true;
	}
	
	
	function detCaveBuilding(x,y,z) {
		return building(x,y,z, 5+rnd.random(10),5+rnd.random(10), 4+rnd.random(5), false);
	}
	
	
	function detCaveSphere(x,y,z) {
		var wall = randomBlockSet([
			[BAlienRock, BChampiLight],
			[BMoonRock, BMoonLight],
			[BPlantRock, BChampiLight],
			[BFrozenRock, BBlackIceLight],
			[BCoal, BCoalHot],
		]);
		var core = randomTreasure();
		var s = rnd.random(7)+4;
		elipse(s,s,s, function(dx,dy,dz) {
			set(x+dx,y+dy,z+dz, rnd.random(100)<90 ? wall[0] : wall[1]);
		});
		elipse(s-2, s-2, s-2, function(dx,dy,dz) {
			set(x+dx,y+dy,z+dz, CAVE);
		});
		while( get(x,y,z-1)==CAVE )
			z--;
		set(x,y,z, wall[0]);
		set(x,y,z+1, wall[0]);
		set(x,y,z+2, core);
		
		return true;
	}
		
	
	function detCaveHeal(x, y, z) {
		if( get(x, y, z) != CAVE || get(x,y,z-1)!=ROCK )
			return false;
		set(x, y, z, alloc(BHealPlant));
		var b = randomBlock( [BPlantSoil] );
		elipse(rnd.random(4)+2, rnd.random(4)+2, rnd.random(2)+2, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( get(x,y,z)==ROCK )
				set(x,y,z, b);
			
		});
		return true;
	}
		

	function detCaveMaterial(x,y,z) {
		var r2 = randomBlock([BRock, BMoonRock, BMarsRock, BAcidRock, BWinterRock, BFrozenRock, BCoal]);
		elipse(32,32,8, function(dx,dy,dz) {
			if( rnd.random(100)<95 && get(x+dx, y+dy, z+dz)==ROCK )
				set(x+dx, y+dy, z+dz, r2);
		});
		return true;
	}
	
	function detCaveFrozen(x,y,z) {
		initPerlin(4);
		if( z>24 )
			return false;
		var h = 16;
		var ice = alloc(BIce);
		var wall = alloc(BFrozenRock);
		elipse(32,32,h, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			var p = perlin3D(x,y,z);
			if( p>0 ) {
				if( get(x,y,z)==CAVE )
					set(x,y,z, ice);
				if( rnd.random(100)<70 && get(x,y,z)==ROCK )
					set(x,y,z, wall);
			}
		});
		return true;
	}
	
	function detCaveToxicPlants(x,y,z) {
		if( z>24 )
			return false;
		var floor = [alloc(BAcidHerb1), alloc(BAcidHerb2)];
		var ceil = alloc(BAcidHerbCeil);
		elipse(32,32,10, function(dx,dy,dz) {
			var x=x+dx, y=y+dy, z=z+dz;
			if( rnd.random(100)<60 && get(x,y,z)==CAVE && get(x,y,z+1)==ROCK )
				set(x,y,z, ceil);
			if( rnd.random(100)<85 && get(x,y,z)==CAVE && get(x,y,z-1)==ROCK )
				set(x,y,z, rnd.random(100)<55 ? floor[0] : floor[1] );
		});
		return true;
	}
	
	function detCaveCeilCharges(x,y,z) {
		if( z>24 )
			return false;
		var charge = alloc(BYellowCeil);
		var plant = randomBlock([BCavePlantCeil, BAcidHerbCeil]);
		var n = rnd.random(20)+3;
		var tries = 1000;
		var coords = [];
		while(n>0 && tries-->0) {
			var x = x+rnd.random(16)*rnd.sign();
			var y = y+rnd.random(16)*rnd.sign();
			var z = z+rnd.random(12);
			if( get(x,y,z-1)==CAVE && get(x,y,z)==CAVE && get(x,y,z+1)==ROCK ) {
				set(x,y,z, charge);
				coords.push({x:x, y:y, z:z});
				n--;
			}
		}
		for( pt in coords)
			elipse(4,4,2, function(dx,dy,dz) {
				var x=pt.x+dx, y=pt.y+dy, z=pt.z+dz;
				if( rnd.random(100)<50 && get(x,y,z)==CAVE && get(x,y,z+1)==ROCK )
					set(x,y,z, plant);
			});
			
		return true;
	}
	
	
	function randomBlockSet(a:Array<Array<BlockKind>>) {
		var s = a[rnd.random(a.length)];
		var set = [];
		for(b in s)
			set.push( alloc(b) );
		return set;
	}
	function randomBlock(a:Array<BlockKind>, ?b:Array<Int>) {
		if( b==null )
			return alloc( a[rnd.random(a.length)] );
		else {
			var i = rnd.random(a.length+b.length);
			if( i<a.length )
				return alloc(a[i]);
			else
				return b[i-a.length];
		}
	}
	
	function placeAround(b:Int, x,y,z, dx,dy,dz, checkFunc:Int->Int->Int->Bool) {
		var tries = 1000;
		while(--tries>0) {
			var tx = x + rnd.random(dx) * rnd.sign();
			var ty = y + rnd.random(dy) * rnd.sign();
			var tz = z + rnd.random(dz) * rnd.sign();
			if( checkFunc(tx,ty,tz) ) {
				set(tx,ty,tz, b);
				break;
			}
		}
	}
	
	function randomTreasure() : Int {
		return randomBlock( [BAlienTreasure, BPinkCharge, BHealPlant, BBonusMedium, BBonusLarge, BBlackLight] );
	}
	
}