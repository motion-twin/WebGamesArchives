class miniwave.sp.bads.Pamplemousse extends miniwave.sp.Bads {//}

	var limit:Number = 70;
	
	function Pamplemousse(){
		this.init();
	}
	
	function init(){
		this.freq = 600;
		this.coolDown = 0.5
		this.type = 8;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		
		if( this.y < this.game.mng.mch-limit )this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		
		var mc = super.shoot();
		mc.vity = 1
		mc.behaviourId = 0;
	}	
	
//{
}