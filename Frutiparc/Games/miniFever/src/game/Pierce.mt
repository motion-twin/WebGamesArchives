class game.Pierce extends Game{//}
	
	
	
	// CONSTANTES
	static var MARGIN = 8
	static var SIDE = 20
	
	// VARIABLES
	var bList:Array<{>sp.Phys,trg:{x:float,y:float}}>;
	var ray:float;
	//var vy:float;
	var sens:int;
	
	// MOVIECLIPS
	var hero:Sprite;
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 260
		super.init();
		ray = 32-dif*0.2
		sens = 1
		attachElements();
	};
	
	function attachElements(){
		
		// BALLONS
		bList = new Array();
		var max = 2 + (dif*0.05)
		for( var i=0; i<max; i++ ){
			var sp = downcast(newPhys("mcPierceBallon"))
			var m = 12
			sp.x = m+Math.random()*(Cs.mcw-2*m)
			sp.y = m+Math.random()*(Cs.mch-2*m)
			//sp.vitx = (Math.random()*2-1)*2.5
			//sp.vity = (Math.random()*2-1)*2.5
			sp.skin._xscale = ray*2
			sp.skin._yscale = ray*2
			sp.friction = 0.92
			sp.flPhys = false;
			sp.init();
			newTarget(sp)
			bList.push(sp)
		}
		
		// HERO
		hero = newSprite("mcPiercer")
		hero.x = MARGIN;
		hero.y = Cs.mch*0.5;
		hero.init();
		
		
		

	}
	
	function update(){
	
		super.update();
		moveBall();
		
		
		switch(step){
			case 1:
				var dy = Cs.mm(0,_ymouse,Cs.mch)-hero.y
				hero.y += dy*0.1
				
				var tr = (-sens+1)*0.5*180
				var dr =  tr - hero.skin._rotation
				while(dr>180)dr-=360;
				while(dr<-180)dr+=360;
				hero.skin._rotation += dr*0.3*Timer.tmod;
			
			
				if( base.flPress && Math.abs(dr) < 2){
					step = 2;
					hero.skin._rotation = tr
				}

				break;
			case 2:
				var tx = Cs.mcw*0.5 + (Cs.mcw*0.5-MARGIN)*sens
				var dx = (tx-hero.x)*Timer.tmod;
				var vx = dx*0.3

				var lim = 3
				while( vx != 0 ){
					
					var vit = Cs.mm(-lim,vx,lim)
					hero.x += vit;
					vx -= vit
					checkCol();
					
					var p = dm.attach("partPiercer",Game.DP_SPRITE2)
					p._x = hero.x;
					p._y = hero.y;
					p._rotation = hero.skin._rotation
					//break;
				}

				if( Math.abs(dx) < 3 ){
					hero.x = tx
					step = 1
					sens *= -1
				}
				
				
				break;
			case 3:
				break;
		}
	
		
	}

	function moveBall(){
		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i];

			
			
			/*
			if( sp.x < SIDE+ray || sp.x > Cs.mcw-(SIDE+ray) ){
				sp.x = Cs.mm( SIDE+ray, sp.x, Cs.mcw-(SIDE+ray) )
				sp.vitx *= -1
			}
			if( sp.y < ray || sp.y > Cs.mch-ray ){
				sp.y = Cs.mm(ray,sp.y,Cs.mch-ray)
				sp.vity *= -1
			}
			*/
			
			sp.towardSpeed(sp.trg,0.1,1);
			if( sp.getDist(sp.trg)<20 )newTarget(sp);
			
			
			for( var n=0; n<bList.length; n++ ){
				var spo = bList[n]
				if(sp!=spo){
					var dist = sp.getDist(spo)
					if( dist < 2*ray ){
						var d = (2*ray)-dist;
						var a = sp.getAng(spo)
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						sp.x -= ca*d*0.5
						sp.y -= sa*d*0.5
						spo.x += ca*d*0.5
						spo.y += sa*d*0.5
						
					}
				}
			}
			sp.skin._x = sp.x;
			sp.skin._y = sp.y;
		}
	}
	
	function newTarget(sp){
		var mx = (ray+SIDE)+20;
		var my = ray;
		sp.trg = {
			x:mx+Math.random()*(Cs.mcw-2*mx)
			y:my+Math.random()*(Cs.mch-2*my)
		}
	}
	
	function checkCol(){
		
		
	
		var pos = {
			x:hero.x + 8*sens
			y:hero.y
		}
		/*
		var mc = dm.attach("mcToken",Game.DP_SPRITE)
		mc._x = p.x;
		mc._y = p.y;
		*/
		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i]
			if( sp.getDist(pos) < ray ){
				var max = 8
				for( var n=0; n<3; n++ ){
					var dec = n*(6.28/8)*0.5
					var speed = 4
					for( var n2=0; n2<max; n2++ ){
						var p = newPart("partPierceExplo");
						var a = dec + (n2/8)*6.28;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						
						var sc = 0.8 - n*0.2
						
						p.x = sp.x + ca*ray*sc;
						p.y = sp.y + sa*ray*sc;
						p.vitx = ca*speed
						p.vity = sa*speed
						p.friction = 0.95-n*0.05
						p.flPhys = false;
						p.timer = 16 + n*2 + Math.random()*8
						p.timerFadeType = 1
						p.vitr = 24+n*8
						p.init();
						p.skin._rotation = a/0.0174
					}
				}

				
				
				sp.kill();
				bList.splice(i--,1)
			}
			
			
			
			
			
		}
		
		
		
		
		if( bList.length == 0 )setWin(true);
		
	}

	
//{	
}















