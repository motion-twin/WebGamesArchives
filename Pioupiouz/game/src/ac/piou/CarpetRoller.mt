class ac.piou.CarpetRoller extends ac.Piou{//}

	var length:int
	var px:int;
	var py:int;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("carpetRoll")
		length = 70
		flExclu= true;
		px = int(piou.x)
		py = int(piou.y)
	}
	
	function update(){
		super.update();

		//Log.print(Level.isFree(px+piou.sens,py))
		
		/*
		if(!Level.isFree(px,py)){
			return;
		}
		*/
		var mc = Cs.game.dm.attach( "mcPiouPix", Game.DP_BASE )
		mc._x = px
		mc._y = py
		piou.updateColor(mc)
		Level.drawMC(mc)
		mc.removeMovieClip()
		
		//Level.drawLink("mcPiouPix",px,py,1,1,null,1)
		downcast(piou.root).sub.nextFrame();
		//
		if( Level.isFree(px+piou.sens,py) ){
			px+=piou.sens;
		}else{
			var flReverse = true;
			for( var i=1; i<7; i++){
				if(  Level.isFree(px,py-i) ){
					if(Level.isFree(px+piou.sens,py-i)){
						flReverse = false;
						break;
					}
				}else{
					break;
				}
			}
			py--
			if(flReverse){
				piou.reverse();
				var flInterrupt = true;
				for( var n=0; n<5; n++ ){
					if(Level.isFree(px+piou.sens,py) ){
						flInterrupt = false;
						px+=piou.sens
						break;
					}
				}
				if(flInterrupt)length=1;
			}
 		}

		length--;		
		if(length==0){
			piou.die();
			kill();
		}else{
			piou.x = px;
			piou.y = py;
		}
	}



	
//{
}