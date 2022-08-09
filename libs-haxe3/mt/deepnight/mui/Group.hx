package mt.deepnight.mui;

class Group extends Component {
	
	public static var DEFAUL_MARGIN = 5;
	public static var DEFAUL_PADDING = 5;
	
	public var margin(default,set)		: Int;
	public var padding(get,set)			: Int;
	public var hpadding(default,set)	: Int;
	public var vpadding(default,set)	: Int;
	var scale							: Float;

	private function new(p, ?margin, ?padding) {
		if (margin == null) margin = DEFAUL_MARGIN;
		if (padding == null) padding = DEFAUL_PADDING;
		super(p);
		this.margin = margin;
		this.padding = padding;
		scale = 1;
	}

	public function removeBorders(?keepPadding=false) {
		if( !keepPadding )
			padding = 0;
		hasBackground = false;
		askRender(true);
	}

	public function setScale(s:Float) {
		scale = s;
		wrapper.scaleX = wrapper.scaleY = s;
	}

	public function setPadding(horizontal:Int, vertical:Int) {
		hpadding = horizontal;
		vpadding = vertical;
	}

	function set_margin(v) {
		askRender(true);
		return margin = v;
	}

	function get_padding() {
		return mt.MLib.max(hpadding, vpadding);
	}

	function set_padding(v) {
		hpadding = vpadding = v;
		askRender(true);
		return v;
	}

	function set_hpadding(v) {
		askRender(true);
		return hpadding = v;
	}

	function set_vpadding(v) {
		askRender(true);
		return vpadding = v;
	}

	public function forceRenderNow() {
		prepareRender();
		render(getWidth(), getHeight());
	}

	override function askRender(structureChanged) {
		if( !renderAsked && structureChanged )
			for(c in children)
				c.askRender(structureChanged);

		super.askRender(structureChanged);
	}

	public inline function vgroup(?transparent=false) {
		var g = new VGroup(this);
		if( transparent )
			g.removeBorders();
		return g;
	}

	public inline function hgroup(?transparent=false) {
		var g = new HGroup(this);
		if( transparent )
			g.removeBorders();
		return g;
	}

	public inline function lgroup(?transparent=false) {
		var g = new LGroup(this);
		if( transparent )
			g.removeBorders();
		return g;
	}

	public inline function label(str, ?color=-1, ?size:Int) {
		var l = new Label(this, str);

		if( color!=-1 )
			l.setFontColor(color);

		if( size!=null )
			l.setFontSize(size);

		return l;
	}

	public inline function labelMultiline(str, ?color:UInt, ?size:Int) {
		var l = label(str, color, size);
		l.multiline = true;
		l.setHAlign(Left);
		return l;
	}

	public inline function button(label:String, ?minWid:Float, onClick:Void->Void) {
		var b = new Button(this, label, onClick);
		if( minWid!=null )
			b.minWidth = minWid;
		return b;
	}

	public inline function check(label:String, ?selected:Bool, onStateChange:Bool->Void) {
		return new Check(this, label, selected, onStateChange);
	}

	public inline function radio(label:String, ?selected:Bool, onStateChange:Bool->Void) {
		return new Radio(this, label, selected, onStateChange);
	}

	public inline function input(?defaultContent="", ?onValueChange:String->Void, ?numberOnly:Bool) {
		return new TextInput(this, defaultContent, onValueChange, numberOnly);
	}

	public inline function image(img:flash.display.DisplayObject, ?onDestroy:Void->Void) {
		return new Image(this, img, onDestroy);
	}

	public inline function inputReadOnly(?defaultContent="") {
		var i = new TextInput(this, defaultContent);
		i.readOnly = true;
		return i;
	}

	public function separator(?col=0xFFFFFF, ?transparent=false) {
		var s = new Separator(this, true);
		s.hasBackground = !transparent;
		s.color = col;
		return s;
	}

}
