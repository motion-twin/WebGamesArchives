package r3d;
import Common;

class Capture {
	
	static inline var UPSCALE = 2;
	
	var data : haxe.io.Bytes;
	var size : Int;
	var engine : h3d.Engine;
	var angles : Int;
	var render : Render;
	var incli : Float;
	var height : Float;
	var center : { x : Float, y : Float };
	var toTrack : Array<Block>;
	var track : Array<{ x : Int, y : Int, z : Int, b : Block }>;
	public var weight : Float;
	
	public function new(data,size,angles,incli=0.5,height=35) {
		this.data = data;
		this.size = size;
		this.angles = angles;
		this.incli = incli;
		this.height = height;
		engine = new h3d.Engine(size * UPSCALE, size * UPSCALE, false, 0, 1);
		engine.onReady = start;
		engine.show(false);
		engine.init();
		toTrack = [];
		track = [];
	}
	
	public function trackBlock( b : Block ) {
		toTrack.push(b);
	}
	
	function start() {
		var level = new Level(1);
		var planet = new r3d.AbstractGame.PlanetData( {
			id : null,
			seed : 0,
			size : 1,
			biome : BIShed,
			waterTotal : 0,
			waterLevel : 0,
			waterFlood : 0,
		});
		planet.curve = 0.0000001;
		weight = 0;
		
		var cst= {
			shipDockBitmap : null,
			laserBitmaps : []
		};
		
		var abs = new AbstractGame(level, engine, planet, new flash.display.Sprite(),cst);
		abs.getEffects = function(_, _, _) : AbstractGame.GameEffects {
			return {
				time : 0,
				fades : [],
				fogPower : 0,
				fogColors : [0, 0, 0],
				dummies : new List(),
				inWater : false,
				select : null,
				currentBlock : null,
				bobbing : null,
				laser : null,
				shipDock : null,
				skyBoxAlpha : 0,
				entities : [],
			};
		};
		
		var cell = haxe.io.Bytes.alloc(Const.TSIZE * 2);
		var s = data;
		if( s.get(0) == 0x78 ) {
			var data = new flash.utils.ByteArray();
			data.writeBytes(s.getData(),0, s.length);
			data.uncompress();
			s = haxe.io.Bytes.ofData(data);
		}
		level.add(0, 0, cell.getData());
		var sx = s.get(0), sy = s.get(1), sz = s.get(2);
		var gravX = 0, gravY = 0, gravCount = 0;
		var pos = 3;
		var btrack = new IntHash();
		for( b in toTrack )
			btrack.set(b.index, b);
		for( y in 0...sy )
			for( x in 0...sx ) {
				cell.blit(Const.addr(x, y, 0) << 1, s, pos, sz * 2);
				for( z in 0...sz ) {
					var b = s.get(pos) | (s.get(pos + 1) << 8);
					if( b != 0 ) {
						gravX += x;
						gravY += y;
						gravCount++;
						weight++;
						var b = btrack.get(b);
						if( b != null )
							track.push( { x:x, y:y, z:z, b:b } );
					}
					pos += 2;
				}
			}
		
		center = { x : 0.5 + (gravX / gravCount), y : 0.5 + (gravY / gravCount) };
		untyped engine.hardware = true; // still perform render the same as hardware mode
		render = new Render(abs);
		render.init();
		haxe.Timer.delay(capture, 1);
	}
	
	function capture() {
		var t0 = flash.Lib.getTimer();
		var height = 35;
		var incli = 0.5;
		var bmp = new flash.display.BitmapData(size * angles, size, true, 0);
		var tmp = new flash.display.BitmapData(engine.width, engine.height, true, 0);
		var put = Block.get(BBedrock);
		var trackFrames = [];
		var stage = flash.Lib.current.stage;
		var old = stage.quality;
		stage.quality = flash.display.StageQuality.HIGH;
		for( i in 0...angles ) {
			var angle = Math.PI * 2 * i / angles;
			var delta = Math.sin(incli) * height;
			var trackPos = [];
			trackFrames.push(trackPos);
			render.setPos( center.x - Math.cos(angle) * delta, center.y - Math.sin(angle) * delta, height, angle, -(Math.PI / 2 - incli));
			render.takeScreenShot(tmp);

			for( p in track ) {
				var v = new h3d.Vector(p.x + 0.5 - 1, p.y + 0.5, p.z + 0.5, 1);
				v.project(engine.camera.m);
				var x = (v.x + 1) * size * 0.5;
				var y = ( -v.y + 1) * size * 0.5;
				var pick = render.pick(x, y, put, 100);
				trackPos.push( { x : x, y : y, b : p.b, visible : pick == null || pick.z <= p.z });
			}
			
			if( UPSCALE == 1 )
				bmp.copyPixels(tmp, tmp.rect, new flash.geom.Point(i * size, 0), tmp);
			else
				bmp.draw(tmp, new flash.geom.Matrix(1/UPSCALE,0,0,1/UPSCALE, i * size, 0),null,null,null,true);
		}
		tmp.dispose();
		render.dispose();
		engine.dispose();
		onReady(bmp, trackFrames);
	}
	
	public dynamic function onReady( bmp : flash.display.BitmapData, track : Array<Array<{ x : Float, y : Float, b : Block, visible : Bool }>> ) {
		throw "assert";
	}

}
