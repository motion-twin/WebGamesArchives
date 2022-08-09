class miniwave.sp.bads.Mure extends miniwave.sp.Bads {//}

	function Mure(){
		this.init();
	}
	
	function init(){
		this.freq = 220
		this.coolDownSpeed = 4
		this.type = 16;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.behaviourId = 1
	}
	
	
//{
}