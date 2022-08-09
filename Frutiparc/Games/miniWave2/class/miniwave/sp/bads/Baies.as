class miniwave.sp.bads.Baies extends miniwave.sp.Bads {//}

	function Baies(){
		this.init();
	}
	
	function init(){
		this.type = 19;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.endUpdate();
	}
	
	function explode(){
		
		for(var i=0; i<3; i++){
			var mc = this.shoot();
			mc.vitx = 8*(random(200)-100)/100
			mc.vity = -(3+random(30)/10)
			mc.killMargin = 0;
			mc.behaviourId = 2;
		}
		super.explode();
	}
	
	
	
//{
}