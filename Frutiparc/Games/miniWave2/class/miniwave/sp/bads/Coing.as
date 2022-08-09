class miniwave.sp.bads.Coing extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 2.5 
	
	function Coing(){
		this.init();
	}
	
	function init(){
		this.freq = 200;
		this.coolDownSpeed = 10;
		this.type = 10;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){

		var mc = super.shoot();
		var a = (57+random(200))/100;
		mc.vitx = Math.cos(a)*this.shotSpeed;
		mc.vity = Math.sin(a)*this.shotSpeed;
		
	}
	
	 
	
	
//{
}