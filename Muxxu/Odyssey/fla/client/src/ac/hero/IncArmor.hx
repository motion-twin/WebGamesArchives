package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class IncArmor extends Action {//}
	
	var hero:Hero;
	var power:Int;
	
	var mask:BMD;

	var base:BMD;
	var wave:mt.fx.ShockWave;
	
	var screen:SP;
	var canvas:flash.display.Bitmap;
	
	public function new(hero,power) {
		super();
		this.hero = hero;
		this.power = power;
		
		

		
		
	}
	override function init() {
		super.init();
		
		hero.folk.anim.stop();
		
		
		canvas = Tools.getScreenshot(hero.folk);
		base = canvas.bitmapData.clone();
		mask = canvas.bitmapData.clone();
		Scene.me.dm.add(canvas, Scene.DP_FX);
		
		screen = new SP();
		
		
		/*
		var max = 4;
		for ( i in 0...max ) {
			var ratio = i / (max-1);

			var speed = 0.05 + ratio * 0.1;
			var wave = new mt.fx.ShockWave(0, Math.max(hero.folk.width, hero.folk.height), speed , 1.0);
	
			wave.colors = [Col.mergeCol(0x50a8f5,0x143550,ratio)];
			wave.setHole(0.2);
			wave.draw();
			wave.twist(12, 0.99);
			wave.setPos( hero.folk.width * 0.5, hero.folk.height * 0.5);
			screen.addChild(wave.root);
		}
		*/
		
		
		
		spc = 0.05;

	}
	
	override function update() {
		super.update();

		var co = Math.pow(coef, 0.5);
		canvas.bitmapData.fillRect(canvas.bitmapData.rect, 0);
		base.fillRect(base.rect, 0);
		base.draw( screen );
		canvas.bitmapData.copyPixels( base, base.rect, new PT(0, 0), mask, new PT(0,0), true );
		
		
		var max = Std.int((1 - coef) * 8);
		for( i in 0... max ){
			var p = new mt.fx.Part(new FxHoriSlash());
			p.root.rotation = -90;
			p.setPos(Std.random(canvas.bitmapData.width), Std.random(canvas.bitmapData.height));
			p.timer = 10;
			p.vy = -Math.random() * 10;
			p.setScale(0.25 + Math.random() * 0.5);
			screen.addChild(p.root);
			p.y += 10;
			Filt.glow(p.root, 16, 2, 0x0088FF);
			p.root.blendMode = flash.display.BlendMode.ADD;
		}
		
		hero.folk.filters = [];
		var bl = (1-coef)*8;
		Filt.glow(hero.folk,bl,bl*0.75,0xCCDDFF);
		
		/*
		hero.folk.filters = [];
		var bl = (1 - coef) * 16;
		Filt.glow(hero.folk,bl,bl*0.1,0xCCDDFF,true);
		*/
		
		if (coef == 1) {
			hero.incArmor(power);
			
			kill();
		}
		
		
	}
	
	override function kill() {
		super.kill();
		base.dispose();
		mask.dispose();
		canvas.bitmapData.dispose();
		hero.folk.anim.play();
	}
	

	
	//
	


	
	
//{
}