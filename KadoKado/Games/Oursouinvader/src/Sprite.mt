class Sprite{

	var x:float;
	var y:float;
	var root:{>MovieClip,obj:Sprite};
	var scale:float;
	
	
	function new(mc:MovieClip){
		root = downcast(mc);
		root.obj = this;
		Cs.game.sList.push(this)
		x=0;
		y=0;
		root._x = -100
		root._y = -100
		scale=100
	}
	
	function setScale(n){
		scale = n
		root._xscale =  n
		root._yscale =  n
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

	function toward(o,c,lim){
		var a = getAng(o)
		var dx = o.x - x;
		var dy = o.y - y;
		x += Cs.mm(-lim,dx*c,lim)
		y += Cs.mm(-lim,dy*c,lim)
	}
	

	// UTILS
	function isOut(m){
		return ( x<-m || x>Cs.mcw+m || y<-m || y>Cs.mch+m )
	}
	

}