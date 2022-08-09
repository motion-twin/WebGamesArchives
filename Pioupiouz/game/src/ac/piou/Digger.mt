class ac.piou.Digger extends ac.Piou{//}

	static var DIG_TEMPO = 3//5

	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("dig")
		timer = 5
	}
	
	function update(){
		super.update();
		if(timer<0){
			if( !checkGround(2,0) ){
				kill();
				return;
			}
				
			timer = DIG_TEMPO
			piou.y++
			//Level.drawLink("mcHoleDigger",piou.x,piou.y,1,1,BlendMode.ERASE,null);
			
			if( !Level.holeSecure("mcHoleDigger",piou.x,piou.y,1,1,0,1) ){
				go()
				kill()
			}
			
			
			for( var i=0; i<3; i++ ){
				var x = piou.x + (Math.random()*2-1)*4;
				var y = piou.y+1;
				var p = Cs.game.newDebris(x,y);
				p.vy = -(1+Math.random()*2)
				p.vx = (Math.random()*2-1)*1
			}
			
		}

				
		
	}	
	
	function interrupt(){
		super.interrupt();
	}
	
	
//{
}