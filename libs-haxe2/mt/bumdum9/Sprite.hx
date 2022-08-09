package mt.bumdum9;
import mt.bumdum9.Lib;

class Sprite<T:flash.display.MovieClip> {//}

	static public var spriteList:Array<Sprite<Dynamic>> = new Array();

	public var x:Float;
	public var y:Float;
	public var root:T;
	public var scale:Float;

	public function new(?mc){
		root = mc;

		// 'obj' est bien un champ obfusqué
		//var mmc = cast root;
		//mmc.obj = this;
		// au cas où la lib n'est pas obfusquée..
		//untyped root["obj"] = this;

		spriteList.push(this);

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
		root.x = x;
		root.y = y;
	}

	public function kill(){
		if( root.parent!=null) root.parent.removeChild(root);
		spriteList.remove(this);
	}

	public function updatePos(){
		root.x = x;
		root.y = y;
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



