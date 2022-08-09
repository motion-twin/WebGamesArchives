class miniwave.sp.bads.Datte extends miniwave.sp.Bads {//}

	// CONSTANTES
	var nbShot:Number = 3
	var decal:Number = 5
	var shotSpeed:Number = 3
	
	// VARIABLES
	var toShot:Number
	var timer:Number
	
	function Datte(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 4
		this.type = 14;
		super.init();
		this.toShot = 0;
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if(this.toShot>0){
			if( this.timer<0 ){
				this.shoot();
				this.toShot--;
			}			
		}else{
			this.checkShoot();
		}
		this.endUpdate();
	}
	
	function update(){
		super.update();
		if(this.toShot>0)this.timer -= Std.tmod;
	}
		
	function shoot(){
		
		if( this.toShot == 0 )this.toShot = this.nbShot-1;
		
		var mc = super.shoot();
		
		var h = this.game.getHeroTarget()
		
		var difx = h.x-this.x;
		var dify = h.y-this.y;
		var a = Math.atan2(dify,difx);

		mc.vitx = Math.cos(a)*this.shotSpeed;
		mc.vity = Math.sin(a)*this.shotSpeed;
		
		mc.updateRotation();
		
		this.timer = this.decal;
	
	}
		
	
//{
}