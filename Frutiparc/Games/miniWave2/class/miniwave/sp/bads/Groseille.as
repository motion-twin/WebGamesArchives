class miniwave.sp.bads.Groseille extends miniwave.sp.Bads {//}

	
	
	
	function Groseille(){
		this.init();
	}
	
	function init(){
		this.freq = 400;
		this.coolDownSpeed = 100;
		this.type = 29;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		for(var i=0; i<1; i++){
			var mc = super.shoot();
			mc.behaviourId = 12
			var h = this.game.getHeroTarget()
			mc.behaviourInfo = {
				target:{x:h.x,y:h.y}
			}
			
			var u = (Math.PI/4)*100
			
			var a = (random(2*u)-u*3)/100
			
			mc.vitx = Math.cos(a)*12
			mc.vity = Math.sin(a)*12
			
			mc.killMargin = 100
			

		}	
	}
	
	
//{
}