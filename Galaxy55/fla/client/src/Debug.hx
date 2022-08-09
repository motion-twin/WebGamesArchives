import Common;
import Protocol;

class Debug {
	
	var game : Game;
	var detailsIndex : Int;
	
	public function new(g) {
		this.game = g;
		if( game.infos.debug ) {
			flash.external.ExternalInterface.addCallback('onCmd', onCommand);
			flash.external.ExternalInterface.call('init2', g.hero.invincible);
		}
	}
	
	function onCommand( cmd : String, param : String ) {
		var interf = game.interf, level = game.level, hero = game.hero, planet = game.planet, render = game.render;
		
		switch( cmd ) {
		case "clear":
			game.api.clearLocalChanges();
		case "power":
			game.hero.miningPower = game.hero.miningPower==1 ? 3 : 1;
		case "nextDet":
			var dall = gen.DetailsGenerator.DETAILS;
			var d = dall[detailsIndex % dall.length];
			if( d == null )
				return;
			detailsIndex++;
			hero.x = d.x + 0.5;
			hero.y = d.y + 0.5;
			if( d.z > 0 ) hero.z = d.z;
		case "start":
			var pos = level.getStartPlace(game.infos.planet);
			if( pos == null )
				log("No start place found");
			else {
				hero.x = pos.x + 0.5;
				hero.y = pos.y + 0.5;
				hero.z = pos.z;
			}
		case "inv":
			var delta = Std.parseInt(param);
			var ilast = interf.inv.t[interf.inv.t.length - 1];
			var bcur = ilast != null ? ilast.k : 0;
			for( i in 0...interf.inv.t.length ) {
				while( true ) {
					if( delta > 0 ) {
						if( bcur + 1 >= Std.int(Block.all.length) ) bcur = 0;
						++bcur;
					} else {
						bcur--;
						if( bcur<0 ) bcur = Std.int(Block.all.length-1);
					}
					var b = Block.all[bcur];
					if( b.type == BTInvisible || b.type == BTWater || (b.flip != null && b.flip.index < b.index) )
						continue;
					break;
				}
				interf.inv.t[i] = { k : bcur, n : 50 };
			}
			interf.display();
		case "fog":
			planet.biome.fogPower *= 0.8;
		case "hide":
			var b = planet.biome.soils[Std.parseInt(param)];
			if( b != null ) render.builder.toggleBlock(Block.get(b));
		case "rebuild":
			var t0 = flash.Lib.getTimer();
			var stats = render.testRebuildAll();
			var dt = flash.Lib.getTimer() - t0;
			log(stats.chunks + " chunks built " + (Std.int(dt * 100 / stats.chunks) / 100) + "ms avg, " + Math.ceil(stats.tri / 1024) + "K.Tri");
		case "count":
			var stats = new flash.Vector<Int>(65536);
			for( cx in level.cells )
				for( c in cx ) {
					if( c.t == null ) continue;
					flash.Memory.select(c.t);
					for( i in 0...Const.TSIZE ) {
						var b = flash.Memory.getUI16(i << 1);
						if( b > 0 ) stats[b]++;
					}
				}
			var blocks = [];
			var tot = 0;
			for( i in 1...0x10000 ) {
				var n = stats[i];
				if( n == 0 ) continue;
				blocks.push( { i : i, n : n } );
				tot += n;
			}
			blocks.sort(function(a, b) return b.n - a.n);
			haxe.Log.clear();
			var cst = Type.getEnumConstructs(BlockKind);
			for( b in blocks )
				log("#" + b.i + "(" + cst[b.i] + ") = " + b.n + " (" + (Std.int(b.n * 10000.0 / tot) / 100) + "%)");
		case "biome":
			save.data._b = Std.parseInt(param);
			save.flush();
		case "mode":
			save.data._m = Std.parseInt(param);
			save.flush();
		case "seed":
			save.data._s = Std.parseInt(param);
			save.flush();
		case "size":
			save.data._sz = Std.parseInt(param);
			save.flush();
		case "dam":
			hero.invincible = (param == "true");
		case "clone":
			var id = -(game.clones.length + 1);
			var s = game.getNetState();
			s.x += Math.cos(s.a) * 5;
			s.y += Math.sin(s.a) * 5;
			var name = "Clone#" + id;
			var c = new ent.OnlineHero(game, { uid : -id, id : null, name : name, camera : false }, s);
			game.userMap.set( -id, name);
			game.clones.push(c);
			var t = new haxe.Timer(10);
			t.run = function() {
				s.a = hero.angle;
				s.az = hero.angleZ;
				if( hero.gravity < 0 )
					s.g = hero.gravity;
				s.select = game.getNetState().select;
			};
		default:
			throw "Unknown command " + cmd;
		}
	}
	
	public function log( v : Dynamic ) {
		haxe.Log.trace(v, null);
	}
	
	static var save : flash.net.SharedObject;
	
	public static function getStartInfos() {
		if( __unprotect__("pmf") != "pmf_" )
			return cast { };
		
		save = flash.net.SharedObject.getLocal("mode");
		
		var infos : Dynamic = save.data;
		if( infos._b == null )
			infos._b = 0;
		if( infos._m == null )
			infos._m = 0;
		if( infos._s == null )
			infos._s = 42;
		if( infos._sz == null )
			infos._sz = 2;
		var start = {
			biome : Type.createEnumIndex(BiomeKind, infos._b),
			mode : Type.createEnumIndex(ClientMode, infos._m, [null]),
			seed : infos._s,
			size : infos._sz,
		};
		var biomes = [];
		for( b in Type.allEnums(BiomeKind) ) {
			var c = Type.enumConstructor(b);
			biomes.push(c.substr(2, c.length-3));
		}
		flash.external.ExternalInterface.call("init", biomes.join(":"), Type.enumIndex(start.biome), Type.enumIndex(start.mode), start.seed, start.size);
		
		return start;
	}
	
}