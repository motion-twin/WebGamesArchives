class miniwave.sp.bads.Banane extends miniwave.sp.Bads {//}

	

	
	function Banane(){
		this.init();
	}
	
	function init(){
		this.type = 2;
		super.init();
		this.coolDown = 0
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.x=this.x
		mc.y=this.y
		mc.vitx=(random(200)-100)/100
		mc.vity=2.5		
		mc.updateRotation();
		//var mc = this.game.newBShot(initObj)
		//mc.gotoAndStop(10+this.type)
	}
	
	
	
//{
}