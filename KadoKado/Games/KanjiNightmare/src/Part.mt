class Part extends Phys{//}

	var outMargin:float;
	
	var flPlatCol:bool;
	
	var timer:float;
	var fadeType:float;
	var fadeLimit:float;
	var scale:float;
	var vr:float;
	var vs:float;
	var rFrict:float;
	var sFrict:float;
	var wait:float;
	var alpha:float;
	var deathScore:KKConst;
	
	var bmp:flash.display.BitmapData;
	
	function new(mc){
		super(mc)
		fadeLimit = 10
		scale = 100
		alpha = 100
		rFrict = 1
		sFrict = 1
		downcast(root).obj = this;
	}
	
	function setScale(sc){
		scale = sc
		root._xscale = sc;
		root._yscale = sc;
	}
	function setAlpha(n){
		alpha = n
		root._alpha = alpha
	}	
	
	function update(){
		if(wait>0){
			wait -= Timer.tmod;
			return;
		}
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
						root._alpha = c*alpha
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
		if(outMargin!=null && isOut(outMargin)){
			kill();
		}
		
		if(flPlatCol )checkPlatCol();
		
	}
	
	function land(pl){
		vy*=-1;
		vr *= -Math.random()*1.5
	}

	
	function kill(){
		if(bmp!=null)bmp.dispose();
		if(deathScore!=null)KKApi.addScore(deathScore)
		super.kill();
	}
//{
}