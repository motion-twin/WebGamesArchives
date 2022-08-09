class miniwave.sp.bads.Betterave extends miniwave.sp.Bads {//}

	var nbShot:Number = 3;
	var angle:Number = 0.4
	
	
	
	function Betterave(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 10
		this.type = 35;
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
			mc.vitx = Math.cos(a)*4.5;
			mc.vity = Math.sin(a)*4.5;
			mc.vitRot = 16
			mc._rotation = random(360);
			
			//_root.test+=">"+a+"\n"
		}
	}
	
//{
}