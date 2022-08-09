class Piou extends Phys{//}
	
	static var FLY = 0
	static var WALK = 1
	static var EXIT = 3

	static var ORIENT = 15
	static var BREAK = 0.25
	static var WEIGHT = 0.3
	
	static var ACC = 2
	static var FRICT = 0.8
	
	static var RAY = 6
	
	static var DIR = [
		{x:1,y:0},
		{x:0,y:1},
		{x:-1,y:0},
		{x:0,y:-1}
	]
	

	var speed:float;

		
		
	var climb:float;
	
	var sens:int
	var side:int;
	
	var step:int;
	var px:int;
	var py:int;
	var fr:int;
	var vx:float;
	var vy:float;
	var parc:float;

	var rotList:Array<int>;

	function new(mc){
		mc = Cs.game.dm.attach( "mcPiou" ,Game.DP_PIOU)
		super(mc)
		
		rotList = new Array();
		//
		weight = 0.3
		speed = 0
		frict = 0.98
		climb = 6
		
		//
		sens = 1
		initStep(FLY)
		
		//
		Cs.game.pList.push(this)
		
		
	}
	
	function initStep(n:int){
		
		switch(step){
			case FLY:
				bouncer = null;
				weight = 0
				break;
			case WALK:
				
				break;
		}
		
		step = n
		switch(step){
			case FLY:
				root.gotoAndStop("fly")
				vx = 0;
				vy = 0;
				weight = WEIGHT
				bouncer = new Bouncer(this);
				bouncer.onBounce = callback(this,land)
				downcast(root).sub._rotation = Math.random()*360
				break;
			
			case WALK:
				parc = 0
				vx = 0;
				vy = 0;			
				px = int(x)
				py = int(y)
				root.gotoAndStop("walk")
			
				break;
		}
	}
	
	function reverse(){
		
		sens *= -1;
		root._xscale = 100*sens
	}
	
	function update(){
		super.update();
		switch(step){
			case FLY:
				downcast(root).sub._rotation += 8*Timer.tmod
				break;
			
			case WALK:
				//sens = null
				if(Key.isDown(Key.LEFT)){
					speed -= ACC*Timer.tmod;
					root._xscale = -100
				}
				if(Key.isDown(Key.RIGHT)){
					speed += ACC*Timer.tmod
					root._xscale = 100
				}
				speed*=FRICT
				walk(speed);
				if(Key.isDown(Key.SPACE)){
					initStep(FLY)
					var sp = 10
					var a = (root._rotation-90)*0.0174;
					
					//a+= speed*0.1
					
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					vx = ca*sp;
					vy = sa*sp - 2;
					x+= ca*RAY
					y+= sa*RAY
				}				
				break;
			

		}

	}
	

	function turn(sens:int){
		side = Cs.sMod(side+sens,4)
		
	}
	
	function walk(dist){
		parc += Math.abs(dist)*Timer.tmod;
		sens = int(dist/Math.abs(dist))

		// INTERRUPT
		var g = DIR[Cs.sMod(side+1,4)]
		if( Cs.game.isFree(px+g.x,py+g.y) ){
			Log.print(" NO MORE GROUND !!!!")
			return;
		}
		
		if( !Cs.game.isFree(px,py) ){
			Log.print(" SPLASH !!!!")
			kill();
			return;
		}
		
		// WALK
		while( parc>1 ){
			parc--
			
			var f = DIR[side]
			px += f.x*sens
			py += f.y*sens
			
			if( !Cs.game.isFree(px,py) ){
				px -= f.x*sens
				py -= f.y*sens
				turn(-sens)
			}else{
				g = DIR[Cs.sMod(side+1,4)]
				if( Cs.game.isFree(px+g.x,py+g.y) ){
					px += g.x;					
					py += g.y;
					turn(sens)					
				}
				
			}
			updateRot();
		}
		x = px
		y = py
		
		// ROT
		

	}
	
	function updateRot(){
		rotList.push(side)
		while(rotList.length>Math.max(3,12/Timer.tmod) )rotList.shift();
		
		var a = [0,0,0,0]
		for( var i=0; i<rotList.length; i++ ){
			a[rotList[i]]++
		}
		
		var db = new Array();
		if(a[0]>=a[2])	db.push([0,a[0]-a[2]]);
		if(a[1]>=a[3])	db.push([1,a[1]-a[3]]);
		if(a[2]>a[0])	db.push([2,a[2]-a[0]]);
		if(a[3]>a[1])	db.push([3,a[3]-a[1]]);
		var n = db[0][0]
		var n2 = db[1][0]
		if( Math.abs(n-n2) > 2 ){
			if(n<n2)n+=4;
			else if(n2<n)n2+=4;
		}

		var max = db[0][1] + db[1][1]
		root._rotation = (n*db[0][1]+n2*db[1][1]) / max *90
		
		//Log.print(db)
	}
	
	function land(vx,vy){
		x = bouncer.px;
		y = bouncer.py;
		if(vx==1 && vy==0)side = 3
		if(vx==0 && vy==1)side = 0;
		if(vx==-1 && vy==0)side = 1;
		if(vx==0 && vy==-1)side = 2;
		parc = 0;
		speed = 0
		if( Math.sqrt(vx*vx+vy*vy) < 10 ){
			initStep(WALK)
		}
		walk(-4)
		walk(4)
	}
	
	function initWalk(){
		initStep(WALK)
		rotList = new Array();
	}

	
	/*
	function explode(ba,ra){
		var ray = 4
		var max = 24
		var lim = Cs.game.sList.length
		if(lim>50){
			max *= (50/lim)
		}
		for( var i=0; i<max; i++ ){
			var a = ba+(Math.random()*2-1)*ra
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 1+Math.random()*6
			var p = Cs.game.newPart("mcDebris")
			p.x = x+ca*ray;
			p.y = y+sa*ray;
			p.vx = ca*sp
			p.vy = sa*sp
			p.weight = 0.1+Math.random()*0.1
			p.setScale(40+Math.random()*80)
			p.timer = 10+Math.random()*30
			p.fadeType = 0
			p.weight = 0.1+Math.random()*0.1
			Cs.setColor(p.root, 0xFFC1C1 ,-255)
			p.bouncer = new Bouncer(p)
			if(!Cs.game.isFree(int(p.x),int(p.y))){
				p.kill();
			}
		}
		kill();
	}
	*/
	function kill(){
		Cs.game.pList.remove(this)
		super.kill()
	}
	
	
	
//{
}