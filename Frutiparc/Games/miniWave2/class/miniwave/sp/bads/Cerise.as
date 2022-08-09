class miniwave.sp.bads.Cerise extends miniwave.sp.Bads {//}

	function Cerise(){
		this.init();
	}
	
	function init(){
		this.freq = 400;
		this.coolDownSpeed = 0.5  
		this.type = 5;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
	
		for(var i=0; i<3; i++){
			var mc = super.shoot();
			var sens = i-1
			mc.x = this.x + 4*sens
			mc.vitx = 0.8*sens
			mc.vity = 1.5 +0.3*(1-Math.abs(sens))
			
		}
		
		
		/*
		var initObj = {
			x:this.x+4,
			y:this.y,
			vitx:0.8,
			vity:1.5
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)
		
		
		var initObj = {
			x:this.x,
			y:this.y,
			vitx:0,
			vity:1.8
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)		
		

		var initObj = {
			x:this.x-4,
			y:this.y,
			vitx:-0.8,
			vity:1.5
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)		
		*/
	}
	
	

//{
}