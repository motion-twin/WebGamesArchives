class miniwave.sp.bads.Strawberry extends miniwave.sp.Bads {//}

	var flShotReady:Boolean;
	
	function Strawberry(){
		this.init();
	}
	
	function init(){
		this.freq = 320
		this.coolDownSpeed = 4;
		this.type = 27;
		this.flShotReady = true;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		if(this.flShotReady){
			var mc = super.shoot()
			var sens = random(2)*2-1
			mc.behaviourId = 11
			mc.behaviourInfo = {
				timer:44,
				launcher:this
			}
			mc.killMargin = 200
			mc.vitx = sens*8;
			mc.vity = 0;
			
			this.flShotReady = false;
			this.gotoAndStop(2)
		}
	}
	
	function catchShot(){
		this.flShotReady = true;
		this.gotoAndStop(1)
	}
	
	
	
//{
}