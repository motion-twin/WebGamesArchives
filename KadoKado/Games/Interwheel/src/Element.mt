class Element{//}
	
	var flRemove:bool;
	
	var x:float;
	var y:float;
	var ray:float;
	var root:MovieClip;
	
	var skin:String;

	
	
	function new(){
		flRemove = false;
	}
	
	function update(){

	}
	
	function attach(){
		root = Cs.game.dm.attach(skin,Game.DP_WHEEL)
		root._x = x;
		root._y = y;
	}
	
	function detach(){
		root.removeMovieClip();
		root = null
	}
	
	
//{
}