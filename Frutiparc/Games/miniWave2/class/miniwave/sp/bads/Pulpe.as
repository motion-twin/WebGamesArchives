class miniwave.sp.bads.Pulpe extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 3;
	
	function Pulpe(){
		this.init();
	}
	
	function init(){
		this.freq = 500;
		this.coolDownSpeed = 8;
		this.type = 18;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function hitSide(){
		super.hitSide();
		var max = 5;
		for( var i=0; i<max; i++ ){
			var d = (Math.PI/2)
			var a = d + ((i+1)/max*d)*this.game.waveSens
			var mc = super.shoot();
			mc.vitx = Math.cos(a)*this.shotSpeed;
			mc.vity = Math.sin(a)*this.shotSpeed;
			mc.updateRotation();
		}
		
		
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vitx = this.shotSpeed;
		mc.vity = this.shotSpeed;
		mc.updateRotation();
		var mc = super.shoot();
		mc.vitx = -this.shotSpeed;
		mc.vity	= this.shotSpeed;
		mc.updateRotation();
	}
	
	
	
	
//{
}