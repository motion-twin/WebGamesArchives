import mt.bumdum.Lib;

class Sprite {//}

	static public var spriteList:Array<Sprite> = new Array();
	
	public var x:Float;
	public var y:Float;
	public var root:flash.MovieClip;
	public var scale:Float;
	
	public function new(?mc:flash.MovieClip){
		root = cast mc;
		
		// 'obj' est bien un champ obfusqué
		var mmc = cast root;
		mmc.obj = this;
		// au cas où la lib n'est pas obfusquée..
		untyped root["obj"] = this;
		
		spriteList.push(this);
		
		x = root._x;
		y = root._y;
		if(root._x==0 && root._y==0 ){
			root._x = -100;
			root._y = -100;
			x=0;	
			y=0;	
		}
		scale=100;
	}
	
	public function setScale(n){
		scale = n;
		root._xscale =  n;
		root._yscale =  n;
	}
	
	public function update(){

		root._x = x;
		root._y = y;
	}
	
	public function kill(){
		root.removeMovieClip();
		spriteList.remove(this);
	}
	
	public function updatePos(){
		root._x = x;
		root._y = y;
	}
	
	public function getDist(o:{x:Float,y:Float}){
		var dx = o.x - x;
		var dy = o.y - y;
		return Math.sqrt( dx*dx + dy*dy );
	}
	
	public function getAng(o:{x:Float,y:Float}){
		var dx = o.x - x;
		var dy = o.y - y;
		return Math.atan2( dy, dx );
	}	

	public function toward(o:{x:Float,y:Float},c:Float,?lim){
		if(lim==null)lim=1/0;
		var dx = o.x - x;
		var dy = o.y - y;
		x += Num.mm(-lim,dx*c,lim);
		y += Num.mm(-lim,dy*c,lim);
	}
//{
}



