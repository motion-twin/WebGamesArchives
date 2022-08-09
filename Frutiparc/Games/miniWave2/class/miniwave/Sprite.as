class miniwave.Sprite extends MovieClip{//}

	// VARIABLES
	var depth:Number;
	var x:Number;
	var y:Number;
	
	// REFERENCES
	var game:miniwave.Game;
	
	
	function Sprite(){
	
	}
	
	function init(){
		this.initDefault();
		this._x = this.x
		this._y = this.y
	}
	
	function initDefault(){
		if( this.x == undefined )		this.x = 0;
		if( this.y == undefined )		this.y = 0;
	}
	
	function update(){
	
	}
	
	function endUpdate(){
		this._x = this.x
		this._y = this.y
	}
	
	function kill(){
		this.game.releaseDepth(this)
		this.game.removeFromList( this, this.game.spriteList );
		this.removeMovieClip();
	}
	
	function hTest( x , y ){ // A CODER
		//_root.test = "hTest("+x+","+y+")\n"
		var o  = this.getBounds(_parent);
		
		return o.xMin < x && x < o.xMax && o.yMin < y && y < o.yMax
		
		
		//return this.hitTest(x,y)
	}
	
	function getDist(o){
		var dx = o.x - this.x
		var dy = o.y - this.y
		return Math.sqrt( dx*dx + dy*dy )
	}
	
	function getAng(o){
		var dx = o.x - this.x
		var dy = o.y - this.y
		return Math.atan2( dy, dx )
	}		
	
//{	
}