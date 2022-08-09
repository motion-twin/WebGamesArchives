class ac.piou.GumBridge extends ac.Piou{//}
	
	static var EXT = 200
	static var RAY_MIN = 20
	static var SPEED = 12
	
	var piv:MovieClip
	var angle:float;
	var parc:float;
	var by:float;
	var sens:int;
	
	var mid:MovieClip
	var st:MovieClip
	var en:MovieClip
	
	var trg:MovieClip;
	var wp:void->void
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("look")
		piv = downcast(piou.root).sub.piv
		piv.stop();
		wp = callback(this,launch)
		Cs.game.waitPress.push(wp);
		step = 0;
		
		trg = Cs.game.dm.attach( "mcTarget", Game.DP_PART )
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 0:
				var dx = Cs.game.map._xmouse - piou.x;
				var dy = Cs.game.map._ymouse - piou.y;
				angle = Math.atan2(dy,dx)
			
				if(dx*piou.sens<0){
					piou.reverse();
				}
				if(dy>0){
					piv._rotation = 0
				}else{
					if(dx<0){
						piv._rotation = - (3.14+angle)/0.0174
					}else{
						piv._rotation = angle/0.0174
					}
				}
				
				var dist = 32
				trg._x = piou.x + Math.cos(angle)*dist
				trg._y = piou.y + Math.sin(angle)*dist - Piou.RAY
				
				break;
			case 1:
				for( var i=0; i<SPEED; i++ ){

					parc += sens
					en._x = parc;
					mid._xscale = parc;
					
					
					var c = Math.pow((parc/EXT),0.5)
					
					var sc = 100-c*(100-RAY_MIN)
					
					st._xscale = sc
					st._yscale = sc
					mid._yscale = sc
					en._xscale = sc
					en._yscale = sc
					
					var y = - Piou.RAY +  (2+Piou.RAY*c*(1-RAY_MIN/100))
					piou.y = by+y*gs
					
					//
				
					
					//
					var px = piou.x+Math.cos(angle)*parc
					var py = piou.y+Math.sin(angle)*parc
					
					if(parc==0){
						go()
						piou.y = by
						piou.updatePos();
						kill();
						break;
					}else if(!Level.isFree(px,py)){
						if(parc>16){
							// PART
							var ray = 10
							for( var n=0; n<10; n++ ){
								var a = Math.random()*6.28
								var ca = Math.cos(a)
								var sa = Math.sin(a)
								var sp = 0.5+Math.random()*1.5	
								var p = piou.getGib(px+ca*ray,py+sa*ray);
								p.vx  = ca*sp
								p.vy  = sa*sp
							}
							
							//
							Level.drawMC(piou.root)
							piou.die();
							kill();
							
							break;
						}else{
							sens=-1
						}
					}else if(parc>EXT){
						sens*=-1
					}
				}
				
				
				break;
		}
		
	}	
	
	function launch(){
		var dx = Cs.game.xm - piou.x;
		var dy = Cs.game.ym - piou.y;
		angle = Math.atan2(dy,dx)		
		var a = Math.atan2(Math.sin(angle),Math.cos(angle)*piou.sens)
		
		
		piou.root.gotoAndStop("gumBridge")
		var mc = downcast(piou.root).sub
		st = mc.st;
		mid = mc.mid;
		en = mc.en;
		mc._rotation = a/0.0174;
		mid._xscale = 0 
		en._rotation = a/0.0174;
		en._x = 0
		en.stop();
		
		by = piou.y
		piou.y -= Piou.RAY
		piou.updatePos();
		
		step = 1
		sens = 1
		//Cs.game.waitPress.remove(wp);
		parc = 0
		
		//
		piou.gerb(angle,0.5,5,5)
		trg.removeMovieClip();
		trg = null;
		
	}

	function interrupt(){
		Cs.game.waitPress.remove(wp)
		//Cs.game.waitPress = null;
		super.interrupt();
	}
	
	
	function onReverse(){
		super.onReverse();
		var dx = Math.cos(angle)
		var dy = Math.sin(angle)
		angle = Math.atan2(-dy,dx)
		by = Cs.gry(by)
		downcast(piou.root).sub._rotation = angle/0.0174;
	}
	
	function kill(){
		if(trg!=null)trg.removeMovieClip();
		super.kill()
	}
	
//{
}