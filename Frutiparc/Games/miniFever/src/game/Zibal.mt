class game.Zibal extends Game{//}
	
	
	
	// CONSTANTES
	static var FOOT_SPEED = 20;
	static var INFO = [
		{
			s:{x:37,y:118}
			d:{x:194,y:125}
		},
		{
			s:{x:184,y:184}
			d:{x:59,y:115}
		},
		{
			s:{x:184,y:56}
			d:{x:178,y:178}
		}		
		{
			s:{x:49,y:183}
			d:{x:175,y:190}
		}
	]
	
	// VARIABLES
	var flWillWin:bool;
	var next:int;
	var timer:float;
	var zibal:sp.Phys;
	var pList:Array<{mc:MovieClip,base:MovieClip,x:float,y:float,angle:float,dist:float}>
	
	// MOVIECLIPS
	var level:{>MovieClip,spos:MovieClip};
	var door:MovieClip;
	var mask:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400
		super.init();
		next = 0;
		airFriction = 0.96
		attachElements();
	};
	
	function attachElements(){
		var li = Math.round(dif*0.04)
		var lvl = INFO[li]
		
		// LEVEL
		level = downcast(dm.attach("mcZibalLevel",Game.DP_SPRITE))
		level.gotoAndStop(string(li+1))
		
		// DOOR
		door = dm.attach("mcPortail",Game.DP_SPRITE2)
		door._x = lvl.d.x		
		door._y = lvl.d.y		
		
		
		// ZIBAL
		zibal = newPhys("mcZibal")
		zibal.x = lvl.s.x;
		zibal.y = lvl.s.y;
		zibal.weight = 0.3;
		zibal.init();
		zibal.skin.stop();
		

		

		
	}
	
	function update(){
		
		if(pList==null){
			// PATTES
			pList = new Array();
			for( var i=0; i<4; i++ ){
				var p = {
					mc:dm.attach("mcZibalFoot",Game.DP_SPRITE2)
					base:dm.attach("mcZibalBaseFoot",Game.DP_SPRITE2)
					x:zibal.x
					y:zibal.y
					angle:null
					dist:null
				}
				p.mc.stop();
				var a = ((i/4)+0.125)*6.28 
				var dx = Math.cos(a)
				var dy = Math.sin(a)
				while( !level.hitTest(p.x,p.y,true) ){
					p.x += dx; 
					p.y += dy; 
				}
				updateFoot(p)			
				pList.push(p)
			}
		}
		
		
		// UPDATE FOOTS
		for( var i=0; i<pList.length; i++ ){
			var p = pList[i]
			updateFoot(p)
		}
		
		// CHECK DEATH
		if( step!=4 && level.hitTest(zibal.x,zibal.y,true) ){
			willWin(false,10)
			destroyFoots();
			zibal.vitx = 0
			zibal.vity = -4
			zibal.skin.gotoAndStop("death")
		}
		
		// CHECK DOOR
		if( step!=4  ){
			var dist = zibal.getDist({x:door._x,y:door._y})
			if( door._currentframe==1 && dist<80 ){
				door.play();
			}
			if( door._currentframe > 14 && dist<14  ){
				willWin(true,10)
				mask = dm.attach("mcZibalMask",Game.DP_SPRITE)
				mask._x = door._x
				mask._y = door._y
				mask._alpha = 0
				zibal.skin.setMask(mask)
				destroyFoots();
			}
			
		}
		
		
		// ORIENT
		var ma = zibal.getAng({x:_xmouse,y:_ymouse})
		zibal.skin._rotation = ma/0.0174
		
		
		// CONTROL
		switch(step){
			case 1:
				if(base.flPress){
					step = 2;
					var p = pList[next]
					p.angle = ma
					p.dist = 0;
					p.x = zibal.x
					p.y = zibal.y
					p.mc.gotoAndStop("1")
					
				}
				break;
			case 2:
				var p = pList[next]
				var dx = Math.cos(p.angle)
				var dy = Math.sin(p.angle)
				var max = Math.floor(FOOT_SPEED*Timer.tmod)
				for( var i=0; i<max; i++){
					p.x += dx
					p.y += dy
					if( level.hitTest(p.x,p.y,true) ){
						p.dist = null
						p.angle = null
						next = (next+1)%4
						step = 3
						pList[next].mc.gotoAndStop("2")
						break;
					}
				}				
				break;
			case 3:
				/*

				*/
				if(!base.flPress)step=1;
				break;
			case 4:
				timer-=Timer.tmod;
				if(timer<0){
					flFreezeResult = false;
					setWin(flWillWin)
				}
				break;
		}
		
		super.update();
	}
	
	function updateFoot(p){
		var a = zibal.getAng(p)
		var dist = zibal.getDist(p)
		p.mc._x = zibal.x;
		p.base._x = zibal.x;
		p.mc._y = zibal.y;
		p.base._y = zibal.y;
		p.mc._rotation = a/0.0174
		p.base._rotation = a/0.0174
		p.mc._xscale = dist;
		
		if(p.dist==null){
			var att = dist*0.01
			zibal.vitx += Math.cos(a)*att*Timer.tmod;
			zibal.vity += Math.sin(a)*att*Timer.tmod;
		}
	}
	
	function destroyFoots(){
		while(pList.length>0){
			var p = pList.pop()
			p.mc.removeMovieClip();
			p.base.removeMovieClip();
		}
	}
	
	function willWin(flag,t){
		flWillWin = flag
		flFreezeResult = true;
		step = 4
		timer = t
	}
		
	
//{	
}

