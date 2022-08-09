class miniwave.sp.bads.Pruneau extends miniwave.sp.Bads {//}

	var power:Number = 1.5
	
	function Pruneau(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 50
		this.type = 15;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function update(){
		if( this.game.step == 2 ){
			var h = this.game.hero;
			var difx = this.x-h.x;
			if( Math.abs(difx) < this.ray+2 && h.flLine ){
				h.y -= this.power*Std.tmod;
				this.gotoAndStop(2);
			}else{
				this.gotoAndStop(1);
			}
		}
		super.update();
	}
	
	
	
	
	
	
//{
}