package mt.deepnight.mui;

class Separator extends Component {
	var vertical		: Bool;
	public function new(p, vertical:Bool, ?size=10) {
		super(p);
		this.vertical = vertical;
		minWidth = minHeight = size;
		color = 0xFFFFFF;
	}


	public function setHorizontal() {
		vertical = false;
		askRender(false);
	}

	public function setVertical() {
		vertical = true;
		askRender(false);
	}


	override function renderBackground(w:Float,h:Float) {
		bg.graphics.clear();
		bg.graphics.lineStyle(1, color, 0.1, true, flash.display.LineScaleMode.NONE);
		if( vertical ) {
			bg.graphics.moveTo(w*0.5, 0);
			bg.graphics.lineTo(w*0.5, h);
		}
		else {
			bg.graphics.moveTo(0, h*0.5);
			bg.graphics.lineTo(w, h*0.5);
		}
	}

	override function getContentWidth() {
		return super.getContentWidth();
	}

	override function getContentHeight() {
		return super.getContentHeight();
	}
}