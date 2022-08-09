class game.Scud extends Game{//}
	
	// CONSTANTES
	static var GUN_SIZE = 16
	static var MIS_SPEED = 2
	static var FB_SPEED = 1.5
	
	// VARIABLES
	var ammo:int;
	var rot:float;
	var boum:float;
	var fTimer:float;
	var interval:float;
	var fList:Array<sp.Phys>
	var sList:Array<{>sp.Phys,d:float}>
	var eList:Array<{>Sprite,vs:float}>
	var aList:Array<MovieClip>
	// MOVIECLIPS
	var gun:MovieClip;

	function new(){
		super();
	}

	function init(){
		gameTime = 420
		super.init();
		airFriction = 1;
		rot = 0
		fTimer = 30
		interval = 30 - dif*0.25
		boum = 70 //- dif*0.4
		sList = new Array();
		fList = new Array();
		eList = new Array();
		ammo = 8
		displayAmmo();
		attachElements();
	};
	
	function attachElements(){
		

	}
	
	function update(){
		switch(step){
			case 1:
				// TURN CANON
				var dx = _xmouse - gun._x;
				var dy = _ymouse - gun._y;
				rot = Cs.mm(-3.14,Math.atan2(dy,dx),0)
				gun._rotation = rot/0.0174
				
				// SHOOT
				if(base.flPress && ammo > 0){
					step = 2
					var sp = downcast(newPhys("mcScud"));
					var ca =  Math.cos(rot);
					var sa =  Math.sin(rot);
					sp.x = gun._x + ca*GUN_SIZE;
					sp.y = gun._y + sa*GUN_SIZE;
					sp.vitx = ca*MIS_SPEED;
					sp.vity = sa*MIS_SPEED;
					sp.flPhys = false;
					sp.d = Math.sqrt( dx*dx + dy*dy )-GUN_SIZE
					sp.init();
					sp.skin._rotation = rot/0.0174;
					sList.push(sp);
					
					ammo--
					displayAmmo();
					
				}			
				break;
			case 2:
				if(!base.flPress){
					step=1;
				}
				break;
		};
		
		// FIREBALL
		fTimer -= Timer.tmod
		while(fTimer<0){
			fTimer += interval
			interval *= 1.2
			addFireBall();
		}
		
		// UPDATES
		updateShots();
		updateExplos();
		updateFireBalls();
		
		
		super.update();
	}

	function updateShots(){
		for( var i=0; i<sList.length; i++ ){
			var sp = sList[i];
			sp.d -= MIS_SPEED
			if(sp.d<0){
				
				explode(sp.x,sp.y,boum)
				
				sp.kill();
				sList.splice(i--,1)
			}			
		}
	}
	
	function updateExplos(){
		var frict = Math.pow(0.5,Timer.tmod)
		for( var i=0; i<eList.length; i++ ){
			var sp = eList[i];
			sp.vs *= frict;
			sp.skin._xscale += sp.vs*Timer.tmod;
			sp.skin._yscale = sp.skin._xscale
			
			// CHECK COL
			for( var n=0; n<fList.length; n++ ){
				var fb = fList[n]
				var ray = sp.skin._xscale*0.5
				var dist =sp.getDist(fb)
				if( dist < ray ){
					explode(fb.x,fb.y,boum*0.75)
					fb.kill()
					fList.splice(n--,1)
				}				
			}
			
			
			// DEATH
			if( sp.vs < 0.1 ){
				sp.kill()
				eList.splice(i--,1)
			}
			
			
			
		}
	}
	
	function updateFireBalls(){
		for( var i=0; i<fList.length; i++ ){
			var sp = fList[i];
			if(sp.y>Cs.mch-2){
				var mc = dm.attach( "mcScudFire", Game.DP_SPRITE )
				mc._x = sp.x;
				mc._y = Cs.mch;
				sp.kill();
				fList.splice(i--,1)
				setWin(false)
			}
		}
	}
	
	function explode(x,y,vs){
		var sp = downcast(newSprite("mcScudExplosion"))
		sp.x = x;
		sp.y = y;
		sp.vs = vs
		sp.init();
		sp.skin._xscale = 6
		sp.skin._yscale = 6
		eList.push(sp)
	}

	function addFireBall(){
		var sp = newPhys("mcFireBall")
		sp.x = Math.random()*Cs.mcw
		sp.y = -10
		
		var p = {x:Math.random()*Cs.mcw,y:Cs.mch}
		var a = sp.getAng(p)
		
		sp.vitx = Math.cos(a)*FB_SPEED
		sp.vity = Math.sin(a)*FB_SPEED
		sp.flPhys = false;
		sp.init();
		sp.skin._rotation = a/0.0174
		fList.push(sp)
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	function displayAmmo(){
		if(aList!=null)while(aList.length>0)aList.pop().removeMovieClip();
		aList = new Array();
		for(var i=0; i<ammo; i++ ){
			var mc = dm.attach("mcScudAmmo",Game.DP_SPRITE2)
			mc._x = (Cs.mcw-(ammo*2 + (ammo-1)*1 ))*0.5 + i*(2+1)
			mc._y = Cs.mch - 4
			aList.push(mc)			
		}
		
	}
	
	
//{	
}















