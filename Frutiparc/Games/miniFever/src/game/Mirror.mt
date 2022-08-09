class game.Mirror extends Game{//}
	
	// CONSTANTES
	var gl:int;
	var rh:int;
	
	// VARIABLES
	var ray:float;
	var a0:float;
	var a1:float;
	var timer:float;
	
	// MOVIECLIPS
	var city:Sprite;
	var monster:{>Sprite,sens:int,decal:float,life:float,light:float};
	var sat:sp.Phys;
	var pan:MovieClip;
	var rad:MovieClip;
	var laser:MovieClip;
	var laserImpact:MovieClip;

	function new(){
		super();
	}

	function init(){
		airFriction = 0.75
		
		gameTime = 650 - dif*2.5;
		super.init();
		
		gl = Cs.mch-8
		ray = 30-dif*0.2
		rh  = gl-20
		
		a0 = 0
		a1 = (Math.random()*2-1)*0.5
		
		attachElements();
		
	};
	
	function attachElements(){
		
		// LASER
		laser = dm.empty(Game.DP_SPRITE)
		
		
		
		
		// CITY
		city = newSprite("mcCity")
		city.x = Cs.mcw*0.5
		city.y = gl
		city.init();
		rad = downcast(city.skin).rad
		
		// LASER IMPACT
		laserImpact = dm.attach( "mcLaserImpact", Game.DP_SPRITE)
		laserImpact._visible = false;
		// MONSTER
		monster = downcast(newSprite("mcGorille"))
		monster.sens = Std.random(2)*2-1
		monster.decal = 0
		monster.life = 100
		monster.light = 0
		monster.x = Cs.mcw*((-monster.sens*0.5)+0.5)
		monster.y = gl;
		monster.skin._xscale = monster.sens*100 
		monster.init();
		
		// SATELLITE
		sat = newPhys("mcSatellite")
		sat.x = Cs.mcw*0.5
		sat.y = Cs.mcw*0.25
		sat.flPhys = false;
		pan = downcast(sat.skin).pan
		pan._xscale = ray*2
		pan._rotation = a1/0.0174
		sat.init();
		
	}
	
	function update(){
		super.update();
		
		switch(step){
			case 1: 
				moveMonster();
				//
				var b = {
					xMin:ray,
					xMax:Cs.mcw-ray,
					yMin:20,
					yMax:Cs.mcw*0.5
				}
				var mp = {
					x:Math.min( Math.max( b.xMin, _xmouse ), b.xMax),
					y:Math.min( Math.max( b.yMin, _ymouse ), b.yMax)
				}
				
				sat.towardSpeed( mp, 0.1, 3 )
				sat.checkBounds( -0.5, 0, b );
				if(base.flPress){
					step = 2
				}
				
				break;
			case 2:
				moveMonster();
				//
				// MOVE RADAR
				var ta = city.getAng({x:_xmouse,y:Math.min(_ymouse,Cs.mch*0.7) })
				var da = ta-a0
				while( da > 3.14 ) da -= 6.28;
				while( da < -3.14 ) da += 6.28;
				a0 += da*0.2*Timer.tmod
				rad._rotation = a0/0.0174
				
				// laser
				var size = Math.min(Math.max(1,12-sat.y*0.1),5.5)
				
				laserImpact._xscale = size*30
				laserImpact._yscale = size*30
				
				laser.clear();
				laser.lineStyle(size,0xFFFFFF,50)
				
				
				var x = city.x
				var y = rh

				var eq0 = getLineEq(x,y,a0)
				var eq1 = getLineEq(sat.x,sat.y+4,a1)
				
				var pos = getIntersection(eq0,eq1)
				laser.moveTo(pos.x,pos.y)
				//*
				if( sat.getDist(pos) < ray ){
					var a = a0-a1
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var na = Math.atan2(sa,-ca)
					
					var eq2 = getLineEq(pos.x,pos.y,na)
					var eq3 = getLineEq(0,gl,0)

					var pos2 = getIntersection(eq2,eq3)
					laser.moveTo(pos2.x,pos2.y)
					laser.lineTo(pos.x,pos.y)
					
					laserImpact._x = pos2.x;
					laserImpact._y = pos2.y;
					laserImpact._visible = true;
					
					if( monster.getDist(pos2) < size*1.5 ){
						monster.light = Math.min( monster.light+20*Timer.tmod,100)
						monster.life -= Timer.tmod;
						if( monster.life < 0 ){
							laser.clear();
							step = 3
							timer = 10
							monster.skin.gotoAndPlay("dead")
							flTimeProof = true;
							laserImpact._visible = false;
							
						}
					}
					
					
				}else{
					eq1 = getLineEq(0,0,0)
					pos = getIntersection(eq0,eq1)
					laser.moveTo(pos.x,pos.y)
					laserImpact._visible = false;
				}				
				//*/
				
				laser.lineTo(city.x,rh)
				
				if(!base.flPress){
					laser.clear();
					laserImpact._visible = false;
					step = 1
				}		
				break;
			case 3:
				timer-=Timer.tmod
				if(timer <0)setWin(true);
							
		}
		
		monster.light *= Math.pow(0.9,Timer.tmod)
		Mc.setPColor(downcast(monster.skin),0xFFFFFF,100-monster.light)
		
	}
	
	function moveMonster(){
		monster.decal = (monster.decal+30*Timer.tmod)%628
		monster.x += Math.max(0,Math.cos(monster.decal/100))*(0.5+dif*0.01)*monster.sens
		
		if( Math.abs(monster.x-city.x) < 20 ){
			setWin(false);
			city.skin.gotoAndStop("2")
			monster.skin.gotoAndPlay("youpi")
			step = 4;
		}
		
	}
	
	
	
	
	// TOOLS
	
	function getLineEq(x,y,a){
		
		var c = Math.sin(a)/Math.cos(a)
		var d = y - c*x

		return {c:c,d:d}
	}
	
	function getIntersection(e0,e1){
		//var y = (-e0.d/(e0.c/e1.c))+e1.d
		var y = ((e0.c*e1.d)-(e1.c*e0.d))/(e0.c-e1.c)
		var x = (y-e0.d)/e0.c

		return{x:x,y:y}
		
	}
	
	
	
//{	
}

