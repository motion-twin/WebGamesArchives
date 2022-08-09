class Sprite{//}
	
	// VARIABLES
	var x:float;
	var y:float;
	var skin:MovieClip;
		
	function new(){

		initDefault();
	}
	
	function init(){
		skin._x = x;
		skin._y = y;
	}

	function initDefault(){
		x = 0;
		y = 0;
	}
	
	function setSkin(mc){
		if(skin!=null)skin.removeMovieClip();
		skin = mc;
		Std.cast(skin).obj = this
	}
	
	function update(){
		skin._x = x
		skin._y = y	
	}

	function kill(){
		skin.removeMovieClip();
	}

	
	// UTILS
	function hTest( x , y ){
		var o  = skin.getBounds(skin._parent);
		return o.xMin < x && x < o.xMax && o.yMin < y && y < o.yMax
	}
	
	function getDist(o){
		var dx = o.x - x
		var dy = o.y - y
		return Math.sqrt( dx*dx + dy*dy )
	}
	
	function getAng(o){
		var dx = o.x - x
		var dy = o.y - y
		return Math.atan2( dy, dx )
	}		
	
	function toward(o,c){
		var dx = o.x - x
		var dy = o.y - y
		x += dx*c*Timer.tmod
		y += dy*c*Timer.tmod
	}
	

	
//{
}