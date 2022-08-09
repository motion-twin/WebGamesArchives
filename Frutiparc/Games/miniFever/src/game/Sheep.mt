class game.Sheep extends Game{//}
	
	// CONSTANTES
	static var SHEEP_RAY = 10;
	static var SHEEP_TURN = 0.1;
	static var DOG_TURN = 0.2;
	static var WALK = 0.6;
	static var FEAR_RAY = 80;
	static var BARK_RAY = 50;
	static var DOOR_RAY = [47,33,19]
	
	
	// VARIABLES
	var di:int;
	var sList:Array<{>sp.Phys,a:float,ta:float,sp:float,pd:float,flIn:bool}>
	
	// MOVIECLIPS
	var bar:MovieClip;
	var dog:{>sp.Phys,a:float,ta:float,pd:float};
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 600+dif*2
		super.init();
		di = Math.round(dif*0.03)
		attachElements();
	};
	
	function attachElements(){

		// BARRIER
		bar = dm.attach("mcSheepBarrier",Game.DP_SPRITE)
		bar.gotoAndStop(string(1+di))
		
		// SHEEP
		sList = new Array();
		var m = 20
		var max = Math.round(1+dif*0.2)
		for( var i=0; i<max; i++ ){
			var sp = downcast(newPhys("mcSheep"))
			sp.x = m + Std.random(Cs.mcw-2*m) 
			sp.y = m + Std.random(Cs.mch-2*m)
			sp.flPhys = false;
			sp.a = Math.random()*6.28;
			sp.ta = sp.a;
			sp.sp = WALK
			sp.pd = Math.random()*628
			sp.flIn = false;
			sp.init();
			sp.skin.stop();
			sList.push(sp);
			
			/* DEBUG ANGLE
			var s = Std.cast(sp)
			s.dm = new DepthManager(s.skin)
			s.mca = s.dm.attach("mcAngle",1)
			//*/
			
		}
		
		// DOG
		dog = downcast(newPhys("mcSheepDog"))
		dog.x = Cs.mcw*0.5
		dog.y = Cs.mch*0.5
		dog.a = 0
		dog.ta = 0
		dog.pd = 0
		dog.flPhys = false;
		dog.init();
		
		
	}
	
	function update(){

		switch(step){
			case 1: 
				
				// DOG
				moveDog();
			
				// SHEEP
				var f = fun(a,b){
					if(a.y>b.y)return 1;
					if(a.y<b.y)return -1;
					return 0;
				}
				sList.sort(f)
				var flDog = true;
				for( var i=0; i<sList.length; i++ ){
					
					var sp = sList[i];
					moveSheep(sp)
					if( flDog && sp.y>dog.y  ){
						dm.over(dog.skin)
					}
					dm.over(sp.skin)
					

				}
				
				// CHECK WIN
				var fl = true;
				for( var i=0; i<sList.length; i++ ){
					if(!sList[i].flIn){
						fl=false;
						break;
					}
				}
				if(fl)setWin(true);
				
			
			
				break;
			
		}
		//
		super.update();
	}
	
	function moveDog(){
		
		// TURN
		var m = {x:_xmouse,y:_ymouse}
		dog.ta = dog.getAng(m)
		var da = dog.ta - dog.a
		while(da>3.14)da-=6.28;
		while(da<-3.14)da+=6.28;
		dog.a += da*DOG_TURN*Timer.tmod
		
		// UPDATE SPEED
		var sp = Cs.mm( 0, (dog.getDist(m)-10)*0.1 , 4)
		
		// MOVE
		dog.vitx = Math.cos(dog.a)*sp
		dog.vity = Math.sin(dog.a)*sp
		
		
		// BODY TURN
		var c = dog.a/6.28 - 0.25
		while(c<0)c+=1;
		while(c>1)c-=1;
		dog.skin.gotoAndStop(string(1+int(c*58)))
		
		// PATTES
		dog.pd = (dog.pd+sp*30*Timer.tmod)
		for(var n=0; n<4; n++ ){
			var mc = Std.getVar( dog.skin, "p"+n )
			mc.p._y = Math.cos((dog.pd+(n/4)*628)/100)
		}		
		
		
	}
	
	function moveSheep(sp){
		
		// ORIENT
		var dd = sp.getDist(dog)
		if(sp.flIn){
			sp.ta = -1.57
			sp.sp = 2
		}else if( dd < FEAR_RAY ){
			sp.ta = dog.getAng(sp)
			sp.sp += (1-dd/FEAR_RAY)*0.5
		}else{
			if(Std.random(80)==0 && sp.sp < 0.8 ){
				sp.ta = Math.random()*6.28;
				sp.sp = WALK
			}
		}
		// PATTES
		sp.pd = (sp.pd+sp.sp*30*Timer.tmod)
		for(var n=0; n<4; n++ ){
			var mc = Std.getVar( sp.skin, "p"+n )
			mc.p._y = Math.cos((sp.pd+(n/4)*628)/100)
		}

		// DECREMENTE SPEED
		sp.sp *= Math.pow(0.9,Timer.tmod)
		
		// BOUND
		if(!sp.flIn)checkBounds(sp);
		
		/* DEBUG ANGLE
		var s = Std.cast(sp)
		s.mca._rotation = sp.ta/0.0174
		//*/
		
		// SHEEP_TURN
		var da = sp.ta - sp.a
		while(da>3.14)da-=6.28;
		while(da<-3.14)da+=6.28;
		sp.a += da*SHEEP_TURN*Timer.tmod
				
		// MOVE
		sp.vitx = Math.cos(sp.a)*sp.sp
		sp.vity = Math.sin(sp.a)*sp.sp
		
		// BODY TURN
		var c = sp.a/6.28 - 0.25
		while(c<0)c+=1;
		while(c>1)c-=1;
		sp.skin.gotoAndStop(string(1+int(c*58)))
		
		// COL
		checkCol(sp)
						
	}
	
	function click(){
		for( var i=0; i<sList.length; i++ ){
			var sp = sList[i]
			if( dog.getDist(sp) < BARK_RAY ){
				sp.sp = 8
			}
		}
	}
	
	
	function checkCol(sp){
		for( var i=0; i<sList.length; i++ ){
			var spo = sList[i];
			if( sp != spo ){
				var dist = sp.getDist(spo)
				if( dist < SHEEP_RAY*2 ){
					var d = (SHEEP_RAY*2-dist)*0.5
					var a = sp.getAng(spo)
					sp.x -= Math.cos(a)*d
					sp.y -= Math.sin(a)*d
					spo.x += Math.cos(a)*d
					spo.y += Math.sin(a)*d							
				}
			}
		}
	}
	
	function checkBounds(sp){
		var m = SHEEP_RAY
		
		if( sp.x < 0+m || sp.x >Cs.mcw-m ){
			  sp.x = Math.min( Math.max(m, sp.x ), Cs.mcw-m )
			evade(sp)
		}		
		
		if( sp.y < 10+m ){
			if( Math.abs((Cs.mcw*0.5)-sp.x) < DOOR_RAY[di] ){
				sp.flIn = true;
			}else{
				sp.y = Math.max ( 10+m,  sp.y )
				evade(sp)
			}
		}
		
		if( sp.y >Cs.mch-m ){
			sp.y = Math.min( sp.y, Cs.mch-m )
			evade(sp)
		}
	}
	
	function evade (sp){
		
		

		

		var wa = null
		var bda = 30000
		//Log.print("evade! "+int(sp.ta*10))
		for( var i=0; i<2; i++ ){
			var x =  sp.x+Math.cos(sp.ta)*20
			var y =  sp.y+Math.sin(sp.ta)*20
			var a = sp.ta;
			var sens = i*2-1
			while( isOut(x,y) ){
				a += 0.01*sens
				x = sp.x+Math.cos(a)*20
				y = sp.y+Math.sin(a)*20
			}
			//Log.print("--> "+int(a*10))
			var da = a-sp.ta
			while(da>3.14)da-=6.28;
			while(da<-3.14)da+=6.28;
			
			if( Math.abs(da) < Math.abs( bda) ){
				//Log.print("*")
				bda = da
				wa = a
			}
		}
		
		sp.ta = wa

		
	}
	
	function isOut(x,y){
		var fl = y<10 && Math.abs(Cs.mcw*0.5-x) > DOOR_RAY[di]
		return x<0 || x>Cs.mcw || y>Cs.mch || fl
	}

	

//{	
}










