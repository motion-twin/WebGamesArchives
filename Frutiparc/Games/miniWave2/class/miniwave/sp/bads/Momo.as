class miniwave.sp.bads.Momo extends miniwave.sp.Bads {//}

	
	function Momo(){
		this.init();
	}
	
	function init(){
		this.freq = 40
		this.coolDownSpeed = 10
		this.type = 43;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		var a = (157+random(75)*(Math.random()*2-1))/100
		mc.vitx = Math.cos(a)*5
		mc.vity = Math.sin(a)*5
		mc.vitRot = 16;
	}

	

//{
}