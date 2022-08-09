import mt.bumdum9.Lib;
import mt.flash.Volatile;

typedef ShieldBall = {>Sprite, sens:Int, height:Float, vx:Float, vy:Float, vr:Float, decal:Float, flActive:Bool, shade:Sprite };

class Shield extends Game{//}

	// CONSTANTES
	var ballRay:Float;
	var shieldRay:Float;
	var shieldMargin:Int;
	var pause:Volatile<Int>;
	var gl:Int;
	var pos:Array<Int>;
	var herb:Sprite;
	// VARIABLES
	var ballList:Array<ShieldBall>;

	// MOVIECLIPS
	var hero:Sprite;


	override function init(dif){
		gameTime = 320;
		super.init(dif);
		ballRay = 6;
		shieldRay = 14;
		shieldMargin = 20;
		gl = Cs.omch-16;
		ballList = new Array();
		pos = [
			gl-12,
			gl-29,
			gl-44,
		];
		attachElements();
		zoomOld();
		pause = 0;
		//Col.setPercentColor(hero.root,100,0);
	}

	function attachElements(){

		bg = dm.attach("shield_bg",0);

		hero = newSprite("mcShieldMan");
		hero.x = Cs.omcw*0.5;
		hero.y = gl;
		hero.updatePos();
		hero.root.gotoAndStop(2);

		herb = newSprite("mcShieldFrontHerb");
		herb.x = 120;
		herb.y = 225;
		herb.updatePos();

		step = -1;
	}

	override function update(){

		moveBall();
		switch(step){

			case -1:
				if( pause++ > 15 ) step = 1;
		
			case 1:
				//
				var sens = (getMousePos().x<Cs.omcw*0.5)?-1:1;
				hero.root.scaleX = -sens;
				var frame = 1;
				var mp = getMousePos();
				if( mp.y < 170 )		frame = 3;
				else if(mp.y < 200)		frame = 2;
			
				hero.root.gotoAndStop(frame);
				//
				if( Std.random( Std.int(100*ballList.length) ) == 0 && !win)	addBall();


				var a  = ballList.copy();
				for( sp in a ){
					var dx = Math.abs(hero.x - sp.x);
					if(sp.flActive){
						if( dx < shieldMargin+ballRay ){
							var dy = Math.abs(pos[frame-1]-sp.y);
							var flWay = sens == -sp.sens;
							if( dy < ballRay+shieldRay && flWay ){
								sp.sens *= -1;
								sp.x = hero.x+(shieldMargin+ballRay)*sp.sens;
								sp.flActive = false;
							}else{

								if( dx < (shieldMargin+ballRay)-12 ){

									sp.sens *= -1;
									step = 2;
									var fr= null;
									if( sp.y < 170 )		fr = flWay?"head0":"head1";
									else if( sp.y < 200)		fr = flWay?"chest0":"chest1";
									else				fr = flWay?"leg0":"leg1";

									hero.root.gotoAndPlay(fr);
									setWin(false);
								}
							}
						}
					}else{
						if( dx > (Cs.omcw*0.5)+ballRay ){
							ballList.remove(sp);
							sp.updatePos();	//?
						}
					}
				}

		}
		//
		super.update();
	}

	function moveBall(){
		for( sp in ballList ){
			sp.x += sp.vx*sp.sens;
			sp.decal = (sp.decal+sp.vy)%628;
			sp.y = gl-( ballRay+Math.abs(Math.cos(sp.decal/100)*sp.height));
			sp.shade.x = sp.x;
			sp.root.rotation += sp.vr * sp.sens;
			
			
			var ball:McShieldBall = cast(sp.root);
			ball.reflet.rotation = -ball.rotation;
		}
	}

	override function outOfTime(){
		setWin(true,20);
		hero.root.gotoAndPlay("win");
		step = 2;
	}

	function addBall(){
		var sp:ShieldBall = cast(newSprite("McShieldBall"));
		sp.sens = (Std.random(2)*2)-1;
		sp.height = 20+Math.random()*40;
		sp.decal = Math.random()*628;
		sp.flActive = true;
		sp.vx = 2.5+dif*1.8+Math.random()*(dif*0.04);
		sp.vy = 5+dif*9.2+Math.random()*(dif*0.2);
		var half = Cs.omcw*0.5;
		sp.x = half - sp.sens*(half+ballRay*2);
		sp.root.gotoAndStop(1+Std.random(sp.root.totalFrames));
		sp.updatePos();
		ballList.push(sp); // BUG MTYPE
		sp.vr = 3+Math.random()*(10+Math.abs(sp.vx));
		sp.shade = newSprite("mcShieldBallShade");
		sp.shade.x = sp.x;
		sp.shade.y = gl;
		sp.shade.updatePos();
		dm.under(sp.shade.root);
	}

}



