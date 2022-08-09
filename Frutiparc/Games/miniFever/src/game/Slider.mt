class game.Slider extends Game{//}
	
	// CONSTANTES
	static var RAY = 12
	static var BRAY = 8
	static var WALL = 20
	static var GRAY = 80

	// VARIABLES
	var pList:Array<{>sp.Phys,angle:float,cd:float,shadow:MovieClip}>
	//var cd:float;
	
	
	// MOVIECLIPS
	var ball:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 500;
		super.init();
		flTimeProof = false;
		airFriction = 0.92
		attachElements();
	};
	
	function attachElements(){
		
		// BALL
		ball = downcast(newPhys("mcSliderBall"))
		ball.x = Cs.mcw*0.5
		ball.y = Cs.mcw*0.5
		ball.flPhys = false;
		ball.init();
		
		// SLIDER
		pList = new Array();
		var max = 2+int(dif*0.09)
		for( var i=0; i<max; i++ ){
			var sl = downcast(newPhys("mcSlider"))
			if(i<2){
				sl.x = Cs.mcw*0.5+(i*2-1)*40
				sl.y = Cs.mch*0.5
			}else{
				sl.x = Cs.mcw-(RAY+WALL)
				sl.y = 40+((i-2)/(max-2))*(GRAY*2) + ((GRAY*2)/(max-1))*0.5
			}
			
			sl.angle = 0
			sl.cd = 0
			sl.flPhys = false;
			sl.init();
			var frame = "2"
			if(i==0){
				frame =  "1"
			}
			downcast(sl.skin).b.gotoAndStop(frame)
			pList.push(sl)
			
			sl.shadow = dm.attach("mcSliderShadow",Game.DP_SPRITE2)
			sl.shadow._x = sl.x;
			sl.shadow._y = sl.y;
			
			
		}
		

	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				moveSliders();
				moveBall();
				break;
		}

		
	}
	
	function moveSliders(){
		for( var i=0; i<pList.length; i++ ){
			var sl = pList[i]
			sl.cd -=Timer.tmod;
			{
				var mp = {x:_xmouse,y:_ymouse}
				var a = sl.getAng(mp)
				var dist = sl.getDist(mp)
				

				switch(i){
					case 6:
					case 10:
						// CORNER
						var lim = (Cs.mcw*0.5)
						var p = {
							x:Cs.mcw-(RAY+WALL)
							y:Cs.mm(Cs.mcw*0.5-GRAY,ball.y,Cs.mcw*0.5+GRAY)
						}
						a = sl.getAng(p)
						dist = sl.getDist(p)
						
						if( sl.cd<0 && ball.x > Cs.mcw-(RAY*2+WALL+6) && Math.abs(ball.y-Cs.mch*0.5) < GRAY ){
							sl.cd = 30
							var lm = 22
							sl.vity += Cs.mm( -lm, (ball.y-sl.y)*0.5, lm )
						}
						
						
						break;
					case 3:
					case 8:
						// ATTAQUANT
						sl.cd-=Timer.tmod
						a = sl.getAng(ball)
						dist = sl.getDist(ball)
						if( Math.abs(a) > 1.7 ){

							if( ball.x > 100 && Math.random()<0.02 && sl.cd<0){
								sl.angle = a
								sl.cd = 30
								var sp = 16
								sl.vitx += Math.cos(sl.angle)*sp
								sl.vity += Math.sin(sl.angle)*sp							
							}
						}else{
							var gp = {x:Cs.mcw,y:Cs.mch*0.5}
							
							var p = {
								x:ball.x*0.8+gp.x*0.2
								y:ball.y*0.8+gp.y*0.2
							}
							a = sl.getAng(p)
							dist = sl.getDist(p)							
						}
						
						break;
					default:
						// GARDIEN
						if(i==0)break;
						var gp = {x:Cs.mcw,y:Cs.mch*0.5}
						
						var p = {
							x:(ball.x+gp.x)*0.5
							y:(ball.y+gp.y)*0.5
						}
						a = sl.getAng(p)
						dist = sl.getDist(p)
						break;
				}

				
				var da = Cs.round( a-sl.angle, 3.14)
				var la = 0.5
				
				sl.angle += Cs.mm( -la, da*0.3, la )*Timer.tmod
				sl.skin._rotation = sl.angle/0.0174
				
				var speed = Cs.mm( 0, (dist-5)*0.006-Math.abs(da), 0.7 )
				
				sl.vitx += Math.cos(sl.angle)*speed*Timer.tmod;
				sl.vity += Math.sin(sl.angle)*speed*Timer.tmod;
		
				if( i==0 && sl.cd<0 && base.flPress ){
					sl.cd = 30
					var ba = sl.getAng(ball)
					sl.angle = ba
					var sp = 22
					sl.vitx += Math.cos(sl.angle)*sp
					sl.vity += Math.sin(sl.angle)*sp
					
				}
				
				
				sl.skin.gotoAndStop(string(int(speed*40)+1))
				
			}
			
			// COL SLIDER
			for( var n=0; n<pList.length; n++ ){
				var slo = pList[n]
				if(slo != sl){
					var dist = sl.getDist(slo)
					if(dist<RAY*2){
						var a = sl.getAng(slo)
						var d = RAY*2-dist
						sl.x -= Math.cos(a)*d*0.5 
						sl.y -= Math.sin(a)*d*0.5 
						slo.x += Math.cos(a)*d*0.5 
						slo.y += Math.sin(a)*d*0.5 
						
					}
					
				}
			}
			
			// COL BALL
			var dist = sl.getDist(ball)
			if(dist<RAY+BRAY){
				var a = sl.getAng(ball)
				var d = (RAY+BRAY)-dist
				ball.x += Math.cos(a)*d
				ball.y += Math.sin(a)*d
				

				
				var cyn1 = Math.sqrt(Math.pow(sl.vitx,2)+Math.pow(sl.vity,2)) 
				var cyn2 = Math.sqrt(Math.pow(ball.vitx,2)+Math.pow(ball.vity,2)) 
				var cyn =cyn1+cyn2
				//var cyn = Math.min( cyn1+cyn2, 17 )

				
				var c =   cyn2 / (cyn1+cyn2)
				
				var a2 = Math.atan2(sl.vity,sl.vitx)
				var da = Cs.round(a-a2,3.14)
				var a3 = (a2+da*c)				
				
				
				
				ball.vitx += Math.cos(a3)*cyn;
				ball.vity += Math.sin(a3)*cyn;
				
				var r = 0.1;
				if(i==0) r = 0.75;
				
				sl.vitx -= Math.cos(a3)*cyn*r;
				sl.vity -= Math.sin(a3)*cyn*r;	
				
				
				
				
				
			}
			
			
			
			//BORDS
			//*
			if(sl.x<RAY ){
				sl.x =  RAY
				sl.vitx = Math.abs(sl.vitx)
			}
			if( sl.x>Cs.mcw-(RAY+WALL)){
				sl.x = Cs.mcw-(RAY+WALL)
				sl.vitx = -Math.abs(sl.vitx)
			}
			/*/
			
			if(sl.x<RAY || sl.x>Cs.mcw-(RAY+WALL)){
				Log.print("collide ("+sl.x+")")
				sl.x = Cs.mm( RAY, sl.x, Cs.mcw-(RAY+WALL) )
				Log.print("-->("+sl.x+")")
				sl.vitx*= -1
			}
			
			//*/
			if(sl.y<RAY || sl.y>Cs.mch-RAY){
				sl.y = Cs.mm(RAY,sl.y,Cs.mch-RAY)
				sl.vity*= -1
			}
			//
			if(sl.cd>0){
				var a = dm.attach("mcSliderShade",Game.DP_SPRITE2)
				a._x = sl.x;
				a._y = sl.y;
				downcast(a).h.gotoAndStop((i==0)?"1":"2")
			}			
			
			// SHADOW
			sl.shadow._x = sl.x+5;
			sl.shadow._y = sl.y+5;
			
			
			// ACTU
			sl.skin._x = sl.x;
			sl.skin._y = sl.y;
			
		}
		
		
		
		
		
		
	}
	
	function moveBall(){
		
		
		
		
		// BORDS

		
		if(flTimeProof){
			if( Math.abs(ball.y-Cs.mch*0.5) > GRAY-BRAY ){
				ball.y = Cs.mm(Cs.mcw*0.5-GRAY,ball.y,Cs.mcw*0.5+GRAY)
				ball.vity*= -1
			}
			
			ball.vitx += 0.5*Timer.tmod
			
			
			if( ball.x > Cs.mcw+BRAY )setWin(true);
			
		}else{
			if(ball.x<BRAY  ){
				ball.x = BRAY
				ball.vitx*= -1
			}
			
			if( ball.x>Cs.mcw-(BRAY+WALL)  ){
				if( Math.abs(ball.y-Cs.mch*0.5) > GRAY-BRAY ){
					ball.x = Cs.mm(BRAY,ball.x,Cs.mcw-(BRAY+WALL))
					ball.vitx*= -1
				}else{
					flTimeProof = true
				}
				
				
			}
			
			if(ball.y<BRAY || ball.y>Cs.mch-BRAY ){
				ball.y = Cs.mm(BRAY,ball.y,Cs.mcw-BRAY)
				ball.vity*= -1
			}
		}
		
		
		// RECALAGE DE LA VITESSE DE LA BALLE
		var speed = Math.sqrt( Math.pow(ball.vitx,2)+ Math.pow(ball.vity,2) )
		var a = Math.atan2(ball.vity,ball.vitx)
		speed = Math.min(speed, 20)
		ball.vitx = Math.cos(a)*speed;
		ball.vity = Math.sin(a)*speed;
		
		
		
		// ACTU
		ball.skin._x = ball.x;
		ball.skin._y = ball.y;
		
		
	}

	
	
//{	
}













