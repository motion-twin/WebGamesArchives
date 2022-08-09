class miniwave.sp.bads.Corinthe extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 6
	
	function Corinthe(){
		this.init();
	}
	
	function init(){
		this.freq = 200
		this.coolDownSpeed = 1;
		this.type = 34;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this;checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		for( var i=0; i<2; i++ ){
			var mc = super.shoot();
			mc.x = this.x + ((i*2)-1)*6
			mc.vitx = 0
			mc.vity = this.shotSpeed
			mc.behaviourId = 14
			mc.behaviourInfo.speed = this.shotSpeed;
			
		}	
	}
	
//{
}