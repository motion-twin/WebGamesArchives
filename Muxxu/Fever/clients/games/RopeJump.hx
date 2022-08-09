import haxe.Log;
import mt.bumdum9.Lib;
class RopeJump extends Game{//}


	var bga : McBga;
	var rope : McCorde;
	var frutiz : McFrutiz;
	var ropeFrame : Float;
	var frutizFrame : Float;
	var vit : Float;
	var go : Bool;
	var jump:Bool;

	
	override function init(dif:Float) {
		//dif = 0.9 ;   // difficulté de 0.1 à 1
		//dif = 0;
		gameTime = 220;
		super.init(dif);
		bga = new McBga();
		addChild(bga);
		rope = new McCorde();
		addChild(rope);
		frutiz = new McFrutiz();
		addChild(frutiz);

		haxe.Log.setColor(0xFFFFFF);
		rope.stop();
		ropeFrame = 11;
		frutizFrame = 0;
	
		vit = dif*2 + 3;
	}

	
	override function update(){
		super.update();
		
	
		if( win == false ) return;
	
		if (click && frutiz.currentFrame == 1) {
			jump = true;
		}
	
		if( jump ) frutizFrame += vit * 0.2;
		if( frutizFrame >= 15 ) {
			frutizFrame = 0;
			jump = false;
		}
		frutiz.gotoAndStop(Std.int(frutizFrame)+1);
		
		
		
		ropeFrame = (ropeFrame+vit)%100;
		rope.gotoAndStop(Std.int(ropeFrame) + 1);

	
		vit += dif/70;
		
		
		if ((rope.currentFrame >= 90 || rope.currentFrame <= 10) && (frutiz.currentFrame <= 2 || frutiz.currentFrame > 12)  ) {
			frutiz.gotoAndPlay("fall");
			
			setWin(false, 20 );
		}

	}
	
	override function outOfTime() {
		setWin(true, 10);
	}





//{
}

