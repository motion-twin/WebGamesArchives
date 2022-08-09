class miniwave.sp.bads.Quetsch extends miniwave.sp.Bads {//}
	
	// CONSTANTES
	var power:Number = 2;
	var zone:Number = 26;
	
	function Quetsch(){
		this.init();
	}
	
	function init(){
		this.freq = 320
		this.coolDownSpeed = 2
		this.type = 24;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function update(){
		super.update();
		this.moveShots();
	}
	
	function moveShots(){
		var list = this.game.hShotList;
		for( var i=0; i<list.length; i++ ){
			var mc = list[i]
			var difx = mc.x - this.x
			var dify = mc.y - this.y
			var dist = Math.sqrt( difx*difx + dify*dify )
			
			if( dist < this.zone ){
				var a = Math.atan2(dify,difx);
				mc.x += Math.cos(a)*this.power;
				mc.y += Math.sin(a)*this.power;
			}
			
			
		}
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vity = 4;
	}
	
	
	
//{
}