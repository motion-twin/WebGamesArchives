package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;


private typedef LPos = { x:Float, y:Float, vx:Float, vy:Float };

class Lightning extends ac.hero.MagicAttack {//}
	

	var arc:Array<LPos>;
	var canvas:SP;
	
	public function new(agg,trg) {
		super(agg, trg);
		Scene.me.fadeTo(0x882266,0.05);
	}
	
	override function start() {
		super.start();
		
		canvas = new SP();
		Scene.me.dm.add(canvas, Scene.DP_UNDER_FX);
		canvas.blendMode = flash.display.BlendMode.ADD;
		arc = [];
		
		var a = agg.folk.getCenter();
		var b = trg.folk.getCenter();
		var dx = b.x - a.x;
		var dy = b.y - a.y;
		
		var sub  = 20;
		var max = Std.int( Math.sqrt(dx*dx+dy*dy)/sub );
		var pow = 2;
		for ( i in 0...max ) {
			var c = i / (max-1);
			arc.push({x:a.x+dx*c,y:a.y+dy*c,vx:(Math.random()*2-1)*pow,vy:(Math.random()*2-1)*pow});
		}
		
		spc = 0.1;
		
		//
		var damage = 10;
		if ( agg.have(FORBIDDEN_ALCHEMY) ) damage++;
		if ( agg.have(ELEMENTS_CONTROL) ) damage += damage>>1;
		trg.hit( { value:damage, types:[MAGIC], source:cast agg } );
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		var cc = 1 - coef;

		var g = canvas.graphics;
		g.clear();
		g.lineStyle(cc*4, 0xFFFFFF);
		var id = 0;
		var shake = 10;
		
		canvas.filters = [];
		trg.folk.filters = [];
		Filt.glow(canvas, 30 * cc, 2 * cc, 0xFFFF00);
		Filt.glow(trg.folk, 4, 12 * cc, 0xFFFFFF);
		Filt.glow(trg.folk, 30 * cc, 2 * cc, 0xFFFF00);
		
		
		for ( p in  arc ) {
			if ( id++ == 0 ) {
				g.moveTo(p.x, p.y);
				continue;
			}
			
			var x = p.x + Std.random(shake) - (shake >> 1);
			var y = p.y + Std.random(shake) - (shake >> 1);
			
			g.lineTo(x, y);

			var c = 1.0;
			if ( id == 1 || id== arc.length ) {
				c *= 0;
			}
			p.x += p.vx*c;
			p.y += p.vy*c;
			
			p.vx *= 0.92;
			p.vy *= 0.92;
			

			
		}
		
		if ( coef == 1 ) {

			for( pos  in arc ) {
				var p = Scene.me.getPart(new fx.Drop());
				p.root.blendMode = flash.display.BlendMode.ADD;
				Filt.glow(p.root, 6, 1, 0xFFFF00);
				p.setPos(pos.x, pos.y);
				p.timer = 5 + Std.random(5);
				p.fadeLimit = 5;
				p.fadeType = 2;
				p.weight = -Math.random() * 0.2;
				p.vx = Math.random();
			}
			
			kill();
			Scene.me.fadeBack();
			canvas.parent.removeChild(canvas);
		}
	
		
		
	}
	
	//
	public function impact() {
		
	}


	
//{
}


























