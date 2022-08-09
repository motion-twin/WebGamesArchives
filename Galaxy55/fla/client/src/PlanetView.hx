import Common;
import Protocol;

class AtmShader extends h3d.Shader {
	
	static var SRC = {
		var input : { pos : Float3, uv : Float2 };
		var tuv : Float2;
		function vertex( mproj : Matrix ) {
			out = pos.xyzw * [1.05, 1.05, 1.05, 1] * mproj;
			tuv = uv;
		}
		function fragment( tex : Texture, scroll : Float2 ) {
			var c = tex.get(tuv + scroll,wrap);
			c.a = c.r * 0.5;
			out = c;
		}
	}
	
}

class PlanetView extends Mode {

	var planet : r3d.Planet;
	var atm : h3d.CustomObject<AtmShader>;
	var level : Level;
	var time : Float;
	var needChunks : Int;
	var load : fx.Load;
	var planetId : Int;
	var posRetry : Int;

	public function new(root, engine, api) {
		super(root, engine,api);
		level = new Level(api.planet.size);
		load = new fx.Load();
		load.percentVisible = true;
		root.addChild(load);
		root.addEventListener(flash.events.Event.ENTER_FRAME, function(_) update());
		time = 0;
		var zoom = 3;
		engine.camera.pos.set(0, zoom, zoom * 0.1);
		engine.camera.target.set(0, 0, 0);
		engine.camera.update();
		init();
		update();
	}
	
	function init() {
		for( x in 0...api.planet.size )
			for( y in 0...api.planet.size ) {
				needChunks++;
				api.requestChunk(x, y);
			}
	}
	
	override function onChunk(x, y, t:haxe.io.Bytes) {
		level.add(x, y, t.getData());
		needChunks--;
		if( needChunks == 0 )
			haxe.Timer.delay(genMap, 1);
	}

	function genMap() {
		var map = gen.Map.make(level, Data.TEXTURE, Data.getBiome(api.planet.biome).water);
		if( map.map.width < 256 ) {
			var mnew = new flash.display.BitmapData(256, 256);
			mnew.draw(map.map, new flash.geom.Matrix(256 / map.map.width, 0, 0, 256 / map.map.height));
			map.map.dispose();
			map.map = mnew;
		}
		haxe.Timer.delay( callback(genPlanet,map), 1 );
	}
	
	function genPlanet( map ) {
		planet = new r3d.Planet(engine, map.map, map.height, api.planet.waterLevel, 0.5, 0.5, 64);
		
		var light = Data.getBiome(api.planet.biome).sunPower / 10;
		planet.shader.ambient = 0.25 * light;
		
		var ldir = new h3d.Vector(-3, 4, 5);
		ldir.normalize();
		ldir.scale3(1.2 * light);
		planet.shader.light = ldir;
		
		
		var sphere = new h3d.prim.Sphere(20, 20);
		sphere.addTCoords();
		atm = new h3d.CustomObject(sphere, new AtmShader());
		atm.material.blend(SrcAlpha, SrcColor);
		var tex = engine.mem.allocTexture(256, 256);
		var bmp = new flash.display.BitmapData(256, 256, true, 0);
		bmp.perlinNoise(64, 64, 4, 0, true, true, 7, true);
		tex.upload(bmp);
		bmp.dispose();
		atm.shader.tex = tex;
		root.removeChild(load);
		load = null;
	}
	
	override function onCommand(cmd) {
		switch( cmd ) {
		case CUploadPlanet(id):
			this.planetId = id;
			if( planet == null ) {
				haxe.Timer.delay(callback(onCommand, cmd), 500);
				return;
			}
			var a = [];
			for( y in 0...api.planet.size )
				for( x in 0...api.planet.size )
					a.push({ x : x, y : y });
			function next(cmd) {
				if( cmd != null )
					onCommand(cmd);
				var c = a.shift();
				if( c == null ) {
					planetDone();
					return;
				}
				var t = level.cells[c.x][c.y].t;
				var t2 = new flash.utils.ByteArray();
				t2.writeBytes(t);
				t2.compress();
				api.send(ASendChunk(id, c.x, c.y, haxe.io.Bytes.ofData(t2)),next);
			}
			next(null);
		default:
			super.onCommand(cmd);
		}
	}
	
	function planetDone() {
		var p = level.getStartPlace(api.planet);
		if( p == null ) {
			posRetry++;
			haxe.Timer.delay(planetDone, 10);
			if( posRetry > 100 )
				throw "Start pos not found";
			return;
		}
		api.send(APlanetDone(planetId, p.x, p.y, p.z, api.planet.waterTotal, api.planet.waterLevel));
	}
	
	function update() {
		if( load != null ) {
			load.center();
			load.progress = untyped api.gen.progress;
		}
		mt.Timer.update();
		time += 0.002;
		if( engine.begin() ) {
			if( planet != null ) {
				planet.shader.rot = new h3d.Vector(time, -time * 0.2);
				planet.render(engine);
				
				atm.shader.scroll = new h3d.Vector(-time * 0.2, time * 0.01);
				atm.shader.mproj = engine.camera.m;
				//atm.render(engine);
			}
			engine.end();
		}
	}
	
}