class miniwave.sp.bads.Courge extends miniwave.sp.Bads {//}

	
	function Courge(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 10
		this.type = 44;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.behaviourId = 19;
		mc.behaviourInfo = {
			amp:0,
			d:0,
			x:this.x
		}
		
	}
	

	

//{
}