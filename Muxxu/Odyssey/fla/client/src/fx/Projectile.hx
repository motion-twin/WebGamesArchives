package fx;
import Protocole;
import mt.bumdum9.Lib;



class Projectile extends mt.fx.Fx {//}
	
	
	var proj:MC;
	var type:Int;
	
	public function new( start:Folk, end:Folk, type:Int) {
		super();

		this.type = type;
		
		// LAUNCH
		var speed = 0.1;
		var sin:Null<Int> = null;
		
		switch(type) {
			case 0 :
				proj = new McGrenade();
				new mt.fx.Rotate(proj,30,0.95);
				sin = 60;
				speed = 0.05;
				
				
			case 1 :
				proj = new MC();
				
			case 2 :
				proj = new McGrenade();
				new mt.fx.Rotate(proj, 30, 0.95);
				proj.scaleX = proj.scaleY = 0.6;
				speed = 0.05;
				sin = 60;
				
			default :
				proj = new McBullet();
		}
		
		
		proj.stop();
		//proj.scaleX *= -f.side;	// TODO
		Scene.me.dm.add(proj, Scene.DP_FX);

		/*
		var x = 0.0;
		for( f in targets ) x += f.root.x;
		var b = { x:x / targets.length, y:Scene.HEIGHT - 20 };
		*/
		
		
		
		var a = start.getCenter();
		proj.x = a.x;
		proj.y = a.y;

		var b = end.getCenter();
		
		var fx = new mt.fx.Tween(proj, b.x, b.y, speed);
		fx.onFinish = impact;
		if( sin != null ) fx.setSin(sin);

	}
	
	override function update() {
		super.update();
		
		coef = Math.min(coef+0.15,1);
		
		// UPDATE PROJ
		switch(type) {
			case 1 :
				for( i in 0...1 ){
					var p = getIceCloud();
					p.setPos(proj.x, proj.y+(Math.random()*2-1)*4 );
					p.vx = 3 + Math.random() * 2  - coef * 2;
					//p.frict = 0.98;
					p.setScale(0.5 + Math.random()*coef  );
				}
	}
		
	}
	
	//
	function getIceCloud() {
		var p = new mt.fx.Part(new McIceCloud());
		
		p.fadeIn(3 + Std.random(5));
		p.sfr = 1.01 + Math.random() * 0.02;
		
		p.fadeType = 1;
		p.fadeLimit = 20;
		p.twist(32, 0.9);
		p.setScale(0.5 + coef*0.5 + Math.random() * 0.5);
		p.timer = 25 + Std.random(20) - Std.int(p.scale*15*(1-coef*0.5));
		
		p.root.blendMode = flash.display.BlendMode.ADD;
		Scene.me.dm.add(p.root,Scene.DP_FX);
		return p;
	}
	
	//
	function impact() {
		kill();
	}
	
	
	
	
//{
}