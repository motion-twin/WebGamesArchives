class ac.piou.Vrille extends ac.Piou{//}

	static var DX = 30
	static var DY = -8	
	static var DIG_TEMPO = 2

	var vrille:MovieClip;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("vrille")
		vrille = Cs.game.dm.attach("mcVrille",Game.DP_PIOU)
		Cs.game.dm.under(vrille)
		vrille._x = piou.x
		vrille._y = piou.y-Piou.RAY
		vrille._xscale  = piou.sens*100
		vrille.stop();
		timer = 25
		step=0
	}
	
	function update(){
		super.update();
		switch(step){
			case 0:
				vrille.nextFrame();
				if(timer<0){
					timer = DIG_TEMPO
					piou.x+=piou.sens
					
					
					// DEBRITS SUR POINTE
					var ppx = int(piou.x+DX*piou.sens)
					var ppy = int(piou.y+DY)
					if(!Level.isFree(ppx,ppy)){

						for( var i=0; i<4; i++ ){
							var p = Cs.game.newDebris(ppx,ppy)//Cs.game.newPart("mcDebris")

							p.vy = (Math.random()*2-1)*1.5 - 1
							p.vx = -(1+Math.random()*4)*piou.sens
							p.setScale( 50+Math.random()*100 )
							if(Std.random(5)==0){
								p.bouncer = new Bouncer(p);
								p.timer += 30
							}
						}						
					}
		
					if(!Level.holeSecure("mcHoleVrille",piou.x,piou.y,piou.sens,1,0,null)){
						go();
						step = 1
						break;
						//piou.initWalk();
						//kill();
					}
					
				}
				
				vrille._x = piou.x
				vrille._y = piou.y-Piou.RAY
				
				/*
				if( !checkGround(5,15*piou.sens) || !checkGround(2,0) ){
					freePiou();
					step  = 1
				}
				*/
				//if(!checkGround(2,0))Log.trace("first!");
				//if(Level.isSquareFree( piou.x+20*piou.sens piou.y-8, 6))Log.trace("second!");				
				if( !checkGround(2,0) || Level.isSquareFree( piou.x+20*piou.sens piou.y-8, 6) ){
					go();

					step  = 1
				}				
				break;
				
			case 1:
				vrille.prevFrame();
				if(vrille._currentframe==0){
					kill();
				}
				break;
		}
		

	}	
	
	function interrupt(){
		go();
		step = 1
		//super.interrupt();
		
	}
	
	
//{
}