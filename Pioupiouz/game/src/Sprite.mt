class Sprite{//}

	var x:float;
	var y:float;
	var root:MovieClip;
	
	function new(mc){
		root = mc;
		downcast(root).obj = this;
		Cs.game.sList.push(this)
		x=0;
		y=0;
		root._x = -100
		root._y = -100
	}
	
	function update(){
		
		root._x = x;
		root._y = y;
	}
	
	function kill(){
		root.removeMovieClip();
		Cs.game.sList.remove(this)
	}
	
	function updatePos(){
		root._x = x;
		root._y = y;
	}
	
	function getDist(o){
		var dx = o.x - x;
		var dy = o.y - y;
		return Math.sqrt( dx*dx + dy*dy );
	}
	
	function getAng(o){
		var dx = o.x - x;
		var dy = o.y - y;
		return Math.atan2( dy, dx );
	}	

	// UTILS
	function isOut(m){
		return ( x<-m || x>Level.bmp.width+m || y<-m || y>Level.bmp.height+m )
	}
	
//{
}