class miniwave.sp.bads.Lemon extends miniwave.sp.Bads {//}

	
	function Lemon(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 1
		this.type = 42;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vity = 2.2;
		mc.behaviourId = 17;
		mc._rotation = 0;
		mc.killMargin = 5
	}
	
	

//{
}