class miniwave.sp.bads.Ananas extends miniwave.sp.Bads {//}

	function Ananas(){
		this.init();
	}
	
	function init(){
		this.coolDownSpeed = 15;
		this.type = 25;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function checkShoot(){
		if(this.coolDown<=0){
			var difx = this.x - this.game.hero.x;
			if( !random((Math.abs(difx)*3)/Std.tmod) ){
				this.coolDown = 100
				this.shoot();
			}
		}
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vity = 8;
	}
	
	
	
	
	
	
	
	
//{
}