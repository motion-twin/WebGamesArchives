import haxe.Log;
import mt.bumdum9.Lib;
class RobinHood extends Game {//}
	
	
	
	var bgH : McHoodBg;
	var arc : McArc;
	var cible : McCible;
	var cVit : Float;
	var mch : Float;
	var mcw : Float;
	var arcState : Int;
	
	
		
	override function init(dif:Float) {
		gameTime = 200;
		super.init(dif);
		
		
		mch = 400;
		mcw = 400;
		
		bgH = new McHoodBg();
		addChild(bgH);
		cible = new McCible();
		addChild(cible);
		cible.scaleX = 1 - (dif/1.8);
		cible.scaleY = cible.scaleX;
		cible.x = 380;
		cible.y = 200 + Math.random() * 100;
		cVit = Std.random(2) * 2 - 1;
		//cible.scaleX = 50;
		
		cVit = 50*(dif/1.5);
		arc = new McArc();
		addChild(arc);
		arc.x = 55;
		arc.y = 200;
		
		
		arcState = 1;
		
		
	}
	
	override function update() {
		
		cible.y += cVit;
		
		if (cible.y + cible.height / 2 >= 400) {
			cVit *= -1;
		}
		
		if (cible.y - cible.height/2 <=  0) {
			cVit *= -1;
		}
		//cible.alpha = click?1:0.5;
		//trace(arcState);
		if (click && arcState == 1 && arc.currentFrame <= 5) {
			
			
			arc.gotoAndPlay(2);
			arcState = 2;
			
		}
		
		if (!click && arcState == 2) {
			arc.gotoAndPlay("boing");
			arcState = 1;
		}
		
		if (arc.currentFrame == 11 && cible.y + cible.height / 2 > arc.y && cible.y - cible.height / 2 < arc.y ) {
			arc.gotoAndPlay("tchak");
			cVit = 0;
			setWin(true,10);
		}
		
		if (arc.currentFrame == 1) {
			 arc.y = mouseY;
		}
		
		
		super.update();
		
		
	}
	
	
	
}