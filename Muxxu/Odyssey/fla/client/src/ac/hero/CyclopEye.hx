package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;




class CyclopEye extends Action {//}
	
	

	var agg:Ent;
	var vic:Ent;
	var list:Array<part.Focus>;
	
	public function new(agg:Ent,vic:Ent) {
		super();
		this.agg = agg;
		this.vic = vic;
		
	}
	override function init() {
		super.init();
		agg.folk.play("atk", launch,true);

	}
	
	override function update() {
		super.update();
		
		
		switch(step) {
			case 0 :
			case 1 :
				if ( timer > 46 ) {
					
					nextStep();
					
					var mc = new McFlashGroup();
					mc.x  = vic.folk.x;
					mc.y  = vic.folk.y;
					mc.blendMode = flash.display.BlendMode.ADD;
					Scene.me.dm.add(mc, Scene.DP_FX);
					
				}
				
			case 2 :
				if( timer > 20 ){
					kill();
					vic.applyDamage( { value:120, types:[], source:agg } );
					
					for ( p in list ) {
						
						var dx = p.x - vic.folk.x;
						var dy = p.y - vic.folk.y;
						var a = Math.atan2(dy, dx);
						
						var sp = Math.max(0,1-(Math.sqrt(dx * dx + dy * dy)/200) )*20;
						
						p.vx = Math.cos(a)*sp;
						p.vy = Math.sin(a) * sp;
						p.asp = 0;
						p.frict = 0.92;
						
					}
					
					
					var e = new mt.fx.ShockWave(100, 800, 0.15);
				
					e.setPos(vic.folk.x, vic.folk.y);
					Scene.me.dm.add(e.root, Scene.DP_FX);
					
					Scene.me.fxGroundImpact(vic.folk.x, 60);
					
				}
			
		}
		
	
	}
	
	function launch() {
		nextStep(0.01);

		
		var max = 128;
		list = [];
		for ( i in 0...max ) {
			var p = new part.Focus(new FxFluo());
			p.setFolkTarget(vic.folk, 10 + Std.random(240), 0.015+Math.random()*0.005);
			p.setScale(0.25 + Math.random() * 0.5);
			p.timer = 50 + Std.random(80);
			p.fadeType = 2;
			p.fadeType = 20;
			
			p.an = Math.random()*6.28;
			list.push(p);
		
		}
		
		
		
		
	}


	
	
//{
}