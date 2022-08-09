class game.SpaceDodge extends Game{//}
	
	// CONSTANTES
	
	// VARIABLES
	var sList:Array<sp.Phys>;
	var tList:Array<{mc:MovieClip,c:float,l:int}>;
	var qList:Array<MovieClip>;
	var pList:Array<{x:float,y:float}>;
	
	// MOVIECLIPS
	var hero:sp.Phys;
	var ship:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 100+dif*3;
		super.init();
		
		sList = new Array();
		tList = new Array();
		pList = new Array();
		
		attachElements();
		
	};
	
	function initDefault(){
		super.initDefault();
		airFriction = 1
	}
	
	function attachElements(){
		
		// QUEUE
		qList = new Array();
		for(var i=0; i<6; i++){
			var mc = dm.attach("mcAliquet",Game.DP_SPRITE)
			mc._alpha = 50-(i*8)
			qList.push(mc)
		}
		
		// HERO
		hero = newPhys("mcAliquet")
		hero.x = Cs.mcw*0.5
		hero.y = Cs.mch-10
		hero.flPhys = false;
		hero.init();
		for(var i=0; i<100; i++ ) pList.push({x:hero.x,y:hero.y});
		
		// TOURELLE
		for( var i=0; i<10; i++ ){
			var mc = Std.getVar(ship,"$t"+i)
			mc.stop();
			tList.push( { mc:mc,c:10+Std.random(10),l:5 } )
		}
		
		var max = 9-(dif*0.1)
		for( var i=0; i<max; i++){
			var rnd = Std.random(tList.length)
			tList[rnd].mc._visible = false
			tList.splice(rnd,1)
		}
		
		
	}
	
	function update(){

		switch(step){
			case 1:
				// HERO
				hero.toward({x:_xmouse,y:_ymouse},0.2,16)
				if( hero.y < ship._height ) heroExplode();
				
				// QUEUE
				var max =  pList.length
				var ec = 4
				for( var i=0; i< qList.length; i++ ){
					var mc = qList[i]
					mc._x = pList[max-i*ec].x
					mc._y = pList[max-i*ec].y
					
				}
				
				pList.push({x:hero.x,y:hero.y});
				
				// TOWER
				for( var i=0; i< tList.length; i++ ){
					var o = tList[i]
					if( o.c > 0 ){
						o.c-=Timer.tmod
					}else{
						tShoot(o)
						if( Std.random(Math.round(8/Timer.tmod)) == 0 ){
							
						}					
					}
					
					
					
				}
				
				// SHOTS
				for( var i=0; i<sList.length; i++ ){
					var mc = sList[i]
					var m = 10
					if( mc.x<-m || mc.x > Cs.mcw+m || mc.y <-m || mc.y >Cs.mch+m ){
						mc.kill();
						sList.splice(i--,1)
					}
					var lim = 8
					if( Math.abs(hero.x-mc.x)<lim && Math.abs(hero.y-mc.y)<lim){
		
						sList.splice(i--,1)
						mc.kill()
						heroExplode();
					}
					
				}
				
				
				
				break;
		}
		//
		super.update();
	}
	
	function outOfTime(){
		setWin(true)
	}

	function tShoot(o){
		// SHOT
		var mc = newPhys("mcTurretShot");
		var m = 0.4
		var a = m+Math.random()*(3.14-2*m);
		var p = 3;
		mc.x = o.mc._x;
		mc.y = o.mc._y;
		mc.vitx = Math.cos(a)*p;
		mc.vity = Math.sin(a)*p;
		mc.flPhys = false;
		mc.init();
		sList.push(mc)
		// TURRET
		o.mc.gotoAndPlay("2")
		o.c = 16
	}
	
	function heroExplode(){

		// PART
		var p = newPart("mcPartSpaceExplo")
		p.x = hero.x
		p.y = hero.y
		p.scale = 200
		p.flPhys = false;
		p.init();

		//
		hero.kill()
		hero = null
		setWin(false)
		
		//
		while(qList.length>0) qList.pop().removeMovieClip();
					
	}
	
	
	
//{	
}




