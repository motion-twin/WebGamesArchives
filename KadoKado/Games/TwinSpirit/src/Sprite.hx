
class Sprite {//}

	public var x:Float;
	public var y:Float;
	public var root:flash.MovieClip;


	public function new(mc){
		Game.me.sprites.push(this);

		root = mc;
		Reflect.setField(root,"obj",this);
		x = 0;
		y = 0;
	}

	public function update(){
		updatePos();
	}

	public function updatePos(){
		root._x = x;
		root._y = y;
	}

	public function kill(){
		Game.me.sprites.remove(this);
		root.removeMovieClip();
	}


//{
}







