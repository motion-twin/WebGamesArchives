package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;




class Vortex extends ac.hero.MagicAttack {//}
	

	var twister:fx.morph.Twister;
	var stones:Array<mt.fx.Part<McDirt>>;
	var clouds:Array<mt.fx.Part<SP>>;
	var power:Int;
	var shake:Int;
	public function new(agg,trg,power) {
		super(agg, trg);
		this.power = power;
		if ( agg.have(FORBIDDEN_ALCHEMY) ) power++;
	}
	
	override function start() {
		super.start();

		spc = 0.01;
		stones = [];
		clouds = [];
		shake = 1;
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		switch(step) {
			case 1 :
				// STONES
				var ray = 60;
				var p = Scene.me.getStone();
				p.setPos( trg.folk.x + (Math.random() * 2 - 1) * ray, Scene.HEIGHT - Scene.GH );
				p.weight = - (0.05 + Math.random() * 0.3);
				p.timer = 80;
				p.twist(24, 0.9);
				stones.push(p);
				
				// LIGHT
				ray >>= 2;
				if ( Std.random(4) == 0 ) {
					var p = Scene.me.getPart(new McIceCloud());
					Scene.me.dm.add(p.root, Scene.DP_UNDER_FX);
					p.setPos( trg.folk.x + (Math.random() * 2 - 1) * ray, Scene.HEIGHT + 80 );
					//p.setScale(4 + Math.random());
					p.setScale(1 + Math.random()*2);
					p.weight = - (0.05 + Math.random() * 0.2);
					p.timer = 100;
					Filt.glow(p.root, 20, 1,0xFFFFFF);
					p.root.blendMode = flash.display.BlendMode.ADD;
					Col.setColor(p.root, Col.getRainbow2());
					clouds.push(p);
				}

				
				//
				trg.folk.filters = [];
				var cc  = coef;
				Filt.glow(trg.folk, 10 * cc, 2 * cc, 0xFFFFFF, true);
				
				
				var lim = 0.5;
				if ( coef > lim ) {
					var cc = (coef - lim) / (1 - lim);
					Scene.me.y = Math.pow(cc,4) * 4 * shake;
					shake *= -1;
				}
				
				if ( coef == 1 ) {
					Scene.me.y = 0;
					impact();
					nextStep();
					
				}
				
			case 2 :
				if ( timer == 30 ) {
					kill();
				}
				
		}
		

		
		
	}
	
	//
	public function impact() {

	
		trg.hit( { value:power, types:[MAGIC], source:cast agg } );
			
			
		//
		var ce = trg.folk.getCenter();
		
		
		
		// STONES
		trg.folk.filters = [];
		for ( p in stones ) {
			var dx = ce.x - p.x;
			var dy = ce.y - p.y;
			var a = Math.atan2(-dy, -dx);
			
			var speed = 1 + Math.sqrt(dx * dx + dy * dy) / 8;
			
			p.weight = p.scale * (0.2 + Math.random() * 0.1);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.setGround(Scene.HEIGHT - Scene.GH, 0.75, 0.5, 30+Std.random(100));
			p.timer = -1;
			

		}
		
		// ONDE
		var p = new mt.fx.ShockWave(100, 200, 0.1);
		p.setHole(0.5);
		Scene.me.dm.add(p.root, Scene.DP_FX);
		p.setPos(ce.x, ce.y);
		
		// MORPH
		new fx.morph.Impact(ce.x, ce.y);
		
		
		// CLOUDS
		for ( p in clouds ) {
			p.fadeType = 2;
			p.timer = 5;
			p.fadeLimit = 5;
		}
		
	}


	
//{
}


























