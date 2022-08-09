@:bind
class Shot extends flash.display.MovieClip {
	public static var TOTAL_FRAMES = 9;
	public static var COLOR = 0;
	public var dx : Float;
	public var dy : Float;
	public var speed : Float;
	public var power : Int;
	public var col1 : flash.display.MovieClip;

	public function new( vec, color:Int ){
		super();
		this.speed = 4.0 * (60 / mt.Timer.wantedFPS);
		this.power = 10;
		this.dx = vec.x;
		this.dy = vec.y;
		ColorSet.setColor(col1, Game.color.getColor(color));
	}

	public static function nextColor(){
		COLOR = ++COLOR % TOTAL_FRAMES;
	}

	public function update(){
		x += dx * speed * mt.Timer.tmod;
		y += dy * speed * mt.Timer.tmod;
	}
}