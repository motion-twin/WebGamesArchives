class kaluga.Bar extends MovieClip{//}

	var width:Number
	var margin:Object;
	var infoBar:kaluga.InfoBar;
	
	function Bar(){
	
	}
	
	function init(){
		this.initDefault()
	}
	
	function initDefault(){
		if( this.width == undefined ) this.width = 10;
		if( this.margin == undefined ) this.margin = {x:{ratio:0.5,min:6},y:{ratio:0,min:3}};
	}
	
	function update(){
	
	}
	
	function kill(){
		this.infoBar.removeElement(this)
		this.removeMovieClip();
	}

//{	
}