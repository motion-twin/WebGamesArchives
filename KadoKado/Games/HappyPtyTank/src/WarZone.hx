@:bind
class WarZone extends flash.display.Sprite {
	public var minX : Float;
	public var maxX : Float;
	public var minY : Float;
	public var maxY : Float;

	public function new(){
		super();
		visible = false;
	}

	public function init(x:Float, y:Float){
		minX = x - Game.W;
		maxX = x + Game.W + 20;
		minY = y - Game.H;
		maxY = y + Game.H + 20;
		this.x = minX;
		this.y = minY;
		visible = true;
	}

	public function destroy(){
		visible = false;
	}

	public function getPoint( x:Float, y:Float ) : flash.geom.Point {
		if (x < 0)
			x = (maxX - minX) + x;
		if (y < 0)
			y = (maxY - minY) + y;
		return new flash.geom.Point(minX + x, minY + y);
	}

	public function isOutOfZone( p:{x:Float, y:Float} ) : Bool {
		return p.x < minX ||
			p.x > maxX ||
			p.y < minY ||
			p.y > maxY;
	}

	public function recall( p:{x:Float, y:Float} ){
		if (p.x < minX)
			p.x = minX;
		if (p.x > maxX)
			p.x = maxX;
		if (p.y > maxY)
			p.y = maxY;
		if (p.y < minY)
			p.y = minY;
	}
}