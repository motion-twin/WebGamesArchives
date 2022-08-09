class game.PopBalloon extends Game{//}
	
	// CONSTANTES
	static var RAY = 16
	// VARIABLES
	var wCount:int;
	var wind:float;
	var wx:float;
	var wy:float;
	var bList:Array<sp.Phys>
	var wList:Array<sp.Phys>
	var next:sp.Phys;
	
	// MOVIECLIPS


	function new(){
		super();
	}

	function init(){
		gameTime = 240
		super.init();
		wCount = 1
		attachElements();
		selectNext();
	};
	
	function attachElements(){
		
		var cs = 1 
		var ray = 30*cs
		var speed = 0.1 + dif*0.005
		var p = {
			va:0
			a:Math.random()*6.28
			x:Cs.mcw-2*ray,
			y:Cs.mch-2*ray,
		}
		
		var max = 8+dif*0.2
		bList = new Array();
		for( var i=0; i<max; i++ ){
			
			var sp = newPhys("mcBalloon")
			var a = Math.random()*6.28
			sp.x = p.x;			
			sp.y = p.y;
			sp.vitx += Math.cos(a)*Math.random()*speed
			sp.vity += Math.sin(a)*Math.random()*speed
			sp.flPhys = false;
			sp.skin.stop();
			sp.init();
			
			bList.push(sp)
			
			p.va += (Std.random(2)*2-1)*0.25
			p.va *= Math.pow(0.9,Timer.tmod)
			p.a += p.va*Timer.tmod;
			var vx = Math.cos(p.a)*ray
			var vy = Math.sin(p.a)*ray
			p.x += vx
			p.y += vy
			
			if( p.x < ray || p.x > Cs.mcw-ray ){
				p.x = Cs.mm( ray, p.x, Cs.mcw-ray )
				vx *= -1
				p.a = Math.atan2(vy,vx)
			}
			if( p.y < ray || p.y > Cs.mch-ray ){
				p.y = Cs.mm( ray, p.y, Cs.mch-ray )
				vy *= -1
				p.a = Math.atan2(vy,vx)				
			}
		}
	}
	
	function update(){
		switch(step){
			case 1:
				// CHECK HIT
				var mp = {x:_xmouse,y:_ymouse}
				var d = next.getDist(mp)
				if( d < RAY ){
					var p = newPart("partBalloonBurst")
					p.x = next.x
					p.y = next.y
					p.flPhys = false
					p.skin._rotation = Math.random()*360
					p.init();
					
					next.kill()
					bList.pop();
					if(bList.length>0){
						selectNext();
					}else{
						next = null;
						setWin(true)
					}
					
				}
				
				// CHECK COL
				for( var i=0; i<bList.length; i++ ){
					var b = bList[i];
					if( b.x < RAY || b.x > Cs.mcw-RAY ){
						b.x = Cs.mm( RAY, b.x, Cs.mcw-RAY )
						b.vitx *= -1
					}
					if( b.y < RAY || b.y > Cs.mch-RAY ){
						b.y = Cs.mm( RAY, b.y, Cs.mch-RAY )
						b.vity *= -1
	
					}
				}
				
				// WIND
				if(wind == null ){
					if( Std.random( int( ((30-dif*0.1)*wCount)/Timer.tmod ) )==0 ){
						wind = 0
						var a = Math.random()*6.28
						var speed = 0.4+dif*0.02
						wx = Math.cos(a)*speed
						wy = Math.sin(a)*speed
						wList = bList.duplicate();
						wCount++
					}
				}else{
					wind += 10*Timer.tmod;
					for( var i=0; i<wList.length; i++ ){
						var b = wList[i]
						if( b.x+b.y < wind ){
							b.vitx += wx;
							b.vity += wy;
							wList.splice(i--,1)
						}
					}
					if(wList.length == 0 )wind = null;
				}
				
				break;
		}
		super.update();
	}
	
	
	
	
	
	function selectNext(){
		next = bList[bList.length-1]
		next.skin.gotoAndStop("2")
	}
	
	

//{	
}

