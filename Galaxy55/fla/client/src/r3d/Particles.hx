package r3d;
import h3d.mat.Data;

class MovingPart extends h3d.part.Particle {

	var game : AbstractGame;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var life : Float;
	
	public function new(g, x, y, z, light, vx = 0., vy = 0., vz = 0.) {
		super(x, y, z, light);
		this.game = g;
		this.vx = vx;
		this.vy = vy;
		this.vz = vz;
		this.life = 50;
	}
	
	public function update( level : Level, dt : Float, col ) {
		x += vx * dt;
		y += vy * dt;
		z += vz * dt;
		vz -= 0.009 * dt;
		if( level.collide(x, y, z) && col ) {
			life -= Math.max(1,Math.sqrt(game.render.parts.breaks.parts.length) / 8);
			vz = 0;
			vx*=0.95;
			vy*=0.95;
		}
		return life>0;
	}
	
}

class ParticlesQuad<T:h3d.part.Particle> extends h3d.CustomObject<Shaders.PartShader> {

	public var parts : Array<T>;
	var game : AbstractGame;
	var buffer : h3d.part.Buffer;
	
	public function new(g) {
		parts = [];
		this.game = g;
		buffer = new h3d.part.Buffer();
		super(buffer, new Shaders.PartShader());
	}
	
	override function render(engine:h3d.Engine) {
		var cam = engine.camera.pos;
		shader.mproj = engine.camera.m;
		shader.cam = game.render.camPosition;
		shader.fogPower = game.render.fogPower;
		buffer.synchronize(cast parts);
		super.render(engine);
	}
	
}

class Particles {

	var game : AbstractGame;
	var engine : h3d.Engine;
	
	public var breaks : ParticlesQuad<MovingPart>;
	
	public function new(g) {
		this.game = g;
		this.engine = g.engine;
	}
	
	public function init(tex) {
		breaks = new ParticlesQuad(game);
		breaks.shader.tex = tex;
	}

	public function doBreakParts( sp : h3d.Point, dir : h3d.Vector, b : Block, pos : { x : Int, y : Int, z : Int }, scale = 1.0 ) {
		var light = game.level.getLightAt(sp.x, sp.y, sp.z, game.planet.defaultLight);
		var p = new MovingPart(game, sp.x, sp.y, sp.z, light, -dir.x * (1 + Math.random() * 0.4 - 0.2) * 0.05, -dir.y * (1 + Math.random() * 0.4 - 0.2) * 0.05, -dir.z * (1 + Math.random() * 0.4 - 0.2) * 0.05);

		if( p.x % 1 > 0.01 ) {
			var d;
			do d = Math.random() * 0.3 - 0.25 while( Std.int(p.x) != Std.int(p.x + d) );
			p.x += d;
		}
		if( p.y % 1 > 0.01 ) {
			var d;
			do d = Math.random() * 0.3 - 0.25 while( Std.int(p.y) != Std.int(p.y + d) );
			p.y += d;
		}
		if( p.z % 1 > 0.01 ) {
			var d;
			do d = Math.random() * 0.3 - 0.25 while( Std.int(p.z) != Std.int(p.z + d) );
			p.z += d;
		}
		
		p.vx = Math.random()*0.05 * (Std.random(2)*2-1);
		p.vy = Math.random()*0.05 * (Std.random(2)*2-1);
		if( Std.random(100)<30 )
			p.vz = 0.05 + Math.random()*0.05;
		else
			p.vz = Math.random()*0.05;
		
		var dx = p.x - pos.x;
		var dy = p.y - pos.y;
		var dz = p.z - pos.z;
		var tex = b.tlr;
		if( dx == 0 || dx == 1 ) {
			dx = dy;
			dy = dz;
		} else if( dy == 0 || dy == 1 ) {
			dy = dz;
		} else
			tex = dz == 0 ? b.td : b.tu;
		
		var size = (Math.random() * 0.15 + 0.05) * scale;
		var px = dx;
		var py = dy;
		var a = 0.;
		var tu = (tex & 63) / 64;
		var tv = (tex >> 6) / 64;
		for( i in 0...3 ) {
			a += Math.random() * Math.PI / 2 + Math.PI / 3;
			var x = Math.cos(a) * size;
			var y = Math.sin(a) * size;
			var tx = px + x;
			var ty = 1 - (py + y);
			if( tx < 0 ) tx = 0 else if( tx > 1 ) tx = 1;
			if( ty < 0 ) ty = 0 else if( ty > 1 ) ty = 1;
			p.addVertex(new h3d.part.Particle.ParticleVertex(x * 0.7, y * 0.7, tu + tx / 64, tv + ty / 64));
		}
		breaks.parts.push(p);
	}
	
	public function doBreak( x : Int, y : Int, z : Int, b : Block ) {
		var h = b.getHeight();
		var pos = { x:x, y:y, z:z };
		for( i in 0...75 ) {
			var x : Float = x, y : Float = y, z : Float = z;
			var face = Std.random(6);
			switch( face ) {
			case 0,1:
				y += Math.random();
				z += Math.random() * h;
				x += face;
			case 2,3:
				x += Math.random();
				z += Math.random() * h;
				y += face & 1;
			default:
				x += Math.random();
				y += Math.random();
				z += face & 1;
			}
			if( game.level.getLightAt(x, y, z, 1) <= 0 )
				continue;
			var rdir = new h3d.Vector(Math.random(), Math.random(), Math.random());
			rdir.normalize();
			doBreakParts(new h3d.Point(x, y, z), rdir, b, pos, 2.);
		}
	}
	
	var partStep : Int;
	
	public function update(dt) {
		var partCount = Std.int(breaks.parts.length / 1000) + 1;
		for( p in breaks.parts.copy() )
			if( !p.update(game.level, dt, (partStep++%partCount) == 0 ) )
				breaks.parts.remove(p);
	}
	
	public function render() {
		breaks.render(engine);
	}
	
}