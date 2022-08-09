class sp.BrickRoller extends Phys{//}

	static var FLY = 1
	static var ROLL = 2
	
	static var SPEED = 0.6
	static var LENGTH = 4
	
	var sens:int;
	var step:int;
	
	var angle:float;
	//var nextLim:float
	var side:int;

	
	function new(mc){
		mc = Cs.game.dm.attach( "mcBrickRoll" ,Game.DP_PIOU)
		super(mc)
		frict = 0.98
		Cs.game.blastList.push(this)
		//setSens(1)
		initStep(FLY)
	}
	
	function setSens(sn){
		sens = sn
		angle = 3.14+root._rotation*0.0174
		side = -1
	}
	
	function initStep(n:int){
		switch(step){
			case FLY:
				weight = null
				removeBouncer()
				flOrient = false

				break;

		}
		step = n
		switch(step){
			case FLY:
				weight = 0.3
				bouncer = new Bouncer(this);
				bouncer.onBounceGround = callback(this,initStep,ROLL)
				flOrient = true
				break;
			case ROLL:
				var sn = 1
				if(vx!=0)sn = Math.round(vx/Math.abs(vx))			
				setSens(sn)
				root._rotation = 0
				
				vx = 0;
				vy = 0;			
				break;			
		}
	}
	
	function update(){
		
		switch(step){
			case FLY:
				break;
			case ROLL:
				roll();
				break;
		}
		super.update();
	}
	
	function roll(){
		angle += SPEED*sens*Timer.tmod
		var flTrace =false;
		if( Math.sin(angle)*side < 0  ){
	
			var a = (-(sens*side)-1)*1.57
			if(!Level.isFree(x-sens,y)){
				angle = a
				flTrace = true;
				for( var i=2; i<5; i++){
					if(!Level.isFree(x-sens,y-i)){
						y--
					}
				}
			}

			side *= -1
		}
		



		
		downcast(root).sub._rotation = angle/0.0174

		if(flTrace ){
			
			root._x = x;
			root._y = y;
			Level.drawMC(root)
			kill();
		}else{
			if( true ){
				var bx = int(x+Math.cos(angle)*LENGTH)
				var by = int(y+Math.sin(angle)*LENGTH)
				if( !Level.isFree(bx,by) ){
					var tr = 0
					while(!Level.isFree(bx,by)){
						angle+= -SPEED*sens*0.1
						bx = int(x+Math.cos(angle)*LENGTH)
						by = int(y+Math.sin(angle)*LENGTH)					
						if(tr++>1000){
							Log.trace("ERROR")
							break;
						}
					}
					angle -= 3.14*sens
					side *= -1
					x = bx
					y = by
					downcast(root).sub._rotation = angle/0.0174
				}
			}
	
		}
		angle = Cs.hMod(angle,3.14)
		
		
		
	
	}
	
	function dropToGround(){
		while(true){
			if(!Level.isFree(x,y+1) ||y>Level.bmp.height)break;
			y++
		}
	}
	
	function onBlast(px,py){
		initStep(FLY)
	}
	
	
	function kill(){
		Cs.game.blastList.remove(this)
		super.kill();
	}
	
	
	
	
	
	
	
	
//{	
}