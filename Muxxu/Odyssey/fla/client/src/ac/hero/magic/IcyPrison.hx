package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class IcyPrison extends ac.hero.MagicAttack {//}
	

	var canvas:SP;
	
	
	public function new(agg,trg) {
		super(agg, trg);
		Scene.me.fadeTo(0x008899,0.05);
	}
	
	override function start() {
		super.start();

		canvas = new SP();
		Scene.me.dm.add(canvas, Scene.DP_FX);
		canvas.filters = [new flash.filters.GlowFilter(0xFFFFFF, 2, 3, 3, 12, 1, false, true)];
		
		spc = 0.01;
		
		trg.folk.play("hit");
		trg.folk.anim.stop();
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		switch(step) {
			case 1 :
				var max = 10 - (timer>>1);
				if ( max < 1 ) max = 1;
			
				for( i in 0...max ){
					var pos = trg.folk.getRandomBodyPos();
					var sh = new fx.CrystalShape();
					canvas.addChild(sh);
					sh.x = pos.x;
					sh.y = pos.y;
					sh.rotation = Std.random(360);
					sh.scaleX = sh.scaleY = Math.random() * 0.5 + 0.5;
					new mt.fx.Spawn(sh, 0.05+Math.random()*0.2, false, true);
				}
				
				//Scene.me.dm.add(sh, 8);
				if ( timer > 55 ) {
					trg.folk.play("hit",null,true);
					trg.freeze(4);
					canvas.parent.removeChild(canvas);
					nextStep();
					Scene.me.fadeBack();
					
					// FX ONDE
					var onde = new mt.fx.ShockWave(100, 160, 0.2);
					onde.setHole(0.5);
					Scene.me.dm.add(onde.root, Scene.DP_FX);
					var pos = trg.folk.getCenter();
					onde.setPos(pos.x, pos.y);
					
					// FX - ICE SHARDS
					var max = 32;
					var cr = 4;
					for ( i in 0...max ) {
						//var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(30));
						var p = Scene.me.getPart( new McCrystal());
						var a = i / max * 6.28;
						var speed = 0.5 + Math.random() * 2;
						//p.launch(a, speed, 0.5+Math.random()*4);
						var pos = trg.folk.getRandomBodyPos();
						p.vx = Math.cos(a) * speed;
						p.vy = Math.sin(a) * speed;
						p.setPos(pos.x+p.vx*cr, pos.y+p.y*cr);
						p.weight = 0.05+Math.random() * 0.2;
						p.twist(12, 0.98);
						p.frict = 0.99;
						p.timer = 10 + Std.random(60);
						p.setGround(Scene.HEIGHT - Scene.GH,0.9,0.6);
						Scene.me.dm.add(p.root, Scene.DP_FX);
						p.setScale(0.2 + Math.random() * 0.2);
						p.fadeType = 2;
						
					}
					
				}
				
			case 2 :
			
				if ( timer == 20 )
					kill();
			
		}
			

		
	}
	
	
	
//{
}


























