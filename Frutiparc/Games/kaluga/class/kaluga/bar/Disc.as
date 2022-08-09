class kaluga.bar.Disc extends kaluga.Bar{//}

	// CONSTANTES
	
	// PARAMS
	var flShadow:Boolean;
	//var shadowColor:Boolean;
	var link:String;
	
	// VARIABLES
	//var width:Number;

	// MOVIECLIPS
	var skin:MovieClip;
	var shadow:MovieClip;
	var mask:ext.geom.CoefSquare;
	
		
	function Disc(){
		this.init();
	}
	
	function init(){
		//_root.test += "[Disc] init()\n"
		super.init();
		this.initSkin();
		this.initMask();
		this.mask.update();
	}
	
	function initDefault(){
		super.initDefault();
		if( this.link == undefined ) this.link = "discFruit"
		if( this.flShadow == undefined ) this.flShadow = true;
		
	}
	
	function initSkin(){
		this.attachMovie(this.link,"skin",10)
		//_root.test+="[Disc] initSkin("+this.link+") this.skin("+this.skin+")\n"
		this.skin._xscale = this.width
		this.skin._yscale = this.width
		this.skin._x = -(this.margin.x.ratio*this.margin.x.min + this.width/2)
		this.skin._y = (1-this.margin.y.ratio)*this.margin.y.min + this.width/2
		
		this.skin.stop();
		
		if(this.flShadow){
			this.attachMovie(this.link,"shadow",8);
			this.shadow.gotoAndStop(2);
			this.shadow._xscale = this.width
			this.shadow._yscale = this.width
			this.shadow._x = this.skin._x;
			this.shadow._y = this.skin._y;			
		}
	}
	
	function initMask(){
		var initObj = {
			ray:this.width/2
		}
		this.attachMovie("geomCoefSquare","mask",14,initObj)
		this.skin.setMask(this.mask)
		this.mask._x = this.skin._x
		this.mask._y = this.skin._y
	}
	
	function setCoef(c){
		//_root.test+="bonjour("+this.mask.update+")\n"
		this.mask.coef = c;
		this.mask.update();
	}
	
	
//{	
}