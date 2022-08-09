class Tip extends flash.display.Sprite {
	var text : flash.text.TextField;
	static var BORDER = 0x6982a1;
	static var BACKGROUND = 0x532919;
	static var TEXT = 0xf5db50;
	
	function new(){
		super();
		text = new flash.text.TextField();
		text.autoSize = flash.text.TextFieldAutoSize.LEFT;
		text.selectable = false;
		text.multiline = true;
		text.textColor = TEXT;
		addChild(text);
		filters = [
			new flash.filters.DropShadowFilter(5, 45, 0x000000, 0.5, 5, 5)
		];
		x = 30;
		y = 30;
	}

	function setText( str:String ){
		text.htmlText = str;
				var fmt = new flash.text.TextFormat();
		fmt.font = "Arial";
		text.setTextFormat(fmt);
		graphics.clear();
		Progression.fillRect(this, BORDER, -10, -1, text.width + 20, text.height + 2);
		Progression.fillRect(this, BACKGROUND, -9, 0, text.width + 18, text.height);
	}

	static var instance : Tip;

	public static function init(){
		if (instance != null)
			throw "Tip already initialized";
		instance = new Tip();
		flash.Lib.current.addChild(instance);
		hide();
	}
	
	public static function show( txt:String ){
		instance.setText(txt);
		instance.visible = true;
		flash.Lib.current.addChild(instance);
		instance.x = flash.Lib.current.mouseX - instance.width / 2 + 20;
		instance.y = flash.Lib.current.mouseY + 10;
		if (instance.x < 5)
			instance.x = 5;
		if (instance.x + instance.width > Progression.W - 5)
			instance.x = Progression.W - instance.width - 5;
				
	}
	
	public static function hide(){
		if (instance.visible){
			instance.visible = false;
			flash.Lib.current.removeChild(instance);
		}
	}
}