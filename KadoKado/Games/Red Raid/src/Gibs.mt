class Gibs extends Part{//}

	var flDropBlood:bool;
	
	var z:float;
	var vz:float;
	var wz:float;
	
	var shadow:MovieClip;
	
	function new(mc){
		flDropBlood = false
		if(mc==null){
			flDropBlood = true
			mc = Cs.game.dm.attach("partAlien",Game.DP_PART);
		}
		super(mc)
		shadow = Cs.game.dm.attach("mcGrenShade",Game.DP_SHADOW)
		shadow._alpha = 50
		z = 0;
		vz = 0;
		wz = 1
	}
	function setScale(sc){
		super.setScale(sc)
		shadow._xscale = sc*0.8;
		shadow._yscale = sc*0.8;
	}

	function update(){
		super.update();
		shadow._x = x;
		shadow._y = y;
		shadow._alpha = root._alpha*0.5
		
		vz -= wz*Timer.tmod;
		vz *= frict
		z += vz*Timer.tmod;
		
		
		
		if(z<0){
			z = 0
			vz *= -0.8
		}
		
		root._y -= z
		
		var c = 0.5;
		if( flDropBlood && Math.random()/Timer.tmod < 0.2 ){
			var p = new Part(Cs.game.dm.attach("partBlood",Game.DP_PART))
			p.x = root._x+(Math.random()*2-1)*5;
			p.y = root._y+(Math.random()*2-1)*5;
			p.vx = vx*c
			p.vy = vy*c
			p.setScale(30+Math.random()*70)
			p.timer = 10+Math.random()*10
			p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
			p.fadeType = 0
			
			
		}
		
	}
	
	function kill(){
		shadow.removeMovieClip();
		super.kill();
	}
//{
}