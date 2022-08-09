class miniwave.sp.bads.Nectarine extends miniwave.sp.Bads {//}

	
	function Nectarine(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 2
		this.type = 32;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this;checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot()
		mc.behaviourId = 13;
		
	}
	
	
//{
}