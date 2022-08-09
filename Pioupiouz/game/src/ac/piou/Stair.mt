class ac.piou.Stair extends ac.Piou{//}

	static var DX = 10
	static var DY = -5
	static var DIG_TEMPO = 30
	static var FRAME_MAX = 30

	var
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("stair")
		initMove();
		
	}
	
	function update(){
		super.update();
		if(timer<0){
			piou.x+=DX*piou.sens
			piou.y+=DY
			if(!checkGround(2,0))kill();
			piou.updatePos();
			initMove();
		}
		var c = 1-timer/DIG_TEMPO
		var frame = int(c*FRAME_MAX)+1
		downcast(piou.root).sub.gotoAndStop(string(frame))
		
		if(frame<20){
			//Level.drawLink("mcDigStair",piou.x,piou.y,piou.sens,1,BlendMode.ERASE,frame);
			if( !Level.holeSecure("mcDigStair",piou.x,piou.y,piou.sens,1,0,frame) ){
				go();
				kill();
			}
			
			var p = { x:12, y:-1 }
			var spoon = downcast(piou.root).sub.spoon;
			spoon.localToGlobal(p)
			downcast(Cs.game.map).globalToLocal(p)
			
			var sp = Cs.game.newDebris(p.x,p.y);
			sp.vx = -(1+Math.random()*2)*piou.sens;
			sp.vy = -(0.5+Math.random()*0.5);
			sp.bouncer = new Bouncer(sp)
			sp.timer += Math.random()*50
		}
		

	}	
	
	function initMove(){
		timer = DIG_TEMPO
		
		/*
		var mc = attachBuilder("mcDigStair",piou.x,piou.y,false);
		mc._xscale *= piou.sens
		mc.blendMode =BlendMode.ERASE
		*/
	}
	
	function checkStairGround(){
		var x = int(piou.x+DX*piou.sens)
		var y = int(piou.y+DY+1)
		
		if(Level.isFree(x,y)){
			go();
			kill();
		}
	}
	
	function kill(){
		piou.y--
		super.kill()
	}
	
	
//{
}