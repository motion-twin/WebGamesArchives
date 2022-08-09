class miniwave.sp.bads.Pomme extends miniwave.sp.Bads {//}

	var maxShot:Number = 5
	
	function Pomme(){
		this.init();
	}
	
	function init(){
		this.type = 13;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.endUpdate();
	}
	
	function explode(){
		for(var i=0; i<this.maxShot; i++){
			var mc = this.shoot();
			var c = ((i*2)-(this.maxShot-1))/(this.maxShot-1)
			mc.vitx = c*3
			mc.vity = 2.5
			mc.updateRotation();
		};
		super.explode();		
	}
	
	
	
	
	
//{
}