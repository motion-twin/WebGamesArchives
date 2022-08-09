class Tanker extends Runner{//}

	
	
	function new(mc) {
		super(mc);
		stLevel=3
		hp =  50
		score = Cs.C300
		stClimbWait = 12//16
		stTossClimb = 6//12
		stTossSmart = 2
		stClimb = 36;
		speed=4
		stDrop.push({w:40,id:1})
		stDrop.push({w:10,id:2})
		stDrop.push({w:30,id:5})
		score = Cs.C100
		
	}
/*
	function initStep(n){
		super.initStep(n)
		switch(step){
			case Cs.ST_NORMAL:
				if(!flWalk){
					flWalk = true;
					root.gotoAndPlay("walk")
				}
				break;
			case Cs.ST_FLY:
				flGround = false;
				break;			
			case Cs.ST_CLIMB:
				root.gotoAndPlay("climb")
				break;
		}
	}

	function update() {
		super.update();
		switch(step){
			case Cs.ST_NORMAL:
				var dvx = sens*speed - vx
				var lim = 0.5
				vx += Math.min(Math.max(-lim,dvx),lim)*Timer.tmod 
				break;
			case Cs.ST_FLY:
				if(flFlyUp && vy>0 ){
					flFlyUp = false;
					root.gotoAndPlay("fly_down")
				}
				break;					
		}
		
	}
	*/
	
	
	// ON
	
	function hit(shot){
		if(step==Cs.ST_NORMAL){
			if(shot.vx*sens<0){
				var p = Cs.game.newPart("mcNinjaShot")
				p._x = shot.root._x;
				p._y = shot.root._y;
				p.gotoAndStop(Cs.game.optList[Cs.OPT_FLAMES]?"2":"1")
				p.vx = -shot.vx*0.75
				p.vy = shot.vy - 3
				p.t = 20+Math.random()*10
				p.weight = 0.4
				return;
			}
		}
		super.hit(shot)
	}
	
	function cut(n){
		if( (Cs.game.hero.x-x)*sens<0 ){
			super.cut(n)
		}else{
			throw(1.57-(1.57*Cs.game.hero.sens),12)
		}
		
		
	}
	
	function throw(a,p){
		if(flGround && hp>0){
			root.gotoAndStop("walk_loop")
		}
		super.throw(a,p)
	}

	function crossSquare(){
		super.crossSquare();

		
		
		if( Cs.game.checkFree(x+sens,y+1) ){
			

			if(isSmart()){
				var dif = Cs.game.hero.x-x;
				if(Cs.game.hero.y<=y+3 && int(dif/Math.abs(dif))!=sens ){
					setSens(-sens)
				}
				
			}else{
				if(Math.random()<0.7)setSens(-sens);

				
			}
	
		}
	}


//{
}








