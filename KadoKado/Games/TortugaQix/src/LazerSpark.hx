import geom.Pt;
import flash.geom.Point;
import flash.display.Shape;

@:bind class Etincelle extends flash.display.MovieClip {
	public function new(){
		super();
	}
}

/*
  This spark starts at the begining of the drawing, follows the drawing and kills the player if it reach him.
 */
class LazerSpark {
	public static var shape = new Etincelle();
	public var pos : Point;
	public var oldPos : Point;
	public var vector : Pt;
	public var movePower : Float;

	public function new(){
		pos = new Point(Game.drawStart.x, Game.drawStart.y);
		oldPos = pos.clone();
		vector = Game.drawVector.clone();
		movePower = 0.0;
	}

	public function update(){
		if (vector == null)
			return;
		var rspeed = movePower + Game.level.lazerSparkSpeed*mt.Timer.tmod;
		var speed = Math.round(rspeed);
		movePower = rspeed - speed;
		for (step in 0...speed){
			var pixels = Game.getDrawingPixels(Math.round(pos.x), Math.round(pos.y));
			var possibilities = [ vector, Direction.leftOf(vector), Direction.rightOf(vector) ];
			vector = null;
			for (vect in possibilities){
				if (vect == null)
					continue;
				var color = pixels[Direction.d2i(vect)];
				if (Colors.isDrawingPath(color)){
					vector = vect;
					break;
				}
			}
			if (vector != null){
				oldPos.x = pos.x;
				oldPos.y = pos.y;
				pos.x += vector.x;
				pos.y += vector.y;
			}
			else {
				return;
			}
		}
	}
}
