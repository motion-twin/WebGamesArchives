import mt.bumdum9.Lib;

class Sprite implements Dynamic {//}
	
	static public var LIST = [];

	public var x:Float;
	public var y:Float;
	public var root:flash.display.MovieClip;
	public var scale:Float;

	public function new(?mc:flash.display.MovieClip){
		root = cast mc;
		// 'obj' est bien un champ obfusqué
		var mmc = cast root;
		mmc.obj = this;
		// au cas où la lib n'est pas obfusquée..
		untyped root["obj"] = this;

		LIST.push(this);

		x = root.x;
		y = root.y;
		if(root.x==0 && root.y==0 ){
			root.x = -100;
			root.y = -100;
			x=0;
			y=0;
		}
		scale=1;
	}

	public function setScale(n){
		scale = n;
		root.scaleX =  n;
		root.scaleY =  n;
	}

	public function update(){
		updatePos();
	}

	public function kill() {
		if(root!=null && root.parent!=null) root.parent.removeChild(root);
		LIST.remove(this);
	}

	public function updatePos(){
		root.x = x;
		root.y = y;
	}

	public function recalPos(n=1){
		root.x = Std.int(x/n)*n;
		root.y = Std.int(y/n)*n;
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

	public function toward(o:{x:Float,y:Float},c:Float,?lim, ?limY){
		if(lim==null)lim=1/0;
		var dx = o.x - x;
		var dy = o.y - y;
		var nx = Num.mm(-lim,dx*c,lim);
		var ny = Num.mm(-lim,dy*c,lim);
		x += nx;
		y += if( limY == null ) ny else if( y + ny >= limY ) 0 else ny;
	}
//{
}



