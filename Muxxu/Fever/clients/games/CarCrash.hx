import haxe.Log;
import mt.bumdum9.Lib;

class CarCrash extends Game {//}
	
	
	var carBg : CarBg;
	var fighter : CarFighter;
	var car : Car;
	

	var life :Int;
	var maxLife :Int;
	var degats : Int;
	
	var timer:Int;
	//var coef:Float;
	
	override function init(dif:Float) {
		gameTime = 300;
		super.init(dif);
		
		
		
		carBg = new CarBg();
		dm.add(carBg,0);
		
		car = new Car();
		dm.add(car,0);
		
		fighter = new CarFighter();
		dm.add(fighter,0);
				
		
		maxLife = Std.int(50 + dif*120);
		life = maxLife;
		
		degats = 9;
		car.c2.gotoAndStop(Std.int(life * car.c2.totalFrames / maxLife));
		
	
	}

	
	
	
	override function update() {
		super.update();
		
		if( fighter.sub == null ) return;
		
		switch(step) {
			case 1 :
				if (click && win == null ) {
					fighter.gotoAndStop("punch");
					timer = 0;
					step++;
				}
				
			case 2 :
				if( click ) 	fighter.sub.nextFrame();
				else			fighter.sub.prevFrame();
			
				
				if( fighter.sub.currentFrame == 1  ) back();
				if( fighter.sub.currentFrame == 11 ) {
					car.play();
					life -= degats;
					step = 5;
					timer = 0;
					car.c2.gotoAndStop(Std.int(life * car.c2.totalFrames / maxLife));
					fighter.sub.play();
					if( car.c2.currentFrame == 1 && win==null) {
						setWin(true, 24);
						new mt.fx.Shake(this, 0, 8, 0.75);
						fxExplode();
					}else {
						fxImpact();
					}
					
					
					
				}
				
				
			case 5 :
				
				if( timer++ >= 8 && !click ) back();
				
		}

		
		
		

		
		
		
	}
		
	
	function back() {
		step = 1;
		fighter.gotoAndStop("stand");
	}
	
	function fxImpact() {
		
		for( i in 0...9 ) {
			var p = getPart();
			p.vx = 1+Math.random() * 4;
			p.vy = -Math.random() * 5;

		}
		
	}
	function fxExplode() {
		
		for( i in 0...64 ) {
			var p = getPart();
			var speed = Math.random() * 8;
			p.vx *= speed;
			p.vy *= speed;

		}
		
	}
	
	function getPart() {
		
		var zones  = [
			new flash.geom.Rectangle(183,217,95,39),
		];
		var r = zones[0];
		
		var p = newPhys("PartCarCrash");
		p.x = r.x + Math.random() * r.width;
		p.y = r.y + Math.random() * r.height;
		p.root.gotoAndStop(Std.random(4) + 1);
		p.weight = 0.25 + Math.random() * 0.25;
		p.vr = (Math.random() * 2 - 1) * 8;
		p.fr = 0.97;
		p.setScale(1 + Math.random());
		p.gy = 270 + Math.random() * 20;
		p.timer = 10 + Std.random(50);
		p.groundCol = function() { p.vx *= 0.75;  };
		
		var dx = r.x + r.width * 0.5 - p.x;
		var dy = r.y + r.height * 0.5 - p.y;
		var a  = 3.14+Math.atan2(dy, dx);
		
		p.vx = Math.cos(a);
		p.vy = Math.sin(a);
		
		return p;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}