class game.Egg extends Game{//}
	
	// CONSTANTES
	var ray:float;
	var gl:float;
	
	// VARIABLES
	var flGround:bool
	var flMiss:bool;
	var flStop:bool
	var px:float;
	var angle:float;
	var decal:float;
	var index:int;
	var pList:Array<{>Sprite,width:float,vitr:float}>
		
	// MOVIECLIPS
	var egg:sp.Phys;
	var nid:MovieClip;
	var bg:{>MovieClip,p1:MovieClip,p2:MovieClip,p3:MovieClip,p4:MovieClip};
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 400;
		super.init();
		ray = 7;
		flGround = false;
		flMiss = false;
		angle = 0;
		decal = 0;
		index = 0;
		gl = Cs.mch-8
		attachElements();
		
	};
	
	function attachElements(){

		
		// NID
		nid = dm.attach("mcNid",Game.DP_SPRITE)
		nid._y = gl;
		
		//* POUTRES
		var last = {x:Cs.mcw*0.5,width:50}
		var max = 3
		pList = new Array();
		for( var i=0; i<max; i++ ){
			var sp = Std.cast(newSprite("mcPoutre"))
		
			var w = 0;
			var x = 0;
			var y = 0;
			
			
			while(true){
				w = 80-(dif*0.4)
				w+= Math.random()*w*0.5
				x = w*0.5 + Math.random()*(Cs.mcw-w)
				y = 50 + (Cs.mch-50)*(i/max)
				var dx = Math.abs(x-last.x)
				if( dx > (last.width-w)+50-dif*0.3 && dx < (last.width+w)*0.5 ) break;
			}
			
			
			sp.width = w
			sp.vitr = 0
			sp.x = x
			sp.y = y
			
			// SIZE
			var free = sp.skin//downcast(sp.skin)
			free.b.mask._xscale = sp.width-4
			free.b._x = -(sp.width-4)*0.5
			free.s0._x = free.b._x
			free.s1._x = -free.b._x			

			sp.init();
			last = upcast(sp)
			pList.push(Std.cast(sp))		
			
		}
		
		var dec = 20
		if( last.x > Cs.mcw*0.5 ){
			nid._x = last.x - (dec+last.width*0.5);
		}else{
			nid._x = last.x + (dec+last.width*0.5);
		}
		
		
		//*/
		
		// EGG
		egg = newPhys("mcEgg")
		egg.x = pList[index].x
		egg.y = pList[index].y-10
		egg.skin.stop();
		egg.init();
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1: 

				// ROTATE NEXT
				var next = pList[index]
				var ta = ((_xmouse/Cs.mcw)*2-1)*0.6
				var da = ta - angle
				angle += da*0.15*Timer.tmod
			
				next.skin._rotation = angle/0.0174
			
				// MOVE EGG
				decal = decal+egg.vitx*12
				while( decal > 314 ) decal -= 628
				while( decal < -314 ) decal += 628
			
				egg.skin._rotation = (decal/100)/0.0174
				downcast(egg.skin).light._rotation = -egg.skin._rotation
				
				var r = ray;
				var brake = 0;
			
				if( decal > 157 || decal < -157 ){
					var c = Math.abs(decal/157)-1
					r += r*c*0.65
					if(flGround)egg.vitx  -= (decal/157)*0.1;
				}
			
				if(!flGround){
					var ca = Math.sin(angle) / Math.cos(angle)
					var cb = next.y - ca*next.x
					var x = egg.x
					var y = egg.y+ray
				
					if( y > ca*x + cb ){
						if( next.getDist({x:x,y:y}) < next.width*0.5 ){
							
							if(flMiss){
								breakEgg();
								egg.vity *= - 0.2
							}else{
								land();
							}
						}else{
							setNext();
							flMiss = true;
						}
					}
					
					if( y > gl ){
						egg.flPhys = false;
						egg.y = gl-r*0.5
						egg.vitx = 0;
						egg.vity = 0						
						if( Math.abs( x - nid._x ) < 10 ){
							var mask = dm.attach("mcNidMask",Game.DP_SPRITE)
							mask._x = nid._x
							mask._y = nid._y
							egg.skin.setMask(mask)
							
							setWin(true);
							step = 2;
						}else{
							breakEgg();
						
						}
					}
				}
			
			
				if(flGround){
					egg.vitx += angle;
					egg.vitx *= Math.pow(0.92,Timer.tmod);

					
					var dist = egg.getDist(next);
					if( dist < next.width*0.5 ){
					
						var dx = egg.x-next.x
						var ds = dx/Math.cos(angle)
						
						var y = Math.sin(angle)*ds
						
						egg.y = (next.y + y)-r
					}else{
						initFall();
						setNext();
					}
				}
				
				// MOVE PLATEFORME
				for( var i=0; i<index; i++){
					var p = pList[i]
					p.vitr += -p.skin._rotation*0.05*Timer.tmod
					p.vitr *= Math.pow(0.95,,Timer.tmod)
					p.skin._rotation += p.vitr
				}
				
			

				break;
			
		}
		//
		egg.skin._x = egg.x
		egg.skin._y = egg.y
		
	}

	
	function land(){
		flGround = true;
		egg.flPhys = false;
		egg.vity = 0
	}
	
	function initFall(){
		//egg.vitx *= 1.1
		//egg.vitx += speed * pList[index].sens * 0.5
		flGround = false;
		egg.flPhys = true;
		
	}
	
	function setNext(){
		index++;
		angle = 0;
	}
	
	function breakEgg(){
		step = 3;
		egg.skin.gotoAndPlay("break")
		bg.p1.gotoAndStop("2")
		bg.p2.gotoAndStop("2")
		bg.p3.gotoAndPlay("2")
		bg.p4.gotoAndStop("2")
		setWin(false)
		
	}
	
//{	
}


