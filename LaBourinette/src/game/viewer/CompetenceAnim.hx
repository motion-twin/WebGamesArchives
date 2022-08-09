package game.viewer;
import game.viewer.TransitionFunctions;

class CompetenceAnim extends flash.display.Sprite {
	static var TOTAL = 20;
	var step : Int;
	var star : Star;
	var player : FieldPlayer;
	var grow : Float -> Float;
	var rotate : Float -> Float;
	var target : FieldPlayer;
	var tstar : Star;

	public function new( p:FieldPlayer, ?t:FieldPlayer ){
		super();
		player = p;
		star = new Star(1, 3, 12);
		star.fillColor = 0x98cdf4;
		star.lineSize = null;
		star.filters = [
			new flash.filters.GlowFilter(0xA0CDFF, 0.5, 2, 2, 1, 1)
		];
		addChild(star);
		blendMode = flash.display.BlendMode.OVERLAY;
		step = 0;
		grow = TransitionFunctions.get(Sine(In));
		rotate = TransitionFunctions.get(Pow(3.0));
		if (t != null){
			target = t;
			tstar = new Star(1, 3, 3);
			tstar.fillColor = 0x777777;
			tstar.lineColor = 0xFF0000;
			tstar.lineSize = 0.2;
			tstar.filters = [
				new flash.filters.GlowFilter(0xA0CDFF, 0.5, 2, 2, 1, 1)
			];
			addChild(tstar);
		}
	}

	public function update() : Bool {
		var ratio = step / TOTAL;
		x = player.x;
		y = player.y;
		star.controlRadius = 3 + 3 * TransitionFunctions.loop(grow(ratio));
		star.internalRadius = 1 + 2 * TransitionFunctions.loop(grow(ratio));
		star.draw();
		star.rotation = 180 * Math.PI * rotate(ratio);
		if (tstar != null){
			tstar.x = target.x - x;
			tstar.y = target.y - y;
			tstar.controlRadius = 3 + 5 * TransitionFunctions.loop(grow(ratio));
			tstar.internalRadius = 1 + 3 * TransitionFunctions.loop(grow(ratio));
			tstar.draw();
			tstar.rotation = 180 * Math.PI * rotate(ratio);
		}
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
