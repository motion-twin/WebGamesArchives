class Part extends Phys{//}

	var timer:float;
	var fadeType:float;
	var fadeLimit:float;
	var scale:float;
	var vr:float;
	var vs:float;
	var rFrict:float;
	var sFrict:float;
	var deathScore:KKConst;
	
	function new(mc){
		super(mc)
		fadeLimit = 10
		scale = 100
		rFrict = 1
		sFrict = 1
		downcast(root).obj = this;
	}
	
	function setScale(sc){
		scale = sc
		root._xscale = sc;
		root._yscale = sc;
	}
	
	function update(){
		super.update();
		if(vr!=null){
			vr*=rFrict;
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
		if(vs!=null){
			vs*=sFrict
			scale+=vs*Timer.tmod
			setScale(scale)
		}
		
	}
	
	function kill(){
		if(deathScore!=null)KKApi.addScore(deathScore)
		super.kill();
	}
//{
}