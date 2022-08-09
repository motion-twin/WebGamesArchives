class miniwave.sp.bads.Kumquat extends miniwave.sp.Bads {//}

	
	function Kumquat(){
		this.init();
	}
	
	function init(){
		this.freq = 280
		this.coolDownSpeed = 8
		this.type = 37;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot()
		mc.behaviourId = 15;
		mc.vitx = 4*(random(2)*2-1)
		mc.vity = 2
		mc.updateRotation();
		
	}
	
	

//{
}