import haxe.Log;
import mt.bumdum9.Lib;
class Test extends Game{//}


	var bga : McBga;
	var rope : McCorde;
	var frutiz : McFrutiz;
	var timeOut : Int;
	var lose : Bool;
	var go : Bool;
	var ropeFrame : Int;
	var jump : Bool;
	var winner : Bool;
	override function init(dif:Float) {
		
		timeOut = 40;
		lose = true;
		go = false;
		jump = false;
		
		gameTime = 400-dif*200;
		super.init(dif);
		bga = new McBga();
		addChild(bga);
		rope = new McCorde();
		addChild(rope);
		frutiz = new McFrutiz();
		addChild(frutiz);
		frutiz.y = -25;
		frutiz.x = -20;
		haxe.Log.setColor(0xFFFFFF);
		rope.stop();
		ropeFrame = 1;
		winner = true;
	}

	
	override function update(){
		super.update();
	
		if (click && frutiz.currentFrame == 1) {
			frutiz.play();
			lose = false;
			go = true;
		}
	
	if (go && winner) {
		ropeFrame += 3;
		if (ropeFrame >= 100) {
			ropeFrame = 1;			
		}
		rope.gotoAndStop(ropeFrame);
		
	} 
		
		timeOut --;
		trace(frutiz.x);
		if (timeOut <= 0 && lose) setWin(false);
		
		if (rope.currentFrame >= 90) {
			jump = true;
		}
		
		
	if ((rope.currentFrame >= 90 || rope.currentFrame <= 10) && frutiz.currentFrame <= 2 && go && jump) {
		
		frutiz.gotoAndPlay("fall");
		winner = false;
	}

	}





//{
}

