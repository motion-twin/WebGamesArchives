class miniwave.sp.bads.Jelly extends miniwave.sp.Bads {//}

	
	function Jelly(){
		this.init();
	}
	
	function init(){
		this.freq = 220
		this.coolDownSpeed = 10
		this.type = 41;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		var mc = super.shoot();
		var c = this.game.getHeroTarget()
		var a = this.getAng(c)
		
		mc.vitx = Math.cos(a)*8
		mc.vity = Math.sin(a)*8
		mc.updateRotation();
		
		mc.behaviourId = 18
		mc.flHit = false;
		
	}
	

	

//{
}