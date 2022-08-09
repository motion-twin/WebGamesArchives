class game.Guardian extends Game{//}
	
	// CONSTANTES
	static var GL = 222
	static var RAY = 3
	static var LIFE_MAX = 16
	static var FALL = 4
	static var SHAKE = 1.8
	
	// VARIABLES
	var life:int;
	var multi:float;
	var timer:float;
	var bList:Array<{>sp.Phys,type:int,sens:int,cd:float, flFree:bool, dec:float, wp:{x:float,y:float}}>
	var sList:Array<sp.Phys>
	var hold:{>sp.Phys,type:int,sens:int,cd:float, flFree:bool, dec:float, wp:{x:float,y:float}}
	var sc:float;
	
	// MOVIECLIPS
	var gen:{ >MovieClip, cal:MovieClip, light:MovieClip }
	var line:MovieClip;
	var cur:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 500 + dif*2.5
		super.init();
		airFriction = 0.95
		sc = 0;
		life = LIFE_MAX;
		multi = (20-dif*0.16)
		
		bList = new Array();
		sList = new Array();
		attachElements();
	};
	
	function attachElements(){
		
		
		// LINES
		line = dm.empty(Game.DP_SPRITE)
		
		// GENERATOR
		gen = downcast(dm.attach("mcGuardianGenerator",Game.DP_SPRITE))
		gen._x = Cs.mcw*0.5
		gen._y = GL
		gen.cal.gotoAndStop(string(life+1))
		
		// CURSOR
		cur = dm.attach("mcGuardianCursor",Game.DP_SPRITE)

	}
	
	function update(){
		super.update();
		switch(step){
			case 1:

				break;
			case 2:
				sc = Math.min( sc+0.1, 1.2 )
				if(Std.random(int(5/Timer.tmod))==0){
					var p = newPart("partExplosion");
					p.x = gen._x + (Math.random()*2-1)*12
					p.y = gen._y - Math.random()*40
					p.flPhys = false;
					p.scale = 30
					p.init();
				}
				
				timer -= Timer.tmod;
				if(timer<0){
					flFreezeResult = false;
					setWin(false)
				}
				
				break;
		}
		
		if( Std.random(int((bList.length*multi)/Timer.tmod))==0 && bList.length < 20 ){
			genBads()
		}
		moveBads();
		moveShots();

		// GENERATOR
		sc *= 0.86
		if(sc>0.1){
			gen.cal._x = (Math.random()*2-1)*sc*SHAKE
			gen.cal._y = (Math.random()*2-1)*sc*SHAKE - 24
		}
		
		// PARTS
		var list = glPart();
		for(var i=0; i<list.length; i++ ){
			var p = list[i]
			if( p.y > GL ){
				p.y = GL
				p.vity *= -0.8
				p.skin._y = p.y
			}
		}
		
		// CURSSOR
		cur._x = _xmouse;
		cur._y = _ymouse;
		
		if(hold != null ){
			cur._x = hold.x;
			cur._y = hold.y;
		}
		
		cur._xscale = Cs.mm(0,cur._xscale,100)
		cur._yscale = cur._xscale;
	}
	
	//

	function genBads(){
		
		var sp = downcast(newPhys("mcGuardianBads"))
		setSens(sp,Std.random(2)*2-1);
		sp.x = Cs.mcw*0.5 - (20+Cs.mcw*0.5)*sp.sens;
		sp.y = GL-RAY;
		sp.type = 0
		if( Std.random(int(dif)) > 30 )sp.type = 1;
		sp.weight = 0.3;
		sp.flPhys = false;
		sp.flFree = true;
		sp.cd = 30;
		if(sp.type==1){
			sp.y = RAY+Math.random()*(GL-2*RAY);
			sp.dec = Math.random()*628
		}
		seekWayPoint(sp);
		sp.init();
		bList.push(sp);
		sp.skin.gotoAndStop(string(sp.type+1));
	
	}

	function moveBads(){
		line.clear();
		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i]
			
			if(!sp.flFree){

				if(!base.flPress){
					release();
					
				}else{
					//sp.x = _xmouse;
					//sp.y = _ymouse;
					var mp = {x:_xmouse,y:_ymouse}
					var dist = sp.getDist(mp)
					var max = 20
					if( dist > max ){
						var c = (dist-max) / max
						var a = sp.getAng(mp)
						var p = 1
						sp.vitx += Math.cos(a)*p*c
						sp.vity += Math.sin(a)*p*c
					}
					line.lineStyle(1,0xFFFFFF,50)
					line.moveTo(mp.x,mp.y)
					line.lineTo(sp.x,sp.y);

					
					
				}
				
				
				
			}else{
				switch(sp.type){
					case 0:
						if(sp.flPhys){
							/*
							if(sp.y > GL ){
								sp.y = GL
								if( sp.vity > FALL ){
									black(sp)
									sp.vity *= -0.8 ;
								}
							}
							*/
						}else{
							if( (sp.x-sp.wp.x)*sp.sens < 0 ){
								sp.x += 0.5*Timer.tmod*sp.sens
							}else{
								downcast(sp.skin).b.gotoAndPlay("1")
								attack(sp);
							}
						}
					
					
						break;
					case 1:
						// TOWARD + ROTAT
						sp.towardSpeed(sp.wp,0.1,0.25)
						var vx = Math.abs(sp.vitx)
						if(sp.vitx*sp.sens < 0 && vx > 1.5 )setSens(sp,-sp.sens);
						sp.skin._rotation = vx*5*sp.sens;
						
						// ATTACK
						var dist = sp.getDist(sp.wp)
						if( dist < 20 )attack(sp);
						
						// DEC
						sp.dec = (sp.dec+15*Timer.tmod)%628
						sp.vity += Math.cos(sp.dec/100)*0.12
						

						break;
					case 2:
						if( sp.y > Cs.mch+5 ){
							sp.kill()
							bList.splice(i--,1)
						}
						break;
				}
				
			}
			
			// CHECK GROUND
			if( sp.type !=2 && sp.y > GL-RAY ){
				sp.y = GL-RAY
				if( sp.vity > FALL ){
					black(sp)
				}
				if(sp.type==0){
					downcast(sp.skin).b.gotoAndPlay("1")
					sp.flPhys = false;
					sp.vitx = 0
					sp.vity = 0
					setSens(sp,(sp.x<gen._x)?1:-1)
				}else{
					sp.vity *= -0.8
				}
				
				var max = Math.min( Math.abs(sp.vity), 10 )
				for( var n=0; n<max; n++ ){
					var p = newPart("partGuardianDirt");
					var a = -Math.random()*3.14
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var ray = 3+Math.random()
					var speed = 3+Math.random()*2
					p.x = sp.x + ca*ray
					p.y = sp.y + sa*ray
					p.vitx += ca*speed + sp.vitx*0.2
					p.vity += sa*speed
					p.weight = 0.2+Math.random()*0.3
					p.scale = p.weight*300
					p.timer = 10+Math.random()*20
					p.timerFadeType = 1
					p.init();
				}
				
			
			}
			
			// UPDATE
			sp.skin._x = sp.x;
			sp.skin._y = sp.y;
			
		}
	}
	
	function black(sp){
		sp.skin.gotoAndStop("3")
		sp.flPhys = true;
		sp.type = 2;
		if(!sp.flFree)release();
	}
	
	function moveShots(){
		for( var i=0; i<sList.length; i++ ){
			var sp = sList[i]
			var m = 4;
			var flDeath  = sp.x<m || sp.x > Cs.mcw-m || sp.y<m || sp.y > Cs.mch-m 
			var r = 16
			var h = 40
			if( sp.x<gen._x+r && sp.x > gen._x-r && sp.y<gen._y && sp.y > gen._y-h ){
				flDeath = true;
				damage();
				
			}
			if(flDeath){
				sp.kill();
				sList.splice(i--,1)
			}
			
		}
	}
	
	//
	
	function click(){
		super.click();
		var xm = {x:_xmouse,y:_ymouse}
		var dmin = 20
		if(hold!=null)release();

		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i];
			var d = sp.getDist(xm)
			if(d<dmin){
				dmin = d
				hold = sp
			}
		}
		
		if(hold!=null){
			hold.flFree = false;
			downcast(hold.skin).b.gotoAndStop("1")
		}
		
		
	}

	function release(){
		hold.flFree = true;
		if(hold.type==0)hold.flPhys = true;
		hold = null
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	//
	
	function setSens(sp,sens){
		sp.sens = sens
		sp.skin._xscale = 100*sens
	}
	
	function seekWayPoint(sp){
		switch(sp.type){
			case 0:
				sp.wp = {
					x:Cs.mcw*0.5 - ( 24 + Math.random()*24 ) * sp.sens
					y:GL
				}
				break;
			case 1:
				var ray = 40+Math.random()*50
				var ma = 0.2
				var a = -( ma + Math.random()*(3.14-2*ma) )
				
				sp.wp = {
					x:gen._x + Math.cos(a)*ray
					y:(gen._y-20) + Math.sin(a)*ray
				}
				break;
			
		}
		
		
	}
	
	function attack(sp){
		sp.cd -= Timer.tmod;
		if( sp.cd <=0 ){
			
			
			sp.cd = 55
			var trg = {
				x : gen._x
				y : gen._y - Math.random()*45
			}

			
			// SHOOT
			var a = sp.getAng(trg)
			var shot = newPhys("mcGuardianBadsShot")
			shot.x = sp.x;
			shot.y = sp.y;
			var v = 4.5;
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			shot.vitx = ca*v
			shot.vity = sa*v
			shot.flPhys = false;
			shot.friction = 1
			shot.init();
			sList.push(shot)
			shot.skin._rotation = a/0.0174
			
			// RECUL
			switch(sp.type){
				case 0:
					sp.x -= ca*2.5
					break;
				case 1:
					sp.vitx -= ca*4
					sp.vity -= sa*4
					break;
			}
		}
	}
	
	function damage(){
		life--;
		sc = 1
		if( life < 0 ){
			step = 2
			timer = 10
			flFreezeResult = true;
			//setWin(false)
		}else{
			gen.cal.gotoAndStop(string(1+int(6*(life/LIFE_MAX))))
		}
		gen.light.play();
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//{	
}

