class miniwave.sp.bads.Blackamber extends miniwave.sp.Bads {//}

	var curSide:Boolean;
	var timer:Number;
	var toShoot:Number
	
	function Blackamber(){
		this.init();
	}
	
	function init(){
		this.type = 33;
		this.flWave = false;
		
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		
		this.x += this.game.waveSpeed
		if(this.x>this.game.mng.mcw+10){
			this.x = -10;
			this.curSide = true
		}
		var dy = (this.ty-this.y)*0.3
		this.y += Math.min( dy, 4 )*Std.tmod;
		
		
		var side = this.getSide();
		
		if(this.curSide != side && this.curSide != undefined){
			this.toShoot = 3;
			this.timer = -1;
			
		}
		this.curSide = side;
		
		
		
		this.endUpdate();
	}
	
	function update(){
		super.update();
		if( this.toShoot>0 ){
			if(this.timer<0){
				this.toShoot--;
				this.shoot();
				this.timer = 4
			}else{
				this.timer -= Std.tmod;
			}
		}	
	}

	function shoot(){
	
		var mc = super.shoot();
		var c = this.game.getHeroTarget()
		//if( c._visible != true )c= { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 }
		var a = this.getAng(c)
		mc.vitx = Math.cos(a)*4
		mc.vity = Math.sin(a)*4
		mc.updateRotation();
		
	}
	
	function hitSide(){

	}

	function getSide(){
		return this.x<this.game.mng.mcw/2
	}
	
	
//{
}