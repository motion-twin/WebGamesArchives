class miniwave.sp.bads.Poivron extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 6
	var key:Array;
	
	function Poivron(){
		this.init();
	}
	
	function init(){
		
		this.key = this.game.mng.fc[1].$key
		
		this.freq = 220
		this.coolDownSpeed = 40
		this.type = 38;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		
		var mc = super.shoot();
		
		var h = this.game.getHeroTarget();
		var s = 0
		if( Key.isDown( this.key[0] ) ) s = -1
		if( Key.isDown( this.key[1] ) ) s = 1
		var c = Math.min( this.getDist(h)/this.shotSpeed, 24)
		var o = {
			x: h.x + c*s*h.speed,
			y: h.y
		}
		
		var a = this.getAng(o)
		
		mc.vitx = Math.cos(a) * this.shotSpeed
		mc.vity = Math.sin(a) * this.shotSpeed
		
		mc.updateRotation();
		
	}
	

//{
}