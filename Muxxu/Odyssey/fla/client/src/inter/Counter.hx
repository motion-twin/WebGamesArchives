package inter;
import Protocole;
import mt.bumdum9.Lib;


class Counter extends SP {//}


	
	//public var icon:mt.pix.Element;
	public var icon:MC;
	public var field:TF;
	var digits:Int;
	var value:Int;
	public var gid:Int;
	var max:Null<Int>;
	
	
	public function new(gid:Int,stock=false) {
		super();
		this.gid = gid;
		var size = 16;
		value = 0;
		
		//icon = new mt.pix.Element();
		//icon.goto(gid,"small",0,0);
		icon = new BaseIcons();
		if (stock) {
			icon = new GameIcons();
			icon.scaleX = icon.scaleY = 0.75;
		}
		icon.gotoAndStop(gid + 1);
		//icon.width = 16;
		//icon.scaleY = icon.scaleX;
		Filt.glow(this, 3, 2);
		
		field = Cs.getField(0xFFFFFF, 16, "diogenes");
		//field.textColor = 0xFF0000;
		field.wordWrap = field.multiline = false;
		field.height = 28;
		field.x = size -1 ;
		field.y = -4;
		
		maj();
		//setDigits(1);
	
		addChild(icon);
		addChild(field);
	}
	
	public function goto(gid) {
		icon.gotoAndStop(gid+1);
	}
	
	public function set(n:Int) {
		value = n;
		maj();
	}
	
	
	public function setDigits(n) {
		digits = n;
		adjustWidth();
		maj();
	}
	/*
	public function setMax(n) {
		max = n;
		adjustWidth();
		maj();
	}
	*/
	
	
	function adjustWidth() {
		//var ww = 20 * digits;
		//if ( max != null ) ww = ww * 2 + 16;
		field.width = field.textWidth+5;
		
	}
	
	function maj() {
		var str = Std.string(value);
		while (str.length < digits ) str = "0" + str;
		if ( max != null ) str += "/" + max;
		field.text = str;
		adjustWidth();
	}
	
	
	
	
//{
}