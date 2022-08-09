import haxe.Log;
import mt.bumdum9.Lib;
class CatchBar extends Game {//}
	
	
	var bgH : CatchBg;
	var bar : Bar;
	var hand : Hand;
	var handTop : HandTop;
	
	var timer : Int;
	var gravity : Float;
	
	var closed : Bool;
	
	
	override function init(dif:Float) {
		super.init(dif);
		
		
		bgH = new CatchBg();
		addChild(bgH);
		hand = new Hand();
		addChild(hand);
		hand.x = 200;
		hand.y = 290;
		bar = new Bar();
		addChild(bar);
		bar.x = 200;
		bar.y = 70;
		handTop = new HandTop();
		addChild(handTop);
		handTop.x = 200;
		handTop.y = 290;
		
		closed = false;
	
		
		timer = 50 + Std.random(50);
		
		gravity = 0.92;
		
		
		
	}
	
	
	override function update() {
		super.update();
		
		
		timer --;
		
		if (timer <= 0) {
			bar.y /= gravity;
		}
		
		
		if (click) {
			
			if( bar.y + bar.height / 2 > hand.y && bar.y - bar.height / 2 < hand.y && bar.anim.currentFrame == 1 && !closed){
				gravity = 1;
				if (closed) {
					bar.anim.play();
				}
			}
			
			hand.gotoAndStop("close");
			handTop.gotoAndStop("close");
			
			closed = true;
	
		}
		
	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}