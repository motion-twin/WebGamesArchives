using StringTools;
using Lambda;

import MoveManager;
import ShotManager;
import BigBullet;
import flash.geom.Point;

class WarZoneBuilder {
	static var warZone : WarZone;	
		
	static function randomCPath() : CPath {
		var c = CPath.PATHES[Std.random(CPath.PATHES.length)].clone();
		c.translate(warZone.minX, warZone.minY);
		return c;
	}

	static function randomPath() : Path {
		var c = Path.PATHES[Std.random(Path.PATHES.length)].clone();
		c.translate(warZone.x, warZone.y);
		return c;
	}
	
	public static function build( circle:Int ){
		warZone = Game.instance.warZone;
		var table = [
			cfoeX3,
			foeWave,
			foeShooterWaves,
		];
		table[Std.random(table.length)](circle);		
	}

	// Vague plutôt difficile :)
	// Les CFoe débarquent sur un path 3 par 3
	// Plus le cercle est éloigné et plus les zones de débarquement sont nombreuses
	// A partir du niveau 10 des lazers sont aussi installés
	static function cfoeX3( circle:Int ){
		var list = [];
		var n = Std.int(Math.max(1, Math.min(2, (circle/3))));
		var path = randomCPath();
		var parts = path.parts();
		var nbrSpawners = Std.int(Math.max(1, Math.min(circle/4, parts.length)));
		var perSpawner = Std.int(Math.max(1, n/nbrSpawners));
		for (i in 0...perSpawner*3)
			list.push({ delay:if (i % 3 == 0) 2.0 else 0.4, cls:untyped CFoe });
		for (i in 0...nbrSpawners){
			var node = extractRandom(parts);
			var rdv = node.getRendezVousPoint();
			var spawner = new Spawner(list, function(c:Enemy){
				c.x = rdv.x;
				c.y = rdv.y;
				c.move = new CPathMoveManager(c, node);
				var extraLife = Std.int(Math.max(0, Math.floor((circle - 30) / 10)));
				c.life += extraLife * 10;
				c.maxLife += extraLife * 10;
			});
			spawner.setPos(rdv);
			Game.instance.addSpawner(spawner);
		}
		var parts = path.parts();
		var lasers = Std.int(Math.max(0, Math.min(parts.length, Math.floor((circle - 0) / 10))));
		for (i in 0...lasers){
			var p = extractRandom(parts);
			var l = new XBalls();
			l.x = p.center.x;
			l.y = p.center.y;
			Game.instance.addFoe(l);
		}
	}

	static function foeWave( circle:Int ){
		var first = true;
		var coords = [ new Point(50,50), new Point(550,550), new Point(50,550), new Point(550,50) ];
		var spawns = [ null, null, null, null ];
		var n = Std.int(Math.max(5, circle*2));
		do {
			var nwave = Std.int(Math.max(5, Math.min(15, n)));
			var list = [];
			for (i in 0...nwave)
				list.push({ delay:0.2, cls:untyped Foe });
			if (first)
				first = false;
			else
				list[0].delay = 8.0;
			n -= nwave;
			var i = Std.random(coords.length);
			if (spawns[i] == null){
				var spawner = new Spawner(list, function(c:Enemy){
					var extraLife = Std.int(Math.max(0, Math.floor((circle - 20) / 5)));
					c.life += extraLife * 2;
					c.maxLife += extraLife * 2;
				});
				spawner.setPos(warZone.getPoint(coords[i].x, coords[i].y));
				spawns[i] = spawner;
				Game.instance.addSpawner(spawner);
			}
			else {
				spawns[i].list = spawns[i].list.concat(list);
			}	
		}
		while (n > 0);	
		if (circle > 10)
			if (Std.random(2) == 0)
				bigbullet(circle);
			else
				rotaShoot(circle);
		if (circle > 15)
			twoMinerSpawners(circle);
	}

	static function foeShooterWaves( circle:Int ){	
		var list = [];
		var waves = Std.int(Math.max(1, Math.min(5, circle/4)));
		var spawns = Std.int(Math.max(1, Math.min(4, waves / 2)));
		var wavesPerSpawn = Std.int(Math.max(1, Math.floor(waves / spawns)));

		var coords = [ new Point(100,100), new Point(500,500), new Point(100,500), new Point(500,100) ];

		var list = [];
		for (i in 0...wavesPerSpawn*5)
			list.push({ delay:if (i != 0 && i % 5 == 0) 3 else 0.20, cls:untyped FoeShooter });
		
		for (w in 0...spawns){
			var c = coords.shift();
			var spawner = new Spawner(list);
			spawner.setPos(warZone.getPoint(c.x, c.y));
			Game.instance.addSpawner(spawner);
		}

		if (circle > 10)
			twoMinerSpawners(circle);		
	}

	static function bigbullet(circle:Int){
		var coords = [
			warZone.getPoint(100, 100),
			warZone.getPoint(100,-100),
			warZone.getPoint(-100,100),
			warZone.getPoint(-100,-100)
		];
		if (circle < 10) extractRandom(coords);
		if (circle < 15) extractRandom(coords);
		if (circle < 17) extractRandom(coords);
		for (c in coords){
			var s = new Spawner([{ delay:1.0, cls:untyped BigBulleter }]);
			s.x = c.x;
			s.y = c.y;
			Game.instance.addSpawner(s);
		}
	}

	static function rotaShoot(circle:Int){
		var coords = [
			warZone.getPoint(100, 100),
			warZone.getPoint(100,-100),
			warZone.getPoint(-100,100),
			warZone.getPoint(-100,-100)			
		];
		if (circle < 10) extractRandom(coords);
		if (circle < 15) extractRandom(coords);
		if (circle < 17) extractRandom(coords);
		for (c in coords){
			var rota = new RotaShooter();
			rota.setPos(c);
			Game.instance.addFoe(rota);
		}
	}
	
	static function twoMinerSpawners(circle:Int){
		var p = randomPath();
		var availableSpawns = p.getSpawns();
		if (availableSpawns.length == 0)
			throw "no spawn ? WTF";
		var n = Std.int(Math.max(1, Math.min(availableSpawns.length, Math.floor(circle / 4))));	
		var list = [ { delay:0.4, cls:untyped Miner } ];
		for (i in 0...n){
			var path = extractRandom(availableSpawns);
			var spawner = new Spawner(list, function(c){
				c.move = new PathMoveManager(c, path);
				c.x = path.point.x;
				c.y = path.point.y;
			});
			spawner.x = path.point.x;
			spawner.y = path.point.y;
			Game.instance.groundLayer.addChild(spawner);
			Game.instance.spawners.push(spawner);
		}
	}

	static function extractRandom<T>( arr:Array<T> ) : T {
		if (arr.length == 0)
			throw "cannot extract random on empty array";
		var n = Std.random(arr.length);
		var r = arr[n];
		arr[n] = arr[arr.length-1];
		arr.pop();
		return r;
	}
		
}