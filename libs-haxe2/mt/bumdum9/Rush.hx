package mt.bumdum9;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;

class Rush implements haxe.Public {
	
	static function box(w,h,color=0xFF0000) {
		var sp = new SP();
		sp.graphics.beginFill(color, 1);
		sp.graphics.drawRect(0, 0, w, h);
		return sp;
	}
}

class RBar extends SP{
	
	var border:Int;
	var mcw:Int;
	var mch:Int;
	var colorBar:Int;
	
	public function new(ww,hh,col=0xFF0000) {
		super();
		border = 1;
		mcw = ww;
		mch = hh;
		colorBar = col;
		display(1);
	}
	
	public function display(coef:Float) {
		var gfx = graphics;
		gfx.clear();
		
		for ( i in 0...3 ) {
			var ma = i * border;
			var ww:Float = mcw-2*ma;
			var hh:Float = mch-2*ma;
			gfx.beginFill([0xFFFFFF, 0, colorBar][i]);
			if ( i == 2 ) ww *= coef;
			
			gfx.drawRect(ma, ma, ww, hh);
		}
	}
}

class PageNav {
	
	public var ready:Bool;
	public var index:Int;
	var a:Array<Dynamic>;
	var select:Int->Void;
	
	public var arrows:Array<SP>;
	public var buts:Array<SP>;
	
	public function new(arr,func) {
		a = arr;
		select = func;
		index = 0;
		ready = true;
		
		arrows = [];
		buts = [];
		
		for ( i in 0...2 ) {
			var sp = new SP();
			outArrow(sp);
			arrows.push(sp);
			buts.push(sp);
		}
		
		maj();
	}
	
	public function autoskin(size=20) {
		for ( i in 0...2 ) {
			var ar = arrows[i];
			var sens = i * 2 - 1;
			ar.graphics.beginFill(0xFFFFFF);
			ar.graphics.moveTo(size*sens,0);
			ar.graphics.lineTo(0,-size);
			ar.graphics.lineTo(0,size);
			ar.graphics.endFill();
		}
	}
	
	public function inc(n) {
		index += n;
		var max = a.length;
		while ( index >= max ) 	index -= max;
		while ( index < 0 )		index += max;
		select(index);
		maj();
	}
	
	public function maj() {
		for ( i in 0...2 ) {
			var ar = arrows[i];
			activeArrow( i, index != i*(a.length-1)  );
		}
	}
		
	public function setReady(flag) {
		ready = flag;
		maj();
	}
	public function setBut(i, but) {
		buts[i].removeEvents();
		buts[i] = but;
	}
	public function setIndex(i) {
		index = i;
		maj();
	}

	function activeArrow(aid:Int, flag) {
		var ar = arrows[aid];
		ar.visible = false;
		buts[aid].removeEvents();
		if ( flag && ready ) {
			buts[aid].makeBut( callback(click, aid), callback(overArrow, ar), callback(outArrow, ar) );
			ar.visible = true;
		}
	}
	
	function click(aid) {
		inc(aid * 2 - 1);
		outArrow(arrows[aid]);
	}
	
	function overArrow(ar:SP) {
		ar.alpha = 1;
	}
	
	function outArrow(ar:SP) {
		ar.alpha = 0.2;
	}
	
	
}

class HTML implements haxe.Public{
	static function col(str,color) {
		return "<font color='" + Col.getWeb(color) + "'>" + str + "</font>";
	}
}

class TField implements haxe.Public {
	static function get(color=0xFFFFFF,size=8,font="nokia",align=-1) {
		var field = new TF();
		field.width = 160;
		field.height = 10;
		field.selectable = false;
		field.embedFonts = true;
		var tf = field.getTextFormat();
		tf.color = color;
		tf.font = font;
		tf.size = size;
		
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		return field;
	}
}






