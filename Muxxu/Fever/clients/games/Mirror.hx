import mt.bumdum9.Lib;

class Mirror extends Game{//}

	// CONSTANTES
	var gl:Int;
	var rh:Int;

	// VARIABLES
	var ray:Float;
	var a0:Float;
	var a1:Float;
	var timer:Float;

	// MOVIECLIPS
	var city:Sprite;
	var monster:{>Sprite,sens:Int,decal:Float,life:Float,light:Float};
	var sat:Phys;
	var pan:flash.display.MovieClip;
	var rad:flash.display.MovieClip;
	var laser:flash.display.MovieClip;
	var laserImpact:flash.display.MovieClip;

	override function init(dif:Float){
		//airFriction = 0.75;
		gameTime = 650 - dif*250;
		super.init(dif);

		gl = Cs.omch-8;
		ray = 30-dif*20;
		rh  = gl-20;

		a0 = 0.0;
		a1 = (Math.random()*2-1)*0.5;

		attachElements();
		zoomOld();

	}

	function attachElements(){

		dm.attach("mirror_bg",0);

		// LASER
		laser = dm.empty(Game.DP_SPRITE);




		// CITY
		city = newSprite("mcCity");
		city.x = Cs.omcw*0.5;
		city.y = gl;
		city.updatePos();
		rad = cast(city.root).rad;

		// LASER IMPACT
		laserImpact = dm.attach( "mcLaserImpact", Game.DP_SPRITE);
		laserImpact.visible = false;
		
		// MONSTER
		monster = cast newSprite("mcGorille");
		monster.sens = Std.random(2)*2-1;
		monster.decal = 0;
		monster.life = 100;
		monster.light = 0;
		monster.x = Cs.omcw*((-monster.sens*0.5)+0.5);
		monster.y = gl;
		monster.root.scaleX = monster.sens;
		monster.updatePos();

		// SATELLITE
		sat = newPhys("mcSatellite");
		sat.x = Cs.omcw*0.5;
		sat.y = Cs.omcw*0.25;
		pan = cast (sat.root).pan;
		pan.scaleX = ray*0.02;
		pan.rotation = a1/0.0174;
		sat.updatePos();
		sat.frict = 0.75;

	}

	override function update(){
		super.update();

		switch(step){
			case 1:
				moveMonster();
				//
				var b = {
					xMin:ray,
					xMax:Cs.omcw-ray,
					yMin:20,
					yMax:Cs.omcw*0.5
				}
				var mmp = getMousePos();
				var mp = {
					x:Math.min( Math.max( b.xMin, mmp.x ), b.xMax),
					y:Math.min( Math.max( b.yMin, mmp.y ), b.yMax)
				}
				sat.towardSpeed( mp, 0.1, 3 );
				if(click)step = 2;

			case 2:
				moveMonster();
				//
				// MOVE RADAR
				var mp = getMousePos();
				var ta = city.getAng({x:mp.x,y:Math.min(mp.y,Cs.omch*0.7) });
				var da = ta-a0;
				while( da > 3.14 ) da -= 6.28;
				while( da < -3.14 ) da += 6.28;
				a0 += da*0.2;
				rad.rotation = a0/0.0174;

				// laser
				var size = Math.min(Math.max(1,12-sat.y*0.1),5.5);

				laserImpact.scaleX = size*30*0.01;
				laserImpact.scaleY = size*30*0.01;

				laser.graphics.clear();
				laser.graphics.lineStyle(size,0xFFFFFF,50);


				var x = city.x;
				var y = rh;

				var eq0 = getLineEq(x,y,a0);
				var eq1 = getLineEq(sat.x,sat.y+4,a1);

				var pos = getIntersection(eq0,eq1);
				laser.graphics.moveTo(pos.x,pos.y);
				//*
				if( sat.getDist(pos) < ray ){
					var a = a0-a1;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var na = Math.atan2(sa,-ca);

					var eq2 = getLineEq(pos.x,pos.y,na);
					var eq3 = getLineEq(0,gl,0);

					var pos2 = getIntersection(eq2,eq3);
					laser.graphics.moveTo(pos2.x,pos2.y);
					laser.graphics.lineTo(pos.x,pos.y);

					laserImpact.x = pos2.x;
					laserImpact.y = pos2.y;
					laserImpact.visible = true;

					if( monster.getDist(pos2) < size*1.5 ){
						monster.light = Math.min( monster.light+20,100);
						monster.life --;
						if( monster.life < 0 ){
							laser.graphics.clear();
							step = 3;
							timer = 10;
							monster.root.gotoAndPlay("dead");
							timeProof = true;
							laserImpact.visible = false;

						}
					}


				}else{
					eq1 = getLineEq(0,0,0);
					pos = getIntersection(eq0,eq1);
					laser.graphics.moveTo(pos.x,pos.y);
					laserImpact.visible = false;
				}
				//*/

				laser.graphics.lineTo(city.x,rh);

				if(!click){
					laser.graphics.clear();
					laserImpact.visible = false;
					step = 1;
				}

			case 3:
				timer--;
				if(timer <0)setWin(true);

		}

		monster.light *= 0.9;
		Col.setPercentColor(monster.root,monster.light*0.01,0xFFFFFF);

	}

	function moveMonster(){
		monster.decal = (monster.decal+30)%628;
		monster.x += Math.max(0,Math.cos(monster.decal/100))*(0.5+dif*1)*monster.sens;

		if( Math.abs(monster.x-city.x) < 20 ){
			setWin(false,30);
			city.root.gotoAndStop("2");
			monster.root.gotoAndPlay("youpi");
			step = 4;
		}

	}




	// TOOLS

	function getLineEq(x:Float,y:Float,a:Float){

		var c = Math.sin(a)/Math.cos(a);
		var d = y - c*x;

		return {c:c,d:d}
	}

	function getIntersection(e0:{c:Float,d:Float},e1:{c:Float,d:Float}){
		//var y = (-e0.d/(e0.c/e1.c))+e1.d
		var y = ((e0.c*e1.d)-(e1.c*e0.d))/(e0.c-e1.c);
		var x = (y-e0.d)/e0.c;

		return{x:x,y:y}

	}



//{
}

