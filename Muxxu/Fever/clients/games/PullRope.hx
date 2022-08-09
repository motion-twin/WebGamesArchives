import mt.bumdum9.Lib;
using mt.deepnight.SuperMovie;

class PullRope extends Game{//}

	static var EXT = 40;

	var weightType:Int;
	var weight:Float;
	var length:Float;

	var startY:Float;
	var pull:Float;
	var pos:Float;
	var rope:flash.display.MovieClip;
	var rope2:flash.display.MovieClip;
	var wheel:flash.display.MovieClip;
	var wheel2:flash.display.MovieClip;

	var rdm:mt.DepthManager;

	override function init(dif:Float){
		gameTime =  360;
		super.init(dif);
		weight = 2;
		weightType = 0;
		length = 600;

		if( dif > 0.3  ){
			weightType++;
			weight += 5;
			length -= 200;
		}
		if( dif > 0.8  ){
			weightType++;
			weight += 3;
			length -= 500;
		}
		length += dif * 1450;
		pos = 0;
		attachElements();

	}

	function attachElements(){


		bg = dm.attach("PullRope_bg",0);
		dm.attach("PullRope_fg",2);

		// ROPE
		rope = dm.attach("PullRope_rope",1);
		rope.x = 250;
		rope.y = -EXT;
		
		//rope.onPress = 			startDrag2;
		//rope.onRelease = 		stopDrag2;
		//rope.onReleaseOutside = 	stopDrag2;
		var me = this;
		//rope.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.startDrag2(); } );
		rope.onMouseDown(startDrag2);
		rope.useHandCursor = true;
		rope.buttonMode = true;
		
		// ROPE 2
		rope2 = dm.attach("PullRope_rope",1);
		rope2.x = 150;
		rope2.y = 0;
		getSmc(rope2).gotoAndStop(weightType+1);
		rdm  = new mt.DepthManager(getSmc(rope2));

		
		// WHEEL
		wheel = dm.attach("PullRope_wheel",1);
		wheel.x = 200;
		wheel.y = 0;
		wheel.stop();
		wheel.mouseEnabled = false;

		// WHEEL 2
		wheel2 = dm.attach("PullRope_wheel",0);
		wheel2.x = 200;
		wheel2.y = 0;
		wheel2.gotoAndStop(2);
		wheel2.mouseEnabled = false;


	}

	override function update(){


		switch(step){
			case 1:
				pos = Math.max(pos-weight,0);
			case 2:
				var mp = getMousePos();
				pull = mp.y - startY;
				if( !click ) stopDrag2();

			case 3:
		}

		var limit = length+340;
		var finalPos = Num.mm( 0,pos+pull,limit);
		if( step < 3 && finalPos == limit ){
			step = 3;
			setWin(true,20);
		}

		rope.y = finalPos%EXT - EXT;
		if( finalPos > length ){
			rope2.y = length-finalPos;
			// PART WATER

				for( i in 0...1 ){
					var mc = rdm.attach("mcPartWaterFlow",0);
					mc.x = (Math.random()*2-1)*60;
					mc.y = Math.random()*200;
					mc.scaleX = 0.5+Math.random()*0.5;
					mc.scaleY = mc.scaleX;
					mc.gotoAndPlay(10);
				}

		}else{
			rope2.y = -(finalPos%EXT);
		}


		getSmc(wheel).rotation = finalPos;
		getSmc(wheel2).rotation = finalPos;


		super.update();
	}

	function startDrag2(){
		if( step == 3 )return;
		var mp = getMousePos();
		startY = mp.y;
		step = 2;
	}
	function stopDrag2(){
		if( step == 3 )return;
		pos += pull;
		pull = 0;
		step = 1;
	}
//{
}

















