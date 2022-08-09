import mt.bumdum.Lib;

class Element {//}

	public var x:Float;
	public var y:Float;

	public var vx:Float;
	public var vy:Float;
	public var frict:Float;
	public var weight:Float;

	public var root:flash.MovieClip;

	public function new(mc){
		root = mc;
		vx = 0;
		vy = 0;
		Game.me.elements.push(this);
	}

	public function update(){

		if(weight!=null ) vy+= weight;

		if( frict!=null ){
			vx *= frict;
			vy *= frict;
		}

		x += vx;
		y += vy;

		updatePos();

	}

	public function updatePos(){
		if( x == null ){
			trace("ERROR x===NULL ");
			return;
		}
		x = Num.sMod(x,Cs.lw);
		root._x = Std.int(x);
		root._y = Std.int(y);
		//root._x = x;
		//root._y = y;
	}

	public function kill(){
		root.removeMovieClip();
		Game.me.elements.remove(this);
	}



//{
}










