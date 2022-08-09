package game.viewer;

/*
 * A lifebar which is updated and animated to indicate life loss.
 */
class LifeBar extends flash.display.Shape {
	var size : Int;
	var max : Int;
	var cur : Int;
	var trg : Int;

	public function new(v:Int, m:Int){
		super();
		size = 5;
		max = m;
		cur = v;
		trg = v;
		y = -3.5;
		render();
	}

	function render(){
		graphics.clear();
		var wTrg = (trg / max) * size;
		var wCur = (cur / max) * size;
		graphics.lineStyle(1, 0x999999, 1);
		graphics.moveTo(-wTrg/2, 0);
		graphics.lineTo( wTrg/2, 0);
		graphics.lineStyle(0.75, 0x000000, 0.8);
		graphics.moveTo(-wTrg/2, 0);
		graphics.lineTo( wTrg/2, 0);
		graphics.lineStyle(0.75, 0xEE0000, 1);
		graphics.moveTo(-wCur/2, 0);
		graphics.lineTo( wCur/2, 0);
	}

	public function isStable() : Bool {
		return cur == trg;
	}

	public function update( ?newV:Int ){
		if (newV != null)
			trg = newV;
		if (cur != trg){
			var d = (trg - cur);
			if (d < 0)
				cur = cur + Std.int(Math.min(-1, Math.round(d/10)));
			else
				cur = cur + Std.int(Math.max(1, Math.round(d/10)));
			render();
		}
	}
}
