class miniwave.sp.bads.Pommette extends miniwave.sp.Bads {//}

	var shotSpeed:Number = 6
	var vitx:Number;
	var oldx:Number;
	
	function Pommette(){
		this.init();
	}
	
	function init(){
		this.freq = 200
		this.coolDownSpeed = 50
		this.type = 49;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		//this.checkShoot();
		this.endUpdate();
	}
	
	function update(){
		super.update();
		this.vitx = this.x-this.oldx
		this.oldx = this.x
	}
	
	function explode(){
		//
		var initObj = {
			x:this.x,
			y:this.y,
			vitx:this.vitx,
			vity:0,
			behaviourId:7,
			behaviourInfo:{
				ray:0,
				raySpeed:16,
				frict:0.77,
				timer:16
			}
		}
		var mc = this.game.newHShot(initObj);
		mc._xscale = 0
		mc._yscale = 0
		mc.gotoAndStop(153)
		//
		super.explode();
	}
	
	

//{
}