class sp.Liquid extends Sprite{//}

	var sens:int;
	
	function new(mc){
		super(mc)
		sens = 1
	}
	
	function update(){

		if( Level.isFree(x,y+1)){
			y++
		}else{
			var nx = x+sens
			if( !Level.isFree(nx,y) ){
				sens*=-1
				if(Level.isFree(x+sens,y+1)){
					x+=sens
				}else{
					Level.drawMC(root)
					kill();
				}
				
			}else{
				x = nx;
			}
		}
		
		if(isOut(0)){
			kill();
		}
		
		
		super.update();
	}
	

	
	
	
	
	
	
	
	
//{	
}