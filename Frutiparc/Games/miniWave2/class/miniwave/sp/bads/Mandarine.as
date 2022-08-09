class miniwave.sp.bads.Mandarine extends miniwave.sp.Bads {//}

	// CONSTANTES
	var ecartMax:Number = 60
	var margin:Number = 15
	
	// VARIABLES
	var flStrafe:Boolean;
	var dx:Number;
	
	function Mandarine(){
		this.init();
	}
	
	function init(){
		this.freq = 280
		this.coolDownSpeed = 1
		this.type = 12;
		this.flStrafe = false;
		this.dx = 0 ;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		
		if( this.flStrafe ){
			
			this.dx *= Math.pow( 0.6 , Std.tmod )
			if(Math.abs(this.dx) < 1 ){
				this.dx = 0;
				this.flStrafe = false;
				this.gotoAndStop(1)
			}
			
			
		}else{
			if(!random(200)){
				for(var i=0; i<10; i++){
					var x = margin + random( this.game.mng.mcw - 2*margin )
					var dx = this.x-x
					if( Math.abs(dx) < this.ecartMax && this.game.isFree(x,this.y) ){
						this.x = x;
						this.flStrafe = true;
						this.dx = dx;
						this.gotoAndStop(2)
						break;
					}

				}
			}
		}
		
		this.checkShoot();
		this.endUpdate();
	}
	
	function endUpdate(){
		this.x += this.dx
		super.endUpdate();
		this.x -= this.dx
	}
	
	
	
	
//{
}