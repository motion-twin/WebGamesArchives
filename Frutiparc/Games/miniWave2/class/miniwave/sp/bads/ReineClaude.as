class miniwave.sp.bads.ReineClaude extends miniwave.sp.Bads {//}

	
	function ReineClaude(){
		this.init();
	}
	
	function init(){
		this.freq = 80
		this.coolDownSpeed = 10
		this.type = 40;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vitx = 3*(random(200)-100)/100
		mc.vity = 7
		mc.y = this.y+12
		mc.updateRotation();
	}
	

	

//{
}