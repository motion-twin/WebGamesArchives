class miniwave.sp.bads.Mangue extends miniwave.sp.Bads {//}

	// CONSTANTES
	var nbShot:Number = 8
	var decal:Number = 3
	var shotSpeed:Number = 3

	// VARIABLES
	var toShot:Number
	var timer:Number	
	
	function Mangue(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 100
		this.type = 21;
		super.init();
		this.toShot = 0;		
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if(this.toShot>0){
			if( this.timer<0 ){
				this.shoot();
				
				if(this.toShot==0)this._rotation = 0;
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
		var c = this.toShot/this.nbShot
		var d =  Math.PI/2
		var a = d + ((c*2)-1)*d

		mc.vitx = Math.cos(a)*this.shotSpeed;
		mc.vity = Math.sin(a)*this.shotSpeed;
		
		mc.updateRotation();
		
		this.timer = this.decal;
	
		this._rotation = (a/(Math.PI/180))-90
		
		this.toShot--;
	}	
	
	
//{
}