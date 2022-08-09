class miniwave.sp.bads.Radis extends miniwave.sp.Bads {//}

	function Radis(){
		this.init();
	}
	
	function init(){
		this.freq = 130
		this.coolDownSpeed = 10
		this.type = 6;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	
	
	
//{
}