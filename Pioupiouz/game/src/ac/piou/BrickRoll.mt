class ac.piou.BrickRoll extends ac.Piou{//}

	static var SPIT_TEMPO = 18
	
	var sens:int;
	var ammo:int;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("brickRoll")
		timer = 10
		sens = piou.sens
		ammo = 14
	}
	
	function update(){
		super.update();
		if(timer<0){
			timer = SPIT_TEMPO
			downcast(piou.root).sub.gotoAndPlay("spit")
			/*
			var sp = new Phys(Cs.game.dm.attach("mcBrickRoll",Game.DP_PART))
			sp.x = piou.x+sens*5;
			sp.y = piou.y-7;
			sp.vx = sens*3
			sp.vy = -2
			sp.flOrient = true;
			sp.weight = 0.3
			sp.bouncer = new Bouncer(sp)
			sp.bouncer.onBounceGround = callback(this,groundCol,sp)
			*/
			var sp = new sp.BrickRoller(null);
			sp.bouncer.px = int(piou.x+sens*5)
			sp.bouncer.py = int(piou.y - 8)
			sp.vx = sens*3
			sp.vy = -2
			
			ammo--
			if(ammo==0){
				if(piou!=null)
				kill();
			}
			
			
		}
	}
	/*
	function groundCol(sp){
		var br = new sp.BrickRoller(null);
		br.x = sp.bouncer.px + sp.bouncer.ox //sp.x
		br.y = sp.bouncer.py + sp.bouncer.oy //sp.y;
		var sn = Math.round(sp.vx/Math.abs(sp.vx))
		//br.setSens(sn)
		//br.sens = sn
		//br.side = -sn
		//br.angle = sp.root._rotation*0.0174
		br.setSens(sens)
		sp.kill();
	}
	*/
	
	function interrupt(){
		super.interrupt()
	}
	

	
//{
}