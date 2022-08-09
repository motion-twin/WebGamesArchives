class Flyer extends Monster{//}

	
	var speed:float;
	var trg:{x:float,y:float}
	
	var waitTimer:float;
	var waitTimerMax:float;
	

	function new(mc) {
		super(mc);
		stLevel=2
		score = Cs.C120
		setSens(Std.random(2)*2-1)
		initStep(Cs.ST_NORMAL)
		
		flCol = false;
		
		stDrop.push({w:150,id:4})
		stDrop.push({w:50,id:8})
		
		waitTimer = 0
		waitTimerMax = 100
		
		weight = 0
		hp = 30
		score = Cs.C30
		
	}
	

	function initStep(n){
		super.initStep(n)
		switch(step){
			case Cs.ST_NORMAL:
				
				break;
		}
	}

	function update() {
		super.update();
		switch(step){
			case Cs.ST_NORMAL:
				waitTimer-=Timer.tmod;
				if(waitTimer<0){
					chooseTrg();
					waitTimer = waitTimerMax+Math.random()*20
					waitTimerMax = Math.max(0,waitTimerMax-8)
				}
				move();
				//root._rotation = vx*3
				var dx = Cs.game.hero.root._x - root._x
				if(dx*sens<0)setSens(-sens);
				break;
		}
		
		
	}

	function move(){
		var dx = trg.x - root._x
		var dy = trg.y - root._y
		var a = Math.atan2(dy,dx)
		var dist =Math.sqrt(dx*dx+dy*dy)
		
		var c = 0.1
		var lim = 0.4
		
		vx += Math.min(Math.max(-lim,Math.cos(a)*dist*c),lim)
		vy += Math.min(Math.max(-lim,Math.sin(a)*dist*c),lim)
		
		
	}
	
	function chooseTrg(){
		
		var dx = Cs.game.hero.root._x - root._x
		var dy = Cs.game.hero.root._y - root._y
		
		var a = Math.atan2(dy,dx)
		var dist = Math.min(Math.sqrt(dx*dx+dy*dy),160)
		trg = {
			x:root._x + Math.cos(a)*dist,
			y:root._y + Math.sin(a)*dist
		}
		//Log.trace("chooseTrg("+trg.x+","+trg.y+")")
	}
	
	function hit(shot){
		nextAnim="hit"
		super.hit(shot)
		
	}
	
	function death(){
		root.gotoAndPlay("death")
		super.death();
	}
	/*
	function death(){
		
		super.death();
		root.removeMovieClip();
	}
	*/
//{
}








