class miniwave.sp.bads.Scarab extends miniwave.sp.Bads {//}

	var fall:Number = 24;
	
	var coolDownFall:Number;
	
	function Scarab(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 4
		this.coolDownFall = 0
		this.type = 36;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		if(this.coolDownFall<0){
			if( !random(240/Std.tmod) && this.game.isFree(this.x,this.y+this.fall,12)){
				this.ty += this.fall;
				this.coolDownFall = 12;
			}
		}
		this.endUpdate();
	}
	
	function update(){
		super.update();
		this.coolDownFall -= Std.tmod;		
	}
	
	function shoot(){
		var mc = super.shoot();
		mc.vitRot = 10;
		mc.vity = 4
	}

	

//{
}