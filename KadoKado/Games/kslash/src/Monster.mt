class Monster extends Ent{//}

	// STATS
	var stClimb:int;
	var stDrop:Array<{w:int,id:int}>
	var stLevel:int;
	var stTossClimb:int;
	var stTossSmart:int;
	var stTossShoot:int;
	var stClimbWait:float;
	var stShootWait:float;
	var score:KKConst;
	
	// VARIABLES

	var flClimbAnim:bool;
	var flSpike:bool;
	
	var hp:float;
	var waitTimer:float;
	var flash:float;
	
	
	function new(mc) {
		super(mc);
		Cs.game.mList.push(this)
		
		
	
		stTossSmart = 10
		flSpike = false;

		stDrop = [
			{ w:100,id:1 }
			{ w:20,	id:2 }
			{ w:1,	id:3 }
		]
		
		
		hp = 10
		score = Cs.C0;
		stClimb = 21;
		
		initStep(Cs.ST_FLY)
	}

	function initStep(n){
		step = n
		switch(step){
			case Cs.ST_NORMAL:
				break;
			case Cs.ST_FLY:
				flGround = false;
				break;			
			case Cs.ST_CLIMB:
				
				flClimbAnim = false
				waitTimer=stClimbWait;
				vx = 0;
				break;
			case Cs.ST_SHOOT:
				waitTimer=stShootWait;
				vx = 0;
				break;
		}
	}
	
	function update() {
		super.update();
		switch(step){
			case Cs.ST_NORMAL:
				break;
			case Cs.ST_FLY:
				break;			
			case Cs.ST_CLIMB:
				
				waitTimer-=Timer.tmod;
				
				if( waitTimer<15 ){
					
					if( !flClimbAnim){
						flClimbAnim = true;
						root.gotoAndPlay("climbEnd");
					}
					if( waitTimer<0 ){
						climb();
					}
				}
				break;
			case Cs.ST_SHOOT:
				waitTimer-=Timer.tmod;
				if( waitTimer<0 ){
					shoot();
					nextAnim="shoot"
				}				
				break;
		}
		
		updateFlash();

		
	}

	function climb(){
		vy-= stClimb;
		initStep(Cs.ST_FLY)
	}

	function shoot(){
		initStep(Cs.ST_NORMAL)
	}
	
	function updateFlash(){
		if(flash!=null){
			var prc= flash
			flash*=0.7
			if(flash<1){
				flash = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}
	}
	
	//
	function cut(n){
		KKApi.addScore(Cs.C50)
		harm(n)
		throw(1.57-(1.57*Cs.game.hero.sens),10)
	}
	
	function hit(shot:Star){
		KKApi.addScore(Cs.C10)
		harm(shot.damage)
		throw(Math.atan2(shot.vy,shot.vx),2)
	}
	
	function harm(n){
		hp-=n
		if(hp<0){
			death();
		}else{
			flash=100
		}
	}
	
	function death(){
		Cs.setPercentColor(root,0,0xFFFFFF)
		KKApi.addScore(score)
		Cs.game.spawnBonus(root._x,root._y,getDrop())
		Cs.game.monsterLevel-=stLevel;
		leaveSquare();
		Cs.game.mList.remove(this)
	}
	
	function getDrop(){
		var sum = 0
		for( var i=0; i<stDrop.length; i++ )sum+=stDrop[i].w;
		var rnd = Std.random(sum)
		sum = 0
		for( var i=0; i<stDrop.length; i++ ){
			sum+=stDrop[i].w;
			if(sum>rnd)return stDrop[i].id;
		}
		return 0;
	}
		
	function throw(a,p){
		var vitx = Math.cos(a)*p
		var vity = Math.sin(a)*p - 3
		if(flGround){
			vity = Math.min(0,vity)
			if(vity<0)initStep(Cs.ST_FLY);
		}
		vx+=vitx
		vy+=vity
	}

	function tryJumpFront(){
		var dist = 0
		while(dist<6){
			dist++
			if(!Cs.game.checkFree(x+(sens*(dist+1)),y+1))break;
		}
		if(dist<6){
			jumpFront(dist)

		}
	}
	
	function jumpFront(dist){
		initStep(Cs.ST_FLY)
		vy = -10
		vx = Math.pow(dist*24,0.5)*sens
	}
	
	// ON
	function land(){
		super.land()
		initStep(Cs.ST_NORMAL)
	}
	
	function crossSquare(){
		super.crossSquare();
		
		
		var flSmart = isSmart();
		
		// CLIMB
		if( step==Cs.ST_NORMAL && stTossClimb!=null && Math.random()*stTossClimb <1 ){
			var flDoIt = true;
			if( Cs.game.hero.y > y-3 && flSmart )flDoIt = false;
			if(flDoIt){
				for( var i=2; i<5; i++ ){
					if(!Cs.game.checkFree(x,y-i)){
						initStep(Cs.ST_CLIMB)
						break;
					}
				}
			}

		}
	}

	function fall(){
		//super.fall();
		initStep(Cs.ST_FLY)
	}	
	
	function bang(){
		super.bang()
		setSens(-sens)
	}
	
	function enterSquare(){
		Cs.game.grid[x][y].list.push(this)
	}
	
	function leaveSquare(){
		super.leaveSquare()
		Cs.game.grid[x][y].list.remove(this)
	}
	
	// TOOLS
	function chooseWay(){
		var sens = Std.random(2)*2-1
		if( isSmart() ) sens = (Cs.game.hero.x<x)?-1:1
		setSens(sens)
	}
	
	// IS ?	
	function isSmart(){
		return Math.random()*stTossSmart < 1	
	}
	

//{
}









