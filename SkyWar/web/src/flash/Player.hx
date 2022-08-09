typedef Pl = {
	var _id : Int;
	var _name : String;
	var _color : Int;
	var _data : List<Int>;
};

class Player extends flash.display.Sprite {
	public var data : Pl;
	var line : flash.display.Sprite;
	
	public function new( data:Pl ){
		super();
		buttonMode = true;
		useHandCursor = true;
		mouseChildren = false;
		this.data = data;
		var txt = new flash.text.TextField();
		var tf = new flash.text.TextFormat();
		tf.font = "Arial"; //, Helvetica, sans-serif";
		tf.size = 14;
		tf.bold = true;
		txt.autoSize = flash.text.TextFieldAutoSize.RIGHT;
		txt.setTextFormat(tf);
		txt.selectable = false;
		txt.textColor = 0xE5A54E;
		txt.text = data._name.charAt(0).toUpperCase() + data._name.substr(1);
		txt.setTextFormat(tf);
		txt.x = 15;
		addChild(txt);
		var spr = new flash.display.Sprite();
		Progression.fillRect(spr, 0x303437, 0, 0, 13, 13);
		Progression.fillRect(spr, Progression.colors[data._color], 1, 1, 11, 11);
		spr.y = 3;
		spr.x = 2;
		addChild(spr);

		var me = this;
		addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_){ 
				me.filters = [ new flash.filters.GlowFilter(0xFFFF00, 0.4, 2, 2) ];
			});
		addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_){
				me.filters = [];
			});
		addEventListener(flash.events.MouseEvent.CLICK, function(_){
				me.enable();
			});
	}

	public function setLine( s:flash.display.Sprite ){
		line = s;
	}

	public function getValue( tick6:Float ) : Int {
		var prev = 0;
		var next = 0;
		for (v in data._data){
			next = v;
			if (--tick6 <= 0)
				break;
			prev = v;
		}
		if (tick6 == 0.0)
			return next;
		if (tick6 < 0)
			return Math.round(next - (next - prev) * Math.abs(tick6));
		return Math.round(prev + (next - prev) * tick6);
	}

	static var current : Player;
	
	public function enable(){
		if (current == this)
			return;
		if (current != null)
			current.disable();
		current = this;
		activate();		
	}
	
	function activate(){
		for (e in Progression.events){
			e.visible = e.filter(data._id);
			if (e.visible){
				e.y = Event.DEFAULT_Y;
			}
		}
		Progression.dispatchEvents(this);
		line.alpha = 1;
		line.filters = [
			Progression.FILTER_LINE_ACTIVE
		];
	}

	function disable(){
		line.alpha = Progression.ALPHA_LINE_INACTIVE;
		line.filters = [
			Progression.FILTER_LINE_INACTIVE
		];
	}
}