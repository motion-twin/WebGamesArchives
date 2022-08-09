package mt.deepnight.hui;

import mt.deepnight.hui.Style;

class Group extends Component {
	public static var DEFAUL_MARGIN = 5;

	public var margin(default,set)		: Int;

	private function new(p, ?margin) {
		if (margin == null) margin = DEFAUL_MARGIN;
		super(p);
		this.margin = margin;
		setCursor(Default);
	}

	public function makeTransparent(?keepPadding=false) {
		if( !keepPadding )
			style.padding = 0;
		style.bg = None;
		disableInteractive();
	}

	function set_margin(v) {
		askRender(true);
		return margin = v;
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

	public function vgroup(?transparent=false) : VGroup{
		var g = new VGroup(this);
		if( transparent )
			g.makeTransparent();
		return g;
	}

	public function hgroup(?transparent=false) : HGroup{
		var g = new HGroup(this);
		if( transparent )
			g.makeTransparent();
		return g;
	}

	public function lgroup(?transparent=false) : LGroup{
		var g = new LGroup(this);
		if( transparent )
			g.makeTransparent();
		return g;
	}

	public function label(str, ?color=-1, ?size:Int, ?align:HAlign) {
		var l = new Label(this, str);

		if( color!=-1 )
			l.style.textColor = color;

		if( size!=null )
			l.style.fontSize = size;

		if( align!=null )
			l.style.contentHAlign = align;

		return l;
	}

	public function button(label:String, ?minWid:Float, onClick:Void->Void) {
		var b = new Button(this, label, onClick);
		if( minWid!=null )
			b.minWidth = minWid;
		return b;
	}

	public function imageButton(tile:h2d.Tile, ?padding:Int, onClick:Void->Void) {
		var b = new ImageButton(this, tile, onClick);
		if( padding!=null )
			b.style.padding = padding;
		return b;
	}

	public function check(label:String, ?selected:Bool, onStateChange:Bool->Void) {
		return new Check(this, label, selected, onStateChange);
	}

	public function radio(label:String, ?selected:Bool, onStateChange:Bool->Void) {
		return new Radio(this, label, selected, onStateChange);
	}

	public function input(?defaultContent="", ?numbersOnly:Bool, ?onConfirm:String->Void) {
		var i = new Input(this, defaultContent);
		i.onConfirm = onConfirm;
		i.numbersOnly = numbersOnly;
		return i;
	}

	public function image(?tile:h2d.Tile, ?graphics:h2d.Graphics) {
		return new Image(this, tile, graphics);
	}

	//public function inputReadOnly(?defaultContent="") {
		//var i = new TextInput(this, defaultContent);
		//i.readOnly = true;
		//return i;
	//}

	public function separator(?col=0xFFFFFF, ?alpha=0.1, ?transparent=false) {
		var s = new Separator(this, false);
		s.style.bg = transparent ? None : Col(col, alpha);
		return s;
	}

}
