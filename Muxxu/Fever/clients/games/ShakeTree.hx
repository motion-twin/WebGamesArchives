import Protocole;
import mt.bumdum9.Lib;

typedef Apple = { >Phys, d:Float, a:Float, lnk:Float, flGround:Bool };

class ShakeTree extends Game{//}

	// CONSTANTES
	var yBase:Float;
	var hh:Float;
	var groundLevel:Float;
	var ray:Float;
	var nbFruit:Int;

	// VARIABLES
	var angle:Float;
	var angleSpeed:Float;
	var oldAngle:Float;

	var fList:Array<Apple>;

	// MOVIECLIPS
	var tronc:Sprite;
	var top:Sprite;
	var dTop:flash.display.MovieClip;
	var dShade:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 320-dif*200;
		super.init(dif);
		yBase = Cs.mch - 50;
		hh = 100;
		ray = 12;
		groundLevel = Cs.mch - 12;

		angle = 0;
		oldAngle = 0;
		angleSpeed = 0;
		nbFruit = 8;
		attachElements();
		updateTronc(0.5);
	}

	function attachElements(){

		bg = dm.attach("shakeTree_bg",0);
		getSmc(bg).stop();
		// DRAW BOTTOM
		dShade = dm.empty(Game.DP_SPRITE);

		// TRONC
		tronc = newSprite("mcShakeTronc");
		tronc.x = Cs.mcw*0.5;
		tronc.y = yBase;
		tronc.updatePos();

		// TOP
		top = newSprite("mcShakeTreeTop");
		top.x = Cs.mcw*0.5;
		top.y = yBase-hh;
		top.updatePos();

		// DRAW TOP
		dTop = dm.empty(Game.DP_SPRITE);


		// FRUITS
		fList = [];
		for( i in 0...nbFruit ){

			var a = 0.0;
			var d = 0.0;
			var t = 0;
			do{
				t++;

				a = -Math.random()*3.14;
				d = Math.random()*100;

				var x = top.x + Math.cos(angle+a)*d;
				var y = top.y + Math.sin(angle+a)*d;

				var flGood = true;
				for( n in 0...fList.length ){
					var f = fList[n];
					var dist = f.getDist({x:x,y:y});
					if( dist < 40-(t*0.1) ){
						flGood = false;
						break;
					}
				}
				if(flGood)break;

			}while(true);


			var mc:Apple = cast newPhys("mcShakeApple");

			mc.flGround = false;
			mc.a = a;
			mc.d = d;

			mc.x = top.x + Math.cos(angle+mc.a)*mc.d;
			mc.y = top.y + Math.sin(angle+mc.a)*mc.d;

			mc.lnk = 100+Math.random()*200;
			mc.updatePos();

			//TYPE(fList.push)
			fList.push(mc);	// BUG MTYPE
		}

		// HERB
		var mc = dm.attach("mcShakeHerb",Game.DP_SPRITE);
		mc.y = Cs.mch;

	}

	override function update(){
		super.update();

		updateTronc(getMousePos().x/Cs.mcw);
		updateFruits();
		oldAngle = angle;


	}

	function updateTronc(mc){

		if(timeProof){
			angleSpeed -= angle*0.2;
			angleSpeed *= 0.95;
			angle += angleSpeed;
		}else{
			angle = Math.min(Math.max(0,mc),1)-0.5;
		}

		var ex = tronc.x + Math.cos(angle-1.57)*hh;
		var ey = tronc.y + Math.sin(angle-1.57)*hh;

		dTop.graphics.clear();
		dTop.graphics.lineStyle( 36, 0x73522B, 100 );
		dTop.graphics.moveTo( tronc.x, tronc.y );
		dTop.graphics.curveTo( tronc.x, tronc.y-hh*0.5, ex, ey );

		dShade.graphics.clear();
		dShade.graphics.lineStyle( 40, 0x000000, 100 );
		dShade.graphics.moveTo( tronc.x, tronc.y );
		dShade.graphics.curveTo( tronc.x, tronc.y-hh*0.5, ex, ey );

		top.root.rotation = angle/0.0174;
		top.x = ex;
		top.y = ey;

	}

	function updateFruits(){
		var da = oldAngle-angle;
		//Log.clear();

		var flFreeTree = true;

		for( mc in fList ){

			if( mc.lnk > 0 ){
				flFreeTree = false;
				mc.x = top.x + Math.cos(angle+mc.a)*mc.d;
				mc.y = top.y + Math.sin(angle+mc.a)*mc.d;
				mc.lnk -= Math.abs(da)*10;
				//Log.trace(mc.lnk)
				if( mc.lnk < 0 ){
					mc.weight = 1;
					mc.vx += da*10;
				}

			}else{

				if( mc.y > groundLevel-ray ){
					mc.y = groundLevel-ray;
					mc.vy *= -0.5;
					mc.vx *= 0.75;
					if( mc.flGround != true ){
						nbFruit --;
					}
					mc.flGround = true;
				}
			}

			mc.root.x = mc.x;
			mc.root.y = mc.y;


		}

		if( !timeProof && flFreeTree ){
			timeProof = true;
			getSmc(bg).play();
		}

		if( nbFruit == 0 )setWin(true,10);

	}








//{
}









