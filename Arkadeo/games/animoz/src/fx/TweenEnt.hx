package fx;
import mt.bumdum9.Lib;
import mt.kiroukou.math.MLib;

enum TweenFx {
	OUTLINE_COLOR(color:Int);
	SHAPE_COLOR(?color:Int);
	UP_DOWN(b:ent.Ball);
	TWINKLE;
	FLOWERS;
	GRASS;
	HEART;
	RAINBOW;
	SHAKE(value:Int);
	FLYING_PARTS;
}

using mt.Std;
class TweenEnt extends mt.fx.Fx {

	var down:Bool;
	var ent:Ent;
	var jump:Float;
	public var tw: Tween;
	var spc:Float;
	var fxs:Array<TweenFx>;
	var op: { x:Float, y:Float };
	var timer : Int;
	
	public function new(ent:Ent, tx:Float, ty:Float, jump = 0.0, speed = 20) {
		super();
		down = false;
		this.ent = ent;
		this.jump = jump;
		tw = new Tween(ent.x,ent.y,tx,ty);
		var dist = tw.getDist() + jump * Math.PI * 0.5;
		spc = speed / dist;
		fxs = [];
		op = { x:ent.root.x, y:ent.root.y };
		timer = 0;
	}
	
	public function addFx(f:TweenFx) {
		fxs.push(f);
		switch(f) 
		{
			case UP_DOWN(b) :
				b.goto("up");
			default :
		}
	}
	
	override function update() {
		super.update();
		Game.me.forceZSort = true;
		op.x = ent.root.x;
		op.y = ent.root.y;
		coef = Math.min(coef + spc, 1);
		
		var c = curve(coef);
		var pos = tw.getPos(c);
		
		ent.x = pos.x;
		ent.y = pos.y;
		ent.z =	-Math.sin(coef*3.14)*jump;
		ent.updatePos();
		
		++timer;
		
		var fPerfCoef = api.AKApi.getPerf();
		var fxDisabled = api.AKApi.isLowQuality();
		for( f in fxs.copy() ) {
			switch(f) {
				case SHAKE(value):
					if( timer % 2 == 0 ) ent.z += value;
					else ent.z -= value;
					ent.updatePos();
					
				case OUTLINE_COLOR(color) :
					if( !fxDisabled )
					{
						if( Game.me.gtimer % Std.int(1 / fPerfCoef) == 0 ) 
						{
							var ray = 50;
							var bmp = Game.me.stamp;
							bmp.fillRect(bmp.rect, 0);
							var m = new MX();
							m.translate(ray, ray);
							bmp.draw(ent.root, m);
							
							var fl = new flash.filters.GlowFilter(color, 1, 2, 2, 10, 1, false, true);
							bmp.applyFilter(bmp, bmp.rect, Cs.PT,fl);
							
							m = ent.root.transform.matrix;
							m.translate(-ray, -ray);
							Game.me.plasma.draw(bmp, m );
						}
					}
				case SHAPE_COLOR(color) :
					if( !fxDisabled )
					{
						if( Game.me.gtimer % 2 == 0 ) 
						{
							if( color == null ) color = Col.hsl2Rgb(coef);
							
							var o = Col.colToObj(color);
							var ct = new CT(0, 0, 0, 1, o.r, o.g, o.b, 0);
							Game.me.plasma.draw(ent.root, ent.root.transform.matrix, ct );
						}
					}
				case TWINKLE :
					if( !fxDisabled )
					{
						if ( Game.me.gtimer % Std.int(1 / fPerfCoef) == 0 ) 
						{
							var ec = 20;
							var p = new mt.fx.Part(new gfx.Spark());
							p.root.gotoAndPlay(Std.random(p.root.totalFrames));
							p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
							p.timer = 15 + Std.random(15);
							p.fadeType = 1;
							p.setScale(1 + Math.random());
							p.root.blendMode = flash.display.BlendMode.ADD;
							Filt.glow(p.root, 8, 1.5, 0xFFFFFF);
							
							Game.me.dm.add(p.root, Game.DP_FX);
							
							var dx = ent.root.x - op.x;
							var dy = ent.root.y - op.y;
							var sp = 0.1 + Math.random() * 0.2;
							
							p.vx = dx * sp;
							p.vy = dy * sp;
							p.frict = 0.9;
						}
					}
				case FLOWERS:
					if( !fxDisabled )
					{
						if( !down) 
						{
							if ( Game.me.gtimer % Std.int(1 / fPerfCoef) == 0 )
							{
								var ec = 20;
								var p = new mt.fx.Part(new gfx.FlowerParticle());
								p.root.gotoAndPlay(Std.random(p.root.totalFrames));
								p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
								p.timer = 15 + Std.random(15);
								p.fadeType = 1;
								p.setScale(.2 + .2*Math.random());
								p.root.blendMode = flash.display.BlendMode.ADD;
								Game.me.dm.add(p.root, Game.DP_ENTS);
								
								var dx = ent.root.x - op.x;
								var dy = ent.root.y - op.y;
								var sp = 0.1 + Math.random() * 0.2;
								
								p.vx = dx * sp;
								p.vy = dy * sp;
								p.frict = 0.9;
							}
						}
					}
				case HEART:
					if( !fxDisabled )
					{
						if ( Game.me.gtimer % Std.int(1 / fPerfCoef) == 0 ) 
						{
							var ec = 20;
							var p = new mt.fx.Part(new gfx.HeartParticle());
							p.root.gotoAndPlay(Std.random(p.root.totalFrames));
							p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
							p.timer = 15 + Std.random(15);
							p.fadeType = 1;
							p.setScale(.2 + .2*Math.random());
							Game.me.dm.add(p.root, Game.DP_ENTS);
							
							var dx = ent.root.x - op.x;
							var dy = ent.root.y - op.y;
							var sp = 0.1 + Math.random() * 0.2;
							
							p.vx = dx * sp;
							p.vy = dy * sp;
							p.frict = 0.9;
						}
					}
				case RAINBOW:
					if( !fxDisabled )
					{
						if ( Game.me.gtimer % Std.int(1 / fPerfCoef) == 0 )
						{
							var ec = 20;
							var p = new mt.fx.Part(new gfx.RainbowParticle());
							p.root.gotoAndPlay(Std.random(p.root.totalFrames));
							p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
							p.timer = 15 + Std.random(15);
							p.fadeType = 1;
							p.setScale(.2 + .2*Math.random());
							//p.root.blendMode = flash.display.BlendMode.ADD;
							Game.me.dm.add(p.root, Game.DP_ENTS);
							
							var dx = ent.root.x - op.x;
							var dy = ent.root.y - op.y;
							var sp = 0.1 + Math.random() * 0.2;
							
							p.vx = dx * sp;
							p.vy = dy * sp;
							p.frict = 0.9;
						}
					}
				case UP_DOWN(b) :
					if ( coef > 0.5 && !down ) 
					{
						b.goto("down");
						down = true;
					}
					if ( coef == 1 ) 
					{
						b.goto("stand");
					}
					
				case GRASS :
					if( coef == 1 ) 
					{
						if( !fxDisabled )
						{
							for ( i in 0...Std.int(8 * fPerfCoef) )
							{
								var ec = 20;
								var p = new mt.fx.Part(new gfx.GrassParticle());
								p.root.gotoAndPlay(Std.random(p.root.totalFrames));
								p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
								p.timer = 25 + Std.random(15);
								p.fadeType = 1;
								p.setScale(.4 + .3 * Math.random());
								p.vr = MLib.frandRangeSym(5);
								p.rfr = 0.95;
								p.vx = MLib.frandRangeSym(5);
								p.vy = MLib.frandRange( -.1, -1.5);
								p.frict = 0.95;
								Game.me.dm.add(p.root, Game.DP_FX);
							}
						}
					}
					
				case FLYING_PARTS:
					if( !fxDisabled )
					{
						if( Std.random( Std.int(4 / fPerfCoef) ) == 0 )
						{
							var particles = [gfx.FlowerParticle, gfx.HeartParticle, gfx.RainbowParticle, gfx.GrassParticle];
							particles.shuffle();
							var partClass = particles.first();
							//
							var ec = 10;
							var p = new mt.fx.Part( cast(Type.createEmptyInstance(partClass), flash.display.MovieClip) );
							p.setPos( ent.root.x + (Math.random() * 2 - 1) * ec, ent.root.y + (Math.random() * 2 - 1) * ec );
							p.timer = 30 + Std.random(15);
							p.weight = (0.05 + Math.random() * 0.1);
							p.fadeType = 1;
							p.setScale(.3 + .3 * Math.random());
							
							p.vr = MLib.frandRangeSym(5);
							p.rfr = 0.95;
							p.vx = MLib.frandRangeSym(5);
							p.vy = MLib.frandRange( -.1, -1.5);
							p.frict = 0.95;
							Game.me.dm.add(p.root, Game.DP_FX);
						}
					}
			}
		}
		
		if( coef == 1 ) kill();
	}
}
