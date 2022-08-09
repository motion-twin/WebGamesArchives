
class Tween{
	public var sx:Float;
	public var sy:Float;
	public var ex:Float;
	public var ey:Float;

	public var sp:Sprite;

	public function new(sx,sy,ex,ey){
		this.sx = sx;
		this.ex = ex;
		this.sy = sy;
		this.ey = ey;
	}

	public function update(c:Float){

		sp.x = sx*(1-c) + ex*c;
		sp.y = sy*(1-c) + ey*c;
	}
}