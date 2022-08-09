package fx;
import mt.bumdum9.Lib;

class PotionYellow extends Fx{//}


	var coef:Float;
	var light:gfx.Light;
	
	public function new() {
		super();
		sn.angle = Math.atan2(Stage.me.height * 0.5 - sn.y, Stage.me.width * 0.5 - sn.x);
		sn.trq = [];
		
		coef = 0;
		var max = 200;
		for( i in 0...max ) pop(i*6.28/max,Math.random()*6);
		
		light = new gfx.Light();
		Stage.me.dm.add(light, Stage.DP_FX);
		light.x = sn.x;
		light.y = sn.y;
		//light.scaleX = light.scaleY = 0.5;
		light.blendMode = flash.display.BlendMode.ADD;
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + 0.01, 1);
		for( i in 0...2 ) if( Math.random() > coef ) pop(Math.random() * 6.28, Math.random() * 2);
		light.scaleX = light.scaleY = Math.pow(1 - coef, 4)*2;
		light.alpha = 1-coef;
		if( coef == 1 ) kill();
		
	}
	
	
	function pop(a,speed:Float) {
		var p = Stage.me.getPart("spark_dust");
		p.sprite.anim.loop = true;
		p.sprite.anim.gotoRandom();
		p.x = sn.x + Std.random(7)-3;
		p.y = sn.y + Std.random(7) - 3;
		p.vx = Snk.cos(a) * speed;
		p.vy = Snk.sin(a) * speed;
		p.timer = 10 + Std.random(80);
		p.frict = 0.95;
		p.sprite.filters = [ new flash.filters.GlowFilter(0xFFFF00, 0.5, 4, 4, 2) ];
		p.sprite.blendMode = flash.display.BlendMode.ADD;
	}

//{
}