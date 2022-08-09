class game.Rope extends Game{//}
	
	
	
	// CONSTANTES
	//static var XMAX = 480//1100
	static var CEIL = 28
	static var TENSION = 30
	static var GSPEED = 16
	static var PRAY = 40
	static var GL = 224
	static var HCENTER = 11
	
	// VARIABLES
	var flWasUp:bool;
	var rx:float;
	var pdec:float;
	var orot:float;
	var timer:float;
	var xmax:float;
	var burn:float;
	var hp:{x:float,y:float}
	
	
	// MOVIECLIPS
	var rope:MovieClip;
	var bg:MovieClip;
	var bande:MovieClip;
	var hero:sp.Phys;
	var grap:sp.Phys;
	var plat:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		//dif = 100
		gameTime = 400
		super.init();
		rx = Cs.mcw*0.5
		pdec = 0;
		burn = 0;
		xmax = 480 + dif*15//*11
		flWasUp = true;
		airFriction = 0.98
		attachElements();
	};
	
	function attachElements(){
		
		// ROPE
		rope = dm.empty(Game.DP_SPRITE)
		
		// PLAT
		plat = newPhys("mcRopePlat")
		plat.x = xmax-(PRAY+20)
		plat.y = GL-8
		plat.flPhys = false;
		plat.friction = 0.9
		plat.init();
		
		// HERO
		hero = newPhys("mcRopeHero")
		hero.x = Cs.mcw*0.5;
		hero.y = Cs.mch*0.5;
		hero.weight = 0.3;
		hero.init();
		
		// BANDE
		bande = dm.attach("mcRopeBande",Game.DP_FRONT)
	
	}
	
	function update(){
		super.update();
		if(step<5)updateScroll();
		updateRope();
		updatePlat();
		updateHero();
	}
	
	function updateRope(){
		rope.clear();
		switch(step){
			case 1:
				
				// ATTIRE
				var p = {
					x:rx,
					y:CEIL
				}
				var d = hero.getDist(p)
				var a = hero.getAng(p)
				if( d > TENSION ){
					var c = (d-TENSION) / TENSION
					var po = 0.15
					hero.vitx += Math.cos(a)*c*po
					hero.vity += Math.sin(a)*c*po
					//Log.print(Math.cos(a)*c*po)
				}
				
				// DRAW
				drawRope(p)

				// CHECK
				orot = hero.skin._rotation
				var dr = ( a/0.0174 + 90 ) - orot
				dr = Cs.round(dr,180)
				hero.skin._rotation += dr*0.25*Timer.tmod;
				var c = -Cs.mm(-1,(a/3.14),0)
				hero.skin.gotoAndStop(string(int(c*20)+1))
				break;
				
			case 2:
				break;
			case 3:
				//Log.print(grap.y)
				if( grap.y < CEIL ){
					rx = grap.x
					step = 1
					grap.kill();
				}
				drawRope(grap)
				break;
			case 4:
				timer-=Timer.tmod;
				if(timer<0)setWin(true);
				hero.y = plat.y;
				break;				
			}
	}

	function updateHero(){
		
		// HP
		var ang = (hero.skin._rotation+90)*0.0174
		hp = {
			x: hero.x + Math.cos(ang)*HCENTER
			y: hero.y + Math.sin(ang)*HCENTER
		}
		
		// CHECK FLAME
		if(hp.y>GL-4 && step !=4 ){
			burn = Math.min(burn+5*Timer.tmod,100);
			
			// PART
			var p = newPart("partFlameBall")
			p.x = hero.x + (Math.random()*2-1)*6;
			p.y = GL + (Math.random()*2-1)*2
			p.weight = -(0.2 + Math.random()*0.2)
			p.timer = 12+Math.random()*12
			p.init();
			
			// FRICTION
			if( hp.y > GL+4 ){
				hero.vitx *= Math.pow(0.85,Timer.tmod)
			}
			
			
			
		}else{
			if(step==4)burn*=0.5;
			burn = Math.max(0,burn-Timer.tmod);
		}
		
		Mc.setPercentColor(hero.skin,burn,0x000000);
		if(burn==100){
			step = 5
			setWin(false);
		}
		
		// BURNING
		if( Math.random()*burn > 25 ){
			var p = newPart("partFlameBall")
			//Log.trace("--"+p.x)
			var ray = Math.random()*10
			var a = Math.random()*6.28
			p.x = hp.x + Math.cos(a)*ray
			p.y = hp.y + Math.sin(a)*ray
			p.vitx = hero.vitx;
			p.vity = hero.vity;
			p.weight = -(0.1 + Math.random()*0.2)
			p.timer = 12+Math.random()*12
			p.init()
			
		}
		
		// CHECK CEIL
		if(hero.y<CEIL+4){
			hero.vity *= -1
			hero.y = CEIL+4
		}
		
		// CHECK PLAT
		var flUp  = hero.y < plat.y-20
		if( ( step==2 || step==3 ) && !flUp && flWasUp ){
			if( Math.abs(hero.x-plat.x) < PRAY ){
				plat.vity += Cs.mm(0,hero.vity,3)*Timer.tmod;
				step = 4
				hero.vitx = 0
				hero.vity = 0
				hero.flPhys = false;
				hero.skin.gotoAndPlay("land")
				hero.y = plat.y
				hero.vitr = 0
				hero.skin._rotation = 0;
				timer = 10
				dm.under(hero.skin)
				flTimeProof=true;
			}
		}
		flWasUp = flUp
		
		//
		hero.skin._x = hero.x;
		hero.skin._y = hero.y;	
	}
	
	function click(){
		switch(step){
			case 1:
				step++
				hero.vitr = (hero.skin._rotation-orot)*1.5
				hero.skin.play();
				break;
			case 2:
				step++
				grap = newPhys("mcRopeGrap")
				var a = hero.getAng({x:_xmouse,y:_ymouse})//-0.75
				grap.x = hero.x;
				grap.y = hero.y;
				grap.vitx = Math.cos(a)*GSPEED;
				grap.vity = Math.sin(a)*GSPEED;
				grap.friction = 1
				grap.flPhys = false;
				grap.init();
				break;
		}
	}
	
	function updateScroll(){
	
		var tx = Cs.mm(-xmax,Cs.mcw*0.5-hero.x,0)
		this._x = tx;
		
		// BG
		bg._x = -this._x*0.9//Math.floor(-this._x/(Cs.mcw))*Cs.mcw
		
		// BANDE
		bande._x = Math.floor(-this._x/(Cs.mcw))*Cs.mcw

	}
	
	function updatePlat(){
		pdec = (pdec+10*Timer.tmod)%628
		var p = {
			x:plat.x
			y:(GL-8)+Math.cos(pdec/100)*1.5
		}
		plat.towardSpeed(p,0.1,0.5)
	}

	function drawRope(p){
		rope.lineStyle(1,0xBBEE00,100)
		rope.moveTo(hero.x,hero.y)
		rope.lineTo(p.x,p.y)	
	}
	

//{	
}

