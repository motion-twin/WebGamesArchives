class Runner extends Monster{//}

	
	var flFlyUp:bool
	var flStraight:bool
	var flWalk:bool
	var speed:float;
	
	function new(mc) {
		super(mc);

		
		setSens(Std.random(2)*2-1)
		
		flWalk=true;
		stClimbWait = 26
		
		initStep(Cs.ST_FLY)
		
	}
	

	function initStep(n){
		super.initStep(n)
		switch(step){
			case Cs.ST_NORMAL:
				if(!flWalk){
					flWalk = true;
					nextAnim = "walk"
				}else{
					nextAnim = "walk_loop"
				}
				break;
			case Cs.ST_FLY:
				flGround = false;
				break;			
			case Cs.ST_CLIMB:
				nextAnim = "climb"
				break;
			case Cs.ST_SHOOT:
				nextAnim = "shootWait"
				break;				
		}
	}

	function update() {
		super.update();
		switch(step){
			case Cs.ST_NORMAL:
				var dvx = sens*speed - vx
				var lim = 0.5
				vx += Math.min(Math.max(-lim,dvx*0.2),lim)*Timer.tmod 
				/*
				var list = Cs.game.grid[x][y].list
				if(list.length>1){
					
					for( var i=0; i<list.length; i++ ){
						var m = list[i]
						if(m!=this && m.sens == sens && m.step == Cs.ST_NORMAL){
							var dx =m.root._x - root._x
							if(Math.abs(dx)<24){
								vx -= 2*dx/Math.abs(dx)
							}
						}
					}
				}
				*/
				break;
			case Cs.ST_FLY:
				if(flFlyUp && vy>0 ){
					flFlyUp = false;
					if(flStraight){
						nextAnim = "fly_straight_down"
						flStraight = false;
					}else{
						nextAnim = "fly_down"
					}
				}
				break;					
		}
		
	}
	

	function jumpFront(dist){
		super.jumpFront(dist)
		flStraight = true;
		flFlyUp = true;
		nextAnim = "fly_straight_up"
	}
	
	function throw(a,p){
		if(flGround && hp>0){
			root.gotoAndStop("walk_loop")
		}
		super.throw(a,p)
	}
	//
	
	function climb(){
		super.climb();
		root.gotoAndStop("fly_up")
		flFlyUp = true;
		flWalk = false
	}
	
	function land(){
		super.land()
		chooseWay();

	}

	function death(){
		//Cs.game.spawnBonus(x,y)
		root.gotoAndPlay("death")
		super.death();
	}
	
//{
}








