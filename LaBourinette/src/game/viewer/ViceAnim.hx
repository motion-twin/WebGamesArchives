package game.viewer;
import game.viewer.TransitionFunctions;

class ViceAnim extends flash.display.Sprite {
	static var TOTAL = 20;
	var step : Int;
	var star : Star;
	var player : FieldPlayer;
	var grow : Float -> Float;
	var rotate : Float -> Float;

	public function new( p:FieldPlayer ){
		super();
		player = p;
		star = new Star(1, 3, 12);
		star.fillColor = 0xAAAAAA;
		star.lineSize = 2;
		star.lineColor = 0x444444;
		star.filters = [
			new flash.filters.GlowFilter(0x000000, 0.5, 2, 2, 1, 1)
		];
		alpha = 0.5;
		addChild(star);
		blendMode = flash.display.BlendMode.OVERLAY;
		step = 0;
		grow = TransitionFunctions.get(Sine(In));
		rotate = TransitionFunctions.get(Pow(3.0));
	}

	public function update() : Bool {
		var ratio = step / TOTAL;
		x = player.x;
		y = player.y;
		star.controlRadius = 3 + 3 * TransitionFunctions.loop(grow(ratio));
		star.internalRadius = 1 + 2 * TransitionFunctions.loop(grow(ratio));
		star.draw();
		star.rotation = 180 * Math.PI * rotate(ratio);
		++step;
		if (step >= TOTAL){
			stop();
			return false;
		}
		return true;
	}

	public function stop() : Void {
		if (parent != null)
			parent.removeChild(this);
	}
}
