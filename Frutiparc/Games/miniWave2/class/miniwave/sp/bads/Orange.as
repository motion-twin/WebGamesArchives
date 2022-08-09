class miniwave.sp.bads.Orange extends miniwave.sp.Bads {//}

	var hp:Number;
	
	function Orange(){
		this.init();
	}
	
	function init(){
		this.type = 1;
		this.freq = 800;
		this.coolDownSpeed = 1;
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
	
//{
}