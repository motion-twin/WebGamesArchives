class Blob extends Phys{//}

	static var GROUND_SPEED = 15
	static var RAY = 8
	static var WEIGHT = 0.5
	static var JUMP = 12
	
	static var JUMP_SIDE_ANGLE = 0.77
	
	var flClick:bool;
	var flMouseRelease:bool;
	var flRelease:bool;
	var flWater:bool;
	
	var step:int;
	var inst:float;
	var blop:float;
	var wet:float;
	
	var ox:float;
	var oy:float;
	var vvx:float;
	var vvy:float;
	
	var cw:Wheel;
	var wa:float;
	
	
	function new(mc){
		super(mc)
		Cs.game.focus = this; 
		flRelease = true
		flMouseRelease = true
		flWater = false
		frict = 1
		wet =  0
		vvx = 0
		vvy = 0
		
		initMouse();
	}
	
	function initMouse(){
		var ml = {
			onMouseDown:callback(this,mouseDown),
			onMouseUp:callback(this,mouseUp),
			onMouseMove:null,
			onMouseWheel:null
		}
		Mouse.addListener(ml)
	}
	
	
	function initStep(s){
		switch(step){

			case 1:	// 
				weight = 0
				frict = 1
				vx = 0
				vy = 0;
				
				break;
			case 2:
				root._rotation = 0
				Cs.game.focus = this
				vvx = 0
				vvy = 0
				break;
			
			
		}
		step = s;
		switch(step){
			case 0: // 
				vx = GROUND_SPEED;
				root.gotoAndStop("1")
				break;
			case 1:	// FLY
				weight = WEIGHT
				frict = 0.98
				blop = 0.6
				break;
			
			case 2: // GRAB
				var ba = getAng(cw)+3.14
				wa = Cs.hMod(cw.a-ba,3.14)
				root.gotoAndPlay("grab")
				inst = 0
				Cs.game.focus = {y:cw.y-Cs.VIEW_WHEEL} //upcast(cw)
				ox=x
				oy=y
				break;
			case 3:
				root.gotoAndPlay("coule")
				break;
			case 4:
				root.removeMovieClip();
				root = Cs.game.dm.attach("mcBlob",Game.DP_PART)
				root.gotoAndPlay("death")
				frict = 0.8 
				weight = WEIGHT
				break;

		}
		

		
		
	}

	function update(){
	
		switch(step){
			case 0: // 
				var m = Cs.SIDE+RAY
				if( x<m || x>Cs.mcw-m ){
					x = Cs.mm( m, x, Cs.mcw-m )
					vx = -vx
				}
				if(checkPress()){
					jump(-1.57)
				}				
				break;
			case 1: // FLY
				
				var a = Math.atan2(vy,vx)
				
				// frame
				var frame = 60+((a+3.14)/6.28)*40
				root.gotoAndStop(string(int(frame)))
				
				// check side
				var m = Cs.SIDE
				if( x<m || x>Cs.mcw-m ){
					x = Cs.mm( m, x, Cs.mcw-m )
					initStep(3)
					//vx *= -1
				} 
				
				/*
				// check ground
				if( y > 0 ){
					y = 0;
					initStep(0);
					break;
				}
				*/
				
				// blop
				blop = Math.max(0.07,blop*Math.pow(0.94,Timer.tmod))
				if(Math.random()<blop){
					var p = newPart();
					var fr = 0.4+Math.random()*0.4
					p.x += (Math.random()*2-1)*3
					p.y += (Math.random()*2-1)*3
					p.vx = vx*fr
					p.vy = vy*fr
					
					p.setScale(50+Math.random()*50 + blop*50)
					p.weight = 0.2+Math.random()*0.2
				}
				
				// water
				if(flWater){
					var fr = Math.pow(0.95,Timer.tmod)
					vx*=fr
					vy*=fr
				}
				
				//
				vvx = ox-x;
				vvy = oy-y;
				ox = x;
				oy = y
				

			

				break;
			case 2:
				var a = cw.a-wa
				x = cw.x + Math.cos(a)*cw.ray;
				y = cw.y + Math.sin(a)*cw.ray;
				root._rotation = a/0.0174
				inst = Math.min(inst+0.1*Timer.tmod,1)
				
				var body = downcast(root).bl
				var pince = downcast(root).pince
				
				if(checkPress())jump(a);
				break;
			case 3:
				
				vy += 0.6*Timer.tmod;
				vy*=Math.pow(0.92,Timer.tmod)
				if(checkPress()){
					var sens = (x<Cs.mcw*0.5)?1:-1
					jump(-1.57 + JUMP_SIDE_ANGLE*sens)
				}
				break;
			case 4:
				wet -= 0.02
				break;
				
		}
		super.update();
		if(!(Key.isDown(Key.SPACE)))flRelease = true;
		if(!flClick)flMouseRelease = true;
		
		
		checkWater();
		if(flWater){
			if(step!=4)wet += 0.015*Timer.tmod;
			//vx*=Math.pow(0.98,Timer.tmod)
			if(vy>0)vy*=Math.pow(0.9,Timer.tmod)
			if( Math.random() < wet ){
				var p = new Part( Cs.game.dm.attach("partTache",Game.DP_OIL) )
				p.x = x;
				p.y = y;
				p.vx = vx*0.5 + (Math.random()*2-1)*1
				p.vy = vy*0.5 + (Math.random()*2-1)*0.5
				p.setScale(100+wet*150+Math.random()*100)
			}
			if( Math.random() < wet ){
				var p = new Bubble(null);
				p.x = x+Math.random()*RAY;
				p.y = y+Math.random()*RAY;
				p.vy = vy*0.8//-Math.random()*2

			}			
		}else{
			if(wet>0){
				wet = Math.max(0,wet-0.02*Timer.tmod);
				
				if( Math.random()*0.5 < wet ){
					var coef = 0.2+Math.random()*0.4
					var p = new Part( Cs.game.dm.attach("partGoutte",Game.DP_OIL) )
					p.x = x + (Math.random()*2-1)*6;
					p.y = y + (Math.random()*2-1)*6;
					p.vx = (vvx+vx)*coef
					p.vy = (vvy+vy)*coef
					p.timer = 10+Math.random()*10
					p.fadeType = 0
					p.setScale(60+wet*80+Math.random()*50)
				}
			}
			
		}
		
		
	}

	function checkDeath(){
		if(wet>1){
			initStep(4)
			Cs.game.initStep(9)
		}

	}
	
	function checkWater(){
		var flw = y-RAY > Cs.game.water._y

		if(flWater){
			if(!flw){
				Cs.game.stats.$pl++
			}
		
		}else{
			if(flw){
				
			}
		}

		flWater = flw
	}
	
	function jump(a){
		Cs.game.stats.$jp++
		flRelease = false
		flMouseRelease = false
		var max = 4
		for( var i=0; i<max; i++ ){
			var dec = Math.random()*2-1
			var na = a + dec*0.8
			var sp = 8-Math.abs(dec)*6
			var c = i/max
			var p = newPart();
			p.vx = Math.cos(na)*sp
			p.vy = Math.sin(na)*sp
			p.setScale(50+c*100);
			p.timer = 10+Math.random()*30
			p.weight = 0.2+c*0.2
			
		}
	
		vx = Math.cos(a)*JUMP
		vy = Math.sin(a)*JUMP			
		initStep(1)
		cw = null;
	
	}
	
	function newPart(){
		var p = new Part( Cs.game.dm.attach("partOil",Game.DP_OIL) )
		p.x = x
		p.y = y
		p.timer= 10+Math.random()*10
		p.fadeType = 0;
		return p;
	}
	
	function explode(ba){
		var max = 32
		for( var i=0; i<max; i++ ){
			var dec = Math.random()*2-1
			var na = ba + dec*0.8
			var sp = (14-Math.abs(dec)*8) * (0.3+Math.random()*0.7)
			var c = i/max
			var p = newPart();
			p.vx = Math.cos(na)*sp
			p.vy = Math.sin(na)*sp
			p.setScale(50+c*150);
			p.timer = 10+Math.random()*20
			p.weight = 0.2+c*0.2
		}
		Cs.game.initStep(9)
		initStep(5)
		kill();
	}
	
	function mouseDown(){
		flClick = true;
	}
	function mouseUp(){
		flClick = false;
	}
		
	function checkPress(){
		return (flRelease && Key.isDown(Key.SPACE)) || (flClick && flMouseRelease)
	}
	
//{
}

// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600
// #339900 | #FFFFFF | #EE6600













