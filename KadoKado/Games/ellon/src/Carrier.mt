class Carrier extends Bads{//}
	
	static var MARGIN = 20
	
	var run:int;
	var turn:float;
	var wTimer:float;
	
	function new(mc){
		level = 2;
		super(mc);
		
		
		ray = 10;
		hp = 1;
		frict = 0.98;
		trg  = { x:Cs.mcw-40, y:MARGIN+Math.random()*(Cs.GL-2*MARGIN)};
		turn = 0;
		wTimer = 250
		
		x = Cs.mcw+20
		y = MARGIN+Math.random()*(Cs.GL-2*MARGIN)
		
		score = Cs.SCORE_CARRIER
		gid = 3
		run = 3
		wTimer = 150
	}
	
	function update(){
		super.update();
		turn = (turn+13*Timer.tmod)%628;
		var pos = {
			x:trg.x+Math.cos(turn/100)*MARGIN
			y:trg.y+Math.sin(turn/100)*MARGIN
		}
		speedToward(pos,0.2,0.2)
		
		// TIMER
		wTimer-=Timer.tmod;
		if(wTimer <=0 ){
			if(run-->0){
			wTimer = 50+Math.random()*150
				trg={
					x:MARGIN+Math.random()*(Cs.mcw-2*MARGIN)
					y:MARGIN+Math.random()*(Cs.GL-2*MARGIN)
				}
			}else{
				wTimer = 1000
				trg={
					x:Cs.mcw+20
					y:y
				}
			}
		}
		if( run==0 && x > Cs.mcw+20 ){
			kill();
		}		
		
		checkGround();
		
	}
	
	function explode(){
		var b = new Bonus(Cs.game.mdm.attach("mcBonus",Game.DP_BONUS));
		b.x = x;
		b.y = y;
		super.explode();
	}
	


//{
}