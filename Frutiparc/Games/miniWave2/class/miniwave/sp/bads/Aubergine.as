class miniwave.sp.bads.Aubergine extends miniwave.sp.Bads {//}
	
	var kx:Number;
	var ky:Number;
	
	var timer:Number
	var vitx:Number;
	var vity:Number;
	var step:Number
	var target:Object;
	
	function Aubergine(){
		this.init();
	}
	
	function init(){
		this.type = 28;
		super.init();
		this.step = 0;
	}
	
	function waveUpdate(){				// SPECIAL FEATURE : MONO SWITCH
		
		super.waveUpdate();
		switch(this.step){
			case 0:
				if( !random(300) ){
					this.step = 1;
					
					this.target = this.game.getHeroTarget();
					//if( this.target._visible != true ) this.target = { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 };
					
					this.timer = this.getDist(this.target)/6.6

					this.kx = this.x
					this.ky = this.y
					this.vitx = 0;
					this.vity = 0;

	
				}			
				break;
		}	
		this.endUpdate();
	}
	
	function update(){
		super.update();
		switch(this.step){
			case 0:
				this._rotation -= Math.min(Math.max(-15,this._rotation*0.4),15)
				break;
			case 1:
				
				var tol = 1;
				var speed = 0.5;
				
				var difx = target.x-this.kx;
				var dify = target.y-this.ky;
				
				if( difx > tol )	this.vitx += Std.tmod*speed;
				if( difx < -tol )	this.vitx -= Std.tmod*speed;
				if( dify > tol )	this.vity += Std.tmod*speed;
				if( dify < -tol )	this.vity -= Std.tmod*speed;			
				
				this.vitx *= this.game.frict;
				this.vity *= this.game.frict;
				
				this.kx += this.vitx;
				this.ky += this.vity;
				
				this._rotation = (Math.atan2(this.vity,this.vitx)/(Math.PI/180))-90
				
				if (timer > 0 ){
					this.timer-=Std.tmod;
				}else{
					this.target = this;
					var dx = this.kx - this.x;
					var dy = this.ky - this.y;
					var dist = Math.sqrt( dy*dy + dx*dx );
					if(dist<6){
						this.step = 0;
						
						
					}
					
				}
				
				this.checkHeroCol(this.kx,this.ky)
				this.endUpdate();
				break;
		}		
	}
		
	function checkHeroShot( x, y ){			// PAS TRES BO
		if(this.step == 1 ){
			super.checkHeroShot(this.kx,this.ky)
		}else{
			super.checkHeroShot(this.x,this.y)
		}
	}	
	
	function explode(nbPart){			// HOULA C'EST PAS MIEUX
		if(this.step == 1){
			var x = this.x
			var y = this.y
			this.x = this.kx
			this.y = this.ky
			super.explode(nbPart);
			this.x = x
			this.y = y		
		}else{
			super.explode(nbPart);
		}
		
	}
	
	function endUpdate(){
		if(step == 1 ){
			this._x = this.kx
			this._y = this.ky
		}else{
			super.endUpdate();
		}
	}
	
	
	
	
//{
}