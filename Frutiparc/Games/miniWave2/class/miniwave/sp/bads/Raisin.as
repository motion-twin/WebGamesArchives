class miniwave.sp.bads.Raisin extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 3;
	
	function Raisin(){
		this.init();
	}
	
	function init(){
		this.freq = 300
		this.coolDownSpeed = 20	
		this.type = 20;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		
		var mc = super.shoot();
		
		var h = this.game.getHeroTarget()
		
		var difx = h.x-this.x;
		var dify = h.y-this.y;
		var a = Math.atan2(dify,difx);

		mc.vitx = Math.cos(a)*this.shotSpeed;
		mc.vity = Math.sin(a)*this.shotSpeed;
		
		mc.updateRotation();

		
	}
		
	
//{
}