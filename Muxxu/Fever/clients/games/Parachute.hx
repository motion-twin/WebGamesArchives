
class Parachute extends Game{//}

	// CONSTANTES
	var leafLevel:Int;
	var paraRay:Int;

	// VARIABLES
	var flWasUp:Bool;
	var leafSens:Int;
	var leafSpeed:Float;
	var leafRay:Float;
	var rotSpeed:Float;
	var paraDecal:Float;

	// MOVIECLIPS
	var para:Phys;
	var leaf:flash.display.Sprite;
	var fan:McFan;

	override function initDecor() {
		zoomOld();
	}

	override function init(dif) {
		
		gameTime = 140;
		super.init(dif);
		leafRay = 40 - dif*10;
		leafSpeed = 0.5+dif*6;
		leafSens = Std.random(2)*2-1;
		paraRay = 25;
		leafLevel = Cs.omch-15;
		attachElements();
		rotSpeed = 0;

	}

	function attachElements(){

		// BG
		bg = dm.attach("parachute_bg", 0);
		
		// LEAF
		leaf = dm.attach("mcLeaf",Game.DP_SPRITE);
		leaf.x = leafRay + Std.random(Math.round(Cs.omcw-leafRay));
		leaf.y = leafLevel;
		leaf.scaleX = leafRay*0.02;
		leaf.scaleY = leafRay * 0.02;
		
		
		// PARA
		para = newPhys("mcParachute");
		para.x = Cs.omcw*0.5;
		para.y = Cs.omch*0.5;
		para.vr = 0;
		para.root.scaleX = paraRay*0.02;
		para.root.scaleY = paraRay*0.02;
		para.root.stop();
		para.updatePos();


		// FAN
		
		fan = new McFan();
		dm.add(fan, Game.DP_SPRITE);
		fan.x = Cs.omcw*0.5;
		fan.y = Cs.omch * 0.5 -20;
		fan.stop();



	}

	override function update() {
		
		switch(step){
			case 1:
				// MOVE LEAF
				moveLeaf();

				// GRAVITY
				para.y += 0.75;

				// POWER FAN
				var dx = para.x - fan.x;
				var left = dx > 0;
				if( Math.abs(dx) < 60 ){
					var pow = rotSpeed*(left?1:-1);
					para.vx += pow*0.02;
					para.vr -= pow*0.05;
				}

				// REPLACE LA FOURMI
				var lim = 1;
				para.vr -= Math.min( Math.max( -lim, (para.root.rotation*0.05) ), lim );
				para.vr *= 0.95;	// FRICT SUP

				// BOUNDS
				if( para.x < paraRay || para.x > Cs.omcw-paraRay ){
					para.vx *= -0.5;
					para.x	= Math.min( Math.max( paraRay, para.x ) , Cs.omcw-paraRay );
				}

				// BOUGE LE FAN
				moveFan();

				// CHECK LANDING
				var y = para.y + Math.cos((para.root.rotation)*0.0175)*paraRay; // A CHECKER
				var flUp = y < leafLevel;

				if( !flUp ){
					if( flWasUp ){
						var d = para.x - leaf.x;
						if( Math.abs(d) < leafRay ){
							paraDecal = d;
							landing(true);
						}
					}
					if( y > leafLevel+10 )landing(false);
				}
				flWasUp = flUp;

			case 2:
				moveLeaf();
				if( win )para.x = leaf.x + paraDecal;
				fan.alpha *=0.5;

		}
		//
		super.update();
	}

	function landing(flag){
		step = 2;
		para.root.gotoAndPlay(flag?"$landing":"$ploufing");
		setWin(flag,50);
		para.root.rotation = 0;
		para.vx = 0;
		para.vy = 0;
		para.vr = 0;

	}

	function moveLeaf(){
		leaf.x += leafSens * leafSpeed;
		if( leaf.x < leafRay || leaf.x > Cs.omcw-leafRay ){
			leafSens *= -1;
			leaf.x	= Math.min( Math.max( leafRay, leaf.x ) , Cs.omcw-leafRay );
		}
	}

	function moveFan(){
		// MOVE
		var mp  = getMousePos();
		fan.x = fan.x*0.5 + mp.x*0.5;
		fan.y = fan.y*0.5 + mp.y*0.5;

		// LEFT RIGHT
		var left = ( para.x - fan.x ) > 0;
		if(left)	fan.prevFrame();
		else		fan.nextFrame();


		// .rotation
		var dy =  para.y - fan.y ;
		fan.rotation = dy * 0.2 * (left?1: -1);

		// TURNING
		if(click)rotSpeed += 1;
		rotSpeed *= 0.95;
		if( fan.fan != null )	fan.fan.fan.rotation += rotSpeed;
	



	}


//{
}






















