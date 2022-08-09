class Inter {//}

	
	var width:int;
	var height:int;
	var margin:int;
	var skinFrame:int;
	var flashLight:float;
	var mx:float;
	var my:float;
	var link:String;
	var skin:MovieClip;
	var base:Base;
	
	
	function new(b){
		mx=0;
		my=0;
		margin = 0;
		skinFrame = 1
		base = b;
		base.interList.push(this);

	}
	
	function init(){
		skin = base.dm.attach( link, Base.DP_INTER );
	}
	
	function update(){

		if( flashLight !=null ){
			flashLight *= Math.pow(0.75,Timer.tmod)
			if( flashLight < 1 ) flashLight = 0;
			Mc.setPercentColor( skin, flashLight, 0xFFFFFF )
			if( flashLight == 0 ) flashLight = null;
			
		}
		
	};

	function flash(){
		flashLight = 100;
		Mc.setPercentColor( skin, flashLight, 0xFFFFFF )
	}
	
	
	
	
	
	
//{	
}