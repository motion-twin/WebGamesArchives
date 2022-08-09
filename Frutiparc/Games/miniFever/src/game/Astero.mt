class game.Astero extends Game{//}
	
	// CONSTANTES
	

	// VARIABLES
	var angle:float;
	var cool:float;
	var startCoef:float;
	var shotList:Array<sp.Phys>;
	var asteroList:Array<sp.Phys>;
	
	// MOVIECLIPS
	var ship:sp.Phys;

	
	function new(){
		super();
	}

	function init(){
		gameTime = 320;
		super.init();
		Log.setColor(0xFFFFFF)
		angle = 0;
		cool = 0;
		shotList = new Array();
		asteroList = new Array();
		startCoef = 1
		attachElements();

		
	};
	
	function initDefault(){
		super.initDefault();
		airFriction = 1;
	}
	
	function attachElements(){
		// SHIP
		ship = newPhys("mcAsteroShip")
		ship.x = Cs.mcw*0.5;
		ship.y = Cs.mch*0.5;
		ship.flPhys = false;
		ship.init();
		
		// ASTEOROID
		var max = 1+Math.floor(dif*0.07)
		var size = 50
		var speed = 1
		for( var i=0; i<max; i++ ){
			var mc = newAstero(size);
			var a = (i/max)*6.28
			mc.x = ship.x+Math.cos(a)*70;
			mc.y = ship.y+Math.sin(a)*70;
			var a2 = Std.random(628)/100;
			mc.vitx = Math.cos(a2)*speed;
			mc.vity = Math.sin(a2)*speed;
			mc.flPhys = false;
			mc.init()
		}		
		
	}

	function update(){
		
		switch(step){
			case 1: 
				startCoef = Math.max( 0, startCoef-0.015*Timer.tmod )
				moveShip();
				moveAstero();
				checkShot();
				break;
			case 2: // ANGLE

		}
		//
		super.update();
	}
		
	function newAstero(size){
		var mc = newPhys("mcAsteroid")
		mc.skin._xscale = size;
		mc.skin._yscale = size;
		mc.flPhys = false
		asteroList.push(mc)
		return mc;
	}
		
	function moveShip(){
		cool = Math.max(0,cool-Timer.tmod);
		
		var m = { x:_xmouse, y:_ymouse };
		var a = ship.getAng(m);
		var da = a - angle;
		while(da>3.14)da-=6.28;
		while(da<-3.14)da+=6.28;
		angle += da*0.5*Timer.tmod;
		ship.skin._rotation = angle/0.0174
		
		if(base.flPress){
			if( cool == 0 && flWin == null ){
				var mc = newPhys("mcAsteroShoot")
				var ca = Math.cos(angle)
				var sa = Math.sin(angle)
				mc.x = ship.x+ca*8
				mc.y = ship.y+sa*8
				mc.vitx = ca*4
				mc.vity = sa*4
				mc.flPhys = false;
				mc.skin._rotation = angle/0.0174
				Std.cast(mc).time = 100
				mc.init();
				shotList.push(mc)
				cool = 2.5//1.5+dif*0.05;
			}
		}else{
			var dist = ship.getDist(m)
			var speed = Math.min( Math.max( 0, (dist-Math.abs(da)*5)*0.005), 0.5 )
			ship.vitx += Math.cos(angle)*speed*(1-startCoef)
			ship.vity += Math.sin(angle)*speed*(1-startCoef)

			//Log.print(ship)
				
			/*
			var dx = m.x - ship.x
			var dy = m.y - ship.y
			var lim = 1
			ship.vitx += Math.min( Math.max( -lim, dx*0.1 ), lim )
			ship.vity += Math.min( Math.max( -lim, dy*0.1 ), lim )
			*/
		}
		var f = Math.pow(0.95,Timer.tmod)
		ship.vitx *= f
		ship.vity *= f		
		checkWarp(ship,10)
		
	}
	
	function moveAstero(){
		for( var i=0; i<asteroList.length; i++ ){
			var mc = asteroList[i]
			mc.x -= mc.vitx*Timer.tmod*startCoef
			mc.y -= mc.vity*Timer.tmod*startCoef
			
			var d = mc.getDist(ship)
			if( d < mc.skin._xscale*0.5+4){
				var explo = newPart("mcPartExplosion")
				explo.flPhys = false;
				explo.x = ship.x;
				explo.y = ship.y;
				explo.scale = 50;
				explo.init();
				ship.kill();
				ship = null;
				//Log.trace("--"+Std.cast(ship))
				setWin(false)
			}
			checkWarp(mc,mc.skin._xscale*0.5)
		}
	}
	
	function checkShot(){
		for( var i=0; i<shotList.length; i++ ){
			var mc = shotList[i]
			var m = 8
			var flKill =  false//mc.x < -m || mc.x > Cs.mcw+m || mc.y < -m || mc.y > Cs.mch+m 
			
			//var list= new Array();
			//for( var n=0; n<asteroList.length; n++ )list.push(asteroList[n]);			
			for( var n=0; n< asteroList.length; n++ ){
				var a = asteroList[n]
				var d = mc.getDist(a)			
				
				var size = a.skin._xscale
				if( d < size*0.5 ){
					if(size>20){
						var ang = Std.random(628)/100
						var ca = Math.cos(ang)
						var sa = Math.sin(ang)
						var ns = size*0.5
						var speed = Math.sqrt( a.vitx*a.vitx + a.vity*a.vity )*1.2
						for( var ii=0; ii<2; ii++ ){
							var sens = ii*2-1
							var na = newAstero(ns);
							na.x = a.x + ca*ns*0.5*sens
							na.y = a.y + sa*ns*0.5*sens
							na.vitx = ca*speed*sens;
							na.vity = sa*speed*sens;
							na.flPhys = false;
							na.init();
						}
					}
					
					var explo = newPart("mcPartAsteroidExplo")
					explo.flPhys = false;
					explo.x = a.x
					explo.y = a.y
					explo.scale = a.skin._xscale*2
					explo.skin._rotation = Std.random(360)
					explo.init();
					
					a.kill();
					asteroList.splice(n,1)
					flKill = true;
					break;
				}
			}
			
			Std.cast(mc).time -= Timer.tmod
			var t = Std.cast(mc).time
			if( t < 0 ){
				flKill = true;
			}else if( t < 10 ){
				mc.skin._alpha = t*10
			}
			
			checkWarp(mc,8)
			
			if(flKill){
				mc.kill();
				shotList.splice(i,1)
				i--
			}
			
		}
		
		if(asteroList.length == 0){
			setWin(true)
		}
		
	}
	
	function checkWarp(mc:{x:float,y:float},m:float){
	
		var xMin = -m
		var xMax = Cs.mcw+m
		var yMin = -m
		var yMax = Cs.mch+m
		
		if( mc.x < xMin ){
			mc.x = xMax+(mc.x-xMin)
		}	
		if( mc.x > xMax ){
			mc.x = xMin+(mc.x-xMax)
		}
		if( mc.y < yMin ){
			mc.y = yMax+(mc.y-yMin)
		}	
		if( mc.y > yMax ){
			mc.y = yMin+(mc.y-yMax)
		}		

	
	}
	

	
	
//{	
}












