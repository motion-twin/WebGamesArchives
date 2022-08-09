package gen;

import Common;
import gen.Generator;

class BiomeGenerator extends Generator {
	
	static inline var EMPTY = Generator.EMPTY;
	static inline var BEDROCK = Generator.BEDROCK;
	static inline var WATER = Generator.WATER;
	
	static inline var CAVE = Generator.CAVE;
	
	static inline var ROCK = Generator.ROCK;
	static inline var SOIL = Generator.SOIL;
	
	static inline var HBITS = Generator.HBITS;
	static inline var HEIGHT = Generator.HEIGHT;

	override function initBiome(biome) {
		switch( biome ) {
		case BIAutumn:
			waterLevel = 32;
			globalScale = 2;
			
			Macro.generate({
				var t = 0.;
				t += addHeight(1, 1);
				t += addHeight(2, 0.5);
				t += addHeight(3, 0.333);
				t += addHeight(4, 0.25);
				t += addHeight(10, 0.4);
				addMulHeight(t, 0.5 / t);
				adjustHeight(1, 1);
				addMulHeight( -0.5, 2);
				
				fillHeight([ { v : -1., h : -32 }, {v : -0.7, h:0 }, { v : 0.2, h : 5 }, { v : 1.0, h : 92 }]);
				
				smoothHeight();
				smoothHeight();
				fillSoil(0.5);
				addHoles(4.5, [{ h : waterLevel, v : -0.8 },{ h : maxHeight, v : 0.5 }]);
				addCaves(1, 1, BBrokenRock);
				addCaveDetails();
				removeBlobs();
				if( smooth3D() > 0 ) stepRetry();
				
				addHighForest();
				addBunker(BRock, 0.5);
				addSand(BAutumnStraw);
				addHerbs(BAutumnHerbs1, BAutumnHerbs2, 1.0, 1.0);
				addHerbs(BAutumnHerbs1, BAutumnHerbs2, 0.5, 1.5);
				addRandom(BPinkFlower, 10);
				addRandomUnderwater( BWood, 100 );
				addCaveCrystals(1.0, BBlueCrystalLight, BBlueCrystalDense, BBrokenRock);
				addMineralsRocks(1);
				
			});
		case BIMoon:
			waterLevel = 32;
			globalScale = 5;
			Macro.generate({
				addHeight(1, 1);
				addHeight(5, 0.15);
				addMulHeight(1, 0.5);
				fillHeight([ {v:0., h:-32}, {v:0.26, h:0}, {v:0.3, h:4}, {v:0.3, h:16}, {v:0.7, h:20}, {v:0.7, h:60}, {v:0.9, h:60}]);//, {v:0.9, h:50}, {v:1.2, h:52 } ]);
				smoothHeight();
				lowerChunks(70, 25);
				fillSoil(0);
				addHoles(6, [ { h : 20 + waterLevel, v : -0.8 }, { h : 55 + waterLevel, v : -0.5 }, { h : 60 + waterLevel, v : -1. } ]);
				addCaves(0.3, 1.5, BMoonBrokenRock);
				addCavePillars(BMoonRockColumn);
				addCaveChampi(BStainPurple);
				removeBlobs();
				addMoonTrees();
				addCliffBalls(75, BPurpleLeaves, BPinkLeaves);
				addBunker(BMoonRock, 2.5);
				addSand(BMoonSand);
				addHerbs(BMoonHerbs1, BMoonHerbs2, 2.0, 0.5);
				addHerbs(BMoonHerbs1, BMoonHerbs2, 0.5, 1.5);
				addRandomFun(makePilar(1, 5, BMoonLightColumn, BMoonLightDead), 8);
				addRandomFun(makePilar(1, 5, BMoonLightColumn, BMoonLight), 20);
				
				addCaveCrystals(1.0, BBlueCrystalLight, BBlueCrystalDense, BMoonBrokenRock);
				addMineralsRocks(1);

				addRandomUnderwater(BCoral2, 100);
			});
		case BIAcidForest:
			waterLevel = 32;
			globalScale = 3;
			Macro.generate({
				addHeight(1, 1);
				addHeight(4, 0.4);
				addHeight(4, 0.4);
				addHeight(4, 0.4);
				fillHeight([ { v : -1., h : -16 }, { v : 0.1, h : 0 }, { v : 1, h : 8 } ]);
				smoothHeight();
				smoothHeight();
				fillSoil(0);
				if( smooth3D() > 0 ) stepRetry();
				addAcidTrees();
				
				addHerbs(BAcidHerb1, BAcidHerb2, 0.2, 2);
				replaceSomeBlocks(BAcidHerb2, BYellowPlant, 10);
				replaceSomeBlocks(BYellowPlant, BBluePlant, 20);
				
				var b = alloc(BCoral1);
				addRandomUnderwaterFun(function(x,y,z) {
					for(h in 0...rnd.random(4)+1)
						set(x,y,z+h, b);
				}, 50);
				
				removeBlobs();
			});
			
		case BIWinterPeaks:
			waterLevel = 32;
			globalScale = 5;
			Macro.generate( {
				var t = 0.;
				t += addHeight(1, 1);
				t += addHeight(2, 0.5);
				t += addHeight(3, 0.333);
				t += addHeight(4, 0.25);
				t += addHeight(10, 0.4);
				addMulHeight(t, 0.5 / t);
				adjustHeight(1, 1);
				addMulHeight( -0.5, 2);
				
				fillHeight([ { v : -1., h : -32 }, { v : -0.5, h : 0 }, { v : 0.7, h : 5 }, { v : 0.8, h : 32 }, { v : 1., h : 70 } ]);
				smoothHeight();
				smoothHeight();
				fillSoil(0);
				
				for( i in 0...10 )
					addHoles(2 + rnd.rand() * 2, [ { h : 34, v : -0.9 }, { h : 35, v : -0.7 } ], CAVE);
				addHoles(2, [ { h : 22, v : -0.8 }, { h : 24, v : -0.5 }, { h : 31, v : -0.6 }, { h : 33, v : -0.9 }, { h : 37, v : -1 } ], CAVE);
				
				if( smooth3D() > 0 ) stepRetry();

				addCaves(2, 0.75, BWinterBrokenRock);
				addCaveCrystals(3.0, BBlueCrystalLight, BBlueCrystalDense, BWinterBrokenRock, CAVE);
				addCaveMinerals(4.0, 30,100);
				
				addCaveAccesses(30);
				addCaveDetails();
				
				removeBlobs();
				
				addWinterDetails();
				
				addBunker(BBlackIce, 0.15, BBlackIceLight);
				addHerbs(BWinterHerb1, BWinterHerb2, 1.5, 1.5);
				addHerbs(BWinterHerb2, BWinterHerb3, 1.0, 1.0);
				
				addRandomUnderwater(BIce, 5);

				replaceSomeBlocks(BWinterHerb2, BFreezerPlant, 12);
			});
		case BIMars:
			waterLevel = 16;
			globalScale = 2;
			Macro.generate( {
				var t = 0.;
				t += addHeight(1, 1);
				t += addHeight(2, 0.5);
				t += addHeight(3, 0.333);
				t += addHeight(4, 0.25);
				t += addHeight(10, 0.4);
				addMulHeight(t, 0.5 / t);
				adjustHeight(1, 1);
				addMulHeight( -0.5, 2);

				fillHeight([ { v : -1., h : -16 }, { v : -0.95, h : 0 }, { v : -0.8, h : 64 }, { v : 1., h : 75 }, { v : 1.12, h : 16 } ]);
				adjustMarsHeight();
				fillSoil(0);
				
				for( i in 0...100 )
					addHoles(3 + rnd.rand() * 3, [ { h : 16, v : -0.7 }, { h : 75, v : -0.8 }, { h : 75, v : -2. } ], EMPTY);
					
				while( smooth3D(0,32) > 0 ) {}
				
				addBunker(BMarsQuickSand, 0.5);
				
				addMarsDetails();
				addHerbs(BMarsHerb1, BMarsHerb2, 3.0, 2.0);
				addHerbs(BMarsHerb3, BMarsHerb2, 3.0, 2.0);
				
				addCaveMinerals(2.0, 12, 20, EMPTY);
				addCaveMinerals(1.0, 20, 60, EMPTY);
				addCaveMinerals(0.5, 70, 90, EMPTY);
				
				for(x in 0...size) // un peu lourd non ?
					for(y in 0...size)
						for(z in 0...60)
							if( get(x,y,z)==EMPTY )
								set(x,y,z, CAVE);
				addCaveDetails();
				
				removeBlobs();
			});
		
		case BIDeadCity:
			waterLevel = 32;
			globalScale = 1.0;
			Macro.generate({
				var t = 0.;
				t += addHeight(1, 1);
				t += addHeight(2, 0.5);
				t += addHeight(3, 0.333);
				t += addHeight(4, 0.25);
				t += addHeight(10, 0.4);
				addMulHeight(t, 0.5 / t);
				adjustHeight(1, 1);
				addMulHeight( -0.5, 2);
				fillHeight([ { v : -1., h : -32 }, { v : -0.5, h : 0 }, /*{ v : 0, h : 30 }, { v : 0.7, h : 0 }, { v : 0.7, h : 20 },*/ { v : 1.3, h : 40 } ]);
				createHeightsLevels(35, 5);
				fillSoil(0);
				
				addDeadDetails();
			});
					
		default:
			waterLevel = 64;
			globalScale = 5;
			Macro.generate({
				addHeight(1, 1);
				fillHeight([ { v : -1., h : -64 }, { v : 1., h : 64 } ]);
				smoothHeight();
				smoothHeight();
				fillSoil(0);
				if( smooth3D() > 0 ) stepRetry();
			});
		}
	}
	
	function addRandomUnderwaterFun( f:Int->Int->Int->Void, proba : Int ) {
		for( y in 0...size )
			for( x in 0...size ) {
				if( rnd.random(proba)!=0 )
					continue;
				var h = height(x,y);
				if( h>=waterLevel-2 )
					continue;
				var u = get(x,y,h-1);
				if( get(x, y, h) == WATER && (u==SOIL || u==BEDROCK) )
					f(x,y,h);
			}
	}
	
	function addRandomUnderwater( b:BlockKind, proba : Int ) {
		var b = alloc(b);
		for( y in 0...size )
			for( x in 0...size ) {
				if( rnd.random(proba)!=0 )
					continue;
				var h = height(x,y);
				if( h>=waterLevel-2 )
					continue;
				var u = get(x,y,h-1);
				if( get(x, y, h) == WATER && (u==SOIL || u==BEDROCK) )
					set(x,y,h, b);
			}
	}
	
	function addRandom( k : BlockKind, proba : Int ) {
		var block = alloc(k);
		for( y in 0...size )
			for( x in 0...size ) {
				if( x & 3 != 0 || y & 3 != 0 || hash(x + y * size) % proba != 0 ) continue;
				var h = height(x,y);
				if( get(x, y, h - 1) != SOIL ) continue;
				oset(x, y, h, block);
			}
	}

	function addRandomFun( f : Int -> Int -> Int -> Bool, proba : Int ) {
		for( y in 0...size )
			for( x in 0...size ) {
				if( x & 3 != 0 || y & 3 != 0 || hash(x + y * size) % proba != 0 ) continue;
				var h = height(x,y);
				if( get(x, y, h - 1) != SOIL ) continue;
				f(x, y, h);
			}
	}
	
	function makePilar( zmin : Int, zmax : Int, bcol, btop ) {
		var bcol = alloc(bcol);
		var btop = alloc(btop);
		return function(x, y, z) {
			var size = zmin + rnd.random(zmax - zmin + 1);
			for( i in 1...size )
				if( get(x, y, z + 1) != EMPTY )
					return false;
			for( i in 0...size )
				set(x, y, z + i, bcol);
			set(x, y, z + size, btop);
			return true;
		};
	}
	
	function addCaveCrystals( amount = 1.0, b, bcond, brk, bempty = EMPTY ) {
		var b = alloc(b);
		var bcond = alloc(bcond);
		var brk = alloc(brk);
		for( i in 0...Std.int(size * size * amount / 100) ) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var zmax = height(x,y);
			var z = rnd.random(zmax);
			while( z < zmax ) {
				if( get(x, y, z) != ROCK )
					break;
				if( get(x - 1, y, z) == bempty || get(x + 1, y, z) == bempty || get(x, y - 1, z) == bempty || get(x, y + 1, z) == bempty ) {
					setBlockRec(x, y, z, ROCK, brk, 10 + rnd.random(10));
					var count = 0, max = 4;
					while( count < max ) {
						for( i in 0...100 ) {
							var x = x + rnd.random(10) - 5;
							var y = y + rnd.random(10) - 5;
							var z = z + rnd.random(10) - 5;
							if( get(x, y, z) == brk ) {
								set(x, y, z, rnd.random(8) == 0 ? bcond : b);
								count++;
							}
						}
						max--;
					}
					z += rnd.random(10) + 1;
				} else
					z++;
			}
		}
	}
	
	
	function addCaveMinerals(amount:Float,zmin,zmax,cave=CAVE) {
		var hard = alloc(BHardRock);
		for( i in 0...Math.round(size * size * amount / 4300) ) {
			var ntry = 2000;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = height(x, y);
				if( z > zmax ) z = zmax;
				while( z >= zmin ) {
					if( get(x, y, z) == cave )
						break;
					z -= 1 + rnd.random(4);
				}
				if( z < zmin ) continue;
				while( z < zmax && get(x,y,z) == cave )
					z++;
				if( z >= zmax ) continue;
			
				var el = [];
				for( i in 0...4 ) {
					var x = x + rnd.random(6) - 3;
					var y = y + rnd.random(6) - 3;
					var z = z + rnd.random(6) - 3;
					el.push( { x : x, y :y, z : z, sx : 1.5 + rnd.rand()*2, sy : 1.5 + rnd.rand()*2, sz : 1.5 + rnd.rand()*2 } );
				}
			
				var empty = 0, full = 0;
				for( e in el )
					elipse(e.sx, e.sy, e.sz, function(dx, dy, dz) {
						if( get(e.x+dx, e.y+dy, e.z+dz)&127 == EMPTY ) empty++ else full++;
					});
				
				var ratio = (empty + 1) / (empty + full + 1);
				if( ratio < 0.1 || ratio > 0.8 )
					continue;

				var pts = [];
				for( e in el )
					elipse(e.sx, e.sy, e.sz, function(dx, dy, dz) {
						var x = e.x + dx, y = e.y + dy, z = e.z + dz;
						if( get(x, y, z) & 127 == ROCK && (cave == EMPTY || !around(x,y,z,EMPTY)) ) {
							set(x, y, z, hard);
							pts.push( { x : x, y : y, z : z } );
						}
					});
				fillMinerals(pts);
				break;
			}
		}
	}
	
	function addMineralsRocks( ratio:Float, ?bempty = EMPTY ) {
		var hard = alloc(BHardRock);
		for( i in 0...Math.round(ratio*size*size/4300) ) {
			while( true ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var zmax = height(x, y);
				var z = -1;
				for( i in rnd.random(zmax)...zmax )
					if( get(x, y, i) == bempty ) {
						z = i;
						break;
					}
				if( z < 0 ) continue;
								
				var el = [];
				for( i in 0...4 ) {
					var x = x + rnd.random(6) - 3;
					var y = y + rnd.random(6) - 3;
					var z = z + rnd.random(6) - 3;
					el.push( { x : x, y :y, z : z, sx : 2 + rnd.random(3), sy : 2 + rnd.random(3), sz : 2 + rnd.random(2) } );
				}
				
				var empty = 0, full = 0;
				for( e in el )
					elipse(e.sx, e.sy, e.sz, function(dx, dy, dz) {
						if( get(e.x+dx, e.y+dy, e.z+dz) == bempty ) empty++ else full++;
					});
				var ratio = (empty + 1) / (empty + full + 1);
				if( ratio < 0.03 || ratio > 0.2 )
					continue;
				var pts = [];
				for( e in el )
					elipse(e.sx, e.sy, e.sz, function(dx, dy, dz) {
						set(e.x + dx, e.y + dy, e.z + dz, hard);
						pts.push( { x : e.x + dx, y : e.y + dy, z : e.z + dz } );
					});
				fillMinerals(pts);
				break;
			}
		}
	}
	
	function density( x, y, z, xx, yy, zz, bempty = EMPTY ) {
		var empty = 0, total = 0;
		elipse(xx, yy, zz, function(dx,dy,dz) {
			if( get(x + dx, y + dy, z + dz) == bempty )
				empty++;
			total++;
		});
		return empty / total;
	}
	
	function fillMinerals( pts : Array<{x:Int,y:Int,z:Int}> )  {
		var min = randMineral();
		function isEmpty(x, y, z) {
			var b = get(x, y, z);
			return b == EMPTY || b == WATER || b == CAVE;
		}
		for( i in 0...Std.int(pts.length / 6) ) {
			var p = pts[rnd.random(pts.length)];
			if( p == null ) break;
			pts.remove(p);
			if( isEmpty(p.x - 1, p.y, p.z) || isEmpty(p.x + 1, p.y, p.z) || isEmpty(p.x, p.y - 1, p.z) || isEmpty(p.x, p.y + 1, p.z) || isEmpty(p.x, p.y, p.z - 1) || isEmpty(p.x, p.y, p.z + 1) ) {
				if( rnd.random(5) != 0 ) continue;
			}
			set(p.x, p.y, p.z, min);
		}
	}
	
	function setBlockRec(x, y, z, old, b, n) {
		for( i in 0...n ) {
			set(x, y, z, b);
			switch( rnd.random(9)>>1 ) {
			case 0: if( get(x - 1, y, z) == old ) x--;
			case 1: if( get(x + 1, y, z) == old ) x++;
			case 2: if( get(x, y - 1, z) == old ) y--;
			case 3: if( get(x, y + 1, z) == old ) y++;
			}
		}
	}

	
	function addHerbs( block, block2, amount:Float, scale : Float) {
		var block = alloc(block), block2 = alloc(block2);
		var count = Std.int((size * size) / 3000);
		var w = waterLevel;
		for( i in 0...count ) {
			var ntry = 100;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = height(x,y);
				if( fget(addr(x, y, z-1)) == SOIL && fget(addr(x, y, z)) == EMPTY ) {
					for( i in 0...4 ) {
						var x = real(x + Math.ceil((rnd.random(12) - 6) * scale));
						var y = real(y + Math.ceil((rnd.random(12) - 6) * scale));
						elipse( Math.ceil((4 + rnd.random(6)) * scale), Math.ceil((4 + rnd.random(6))*scale), 0, function(dx, dy, _) {
							var x = real(x + dx);
							var y = real(y + dy);
							if( hash(x + y * size) % 100 < 60 ) return;
							var h = height(x,y);
							if( h - z <= 2 && h - z >= -2 && get(x,y,h-1) == SOIL )
								oset(x, y, h, hash(x+y*size)&1 == 0 ? block : block2);
						});
					}
					break;
				}
			}
		}
	}
	
	function addBunker( block, ratio:Float, ?core:BlockKind ) {
		var block = alloc(block);
		var core = if( core!=null ) alloc(core) else null;
		var count = Std.int(ratio * (size * size) / 3000);
		for( i in 0...count ) {
			var ntry = 100;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = height(x,y)-1;
				if( fget(addr(x, y, z)) == SOIL ) {
					var n = 4;
					var all = [];
					for( i in 0...n ) {
						var x = real(x + rnd.random(12) - 6);
						var y = real(y + rnd.random(12) - 6);
						elipse(3 + rnd.random(5), 3 + rnd.random(5), 4, function(dx, dy, dz) {
							var a = addr(real(x + dx), real(y + dy), z + dz);
							if( fget(a) == SOIL ) {
								fset(a, block);
								all.push(a);
							}
						});
					}
					if( core!=null )
						for( i in 0...rnd.random(n)+1 )
							if( all.length>0 )
								fset( all.splice(rnd.random(all.length), 1)[0], core );
					break;
				}
			}
		}
	}
	
	function addSand( block ) {
		var block = alloc(block);
		var count = Std.int((size * size) / 3000);
		var w = waterLevel;
		for( i in 0...count ) {
			var ntry = 100;
			while( ntry-- > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				if( rnd.random(100) == 0 || (fget(addr(x, y, w)) == WATER && (fget(addr(real(x + 1), y, w)) == SOIL || fget(addr(x, real(y + 1), w)) == SOIL)) ) {
					for( i in 0...4 ) {
						var x = real(x + rnd.random(12) - 6);
						var y = real(y + rnd.random(12) - 6);
						elipse(4 + rnd.random(6), 4 + rnd.random(6), 4, function(dx, dy, dz) {
							var a = addr(real(x + dx), real(y + dy), w + dz);
							if( fget(a) == SOIL ) fset(a, block);
						});
					}
					break;
				}
			}
		}
	}
	
	function addCliffBalls(zmin, mainBlock, secBlock) {
		var mainBlock = alloc(mainBlock);
		var secBlock = alloc(secBlock);
		var crystal = alloc(BYellowCrystalDense);
		var crystalLight = alloc(BYellowCrystalLight);
		var count = Std.int((size*size / 300));
		var delta = 6;
		
		// feuillages
		var balls = new Array();
		for( i in 0...count ) {
			var ntry = 100;
			while( ntry-->0 ) {
				var x = rnd.random(size-2)+1;
				var y = rnd.random(size-2)+1;
				var h = height(x,y);
				if( h>=zmin && ( h-height(x-1,y)>=delta || h-height(x+1,y)>=delta || h-height(x,y-1)>=delta || h-height(x,y+1)>=delta ) ) {
					var z = zmin+rnd.random(h-zmin);
					for( j in 0...4 ) {
						var x = real(x + rnd.random(6) - 3);
						var y = real(y + rnd.random(6) - 3);
						balls.push({x:x,y:y,z:z});
						var sz = 1+rnd.random(2);
						elipse(3 + rnd.random(3), 3 + rnd.random(3), sz, function(dx, dy, dz) {
							var a = addr(real(x + dx), real(y + dy), z + dz);
							if( fget(a) == EMPTY ) {
								if( rnd.random(100)>=20 )
									fset(a, mainBlock);
								else
									fset(a, secBlock);
									
							}
						});
					}
					break;
				}
			}
		}
		
		// crystaux
		var count = Std.int((size*size / 1000));
		for(i in 0...count) {
			var ntry = 100;
			while( ntry-->0 ) {
				var b = balls[rnd.random(balls.length)];
				var x = real(b.x+rnd.random(3));
				var y = real(b.y+rnd.random(3));
				var z = real(b.z-rnd.random(2));
				if( (get(x,y,z)==mainBlock || get(x,y,z)==secBlock) && get(x,y,z-1)==EMPTY ) {
					set(x,y,z-1, crystal);
					break;
				}
			}
		}
		
		// crystaux morts
		var count = Std.int((size*size / 300));
		for(i in 0...count) {
			var ntry = 100;
			while( ntry-->0 ) {
				var b = balls[rnd.random(balls.length)];
				var x = real(b.x+rnd.random(3));
				var y = real(b.y+rnd.random(3));
				var z = real(b.z-rnd.random(2));
				if( (get(x,y,z)==mainBlock || get(x,y,z)==secBlock) && get(x,y,z-1)==EMPTY ) {
					while( get(x,y,z-1)==EMPTY )
						z--;
					var base = get(x,y,z-1);
					if( base==SOIL || base==ROCK )
						set(x,y,z, crystalLight);
					break;
				}
			}
		}
	}

	function addHighForest() {
		initPerlin(2);
		var tree = alloc(BWood), leaves = alloc(BGreenLeaves), champi = alloc(BChampiLight), vines = [alloc(BVines), alloc(BVinesY)];
		var cactus = alloc(BCactus);
		var cactusBase = alloc(BCactusBase);
		var cactusFlower = alloc(BCactusFlower);
		var lightCrystal = alloc(BYellowCrystalLight);
		var denseCrystal = alloc(BYellowCrystalDense);
		for( y in 0...size )
			for( x in 0...size ) {
				if( (x + y) & 1 != 0 ) continue;
				
				var p = x + y * size;
				var h = hval(p);
				if( h == 0 || h > 50 || fget((p << HBITS) + h - 1) != SOIL || fget((p << HBITS) + h) != EMPTY ) continue;
				
				
				var hp = hash(p);
				var g = perlin2D(x, y);
				if( g < 0 ) {
					if( g < -0.25 && x%3 == 0 && y%3==0 && hp % 10 == 0 ) {
						fset((p << HBITS) + h - 1, cactusBase);
						fset((p << HBITS) + h, cactus);
						for(i in 0...rnd.random(5)+1)
							fset((p << HBITS) + h + 1 + i, (rnd.random(100)<20) ? cactusFlower : cactus );
					}
					continue;
				}
				
				if( hp & 7 != 0 ) {
					if( hp & (511-7) == 0 )
						fset((p << HBITS) + h, champi);
					continue;
				}
								
				var size = rnd.random(10) + 15;
				for( i in 1...size+1 ) {
					var z = h + size - i;
					fset((p << HBITS) + z, tree);
				}
				var count = 20;
				for( i in 0...count ) {
					var x : Float = x, y : Float = y, z = h + size;
					var angle = i * 6.28 / count;
					for( i in 0...10 ) {
						var ix = Std.int(x), iy = Std.int(y);
						oset(Std.int(x), Std.int(y), z, leaves);
						if( rnd.random(403) == 0 && get(Std.int(x), Std.int(y), z) == leaves )
							oset(Std.int(x), Std.int(y), z - 1, denseCrystal);
						if( rnd.random(403) == 0 && get(Std.int(x),Std.int(y),h-1) == SOIL )
							oset(Std.int(x), Std.int(y), h, lightCrystal);
						x += Math.cos(angle) * 0.4;
						y += Math.sin(angle) * 0.4;
					}
				}
				for( i in 0...15 ) {
					var x = rnd.random(12) - 6 + x;
					var y = rnd.random(12) - 6 + y;
					var z = h + size - 1;
					var v = vines[rnd.random(2)];
					if( get(x, y, z + 1) == leaves ) {
						var h = (size >> 2) + rnd.random(size >> 2);
						while( h-- > 0 ) {
							if( !oset(x, y, z, v) )
								break;
							z--;
						}
					}
				}
			}
	}

	function addClassicTrees() {
		var tree = alloc(BWood), leaves = alloc(BGreenLeaves);
		for( y in 0...size )
			for( x in 0...size ) {
				if( (x + y) & 1 != 0 ) continue;
				var p = x + y * size;
				var h = hval(p);
				if( h == 0 || h > 40 || fget((p << HBITS) + h - 1) != SOIL || fget((p << HBITS) + h) != EMPTY || hash(p) & 63 != 0 ) continue;
				var size = rnd.random(10) + 6;
				for( i in 0...size-2 )
					fset((p<<HBITS) + i + h, tree);
				var count = 30;
				for( i in 0...count ) {
					var x : Float = x, y : Float = y, z : Float = h + size-1;
					var angle = i * 6.28 / count;
					var gravity = -rnd.rand() * 0.3;
					while( z > h + (size >> 1) ) {
						oset(Std.int(x), Std.int(y), Std.int(z), leaves);
						x += Math.cos(angle) * 0.4;
						y += Math.sin(angle) * 0.4;
						z -= gravity;
						gravity += 0.1;
						if( gravity > 1 ) gravity = 1;
					}
				}
			}
	}
	
	function lowerChunks(zmin:Int, zloss:Int, ?ratio=1.0) {
		var count = ratio * size * size / 300;
		var delta = 10;
		for( i in 0...Math.ceil(count) ) {
			var ntry = 100;
			while( ntry-->0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var h = height(x, y);
				if( h < zmin ) continue;
				if( h >= zmin && ( h - height(x - 1, y) >= delta || h - height(x + 1, y) >= delta || h - height(x, y - 1) >= delta || h - height(x, y + 1) >= delta ) ) {
					var z0 = h - max(rnd.random(zloss), rnd.random(zloss));
					var width = 3 + rnd.random(4);
					var height = 3 + rnd.random(4);
					x += rnd.random(width) - (width >> 1);
					y += rnd.random(height) - (height >> 1);
					var ray = 1 + (rnd.rand() - 0.5) * 0.1;
					var count = 0;
					for( dx in -width...width+1 )
						for( dy in -height...height + 1 )
							if( this.height(real(x + dx), real(y + dy)) < z0 && (dx/width) * (dx/width) + (dy/height)*(dy/height) < ray ) {
								count++;
								setHeight(x + dx, y + dy, z0);
							}
					if( count > 10 )
						break;
				}
			}
		}
	}
	
	function addMoonTrees() {
		var h0 = 60 + 32;
		var tree = alloc(BWood);
		var blocks = [Generator.MINERAL_RARE, alloc(BMoonLight), alloc(BMoonLight), alloc(BMoonLight), alloc(BMoonLightDead)];
		for( i in 0...Math.ceil(size * size / 2000) ) {
			var ntry = 1000;
			while( ntry-->0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var d = 5;
				if( height(x, y) < h0  || height(real(x+d),y) < h0 || height(real(x-d),y) < h0 || height(x,real(y+d)) < h0 || height(x,real(y-d)) < h0 )
					continue;
				function near() {
					var h = height(x, y) + 5;
					for( dx in -20...20 )
						for( dy in -20...20 )
							if( get(x + dx, y + dy, h) == tree )
								return true;
					return false;
				}
				if( near() )
					continue;
				var h = height(x, y);
				for( i in 0...30 ) {
					var ix = x, iy = y, iz = h;
					var x : Float = x, y : Float = y, z : Float = h;
					var vx = (rnd.rand() - 0.5) * 0.2;
					var vy = (rnd.rand() - 0.5) * 0.2;
					var vz = (rnd.rand() - 0.5) * 0.2 + 0.7;
					var zmax = 0.;
					for( s in 0...rnd.random(50) + 70 ) {
						ix = Std.int(x);
						iy = Std.int(y);
						iz = Std.int(z);
						oset(ix,iy,iz, tree);
						x += vx;
						y += vy;
						z += vz;
						if( z > zmax )
							zmax = z;
						if( z > 125 && vz > 0 )
							vz *= 0.8;
						vz -= 0.01;
						if( z < h + 10 && vz < 0 )
							break;
					}
					if( vz < 0 && z < zmax - 5 ) {
						var leaves = alloc(rnd.random(4) == 0 ? BPinkLeaves : BPurpleLeaves);
						elipse(2, 2, 2, function(dx, dy, dz) set(ix + dx, iy + dy, iz + dz, leaves));
						set(ix,iy,iz, blocks[rnd.random(blocks.length)]);
					}
				}
				break;
			}
		}
	}
	
	function addCavePillars(b) {
		var b = alloc(b);
		for( i in 0...Math.ceil(size * size / 1500) ) {
			var ntry = 100;
			while( --ntry > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = rnd.random(height(x, y));
				if( get(x, y, z) != CAVE ) continue;
				var z0 = z;
				while( get(x, y, z) == CAVE )
					z++;
				if( get(x, y, z) == EMPTY )
					z = z0;
				else
					z--;
				while( get(x, y, z) == CAVE )
					set(x, y, z--, b);
				break;
			}
		}
	}
	
	function addCaveChampi(b, ratio = 1.0) {
		var b = alloc(b);
		var dead = alloc(BStainEmpty);
		for( i in 0...Math.ceil(ratio * size * size / 10000) ) {
			var ntry = 100;
			while( --ntry > 0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = rnd.random(height(x, y));
				if( get(x, y, z) != CAVE ) continue;
				while( get(x, y, z) == CAVE )
					z--;
				z++;
				elipse(2, 2, 1, function(dx, dy, dz) {
					if( get(x + dx, y + dy, z + dz) == CAVE && get(x + dx, y + dy, z + dz - 1) == ROCK ) {
						set(x + dx, y + dy, z + dz, rnd.random(100)<80 ? b : dead );
					}
				});
				break;
			}
		}
	}
	
	function carveTreeRec(x, y, z, tree, empty) {
		if( get(x, y, z) != tree )
			return;
		if( get(x - 1, y, z)&127 != tree || get(x + 1, y, z)&127 != tree || get(x, y - 1, z)&127 != tree || get(x, y + 1, z)&127 != tree || get(x, y, z - 1)&127 != tree || get(x, y, z + 1)&127 != tree )
			return;
		set(x, y, z, tree | 128 );
		carveTreeRec(x + 1, y, z, tree,empty);
		carveTreeRec(x - 1, y, z, tree,empty);
		carveTreeRec(x, y + 1, z, tree,empty);
		carveTreeRec(x, y - 1, z, tree,empty);
		carveTreeRec(x, y, z - 1, tree,empty);
		set(x, y, z, empty);
	}
	
	function addAcidTrees() {
		var wood = alloc(BAcidWood);
		var woodHole = alloc(BAcidWoodHole);
		var woodBubble = alloc(BAcidWoodBubble);
		var leaves1 = alloc(BAcidLeaves);
		var leaves1Bubble = alloc(BAcidLeavesBubble);
		var leaves2 = alloc(BAcidLeaves2);
		var leaves2Bubble = alloc(BAcidLeaves2Bubble);
		var champi = alloc(BAcidMush);
		var fruit = alloc(BStainGreen);
		
		var trees = new Array<{x:Int,y:Int,z:Int,h:Int}>();
		for( i in 0...Math.ceil(size * size / 200) ) {
			var ntry = 1000;
			while( ntry-->0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				if( height(x, y) < waterLevel )
					continue;
				var z = height(x, y);
				var h = max(rnd.random(100 - z), rnd.random(100 - z));
				if( h < 30 )
					continue;
				var found = false;
				for( t in trees ) {
					var dx = realDist(t.x - x);
					var dy = realDist(t.y - y);
					var d = dx * dx + dy * dy;
					if( d < 15 * 15 ) {
						found = true;
						break;
					}
				}
				if( found )
					continue;
				trees.push( { x:x, y:y, z : z, h:h } );
				break;
			}
		}
		
		for( t in trees ) {
			var oz = t.z;
			var x = t.x;
			var y = t.y;
			var z = t.z + 20;
			
			var a = rnd.rand() * Math.PI;
			var k = 5;
			var hasChampi = rnd.random(5) == 0;
			for( i in 0...k ) {
				a += Math.PI * 2 / k;
				var len = 5 + rnd.rand() * 5;
				var dx = Math.ceil(Math.cos(a) * len);
				var dy = Math.ceil(Math.sin(a) * len);
				line(x, y, t.z, dx, dy, -5, function(x, y, z) { set(x, y, z, wood); if( hasChampi && rnd.random(2) == 0 ) oset(x, y, z + 1, champi); });
			}
			
			var falloff = 0.15 + (rnd.rand() - 0.5) * 0.1;
			
			while( true ) {
				var rz = z - z % 10;
				var dx = rnd.random(7) - 3;
				var dy = rnd.random(7) - 3;
				if( rz == oz ) {
					dx = 0;
					dy = 0;
				} else {
					line(x, y, oz, dx, dy, rz - oz, function(x, y, z) elipse(1 + rnd.rand() * 1.5, 1 + rnd.rand() * 1.5, 1 + rnd.rand() * 1.5, function(dx, dy, dz) set(x + dx, y + dy, z + dz, wood)));
					x += dx;
					y += dy;
					oz = rz;
				}
				var light = rnd.random(3)==0;
				var w = 10 + rnd.random(6);
				var h = 10 + rnd.random(6);
				for( i in 0...10 ) {
					var cx = x + rnd.random(w) - (w >> 1);
					var cy = y + rnd.random(h) - (h >> 1);
					var cw, ch;
					do {
						cw = min(rnd.random(w), rnd.random(w));
						ch = min(rnd.random(h), rnd.random(h));
					} while( cw < 3 || ch < 3 );
					circle(cw,ch, function(dx, dy) {
						var dx = cx + dx - x;
						var dy = cy + dy - y;
						var ray = Math.sqrt(dx * dx + dy * dy);
						var b = light ? ( rnd.random(100)<5 ? leaves2Bubble : leaves2 ) : ( rnd.random(10)==0 ? leaves1Bubble : leaves1 );
						if( oset(x + dx, y + dy, rz - Std.int(ray * falloff), b) && rnd.random(100) == 0 && ray > rnd.rand() * 10 )
							oset(x + dx, y + dy, rz - Std.int(ray * falloff) + 1, fruit);
					});
				}
				
				if( z == t.z + t.h )
					break;
				z += 8 + rnd.random(8);
				if( z > t.z + t.h )
					break;
			}
			if( oz >= 80 && rnd.random(3) == 0 )
				set(x, y, oz + 1, alloc(BAcidFruit));
			for( dx in -1...2 )
				for( dy in -1...2 )
					for( dz in -3...0 )
						carveTreeRec(x+dx, y+dy, oz + dz, wood, CAVE);
		}
		
		// add parasits leaves
		var parasit = alloc(BBrownLeaves);
		var count = 0;
		for( i in 0...Math.ceil(size * size / 30) ) {
			var ntry = 100;
			while( ntry-->0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = rnd.random(100);
				if( get(x, y, z) != wood )
					continue;
				elipse(2, 2, 1.5, function(dx, dy, dz) oset(x + dx, y + dy, z + dz, parasit));
				count++;
				break;
			}
		}
		
		// replace CAVE by tree content
		var sap = alloc(BAcidTreeSap);
		for( i in 0...size * size * HEIGHT ) {
			if( fget(i) == wood && rnd.random(10)==0 )
				fset(i, rnd.random(100)<30 ? woodBubble : woodHole );
			if( fget(i) == CAVE )
				fset(i, rnd.random(5) == 0 ? sap : EMPTY);
		}
		
		// add minerals
		var rock = alloc(BHardRock);
		for( i in 0...Math.ceil(size * size / 3000) ) {
			var ntry = 1000;
			while( ntry-->0 ) {
				var x = rnd.random(size);
				var y = rnd.random(size);
				var z = waterLevel;
				if( get(x, y, z) != WATER ) continue;
				var s = 5;
				if( get(x + s, y, z) != WATER || get(x - s, y, z) != WATER || get(x, y - s, z) != WATER || get(x, y + s, z) != WATER )
					continue;
				var h = 1;
				while( get(x, y, z - h) == WATER && h < 5 )
					h++;
				if( h >= 3 ) continue;
				var el = [];
				for( i in 0...4 ) {
					var x = x + rnd.random(5) - 2;
					var y = y + rnd.random(5) - 2;
					var z = z - h - 1;
					var sx = 1.3 + rnd.rand() * 1.5;
					var sy = 1.2 + rnd.rand() * 1.5;
					var sz = 1 + rnd.rand() * 1.3;
					el.push( { x:x, y:y, z:z, sx:sx, sy:sy, sz:sz } );
				}
				var pts = [];
				for( e in el )
					elipse(e.sx, e.sy, e.sz, function(dx, dy, dz) {
						var x = e.x + dx, y = e.y + dy, z = e.z + dz;
						if( get(x, y, z) == EMPTY || get(x, y, z) == WATER ) {
							set(x, y, z, rock);
							pts.push( { x:x, y:y, z:z } );
						}
					});
				fillMinerals(pts);
			}
		}
	}
	
	function addCaveAccesses( zchk ) {
		gen(0.2, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = zchk;
			if( get(x, y, z) != CAVE )
				return false;
			while( get(x, y, z) == CAVE )
				z++;
			var zstart = z;
			while( true ) {
				var b = get(x, y, z);
				if( b == WATER )
					return false;
				if( b == EMPTY )
					break;
				z++;
			}
			if( z - zstart > 10 )
				return false;
			eraseCaveRec(x, y, z - 1, 20);
			for( z in zstart...z ) {
				if( rnd.random(5) == 0 )
					elipse(1.5, 1.5, 1.5, function(dx, dy, dz) set(x + dx, y + dy, z + dz, EMPTY));
				else
					set(x, y, z, EMPTY);
			}
			return true;
		});
	}
	
	function eraseCaveRec( x, y, z, rec ) {
		if( get(x, y, z) != CAVE )
			return;
		set(x, y, z, EMPTY);
		rec--;
		if( rec == 0 ) return;
		eraseCaveRec(x - 1, y, z, rec);
		eraseCaveRec(x + 1, y, z, rec);
		eraseCaveRec(x, y - 1, z, rec);
		eraseCaveRec(x, y + 1, z, rec);
		eraseCaveRec(x, y, z - 1, rec);
		eraseCaveRec(x, y, z + 1, rec);
	}
	
	function addWinterDetails() {
		var ice = alloc(BIce);
		for( x in 0...size )
			for( y in 0...size ) {
				var z = waterLevel;
				var p = addr(x,y,z);
				if( fget(p) == WATER && fget(p - 1) != WATER ) {
					if( (get(x,y+1,z-1) != WATER && get(x,y-1,z-1) != WATER && get(x+1,y,z-1) != WATER && get(x-1,y,z-1) != WATER) || rnd.random(5) == 0 )
						fset(p, ice);
				}
			}
		
		// small pitonics
		gen(0.2, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z > 40 )
				return false;
			for( dx in -1...2 )
				for( dy in -1...2 )
					if( get(x + dx, y + dy, z) != EMPTY || get(x + dx, y + dy, z - 1) != SOIL )
						return false;
			var h = 2 + rnd.random(8);
			var isIce = rnd.random(5) == 0;
			for( i in 0...h )
				set(x, y, z + i, isIce ? ice : rnd.random(2) == 0 ? ROCK : SOIL);
			for( d in [[ -1, 0], [1, 0], [0, 1], [0, -1]] ) {
				var dx = d[0], dy = d[1];
				for( i in 0...Math.ceil(h/4) + rnd.random(h >> 1) )
					oset(x + dx, y + dy, z + i, isIce ? ice : rnd.random(2) == 0 ? ROCK : SOIL);
			}
			return true;
		});
		
		// cascades
		var source = alloc(BCascadeSource);
		var fall = alloc(BCascadeFall);
		gen(0.2, 1000, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z < 80 || get(x,y,z) == EMPTY )
				return false;
			z = 70 + rnd.random((z - 80) >> 1);
			var dx = rnd.random(2) == 0 ? -1 : 1;
			var dy = rnd.random(2) == 0 ? -1 : 1;
			if( rnd.random(2) == 0 ) dx = 0 else dy = 0;
			while( true ) {
				var b = get(x, y, z);
				if( b == EMPTY ) break;
				if( b == source || b == fall ) return false;
				x += dx;
				y += dy;
			}
			var len = 3 + rnd.random(3);
			for( i in 0...len+1 )
				if( get(x + dx * i, y + dy * i, z) != EMPTY )
					return false;
			var nfall = 0;
			while( get(x + dx * len, y + dy * len, z - nfall) == EMPTY )
				nfall++;
			if( nfall < 10 )
				return false;
			for( i in 0...len ) {
				set(x, y, z, SOIL);
				x += dx;
				y += dy;
			}
			set(x, y, z, source);
			z--;
			while( get(x, y, z) == EMPTY ) {
				set(x, y, z, fall);
				z--;
			}
			return true;
		});
		
		// hidden flowers
		var hidden = alloc(BWinterHidden);
		gen(0.3, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z <= waterLevel || z > 40 || get(x,y,z) != EMPTY || get(x,y,z-1) != SOIL ) return false;
			set(x, y, z, hidden);
			return true;
		});
		
		// teintures
		var stain = alloc(BStainWhite);
		var empty = alloc(BStainEmpty);
		gen(0.45,1000,function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x,y);
			if( z>=60 && get(x, y, z)==EMPTY && (get(x,y,z-1)==ROCK || get(x,y,z-1)==SOIL) ) {
				set(x, y, z, rnd.random(100)<75 ? stain : empty);
				return true;
			}
			return false;
		});
		
		// sapins
		var tree = alloc(BWinterWood);
		var leaves = alloc(BWinterLeaves);
		var stalag1 = alloc(BIceStalactite1);
		var stalag2 = alloc(BIceStalactite2);
		gen(0.1, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( get(x, y, z) != EMPTY || get(x, y, z - 1) != SOIL )
				return false;
			var trees = new Array();
			for( i in 0...10 ) {
				var ntry = 20;
				var px, py, pz, h;
				do {
					px = x + rnd.random(17) - 8;
					py = y + rnd.random(17) - 8;
					pz = height(px, py);
					h = 8 + rnd.random(8);
				} while( --ntry > 0 && (get(px, py, pz) != EMPTY || get(px, py, pz - 1) != SOIL || !free(px-4,py-4,pz+1,8,8,h) || pz > 40) );
				if( ntry <= 0 ) break;
				set(px, py, pz, tree);
				trees.push( { x:px, y:py, z:pz, h:h } );
			}
			
			var all = [];
			function addLeaves(x,y,z) {
				oset(x, y, z, leaves);
				all.push( {x:x, y:y, z:z} );
			}
			for( t in trees ) {
				var x = t.x, y = t.y, z = t.z, h = t.h;
				for( i in 0...h )
					set(x, y, z + i, tree);
				set(x, y, z + h, leaves);
				var size = 1;
				var dz = h - 1;
				while( dz > h >> 2 ) {
					for( i in -size...size+1 ) {
						addLeaves(x - size, y + i, z + dz);
						addLeaves(x + size, y + i, z + dz);
						addLeaves(x + i, y - size, z + dz);
						addLeaves(x + i, y + size, z + dz);
					}
					if( size < 4 && rnd.random(3+size*size) == 0 )
						size++;
					dz--;
				}
			}
			var n = 15;
			while( n>0 && all.length>0 ) {
				var c = all.splice(rnd.random(all.length), 1)[0];
				if( get(c.x, c.y, c.z-1)==EMPTY) {
					oset(c.x, c.y, c.z-1, rnd.random(2)==0 ? stalag1 : stalag2 );
					n--;
				}
			}
			return true;
		});
	}
	
	function adjustMarsHeight() {
		gen(0.05, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z < 80 ) return false;
			var h = 3 + rnd.rand() * 10;
			circle(5 + rnd.rand() * 5, 5 + rnd.rand() * 5, function(dx, dy) {
				var x = x + dx, y = y + dy;
				var r = 30 / (dx * dx + dy * dy + 30);
				setHeight(x, y, height(x, y) + Math.ceil(r * h));
			});
			return true;
		});
	}
	
	function addMarsDetails() {
		// soil2
		var soil2 = alloc(BMarsSoil2);
		initPerlin(3);
		for( x in 0...size )
			for( y in 0...size ) {
				var p = ((perlin2D(x, y) + 1) * 4) % 1;
				if( p < 0.3 ) {
					var z = height(x, y) - 1;
					if( get(x, y, z) == SOIL )
						set(x, y, z, soil2);
				}
			}
					
		
		// rocks
		var rock = alloc(BMarsHardRock);
		gen(1, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z < 80 ) return false;
			set(x, y, z, rock);
			return true;
		});
		
		// craters
		var crock = alloc(BMarsCraterRock);
		var bluerock = alloc(BMarsBlueRock);
		gen(0.1, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z < 50 ) return false;
			var size = 4 + rnd.rand() * 8;
			elipse(size, size, size * 0.5, function(dx, dy, dz) {
				var x = x + dx, y = y + dy, z = z + dz;
				if( get(x, y, z - 1) == ROCK && (dx*dx+dy*dy) / (size*size) < 0.33 )
					set(x, y, z - 1, rnd.random(10) == 0 && !around(x,y,z-1,bluerock) ? bluerock : crock);
				while( get(x,y,z) != EMPTY )
					set(x, y, z++, EMPTY);
			});
			return true;
		});
		
		// cactus
		var cactus = alloc(BMarsCactus);
		var bones = alloc(BMarsCactusFossil);
		var flower = alloc(BMarsCactusFlower);
		gen(0.03, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z < 83 ) return false;
			
			for( i in 0...10 ) {
				var x = x + rnd.random(21) - 10;
				var y = y + rnd.random(21) - 10;
				var z = height(x, y);
				if( z < 83 || get(x, y, z - 1) != SOIL )
					continue;
				var h = 3 + rnd.random(3);
				for( i in 0...h )
					oset(x, y, z++, rnd.random(100)<10 ? bones : cactus);
				for( i in 0...2 ) {
					var z = z -1, x = x, y = y;
					var dx = 0, dy = 0;
					switch( rnd.random(4) ) {
					case 0: dx++;
					case 1: dy++;
					case 2: dx--;
					case 3: dy--;
					}
					function rndCactus() {
						return rnd.random(5) == 0 ? flower : rnd.random(100)<10 ? bones : cactus;
					}
					for( i in 0...min(rnd.random(3), rnd.random(3)) ) {
						x += dx;
						y += dy;
						oset(x, y, z, rndCactus());
					}
					for( i in 0...max(rnd.random(h)+1,rnd.random(h)+1) ) {
						oset(x + dx, y + dy, z, rndCactus());
						z++;
					}
				}
			}
			return true;
		});
		
		// hidden caves
		var qsand = alloc(BMarsQuickSand);
		for( x in 0...size )
			for( y in 0...size ) {
				if( realHeight(x + y * size) > 1.02 ) {
					for( z in 0...2 )
						oset(x, y, 75 + z, qsand);
				}
			}
		
		// fossils
		var fossil = alloc(BMarsRockFossil);
		gen(0.1,1000,function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = 32 + rnd.random(height(x, y) - 32);
			if( get(x, y, z) == ROCK && around(x, y, z, EMPTY) ) {
				set(x, y, z, fossil);
				return true;
			}
			return false;
		});
		
		// teintures
		var stain = alloc(BStainOrange);
		var empty = alloc(BStainEmpty);
		var n = 30;
		var tries = n*50;
		while(n>0 && tries-->0) {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = rnd.random(24)+12;
			if( get(x,y,z)==EMPTY ) {
				while( !isSolidAt(x,y,z-1) )
					z--;
				elipse(4,4,5, function(dx,dy,dz) {
					var x=x+dx, y=y+dy, z=z+dz;
					if( rnd.random(100)<30 && get(x,y,z)==EMPTY && isSolidAt(x,y,z-1) )
						set(x,y,z, rnd.random(100)<60 ? stain : empty);
				});
				n--;
			}
		}
	}
	
	function createHeightsLevels( hmin, hmod ) {
		for( y in 0...size )
			for( x in 0...size ) {
				var h = height(x, y) - hmin;
				if( h < 0 )
					continue;
				setHeight(x, y, hmin + (h - (h % hmod)));
			}
	}
	
	
	function addDeadDetails() {
		var tree = alloc(BDeadTree);
		var leaves = alloc(BDarkLeaves);
		var deadWindows = [];
		
		var swamp = alloc(BDeadSwamp);
		for( x in 0...size )
			for( y in 0...size ) {
				var z = height(x, y);
				if( z <= waterLevel + 2 && get(x, y, z-1) == SOIL )
					set(x, y, z-1, swamp);
			}
				
		
		function genDeadHouse(x, y, z) {
			var w = 4 + rnd.random(5);
			var h = 4 + rnd.random(5);
			function check() {
				for( dx in 0...w +1 )
					for( dy in 0...h + 1 ) {
						if( get(x+dx, y+dy, z) != EMPTY || !isSolid(get(x+dx, y+dy, z - 1)) || get(x+dx,y+dy,z-1) == swamp )
							return false;
					}
				return true;
			}
			if( !check() )
				return false;

				
			// walls
			var mat = rnd.random(5) == 0 ? ROCK : tree;
			var imat = mat == ROCK ? tree : ROCK;
			
			var stairs = 1 + min(rnd.random(4), rnd.random(4));
			var height = 5 * stairs;

			for( dz in 0...height ) {
				for( dx in 0...w + 1 ) {
					set(x + dx, y, z + dz, mat);
					set(x + dx, y + h, z + dz, mat);
				}
				for( dy in 0...h + 1 ) {
					set(x, y + dy, z + dz, mat);
					set(x + w, y + dy, z + dz, mat);
				}
			}

			for( i in 0...stairs+1 ) {
				var z = z + i * 5;
				if( i == stairs ) z--;
				set(x, y, z, imat);
				set(x + w, y, z, imat);
				set(x + w, y + h, z, imat);
				set(x, y + h, z, imat);
			}
			
			// stairs
			for( s in 0...stairs ) {
				var z = z + s * 5;
				
				if( s > 0 ) {
					for( dx in 1...w )
						for( dy in 1...h )
							oset(x + dx, y + dy, z - 1, leaves);
				}
				
				// entrance - window
				{
					var dx = 0, dy = 0;
					switch( rnd.random(4) ) {
					case 0: dx++;
					case 1: dx--;
					case 2: dy++;
					case 3: dy--;
					}
					var x = x, y = y;
					x += 2 + rnd.random(w - 4);
					y += 2 + rnd.random(h - 4);
					while( get(x, y, z) == EMPTY ) {
						x += dx;
						y += dy;
					}
					if( s > 0 )
						deadWindows.push( { x:x, y:y, z:z, dx:dx,dy:dy } );
					var count = 2;
					while( get(x, y, z) != EMPTY && count-- > 0 ) {
						for( dz in 0...3 )
							set(x, y, z+dz, EMPTY);
						x += dx;
						y += dy;
					}
				}
				
			}
			
			
			
			// roof
			while( w >= 1 && h >= 1 ) {
				w -= 2;
				h -= 2;
				x++;
				y++;
				for( dx in 0...w +1 )
					for( dy in 0...h + 1 )
						set(x + dx, y + dy, z + height, leaves);
				height++;
			}
			
			return true;
		}
		
		// villages
		gen(0.01, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			var z = height(x, y);
			if( z > waterLevel || get(x, y, z) != WATER )
				return false;
			for( i in 0...15 ) {
				var ntry = 100;
				while( ntry-- > 0 ) {
					var x = real( x + rnd.random(50) - 25 );
					var y = real( y + rnd.random(50) - 25 );
					var z = height(x, y);
					if( genDeadHouse(x, y, z) )
						break;
				}
			}
			return true;
		});
		
		// add passerels
		
		for( d in deadWindows ) {
			var x = d.x;
			var y = d.y;
			var z = d.z;
			var dx = d.dx;
			var dy = d.dy;
			var dist = 0;
			while( get(x, y, z) == EMPTY && dist++ < 8 ) {
				x += dx;
				y += dy;
			}
			if( get(x, y, z) == tree && get(x - dy, y - dx, z) == tree && get(x + dy, y + dx, z) == tree ) {
				x = d.x + dx;
				y = d.y + dy;
				z--;
				for( i in 1...dist ) {
					oset(x, y, z, tree);
					oset(x + dy, y + dx, z, tree);
					oset(x - dy, y - dx, z, tree);
					x += dx;
					y += dy;
				}
				z++;
				for( dz in 0...3 )
					set(x, y, z + dz, EMPTY);
			}
		}
		
		// trees
		gen(0.03, function() {
			var x = rnd.random(size);
			var y = rnd.random(size);
			for( i in 0...30 ) {
				var x = real( x + rnd.random(30) - 15 );
				var y = real( y + rnd.random(30) - 15 );
				var z = height(x, y);
				if( get(x, y, z) != EMPTY || get(x, y, z - 1) != SOIL )
					continue;
				for( dz in 4...9 )
					if( get(x, y, z + dz) != EMPTY ) {
						z = -1;
						break;
					}
				if( z < 0 ) continue;
					
				var h = 6 + rnd.random(8);
				var sz = z;
				line(x, y, z, rnd.random(5) - 2, rnd.random(5) - 2, h >> 1, function(x, y, z) {
					oset(x, y, z, tree);
					if( z == sz + (h >> 1) )
						for( i in 0...4 )
							line(x, y, z, rnd.random(11) - 5, rnd.random(11) - 5, h >> 1, function(x,y,z) oset(x,y,z,leaves));
				});
			}
			return true;
		});
	}
		
}

