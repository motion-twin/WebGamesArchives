
class Sprite {//}

	public var x:Float;
	public var y:Float;
	public var scx:Float;
	public var scy:Float;
	public var root:flash.MovieClip;
	public var behaviours:Array<SpriteBehaviour>;


	public static var LIST:Array<Sprite> = [];


	public function new(mc){
		LIST.push(this);
		root = mc;
		Reflect.setField(root,"obj",this);
		x = 0;
		y = 0;
		scx = 1;
		scy = 1;
		behaviours = [];
	}

	public function update(){
		for( bh in behaviours )bh.update();
		updatePos();
	}

	public function updatePos(){
		root._x = x;
		root._y = y;
	}

	public function kill(){
		LIST.remove(this);
		root.removeMovieClip();
	}

	public function setScale(scx,?scy){
		this.scx = scx;
		this.scy = scx;
		if( scy != null ) this.scy = scy;
		root._xscale = scx*100;
		root._yscale = scy*100;
	}


//{
}







