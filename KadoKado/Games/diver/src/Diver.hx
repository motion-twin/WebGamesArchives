import Game;
import mt.bumdum9.Lib;

enum DiverState {
	DS_HIT;
	DS_SWIM;
	
}

class Diver
{//}

	public var mc			: McDiver;
	public var dx			: Float;
	public var dy			: Float;
	public var coteX		: Int;
	public var coteY		: Int;
	var lastDx				: Float;
	var lastDy				: Float;
	
	var frame:Int;
	var timer:Int;
	public var state:DiverState;
	
	public function new() {
		
		mc = new McDiver();
		mc.stop();
		mc.smc.stop();
		Game.me.dm.add(mc, 10);
		dx = 0;
		dy = 0;
		coteX = 10;
		coteY = 20;
		lastDx = 0;
		lastDy = 0;
		
		frame = 0;
		state = DS_SWIM;
		
		//
		mc.x = (Game.mcw / 2);
		mc.y = 0;
	}

	public function update() {
		switch(state ) {
			
			case DS_SWIM :
				control();
				
				var trot = -dx * 10;
				var drot = Num.hMod( trot-mc.rotation, 180);
				mc.rotation += drot * 0.25;
				
				
			case DS_HIT:
			
				mc.rotation += timer * 0.5;				
				timer--;
				if( timer == 0 ) {
					mc.gotoAndStop(1);
					state = DS_SWIM;
					frame = 0;					
				}
		}
		
		move();

	}
	
	public function control() {
		if (mt.flash.Key.isDown(40)) swim();
		
		if (mt.flash.Key.isDown(39))
			dx += Game.SPEED;
		if (mt.flash.Key.isDown(37))
			dx -= Game.SPEED*0.5;
		if (mt.flash.Key.isDown(38))
			dy -= Game.SPEED;
	}
	
	public function move() {
		dx *= Game.FROTTEMENT;
		dy *= Game.FROTTEMENT;
		mc.x += dx;
		mc.y += dy;
		
		lastDx = dx;
		lastDy = dy;
		

			
		if (mc.x >= Game.mcw - coteX / 2) {
			if (lastDx != 0)
				dx = 0;
			mc.x =  Game.mcw - (coteX/2);
		}
		if (mc.x <= coteX / 2) {
				if (lastDx != 0)
					dx = 0;
			mc.x = (coteX/2);
		}
		if (mc.y <= coteY / 2) {
			if (lastDy <= -0.2)
				dy = 0;
			mc.y = (coteY/ 2);
		}
		
		if (mc.y > Game.mch)
			Game.me.step = NEWLEVEL;
	}
	
	function swim() {
		frame = (frame + 1) % mc.smc.totalFrames;
		
		var coef = 0.75;
		switch(frame) {
			case 14,15, 16, 17 : coef = 2;
			case 18, 19, 20 : coef = 3;
			case 21,22,23,24,25 : coef = 1;
		}
		
		mc.smc.gotoAndStop(frame);
		
		
		dy += Game.me.speed * coef;
		
		
		
	}
	
	public function hit(b:Bubble) {
		mc.gotoAndStop(3);
		state = DS_HIT;
		
		var n = 0;
		switch(b.size) {
			case LITTLE : 	n = 15;
			case MEDIUM : 	n = 20;
			case BIG : 		n = 30;
		}
		
		timer += Std.int(n);
		if( timer > 40 ) timer = 40;
		
		
	}

//{
}