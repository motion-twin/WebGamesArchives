class miniwave.sp.bads.Myrtille extends miniwave.sp.Bads {//}

	var flKamikaze:Boolean;
	var hp:Number;
	var vitx:Number;
	var vity:Number;
	
	
	function Myrtille(){
		this.init();
	}
	
	function init(){
		this.vitx = 0;
		this.vity = 0;
		this.flKamikaze = false;
		this.hp = 2
		this.type = 26;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if( hp == 1 && !this.flKamikaze ) this.initKamikaze();
		this.endUpdate();
	}
	
	function update(){
		super.update();
		
		if( this.flKamikaze ){
			
			var tol = 5
			var speed = 0.2
			
			var h = this.game.hero
			if( h._visible != true ) h = { x:this.game.mng.mcw/2, y:-100 };
			
			var difx = h.x-this.x;
			var dify = h.y-this.y;
			
			if( difx > tol )	this.vitx += Std.tmod*speed;
			if( difx < -tol )	this.vitx -= Std.tmod*speed;
			if( dify > tol )	this.vity += Std.tmod*speed;
			if( dify < -tol )	this.vity -= Std.tmod*speed;			
			
			var c = Math.pow(0.98,Std.tmod)
			
			this.vitx *= c;
			this.vity *= c;
			this._rotation = Math.atan2(this.vity,this.vitx)/(Math.PI/180) - 90;
			
			this.x += this.vitx;
			this.y += this.vity;
			
			this.endUpdate();
			
		}	
		
	}
	
	function hit(){
		this.hp--;
		if( this.hp == 0 ){
			this.explode();
		}else{
			this.nextFrame();
		}
	}
	
	function initKamikaze(){
		this.flKamikaze = true;
		this.flWave= false;
		
	}
	
	function reset(t){
		if(this.flKamikaze){
			this.explode();
		}else{
			super.reset(t)
		}
	}	
	
//{
}