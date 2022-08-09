class game.Rempart extends Game{//}
	
	// CONSTANTES
	static var CLIMBER_RAY = 20
	static var VEGETABLE_SPEED = 8
	
	// VARIABLES
	var cList:Array<{>MovieClip,step:int,t:float}>
	var vList:Array<sp.phys.Part>
	var freq:float;
	var delay:float;
	var cd:float;
	var frame:float;
	
	// MOVIECLIPS
	var hero:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 500+dif*2;
		super.init();
		cList = new Array();
		vList = new Array();
		freq = 46-dif*0.2
		delay = 10
		cd = 0
		frame = 0
		attachElements();
	};
	
	function attachElements(){
		
		// HERO
		hero = dm.attach("mcRempartHero",Game.DP_SPRITE)
		hero._x = Cs.mcw*0.5
		hero._y = 68
		hero.stop();
		
		// REMPART
		dm.attach("mcRempart",Game.DP_SPRITE)
		
	}
	
	function update(){
		cd -= 0.05*Timer.tmod
		switch(step){
			case 1:
				moveHero();
				if( Std.random(int(freq/Timer.tmod)) == 0 || cList.length == 0 )genClimber();
				moveClimber();
				updateShoot();
				break;
			
		}
		super.update();
	}
	
	// CLIMBER
	function genClimber(){
		var mc = downcast(dm.attach("mcRempartClimber",Game.DP_SPRITE))
		var m = 20
		mc._x = m + Math.random()*(Cs.mcw-2*m)
		mc._y = Cs.mch+30
		mc.step = 0
		mc.t = 0;
		mc.step = 0
		cList.push(mc)
	}
	
	function moveClimber(){
		for( var i=0; i<cList.length; i++ ){
			var mc = cList[i]
			switch(mc.step){
				case 0:
					mc.t -= Timer.tmod
					if(mc.t<0){
						mc.t = 6//delay
						mc.step = 1
						mc.play()
					}
					break;
				case 1:
					mc._y -= 2*Timer.tmod
					mc.t -= Timer.tmod
					if(mc.t<0){
						mc.t = delay
						mc.step = 0			
					}
					
					
					
					break;	
				case 2:
					mc._y += 2*Timer.tmod
					mc.t -= Timer.tmod
					if(mc.t<0){
						mc.t = 5
						mc.step = 0			
					}
					break;						
			}
			checkCol(mc);
			if(mc._y<70)setWin(false);
		}
	}
	
	function checkCol(mc){
		for( var n=0; n<cList.length; n++ ){
			var mco = cList[n]
			var dx = mc._x - mco._x
			var dy = mc._y - mco._y
			var dist = Math.sqrt(dx*dx+dy*dy)
			if( dist < CLIMBER_RAY*2 ){
				var d = (CLIMBER_RAY*2-dist)*0.5
				var a = Math.atan2(dy,dx)
				mc._x += Math.cos(a)*d
				mc._y += Math.sin(a)*d
				mco._x -= Math.cos(a)*d
				mco._y -= Math.sin(a)*d							
			}
		}
		
		if( mc._x < -CLIMBER_RAY || mc._x > Cs.mcw+CLIMBER_RAY ){
			mc._x = Cs.mm( -CLIMBER_RAY, mc._x, Cs.mcw+CLIMBER_RAY )
		}
		
		
		
	}
	

	// SHOOT	
	function click(){
		super.click();
		
		if(cd<0.5){
			cd = 1
			hero.gotoAndPlay("shoot")
			var sp = newPart("mcRempartVegetable")
			sp.x = hero._x+28;
			sp.y = 12;
			var a = sp.getAng( {x:_xmouse,y:_ymouse} );
			sp.vitx = Math.cos(a)*VEGETABLE_SPEED;
			sp.vity = Math.sin(a)*VEGETABLE_SPEED-2;
			sp.vitr = 4*(Math.random()*2-1)
			sp.weight = 0
			sp.init();
			sp.skin.gotoAndStop( string( Std.random(sp.skin._totalframes)+1 ) )
			sp.skin._rotation = Math.random()*360
			vList.push(sp)
		}

	}
	
	function updateShoot(){
		for( var i=0; i<vList.length; i++ ){
			var sp = vList[i]
			for( var n=0; n<cList.length; n++ ){
				var mc = cList[n]
				var dist = sp.getDist({x:mc._x,y:mc._y})
				if( dist < CLIMBER_RAY ){
					mc.step = 2
					mc.t = sp.vity*10
					sp.vity *= -1
					sp.timer = 20
					sp.weight = 0.5
					sp.vitr = (Math.random()*2-1)*36
					vList.splice(i--,1)
					break;
				}
				
				
			}
		}
	}
	
	// HERO
	function moveHero(){
		
		var dx = _xmouse - hero._x;
		if(cd<0){
			var lim = 4
			var vx = Cs.mm( -lim, dx*0.1, lim )*Timer.tmod
			hero._x += vx
			
			frame = (frame+Math.abs(vx*0.5))%20
			//Log.print(frame)
			hero.gotoAndStop(string(int(frame)+1))
			
		}
		
	}
	

	
	function outOfTime(){
		setWin(true)
	}
	
	
	
	
//{	
}

