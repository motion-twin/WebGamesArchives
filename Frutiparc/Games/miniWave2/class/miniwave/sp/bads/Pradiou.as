class miniwave.sp.bads.Pradiou extends miniwave.sp.Bads {//}

	var hp:Number;
	
	function Pradiou(){
		this.init();
	}
	
	function init(){
		this.type = 7;
		super.init();
		this.hp = 2
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if(this.hp==1)this.checkShoot();
		this.endUpdate();
	}
	
	function hit(){
		this.hp--;
		if( this.hp == 0 ){
			this.explode();
		}else{
			this.freq = 10
			this.coolDownSpeed = 5;
			this.nextFrame();
		}
	}
	
	function shoot(){
		var mc = super.shoot()
		mc.vity = 3
	}
	
//{
}