class Grenade extends Phys{//}

	static var SPEED = 6
	static var RAY = 40
	static var DAMAGE = 8
	
	var parcouru:float;
	var max:float;
	var tx:float;
	var ty:float;
	var sx:float;
	var sy:float;
	
	
	var shadow:MovieClip;
	
	function new(mc){
		mc = Cs.game.dm.attach("mcGrenade",Game.DP_FLY)
		super(mc)
		shadow = Cs.game.dm.attach("mcGrenShade",Game.DP_SHADOW)
	}
	
	function setPos(px,py){
		sx = px
		sy = py
		x = sx
		y = sy
	}
	
	function setTrg(px,py){
		max = getDist({x:px,y:py})
		parcouru = 0
		tx = px;
		ty = py;
	}
	
	function update(){

		parcouru = Math.min((parcouru+SPEED*Timer.tmod),max)
		
		var c = parcouru/max
		
		x = sx*(1-c) + tx*c
		y = sy*(1-c) + ty*c
		shadow._x = x;
		shadow._y = y;
		y -= Math.sin(c*3.14)*(max*0.4)
		
		
		if(parcouru == max){
			var list = Cs.game.bList.duplicate();
			for( var i=0; i<list.length; i++ ){
				var sp = list[i]
				var dist = getDist(sp)
				if( dist<RAY+sp.ray ){
					sp.hit( DAMAGE, getAng(sp) )
					
				}
			}
			var mc = Cs.game.dm.attach("partOnde",Game.DP_PART)
			mc._x = x;
			mc._y = y;
			mc._xscale = RAY*2
			mc._yscale = mc._xscale
			
			mc = Cs.game.dm.attach("partExplosion",Game.DP_PART)
			mc._x = x;
			mc._y = y;
			mc._xscale = RAY*1.7
			mc._yscale = mc._xscale			
			
			kill();
			
			
			
		}
		
		super.update();

		
	}
	
	function kill(){
		shadow.removeMovieClip();
		super.kill();
	}
	

	


//{
}