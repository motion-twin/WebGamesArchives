class ac.piou.Grenade extends ac.Piou{//}

	static var POWER = 8
	
	var grenade:bnc.Grenade;
	
	
	var piv:MovieClip
	var angle:float;
	

	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		step = 0
		//
		var dy = -Piou.RAY
		while(!Level.isFree(int(piou.x),int(piou.y+dy)) ){
			dy++
			if(dy>0){
				go();
				kill();
				return;
			}
			
		}		
		///
		grenade = new bnc.Grenade(Cs.game.dm.attach("mcGrenade",Game.DP_PIOU))
		grenade.timer = 60
		grenade.ray = 40
		grenade.bouncer.px = int(piou.x) 
		grenade.bouncer.py = int(piou.y+dy)
		grenade.vx = 0//Math.cos(a)*POWER
		grenade.vy = -2//Math.sin(a)*POWER
		
		//
		go();
		kill();
		
	}
	
	

	
//{
}