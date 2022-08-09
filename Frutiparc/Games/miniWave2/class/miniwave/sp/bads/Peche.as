class miniwave.sp.bads.Peche extends miniwave.sp.Bads {//}

	
	function Peche(){
		this.init();
	}
	
	function init(){
		this.freq = 220;
		this.coolDownSpeed = 6;
		this.type = 30;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		
		var mc = super.shoot();

		
		var u = (Math.PI/4)*100
		var a = ( u*3 - random(2*u) )/100
		
		mc.vitx = Math.cos(a)*6
		mc.vity = Math.sin(a)*6	
		
	}
	
	
//{
}