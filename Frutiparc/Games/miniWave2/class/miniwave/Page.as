class miniwave.Page extends MovieClip{//}

	// CONSTANTES	
	var dp_box:Number =   100;
	
	// PARAMETRES
	var width:Number;
	var height:Number;
	
	
	// VARIABLES
	var flActive:Boolean;
	var boxList:Array;
	var depthRun:Number;
	var step:Number;

	
	// REFERENCES
	var menu:miniwave.Menu;
	
	
	function Page(){
		
	}
	
	function init(){
		this.flActive= true;
		this.boxList= new Array();
		this.depthRun = 0;
		this.step = 0;
		this.initBox();
		
		this.menu.mng.sfx.play( "sMenuPage")
		//this.mng.music.setVolume( 1, 50 )		
	}

	function initBox(){
		
	}	
	
	function update(){
		super.update();
		
		for( var i=0; i<this.boxList.length; i++){
			this.boxList[i].update();
		}
		
		switch(this.step){
			case 0:
				break;
			case 1:
				this._alpha *= 0.9
				if(this.boxList.length==0){
					this.kill();
				}
				break;
		}
		
	}
	
	
	function newBox(link,initObj){
		if( initObj == undefined )initObj = new Object();
		initObj.page = this;
		var d = this.depthRun++;
		this.attachMovie( link, "box"+d, this.dp_box+d,initObj )
		var mc = this["box"+d]
		this.boxList.push(mc)
		return mc;
		
	}
	
	function vanish(id){
		for( var i=0; i<this.boxList.length; i++ ){
			this.boxList[i].vanish(i*4);
		}
		this.step = 1
	}
	
	function removeBoxFromList(box){
		for( var i=0; i<this.boxList.length; i++ ){
			if( this.boxList[i] == box ){
				this.boxList.splice(i,1)
				break;
			}
			
		}
	}
	
	function menuIsActive(a){
		if( typeof a == "boolean" || typeof a == "number" || typeof a == "string")return a;
		for(var i=0; i<a.length; i++){
			if(a[i])return true;
		}
		return false;
	}
	
	function select(id){
	
	}
	
	function rOver(id){
	
	}
	
	function rOut(id){
	
	}	

	
	function kill(){
		while(this.boxList.length>0)this.boxList.pop().kill();
		this.removeMovieClip();
	}
	

	
	
	
	
	
//{
}