class LevelElement extends Phys{//}
	
	var step:int;
	
	function new(mc){
		super(mc)
		Cs.game.eList.push(this)
		Cs.game.blastList.push(this)
		frict = 0.97
		initStep(0)
	}

	function initStep(n:int){
		switch(step){
			case 0:
				//removeBouncer();
				
				bouncer.parc = 0
				bouncer.ox = 0
				bouncer.oy = 0
				x = bouncer.px
				y = bouncer.py
				bouncer = null
				vx = 0;
				vy = 0;
				weight = 0
				break;
		}
		step = n
		switch(step){
			case 0:
				bouncer = new Bouncer(this)
				bouncer.onBounceGround = callback(this,initStep,1)
				weight = 0.3
				break;
			case 1:
				onLand();
				break;
		}
	}
	
	function update(){
		super.update();
		if(step==0)checkLim();
	}
	
	function onLand(){
	
	}
	
	function checkLim(){
		if(isOut(0))kill();
	}
	
	function kill(){
		Cs.game.eList.remove(this)
		Cs.game.blastList.remove(this)
		super.kill();
	}
	
	function onBlast(x,y){
		if(step!=0)initStep(0);
	}

	
	
//{
}