class miniwave.sp.bads.Clementine extends miniwave.sp.Bads {//}

	
	function Clementine(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 1
		this.type = 3;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		

		for(var i=0; i<2; i++){
			var mc = super.shoot();
			var sens = i*2-1
			mc.x = this.x + 3*sens
			mc.vitx = 0.5*sens
			mc.vity = 2
			
		}
		
		/*
		var initObj = {
			x:this.x+3,
			y:this.y,
			vitx:0.5,
			vity:2
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)
		
		var initObj = {
			x:this.x-3,
			y:this.y,
			vitx:-0.5,
			vity:2
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)
		*/
	}
	
	
//{
}