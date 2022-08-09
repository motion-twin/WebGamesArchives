class kaluga.FrameAnimManager{//}

	// PARAMETRES
	var flLoop:Boolean;
	var frame:Number;
	var start:Number;
	var end: Number;
	var callBack:Object;
	var root:MovieClip;
	
	// VARIABLEs
	var dif:Number;
	
	function FrameAnimManager(initObj){
		for(var elem in initObj){
			this[elem] = initObj[elem]
		}
		this.init();
	}
	
	function init(){
		
		// DEFAUT
		if( this.start == undefined ) 	this.start = 1;
		if( this.frame == undefined ) 	this.frame = this.start;
		if( this.end == undefined ) 	this.end = 21;
		if( this.flLoop == undefined ) 	this.flLoop = true;
		
		//INIT
		if(this.flLoop){
			this.dif = this.end - this.start;
		}

	}
	
	function update(coef){
		if(coef==undefined)coef=1;
		this.frame += kaluga.Cs.tmod*coef
		var f = Math.round(this.frame)
		
		if(f >= this.end){
			if(this.flLoop){
				while(f >= this.end){
					this.frame -= this.dif;
					f -= this.dif;
				}
			}else{
				f = this.end;
				this.callBack.obj[this.callBack.method](this.callBack.args)
			}
		}
		
		this.root.gotoAndStop(f)
	}
	
	
//{
}