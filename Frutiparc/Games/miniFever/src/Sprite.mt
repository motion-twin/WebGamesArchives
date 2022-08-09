class Sprite{//}
	
	// VARIABLES
	var x:float;
	var y:float;
	var typeList:Array<int>;
	var skin:MovieClip;
	var parent:MovieClip;
	// REFERENCES
	var game:Game;	
	
	
	function new(){
		//super();
		typeList = new Array();
		initDefault();
	}
	
	function init(){
		//Log.trace( "[SPRITE] init()\n" );
		addToList(Cs.SPRITE);
		skin._x = x;
		skin._y = y;
	}

	function initDefault(){
		x = 0;
		y = 0;
	}
	
	function setSkin(mc){
		skin = mc;
		Std.cast(skin).obj = this
	}
	
	function blastSkin(mc){
		skin.removeMovieClip();
		setSkin(mc)
	}
	
	function update(){
		
		skin._x = x
		skin._y = y	
	}

	function kill(){
		removeFromList();
		skin.removeMovieClip();
	}
	
	// LIST
	
	function addToList(id){
		game.mcList[id].push(this);
		typeList.push(id);
	}
	
	function removeFromList(){
		var list = typeList;
		//Log.trace("done!")
		for( var n=0; n<list.length; n++){
			//Log.trace("--")
			var a = game.mcList[list[n]]
			for(var i=0; i<a.length; i++){
				//Log.trace("found")
				if( a[i] == this ){
					a.splice(i,1);
					break;
				}
			}			
		}
	}
	
	// UTILS
	
	function hTest( x , y ){
		var o  = skin.getBounds(skin._parent);
		return o.xMin < x && x < o.xMax && o.yMin < y && y < o.yMax
	}
	
	/* function shapeHitTest( x , y ){
		return skin.hitTest(x,y,true)
	}
	*/
	
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
	
	function toward(o,c,lim){
		if(lim==null)lim = 1/0 //Infinity
		var dx = o.x - x
		var dy = o.y - y
		x += Math.min( Math.max( -lim, dx ), lim ) * c * Timer.tmod
		y += Math.min( Math.max( -lim, dy ), lim ) * c * Timer.tmod
	}

	
	
//{
}