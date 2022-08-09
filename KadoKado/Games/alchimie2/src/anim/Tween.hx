package anim ;


class Tween{

	public var sx:Float ;
	public var sy:Float ;
	public var ex:Float ;
	public var ey:Float ;

	public var mc : flash.MovieClip ;

	public function new(sx,sy,ex,ey, m) {
		this.sx = sx ;
		this.ex = ex ;
		this.sy = sy ;
		this.ey = ey ;
		this.mc = m ;
	}

	public function update(c : Float) {
		mc._x = sx*(1 - c) + ex * c ;
		mc._y = sy*(1 - c) + ey * c ;
	}

}