class ac.piou.Jump extends ac.Piou{//}


	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		//piou.initStep(Piou.FALL)
		piou.initStep(Piou.FLY)
		piou.vx = (3.5+piou.speed)*piou.sens
		piou.vy = -6
		piou.root.gotoAndStop("jump")
		piou.bouncer.onBounce = callback(this,bang)
	}
	
	
	function update(){
		super.update();
		piou.root._rotation = piou.vy*10*piou.sens
		/*
		if( piou.step != Piou.FLY ){
			kill();
		}
		*/
	}	
	
	function bang(){

		var ovy = piou.vy
		piou.initStep(Piou.FALL)
		piou.root._rotation = 0
		if(ovy>=Piou.FALL_DEATH_LIMIT)piou.vy = ovy;

		kill();
		
	}
	
	function kill(){
		super.kill();
	}
	
//{
}