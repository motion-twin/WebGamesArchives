package ac.mon;
import Protocole;
import mt.bumdum9.Lib;

private typedef Ray = { mc:fx.ConeRay, vr:Float, t:Int, scy:Float };

class Kamikaze extends Action {//}
	
	static var HEIGHT = 60;
	
	public var agg:Monster;
	public var trg:Hero;

	var dec:Int;
	var bx:Float;
	var rays:Array<Ray>;
	
	public function new(agg,trg) {
		super();
		this.agg = agg;
		this.trg = trg;
	}
	
	override function init() {
		super.init();
		dec = 0;
		add( new ac.MoveMid(agg.folk) );
		
	}
	

	
	
	override function update() {
		super.update();
		switch(step) {
			case 0 : // GO
				if ( tasks.length == 0 ){
					nextStep(0.02);
					agg.folk.anim.stop();
				}
					
			case 1 : // RISE
			
				var c = 0.5 - Math.cos(coef * 3.14) * 0.5;
				agg.folk.y = (Scene.HEIGHT-Scene.GH) - HEIGHT*c;
				if ( coef == 1 ){
					bx = agg.folk.x;
					nextStep(0.01);
					rays = [];
					agg.folk.play("crack");
				}
			
				
			case 2 :
				
				// FLOAT
				dec = (dec + 12) % 628;
				agg.folk.x = bx;
				agg.folk.y = (Scene.HEIGHT - HEIGHT) + Math.sin(dec * 0.01) * 8;
				
				// SHAKE
				var a = Math.random() * 6.28;
				var ray = Math.random() * 10 * coef;
				agg.folk.x += Math.cos(a) * ray;
				agg.folk.y += Math.sin(a) * ray;
				
				// RAYS
				if ( timer%4 == 0 && rays.length < 20 ) {
					var mc = new fx.ConeRay();
					mc.rotation = Math.random() * 360;
					rays.push( { mc:mc, vr:(Math.random() * 2 - 1) * 0.2, t:0, scy:0.1 + Math.random() * 0.5 } );
					mc.scaleX = 2;
					mc.blendMode = flash.display.BlendMode.ADD;
					Scene.me.dm.add(mc, Scene.DP_BG);
				}
				
				for (o in rays ) {
					o.t++;
					o.mc.rotation += o.vr;
					o.mc.scaleY = Math.min(o.t / 20, 1)*o.scy;
					o.mc.x = agg.folk.x;
					o.mc.y = agg.folk.y - 16;
					if ( timer > 60 )
						//o.scy += 0.25;
						o.scy *= 1.2;
				}
				
				// EXPLODE
				if ( timer > 80 ) {
					nextStep();
					fxExplode();
					trg.hit( { value:agg.life << 1, types:[FIRE], source:cast agg } );
					agg.life = 0;
					kill();
			
				}
				

				


				
				
			default :
			
		}
		
	}
	

	function fxExplode() {
	// CLOUD EXPLOSION
		var max = 32;
		var cr = 8;
		for ( i in 0...max ) {

			var p = new part.Cloud();
			var a = i / max * 6.28;
			var sp = Math.random() * 5;
			p.vx = Math.cos(a) * sp;
			p.vy = Math.sin(a) * sp;
			var x = agg.folk.x + p.vx*cr;
			var y = agg.folk.y + p.vy * cr;
			p.setPos(x, y);

			var sleep = new mt.fx.Sleep(p,Std.random(10+Std.int(sp)));
			sleep.hide(p.root,true);
		}
		
		// MAGMA STONES
		var max = 8;
		for ( i in 0...max ) {
		
			var p = new part.MagmaStone();
			p.x = agg.folk.x;
			p.y = agg.folk.y;
			p.launch( (Math.random()*2-1)*2-1.57, 6+ Math.random() * 4);
			
			
		}
		
		// SPARK
		var max = 32;
		for ( i in 0...max ) {

			var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(50));
			var a = i / max * 6.28;
			var speed = Math.random() * 8;
			p.launch(a, speed, 0.5+Math.random()*4);
			p.setPos(agg.folk.x, agg.folk.y);
			p.frict = 0.99;
			p.timer = 20 + Std.random(80);
			att(p.root);
			
		}
		
		
		// CLEAN
		agg.folk.visible = false;
		for ( o in rays )
			o.mc.parent.removeChild(o.mc);
			
			

			
	}
	
//{
}






