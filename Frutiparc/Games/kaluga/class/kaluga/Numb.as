class kaluga.Numb extends MovieClip{//}

	// PARAMS
	var num:Number;
	var align:Number;
	var scale:Number;
	var link:String;
	
	// VARIABLES
	
	
	// MOVIECLIPS
	var compteur:MovieClip;
	
	function Numb(){
		//_root.test += "[Numb] init()\n"
		this.init();
	};
	
	function init(){
		if(align==undefined)align=1;
		if(scale==undefined)scale=100;		
		if(link==undefined)link="numberRed";		
		if(this.num)this.setNum(this.num);
	};
	
	function setNum(num){
		this.num = num;
		this.createEmptyMovieClip("compteur",1)
		var n = Number(num).toString();
		var x = 0;
		for( var i=0; i<n.length; i++ ){
			//_root.test+="."
			this.compteur.attachMovie(this.link,"n"+i,i)
			var mc = this.compteur["n"+i]
			var c = n.substr(i,1)
			if(c!="."){
				mc.gotoAndStop(Number(c)+1)
			}else{
				mc.gotoAndStop(11);
			}
			mc._x = x
			x += mc._width//-2;				
		};
		//_root.test+="\n"
		this.compteur._xscale = scale;
		this.compteur._yscale = scale;
		this.compteur._x = (-this.compteur._width/2)*align;		
	}
	
//{	
}