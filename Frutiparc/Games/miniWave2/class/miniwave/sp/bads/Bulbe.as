class miniwave.sp.bads.Bulbe extends miniwave.sp.Bads {//}

	
	function Bulbe(){
		this.init();
	}
	
	function init(){
		this.freq = 180
		this.coolDownSpeed = 6
		this.type = 45;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		for( var i=0; i<2; i++ ){
			var mc = super.shoot();
			mc.vitx = (i*2-1)*5
			mc.vity = -2;
			mc.behaviourId = 20
			
		}
		
		
		
		
	}
	

	

//{
}