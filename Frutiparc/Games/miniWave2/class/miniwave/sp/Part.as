class miniwave.sp.Part extends miniwave.Sprite {//}

	
	var flGrav:Boolean;
	var flOrient:Boolean;
	
	var fadeType:Number;
	
	var timer:Number;
	var vitx:Number;
	var vity:Number;
	var vitr:Number;
	var weight:Number;
	//var accx:Number;
	//var accy:Number;
	
	function Part(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Part] init()\n"
		super.init();
	}
	
	function initDefault(){
		super.initDefault()
		if( this.flGrav == undefined ) 		this.flGrav =	true;
		if( this.flOrient == undefined ) 	this.flOrient =	false;
		if( this.vitx == undefined ) 		this.vitx=0;
		if( this.vity == undefined ) 		this.vity=0;
		if( this.vitr == undefined )		this.vitr=0;
		//if( this.accx == undefined )		this.accx=0;
		//if( this.accy == undefined )		this.accy=0;
		if( this.weight == undefined )		this.weight=0.5;
	}
	
	
	function update(){
		super.update();
		
		if(this.flGrav){
			this.vity += this.game.gravite*this.weight*Std.tmod
		};
		
		//this.vitx += this.accx
		//this.vity += this.accy
		
		this.vitx *= this.game.frict;
		this.vity *= this.game.frict;
		this.vitr *= this.game.frict;
		
		this.x += this.vitx*Std.tmod;
		this.y += this.vity*Std.tmod;
		this._rotation += this.vitr;
		
		if( this.timer != undefined ){
			this.timer -= Std.tmod;
			if(this.timer<0){
				this.kill();
			}else if(this.timer<10){
				switch(this.fadeType){
					case 1:
						this._xscale = this.timer*10
						this._yscale = this.timer*10
						break;
					default:
						this._alpha = this.timer*10;
						break;
				}
			}
		};
		
		if( this.flOrient ){
			//_root.test+="-\n"
			var a = Math.atan2(this.vity,this.vitx);
			this._rotation = a/(Math.PI/180);
		};
		
		this.endUpdate();
	}
	
	function kill(){
		this.game.removeFromList( this, this.game.partList );
		super.kill();
	}
	
	
	
//{	
}