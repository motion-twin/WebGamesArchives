package fx;

class Load extends flash.display.Sprite {

	var size : Float;
	var text : flash.text.TextField;
	public var percentVisible(getPV,setPV) : Bool;
	public var color : Int;
	public var progress(default,setProgess) : Float;
	
	public function new( ?color = 0xC93814 ) {
		super();
		size = 260;
		progress = 0;
		this.color = color;
		filters = [ new flash.filters.GlowFilter(color, 1, 8, 8, 1) ];
	}

	public function center() {
		x = Std.int((stage.stageWidth - width)*0.5);
		y = Std.int((stage.stageHeight - height)*0.5);
	}

	function setProgess( v : Float ) {
		if( v < 0 ) v = 0 else if( v > 1 ) v = 1;
		progress = v;

		var g = graphics;
		g.clear();
		g.beginFill(color, 0.25);
		g.lineStyle(1, color, 0.7, true);
		g.drawRect(0,0,300,4);
		
		g.lineStyle(0,0,0);
		g.beginFill(color,1);
		g.drawRect(v * size, 0, 40, 4);
		
		if( text != null )
			text.text = Std.string(Std.int(v * 100) + "%");
		
		return v;
	}
	
	function getPV() {
		return text != null;
	}
	
	function setPV(v) {
		if( text != null ) {
			removeChild(text);
			text = null;
		}
		if( !v )
			return false;
		text = new flash.text.TextField();
		text.width = 40;
		text.height = 20;
		text.textColor = color;
		text.mouseEnabled = false;
		text.x = Std.int(width * 0.5);
		text.y = 3;
		addChild(text);
		setProgess(progress);
		return true;
	}
		
}