class game.Acrobate extends Game{//}
	
	// CONSTANTES
	static var INTERVAL = 50
	static var GL = 220
	static var RAY = 10
	static var DX = 70
	static var DRAY = 17
	static var RUN = 3
	static var POWER = 8
	
	// VARIABLES
	var objectif:int;
	var qdec:float;
	var decal:float;
	var timer:float;
	var last:int;
	var aList:Array<{>sp.Phys,step:int,sens:int,side:int,pos:int,flReject:bool}>
	
	// MOVIECLIPS
	var dalle:MovieClip;
	var arrow:MovieClip;

	function new(){
		super();
	}

	function init(){
		
		gameTime = 500
		super.init();
		aList = new Array();
		timer = 0;
		qdec = 0
		objectif = 1+Math.floor(dif*0.09)
		attachElements();
	};
	
	function attachElements(){
			
		// DALLE
		dalle._x = DX
		
		//
		var y =  -18
		var d = new DepthManager(dalle)
		for( var i=0; i<objectif; i++){
			var mc = d.attach("mcAcrobateShade",Game.DP_SPRITE)
			mc._y = y
			y -= 2*RAY
			
		}
		
	}
	
	function update(){
		super.update();
		timer-=Timer.tmod;
		if(timer<0){
			timer = INTERVAL
			genApple();
		}
		
		moveApple();
		
		
		if( last == objectif-1 )setWin(true)
		switch(step){
			case 1:
				break;
		}
		
		
	}
	
	function genApple(){
		var sp = downcast(newPhys("mcRunningApple"))
		sp.x = Cs.mcw + RAY
		sp.y = GL-RAY
		sp.flPhys = false;
		sp.step = 0;
		sp.sens = -1
		sp.side = 1
		sp.weight = 0.5
		sp.init();
		aList.push(sp)
		
	}
	
	function moveApple(){
		var flSeekJumper = step == 1
		var list = new Array();
		for( var i=0; i<aList.length; i++ ){
			var sp = aList[i];
			
			switch(sp.step){
				
				case 0: // RUNNING
				
					sp.x += sp.sens*RUN*Timer.tmod;
					var m = 30
				
					if( sp.sens==-1 && sp.side == 1 && sp.x < DX+DRAY+RAY ){
						sp.x = DX+DRAY+RAY 
						sp.sens = 1
						sp.skin._xscale = -100
					}
				
					// CHECK JUMP
					if(  flSeekJumper && base.flPress && sp.sens ==-1 && sp.x > DX+m && sp.x < Cs.mcw-m ){
						step = 2
						sp.step = 1
						decal = 314
						arrow = dm.attach("mcAcrobateOrient",Game.DP_SPRITE)
						arrow._x= sp.x;
						arrow._y= sp.y;
						arrow._rotation = -180
						flSeekJumper = false
						sp.skin.gotoAndPlay("prepare")
						sp.vitx = -RUN
					}
					
					
					
					
					
					break;
					
				case 1: // PREPARE JUMP
					sp.vitx *= Math.pow(0.8,Timer.tmod)
					decal = (decal+12*Timer.tmod)%628
					var angle = 3.14+(0.77+Math.cos(decal/100)*0.77)
					arrow._x= sp.x;
					arrow._y= sp.y;
					arrow._rotation = angle/0.0174
					if(!base.flPress){
						sp.skin.gotoAndPlay("fly")
						step = 1
						sp.step = 2
						sp.flPhys = true;
						var p = POWER
						if(last!=null)p+=last*1.5
						sp.vitx += Math.cos(angle)*p
						sp.vity += Math.sin(angle)*p
						arrow.removeMovieClip();
						arrow = null;
					}
					
					
					
					break;
				case 2: // FLYING
					
					// ORIENT
					sp.skin._rotation = (Math.atan2(sp.vity,sp.vitx)/0.0174) + 180*(sp.sens-1)*0.5
					
					
					// CHECK GROUND
					if( sp.y > GL-RAY ){
						sp.y = GL-RAY
						sp.vitx = 0
						sp.vity = 0
						sp.flPhys = false;
						sp.flReject = false;
						sp.step = 0;
						sp.side = (sp.x<DX)?-1:1;
						sp.skin.gotoAndPlay("1")
						sp.skin._rotation = 0
					}
					
					// CHECK COLLIDE
					if(last==null){
						if( sp.vity > 0 && Math.abs(DX-sp.x)<DRAY && sp.y > GL-((2*RAY)+4) ){
							land(sp)
							break;
						}
					}else{
						for( var n=0; n<aList.length; n++ ){
							var spo = aList[n]
							if(spo.pos!=null){
								var dist = sp.getDist(spo)
								if( dist < (2*RAY*1.2) ){
									if(last==spo.pos && sp.y < spo.y ){
										land(sp)
										break;
									}else{
										if(!sp.flReject){
											sp.sens*=-1
											sp.vitx*=-1
											var a = spo.getAng(sp)
											var d = 2*RAY - dist
											sp.x += Math.cos(a)*d
											sp.y += Math.sin(a)*d
											sp.flReject = true;
											sp.skin._xscale = -sp.sens*100
											
										}
										break;
									}
								}
							}
						}
					}

					break;
				case 3: // QUEUE
					list[sp.pos] = sp;
					
					if( !sp.flReject && Math.random()*Timer.tmod<0.02 ){
						if(sp.pos==0){
						
						}else{
							sp.skin.gotoAndPlay("$anim"+Std.random(6))
							sp.flReject = true;
						}
					}
					
					break;
					
					
			}
			
			sp.skin._x = sp.x
			sp.skin._y = sp.y
			
		}
		
		// QUEUE
		qdec = (qdec+8*Timer.tmod)%628
		var next = {
			x:DX,
			y:GL-23
		}
		var a = Math.cos(qdec/100)*0.05//0.02//0.016//*0.012
		var angle = -1.57
		for( var i=0; i<list.length; i++ ){
			var sp = list[i]
			sp.x = next.x;
			sp.y = next.y;
			sp.skin._rotation = angle/0.0174 + 90
			next.x += Math.cos(angle)*2*RAY
			next.y += Math.sin(angle)*2*RAY
			angle += a
			a *= 1.23
		}
		
		
		
		
	}
	
	function land(sp){
		//Log.trace(last)
		var frame = 2
		if(last==null){
			last=0
			frame = 1
		}else{
			last++
		}
		sp.pos = last;
		sp.step = 3
		sp.vitx = 0
		sp.vity = 0
		sp.flPhys = false;
		sp.skin.gotoAndPlay("base")
		//downcast(sp.skin).shoes.gotoAndStop(string(frame))
		downcast(sp.skin).fs = frame;
	}
	
	
	
//{	
}

