class miniwave.sp.bads.PoisChiche extends miniwave.sp.Bads {//}

	
	function PoisChiche(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 4
		this.type = 47;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		
		var mc = super.shoot();
		mc.vitx = 6*(random(2)*2-1)
		mc.vity = 6
		mc.vitRot = 16
		mc.behaviourId = 22
		mc.behaviourInfo = { step:0 } 
		
	}
	

	

//{
}