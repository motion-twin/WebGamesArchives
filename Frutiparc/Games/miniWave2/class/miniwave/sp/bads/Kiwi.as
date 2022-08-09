class miniwave.sp.bads.Kiwi extends miniwave.sp.Bads {//}

	var nbShot:Number = 8
	var angle:Number = 0.8
	
	function Kiwi(){
		this.init();
	}
	
	function init(){
		this.freq = 360
		this.coolDownSpeed = 1
		this.type = 39;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
	
		for( var i=0; i<this.nbShot; i++){
			var mc = super.shoot();
			var a = (Math.PI/2) + this.angle * (( i/(this.nbShot-1))*2 - 1 );
			mc.vitx = Math.cos(a)*3.5;
			mc.vity = Math.sin(a)*3.5;
			//mc.vitRot = 16
			mc.behaviourId = 16;
			mc._rotation = random(360)
		}	
		
		
	}

	

//{
}