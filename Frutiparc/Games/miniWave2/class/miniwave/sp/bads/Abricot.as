class miniwave.sp.bads.Abricot extends miniwave.sp.Bads {//}

	
	function Abricot(){
		this.init();
	}
	
	function init(){
		//this.freq = 220;
		//this.coolDownSpeed = 6;
		this.type = 31;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		//this.checkShoot();
		this.endUpdate();
	}
	
	function hitSide(){
		super.hitSide();
		var mc = super.shoot();
		
		var h = this.game.getHeroTarget()
		//if( h._visible != true ) h = { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 }		
		var a = this.getAng(h)
		
		mc.vitx = Math.cos(a) * 6
		mc.vity = Math.sin(a) * 6
		mc.updateRotation();
		
	}
	
	
	
//{
}