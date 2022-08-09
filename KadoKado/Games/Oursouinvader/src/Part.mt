class Part extends Phys{//}

	var timer:float;
	var fadeType:float;
	var fadeLimit:float;

	
	
	function new(mc){
		super(mc)
		Cs.game.pList.push(this)
		fadeLimit = 10
		scale = 100
	}

	function update(){
		super.update();
		
		

		if(timer!=null){
			timer-=Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit
				switch(fadeType){
					case 0:
						root._xscale = scale*c;
						root._yscale = root._xscale;					
						break;
					case 1:
						root._yscale = scale*c;					
						break;					
					default:
						root._alpha = c*100
						break;
				}
				if(timer<0){
					kill();
				}
				
			}
		}

		
	}
	
	
	function kill(){
		Cs.game.pList.remove(this)
		super.kill();
	}
//{
}