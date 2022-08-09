class miniwave.panel.LetterLife extends MovieClip{//}


	// VARIABLE
	var game:miniwave.Game;
	var depthRun:Number;
	
	var mcList:Array;
	
	function LetterLife(){
		this.init();
	}
	
	function init(){
		
		this._x = this.game.mng.mcw;
		this._y = this.game.mng.mch;
		this.depthRun = 0
		this.mcList = new Array();

	}
	
	function addLife(n){
		if( n == undefined ) n = 1;
		for( var i=0; i<n; i++){
			var d = depthRun++
			this.attachMovie( "letterLife","life"+d, d );
			var mc = this["life"+d]
			mc._x = -(mcList.length+0.8)*12
			mc._y = -6
			//mc._xscale = (this.size*100)/20
			//mc._yscale = (this.size*100)/20
			mcList.push(mc)
		}
	}
	
	function removeLife(n){
		_root.test += "removeLife("+n+")\n"
		if( n == undefined ) n = 1;
		for( var i=0; i<n; i++){
			this.mcList.pop().gotoAndPlay("death");
		}
		return mcList.length == 0;
	}
	
	function update(){

	}
	

	
//{
}