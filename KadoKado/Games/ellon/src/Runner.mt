class Runner extends Bads{//}

	static var MARGIN = 30;

	var tx:float;
	var runFrame:float;
	var wTimer:float;
	var shotLeft:float;
	
	function new(mc){
		level = 6
		super(mc)
		ray = 11
		hp = 4
		frict = 0.98
		score = Cs.SCORE_RUNNER
		root._xscale *= -1
		
		newTrg();
		tx+=MARGIN
		x = Cs.mcw+ray+5
		y = Cs.GL-ray
		
		runFrame = 0
		
		shootRate = 1
		cooldown = 100
		shotLeft = 3
		gid = 5
		
	}
	
	function update(){
		super.update();
		var dx = tx-x;
		var lim = 2.5
		
		var vit = Cs.mm(-lim,dx*0.1,lim)
		x += vit*Timer.tmod;
		
		var speed = Math.max(0,2.5+vit*0.3)
		
		runFrame = (runFrame+speed*Timer.tmod)%40
		root.gotoAndStop(string(int(runFrame)))
		
		wTimer-=Timer.tmod
		if(wTimer<0){
			newTrg();
		}
	}
	
	function shoot(){
		shotLeft--
		if(shotLeft==0){
			cooldown = 60
			shotLeft = 3
		}else{
			cooldown = 4
		}
		var s = newAimedShot(2.5,0);
		s.setSkin(2)
		
	}
	
	function newTrg(){
		wTimer = 20+Math.random()*80
		tx = MARGIN+Math.random()*(Cs.mcw-2*MARGIN);
	}
	


//{
}