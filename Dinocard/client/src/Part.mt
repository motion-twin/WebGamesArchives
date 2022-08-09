class Part extends Phys{//}

	var timer:float;
	var fadeType:float;
	var fadeLimit:float;
	var freezeTimer:float;
	var vr:float;
	
	function new(mc){
		super(mc)
		fadeLimit = 10
		
		Cs.game.partList.push(this)
	}
	

	function update(){
		if(freezeTimer!=null){
			freezeTimer-=Timer.tmod;
			if(freezeTimer<=0){
				root.play();
				freezeTimer = null;
			}
			return;
		}
		super.update();
		if(vr!=null){
			vr*=frict
			root._rotation += vr*Timer.tmod
		}
		if(timer!=null){
			timer-=Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit
				switch(fadeType){
					case 0:
						root._xscale = scale*c;
						root._yscale = root._xscale;					
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
	
	function freeze(n){
		freezeTimer = n
		root.stop();
	}
	

	
	function kill(){
		Cs.game.partList.remove(this)
		super.kill();
	}
//{
}