class game.Tree extends Game{//}
	
	// CONSTANTES
	static var FRAME = 80
	static var LAG_TIMER_MAX = 100
	static var HEIGHT = 197
	static var GL = 216
	
	// VARIABLES
	var lagTimer:float;
	var frame:float;
	var angle:float;
	var oldAngle:float;
	var timer:float;
	var weight:float;
	
	var pl:Array<{x:float,y:float,vx:float,vy:float}>
	
	// MOVIECLIPS
	var hero:Sprite;
	var tree:Sprite;
	
	//var m0:MovieClip;
	//var m1:MovieClip;
	var shade:MovieClip;
	
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 150+dif*3
		super.init();
		lagTimer = LAG_TIMER_MAX
		frame = 0;
		angle = Math.random()*0.01;
		attachElements();
		
		weight = 1.03
		
	};
	
	function attachElements(){
		
		// SHADE
		shade = dm.attach("mcTreeShade",Game.DP_SPRITE)
		shade._x = Cs.mcw*0.5
		shade._y = GL+3
		shade._xscale = 0
		
		// TREE
		tree = newSprite("mcTreeTree")
		tree.x = Cs.mcw*0.5
		tree.y = 197
		tree.init();
		
		// HERO
		hero = newSprite("mcTreeHero")
		hero.x = Cs.mcw*0.5
		hero.y = 219
		hero.init();
		
		// HERB
		dm.attach("mcTreeHerb",Game.DP_SPRITE)
		
		
	}
	
	function update(){

		switch(step){
			case 1: 
				// HERO
				var dx = _xmouse-hero.x
				var lim = 4
				var vx =  Cs.mm(-lim,dx*0.1,lim)*Timer.tmod
				hero.x += vx
				
				frame = frame+vx*4
				
			
				angle -= vx*0.005
			
				while(frame<0)frame+=FRAME;
				while(frame>FRAME)frame-=FRAME;
			
				hero.skin.gotoAndStop(string(int(frame)+1))
			
				// TREE
				var c = 1
				if(lagTimer!=null){
					lagTimer -= Timer.tmod;
					if(lagTimer<0){
						c = 1-lagTimer/LAG_TIMER_MAX
						lagTimer = null;
					}
				}
				
				weight *= 1.0003
				
				angle *= (weight*c)+1*(1-c)
				tree.skin._rotation = angle/0.0174
				tree.x = hero.x
			
				if( Math.abs(angle) > 0.8 ){
					initFall();
				}
				
				moveShade(angle-1.57)
				
				// OLD ANGLE
				oldAngle = angle
				
				break;
			case 2:
				for( var i=0; i<pl.length; i++ ){
					var o = pl[i];
					o.vy += 0.3*Timer.tmod;
					var frict = Math.pow(0.95,Timer.tmod);
					o.vx *= frict;
					o.vy *= frict;					
					o.x += o.vx*Timer.tmod;
					o.y += o.vy*Timer.tmod;
					
					if( o.y > GL ){
						o.y = GL
						o.vy *= -0.9
					}
				}
				var p0 = pl[0]
				var p1 = pl[1]
				var dx = p0.x - p1.x 
				var dy = p0.y - p1.y

				var dist = Math.sqrt(dx*dx+dy*dy)
				var dif = HEIGHT-dist
				
				var a = Math.atan2(dy,dx)
				
				p0.x += Math.cos(a)*dif*0.5
				p0.y += Math.sin(a)*dif*0.5
				
				p1.x -= Math.cos(a)*dif*0.5
				p1.y -= Math.sin(a)*dif*0.5
				
				tree.x = p0.x
				tree.y = p0.y
				tree.skin._rotation =  a/0.0174 - 90
				
				/* DEBUG
				m0._x = pl[0].x
				m0._y = pl[0].y
				m1._x = pl[1].x
				m1._y = pl[1].y
				//*/
				moveShade(a+3.14)
				
				timer -= Timer.tmod
				if(timer<0){
					flFreezeResult = false;
					setWin(false)
					timer = null
				}
				break;
			
		}
		//
		super.update();
	}
	
	function moveShade(a){
		shade._x = tree.x
		shade._xscale = Math.cos(a)*HEIGHT	
	}
	
	
	function initFall(){
		/* DEBUG
		m0 = dm.attach("mcMarker",Game.DP_SPRITE)
		m1 = dm.attach("mcMarker",Game.DP_SPRITE)
		//*/

		flFreezeResult = true;
		
		step = 2

		pl = new Array();
		pl.push({x:tree.x,y:tree.y,vx:0,vy:0})
		
		var a = angle - 1.57
		var x = pl[0].x+Math.cos(a)*HEIGHT
		var y = pl[0].y+Math.sin(a)*HEIGHT
		
		//var cx = Math.cos(a)*2
		//var cy = Math.sin(a)*2
		
		a = oldAngle - 1.57
		var ox = pl[0].x+Math.cos(a)*HEIGHT
		var oy = pl[0].y+Math.sin(a)*HEIGHT
		
		pl.push({x:x, y:y, vx:x-ox, vy:y-oy})
		
		//dm.over(tree.skin)
		var mc = dm.attach("mcTreeHeroAngry",Game.DP_SPRITE)
		mc._x = hero.x;
		mc._y = hero.y;
		hero.kill();
		
		timer = 20
		
		
		/* CENTRIFUGE
		for( var i=0; i<pl.length; i++ ){
			var o = pl[i]
			o.vx = cx 
			o.vy = cy 
		}
		//*/
		
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	
	

//{	
}










