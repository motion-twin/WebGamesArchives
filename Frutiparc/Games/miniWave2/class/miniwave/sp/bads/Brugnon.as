class miniwave.sp.bads.Brugnon extends miniwave.sp.Bads {//}

	var hp:Number;
	
	function Brugnon(){
		this.init();
	}
	
	function init(){
		this.freq = 360
		this.coolDownSpeed = 1
		this.type = 48;
		super.init();
		this.hp = 2
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function hit(){
		this.hp--;
		if( this.hp == 0 ){
			this.explode();
		}else{
			this.nextFrame();
		}
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vity = 0.6
		mc.vitRot = 6
		mc.behaviourId = 23;
		
	}
	

//{
}