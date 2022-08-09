class fx.Line extends Part{//}

	var cx:float;
	var cy:float;
	
	function new(mc){
		super(mc);
	}
	
	function update(){
		super.update();
		
		if(cx!=null)root._xscale = 100*vx*cx;
		if(cy!=null)root._yscale = 100*vy*cy;
		
	}
	

//{
}