class miniwave.Box extends MovieClip{//}
		
	// CONSTANTE
	var speedCoef:Number = 0.5;
	var speedMax:Number = 8;

	// VARIABLES
	var flVanish:Boolean;
	var flLock:Boolean;
	
	var gx:Number;
	var gy:Number;
	var gw:Number;
	var gh:Number;
	
	var x:Number;
	var y:Number;
	var w:Number;
	var h:Number;
	
	var step:Number;
	var waitTimer:Number;
	var timer:Number;
	var colBack:Number;
	var colLine:Number;
	var totalDif:Number;
	
	var interpoList:Array;
	
	
	// REFERENCE
	var page:miniwave.Page
		
	function Box(){
	
	}
	
	function init(){

		this.initDefault();
		this.flVanish = false;
		this.step = 0;
		this.colBack = 0xBCBCDA//0x8A8ABD
		this.colLine = 0xFFFFFF
		this.timer = this.waitTimer;
		this.interpoList = ["x","y","w","h"]
		if(this.flLock){
			this.colBack = 0x8A8ABD
			this.colLine = 0xBCBCDA
		}
	}
	
	function initDefault(){
		super.initDefault();
		if( this.gx == undefined ) 		this.gx = 100;
		if( this.gy == undefined ) 		this.gy = 100;
		if( this.gw == undefined ) 		this.gw = 100;
		if( this.gh == undefined ) 		this.gh = 100;
		if( this.x == undefined ) 		this.x = this.gx;
		if( this.y == undefined ) 		this.y = this.gy;
		if( this.w == undefined ) 		this.w = 0;
		if( this.h == undefined ) 		this.h = 0;	
		if( this.waitTimer == undefined ) 	this.waitTimer = 0;	
		if( this.flLock == undefined ) 		this.flLock=false;	
	}
	
	function update(){
		var frict = Math.pow( this.speedCoef, Std.tmod )
		
		switch(this.step){
			case 0:
				this.timer-= Std.tmod
				if(this.timer<=0){
					this.step = 1
				}
				break;
			case 1:
				var dif = this.tweenAll((1-frict))
				if( dif<0.5){
					if(this.flVanish){
						this.kill();
					}else{
						
						this.tween(1);
						this.step = 2;
						this.tryToInitContent();
					}
				}
				this.updateDraw();
				this._x = this.x
				this._y = this.y
				break;
			case 2:
				break;			
		}
	}
	
	function tweenAll(c){
		this.totalDif = 0;		
		/*
		for(var i=0; i<this.interpoList.length; i++){
			var n = this.interpoList[i];
			var dif = this["g"+n]-this[n];
			this[n] += Math.min(Math.max( -this.speedMax, dif*c), this.speedMax );
			totalDif+=Math.abs(dif);
		}
		*/
		this.x += this.tween( this.x, this.gx, c)
		this.y += this.tween( this.y, this.gy, c)
		this.w += this.tween( this.w, this.gw, c)
		this.h += this.tween( this.h, this.gh, c)
		
		return totalDif
	}
	
	function tween( v, g, c ){
		var dif = g-v;
		this.totalDif+=Math.abs(dif);
		return Math.min(Math.max( -this.speedMax, dif*c), this.speedMax );
	}
	
	
	function updateDraw(){
		//_root.test+="draw("+this.gw+","+this.gh+")\n"
		
		this.clear();
		this.lineStyle(2,this.colLine)
		
		var curve = Math.min(this.w/2,Math.min(this.h/2,10))
		this.moveTo(	curve,			0									)
		this.beginFill( this.colBack )

		this.lineTo(	(this.w-curve),	0										)
		this.curveTo(	this.w,			0,			this.w,			curve			)
		this.lineTo(	this.w,			(this.h-curve)								)
		this.curveTo(	this.w,			this.h,			(this.w-curve),		this.h			)
		this.lineTo(	curve,			this.h									)
		this.curveTo(	0,			this.h,			0,			(this.h-curve)		)
		this.lineTo(	0,			curve									)
		this.curveTo(	0,			0,			curve,			0			)
		this.endFill()
			
	}
	
	function vanish(timer){
		if( timer == undefined ) timer = 0;
		this.timer = timer;

		this.removeContent();
		this.gx = (this.gx+this.gw)-4;
		this.gy = (this.gy+this.gh)-4;
		this.gw = 4;
		this.gh = 4;
		this.step = 0;
		this.flVanish = true;
	}
	
	function updateGFX(){
	
		
	}
	
	function kill(){
		this.page.removeBoxFromList(this)
		this.removeMovieClip();
	}
	
	
	function tryToInitContent(){
		if(!this.flLock){
			this.page.menu.mng.sfx.playSound("sMenuBeep2",47);
			this.page.menu.mng.sfx.setVolume(48,50);
			this.initContent();
		}
	}
	
	function initContent(){
		//this.colBack = 0xBCBCDA
		//this.colLine = 0xFFFFFF
	}
	
	function removeContent(){
	
	}	
	
	function lock(){
		this.colBack = 0x8A8ABD
		this.colLine = 0xBCBCDA
		this.updateDraw();
		this.removeContent();
	}
	
//{	
}