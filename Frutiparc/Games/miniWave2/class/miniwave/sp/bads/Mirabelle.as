class miniwave.sp.bads.Mirabelle extends miniwave.sp.Bads {//}

	//var laserLengthMax:Number = 200
	
	var laserLength:Number = 160
	
	function Mirabelle(){
		this.init();
	}
	
	function init(){
		this.freq = 220
		this.coolDownSpeed = 4
		this.type = 23;
		super.init();
		//this.laserLength = 10
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		//this.laserLength = Math.min(this.laserLength+(0.1*Std.tmod), this.laserLengthMax )
		this.endUpdate();
	}
	
	function shoot(){
		var mc:miniwave.sp.Shot = super.shoot();
		mc.shot._xscale = this.laserLength;
		mc.shot.square._xscale = 0;
		mc.behaviourId = 5;
		mc.behaviourInfo = {
			length:this.laserLength,
			parcouru:0
		}
		mc.vity = 4;
		mc.flare._xscale = 0
		mc.flare._yscale = 0
		mc.killMargin = this.laserLength;
	}
	
	
//{
}