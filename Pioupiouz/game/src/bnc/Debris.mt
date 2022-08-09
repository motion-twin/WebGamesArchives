class bnc.Debris extends Phys{//}

	var fadeLimit:float;
	var timer:float;
	
	function new(mc){
		if(mc==null)mc=Cs.game.dm.attach("mcDebris",Game.DP_PIOU);
		super(mc)
		bouncer = new Bouncer(this)
		frict = 0.98
		bouncer.frict = 0.4
		weight = 0.1+Math.random();
		fadeLimit = 10
	}
	
	function update(){
		super.update()
		timer -= Timer.tmod;
		if(timer<fadeLimit){
			root._alpha = 100*timer/fadeLimit
			if(timer<0){
				kill();
			}
		}
		
	}

	
//{
}