class ac.piou.Dash extends ac.Piou{//}

	var speed:float

	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		flExclu= true;
		piou.root.gotoAndStop("dash")
		downcast(piou.root).sub.stop();
		speed = 40
	}
	
	function update(){
		super.update();
		speed *= 0.82
		piou.vx = Math.min(speed,12)*piou.sens
		if(speed<1){
			piou.fall();
			kill();
			return;
		}
		// PARTS
		var max =  Math.abs(piou.vx)
		for( var i=0; i<max; i++ ){
			var px = piou.x + Math.random()*Piou.RAY*1.2
			var py = piou.y - Math.random()*2*Piou.RAY*1.2
			
			var p = Cs.game.newDebris(px,py)
			p.vy = (Math.random()*2-1)*1.5 - 1
			p.vx = -(1+Math.random()*(1+max*0.75))*piou.sens
			if(Std.random(6)==0){
				p.bouncer = new Bouncer(p)
				p.timer += 30
			}
		}
		if(!Level.isSquareFree(piou.x+(Piou.RAY*0.8)*piou.sens,piou.y-Piou.RAY,2)){
			var p = new Part( Cs.game.dm.attach("mcNuage",Game.DP_PART) )
			p.x = piou.x+Piou.RAY+(Math.random()*2-1)*3;
			p.y = piou.y-(3+Math.random()*4);
			p.vr = (Math.random()*2-1)*16
			p.setScale(10+max*15)
			piou.x-=Math.min(speed,4)*piou.sens
		}
		
		//
		//Level.drawLink("mcHoleDash",piou.x,piou.y,piou.sens,1,BlendMode.ERASE,null);
		if( !Level.holeSecure( "mcHoleDash" ,piou.x, piou.y, piou.sens, 1, 0, 1 ) ){
			piou.fall();
			kill();
		}
	}	
	

	
	
//{
}