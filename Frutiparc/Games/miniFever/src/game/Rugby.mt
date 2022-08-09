class game.Rugby extends Game{//}
	
	
	// CONSTANTES

	// VARIABLES

	
	// MOVIECLIPS
	var ball:{>sp.Phys,z:float,vitz:float};
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 500
		super.init();
		attachElements();
	};
	
	function attachElements(){
		// BALL
		ball = downcast(newPhys("mcRugbyBall"))
		ball.x = 190
		ball.y = 190
		ball.z = 0
		
		ball.flPhys = false;
		ball.init();
		ball.skin._xscale = 150
		ball.skin._yscale = 150
	}
	
	function update(){

		switch(step){
			case 1: 
						
				break;
			case 2: 

				break;			
		}
		super.update();
	}
	
	function click(){
		
		if(step==1){
			var xp = { x:_xmouse, y:_ymouse }
			var dist = ball.getDist(xp)
			if( dist < 35 ){
				var a = ball.getAng(xp)
				
				ball.vitx = -Math.cos(a)*sp
				ball.vity = -Math.sin(a)*sp
				ball.vitz = 30
				
				
				step = 2
			}
					
			
			
		}
	}
	
	

//{	
}

