class ac.piou.Crevasse extends ac.Piou{//}

	
	static var FRAME_MAX = 20;
	static var CHAOS = 18;
	static var SPEED = 20;

	var pList:Array<{x:float,y:float}>
	var rnd :Random;
	var sens:int;
	
	var bolt:MovieClip;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		pList = [ {x:piou.x,y:piou.y} ]
		/*
		var r = Std.random(100)
		Log.clear()
		Log.trace(r)
		*/
		rnd = new Random(32);
		sens = -piou.sens
		
		piou.fall();
		piou.vy = -1.5
		freePiou();
		
		bolt = Cs.game.dm.attach("mcCrevasseBolt",Game.DP_PART)
		bolt._x = piou.x;
		bolt._y = piou.y;
		
	}
	
	function update(){
		
		super.update();

		

		var np=null
		if( timer==null ){
			
			
			sens*=-1
			var dx = rnd.rand()*sens*CHAOS
			var dy = SPEED
			
			var last = pList[0]
			np = { x:last.x+dx, y:last.y+dy }
			
			while(pList.length>FRAME_MAX)pList.pop();
			if(Level.isFree(np.x,np.y)){
				timer = 5;
				bolt.removeMovieClip();
			}
			
			for( var i=0; i<3; i++ ){
				var p = Cs.game.newDebris(int(np.x),int(np.y));
				p.vy = Math.random()*3
				p.vx = (Math.random()*2-1)
				p.setScale(50+Math.random()*100)
				if(i==0){
					p.bouncer = new Bouncer(p)
					p.timer += 30
					p.weight += 0.1+Math.random()*0.3
				}
			}
			
			
		}else{
			
			if(timer--<=0){
				kill();
			}
		}
		
		pList.unshift( np )
		
		
		for( var i=0; i<pList.length-1; i++ ){
			var p0 = pList[i]
			var p1 = pList[i+1]
			if(p1!=null){
				var rot = Cs.getAng(p1,p0)/0.0174
				var dist = Cs.getDist(p0,p1)
				Level.holeSecure("mcCrevasse",p0.x,p0.y,dist/20,1,rot,i+1)
				if(i==0){
					var mc = Cs.game.dm.attach("mcCrevasseLight",Game.DP_PART)
					mc._x = p0.x
					mc._y = p0.y
					mc._xscale = dist*5
					mc._rotation = rot;
					bolt._x = p0.x;
					bolt._y = p0.y;
					bolt._rotation = Math.random()*360					
				}
			}
		}

		
	}	
	
	function interrupt(){
		go()
		step = 1
		//super.interrupt();
		
	}
	
	
//{
}