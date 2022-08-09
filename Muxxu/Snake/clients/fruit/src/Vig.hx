import Protocole;
import mt.bumdum9.Lib;
import Main;

class Vig extends SP{//}
	
	//public static var WIDTH = 171;
	public static var WIDTH = 219;
	public static var HEIGHT = 48;
	
	var data:DataFruit;
	var dm :mt.DepthManager;
	
	public function new(id, num) {
		super();

		data = DFruit.LIST[id];
		
		// ROOT
		Main.root.addChild(this);
		dm = new mt.DepthManager(this);
		//this.scaleX = this.scaleY = 2;
				
		// BG
		var bg = new pix.Sprite();
		bg.drawFrame(Gfx.bg.get(0),0,0);
		dm.add(bg,0);
		
		// LEVEL
		var lvl = 0;
		var a = DFruit.EXPLIMIT;
		var n = num;
		var coef = 1.0;
		for( lim in a ) if( n >= lim) lvl++;
		coef = n / a[a.length - 1];
		
		// STOCK
		var f = getField(3, 0, 8, "nokia");
		var ww = 28;
		f.x = WIDTH - (ww-2);
		f.width = ww;
		f.y = 6;
		f.text = Std.string(num);
		
		// BARRE
		var hh = Std.int(Math.min(coef,1)*27);
		var bar = new flash.display.Sprite();
		dm.add(bar, 1);
		bar.graphics.beginFill(0xfe4b4b);
		bar.graphics.drawRect(0, 0, 7, hh);
		bar.x = WIDTH-11;
		bar.y = 47 - hh;
		
		//
		displayData(lvl, data, id, coef);
		
	}
	
	function displayData(lvl:Int, data:DataFruit, id:Int, coef:Float) {
		
		// TITRE 1/2
		var f = getField((lvl>1)?0:4, -1, 8, "nokia");
		f.x = 0;
		f.y = -2;
		
		f.text = Lang.FRUIT_UNKNOWN;
		if( lvl > 1 ) {
			//f.text = Data.FRUIT_TEXT[id]._name;//data.name;
			//f.text = DFruit.LIST[id].name ;
			f.text = Data.TEXT[id].fruit ;
			f.width = Math.min( 180, f.textWidth + 4 );
		}
		
		// FRUIT NO
		var f = getField(2, 1, 8 );
		f.x = 144;
		f.y = 8;
		f.width = 50;
		f.text = "no."+Std.string(data.rank+1);
		
		// FRUIT
		var fruit = new pix.Sprite();
		fruit.drawFrame(Gfx.fruits.get(id));
		fruit.x = 19;
		fruit.y = 19 + 10;
		dm.add(fruit, 1);
		if( lvl == 0 ) 	Col.setPercentColor( fruit, 1, 0x52B31E);
		else {
			var shade = new pix.Sprite();
			shade.drawFrame(Gfx.fruits.get(id));
			shade.x = fruit.x + 2;
			shade.y = fruit.y + 2;
			dm.add(shade, 0);
			Col.setPercentColor( shade, 1, 0x52B31E);
			
		}
		
		// STATS
		if( lvl >= 3 ){
	
			var a = Lang.FRUIT_PROPS;
			var b = [Std.int(DFruit.getFruitAverageScore(data.rank) * data.score * 0.1), data.vit + " " + Lang.WEIGHT_UNIT, data.cal + " "+Lang.CAL_UNIT, data.sta + " "+Lang.TIME_UNIT];
			for( i in 0...4 ) {
				var f = getField(1,-1);
				f.x = 38;
				f.y = 9+i*7;
				f.text = a[i] + " :";
				f.width = f.textWidth + 4;
				var ff = getField(0,-1);
				ff.x = 108;
				ff.y = f.y;
				ff.text = Std.string(b[i]);
			}
		}
		
		// PROPRIETE / ANALYSE
		var f = getField(2, -1,8);
		f.x = 38;
		f.y = 38;
		f.width = 200;
		if( lvl >= 4 ) {
			var str = "";
			for( n in data.tags ) {
				if( str.length > 0 ) str += ",";
				str += Lang.FRUIT_TAGS[Type.enumIndex(n)];
			}
			f.text = str;
		}else {
			/*
			f.text = "analyse... "+Std.string(Std.int(coef*100))+"%";
			f.width = f.textWidth + 4;
			*/
		}
	}
		
	public function getField(col=0, align = 0, size = 8, font="04b03") {
		
		var field = new flash.text.TextField();
		field.selectable = false;
		field.embedFonts = true;
		var tf = field.getTextFormat();
		tf.color = [0xFFFFFF,0xc7ff77,0x319202,0xFFDDDD,0x52b31e][col];
		tf.font = font;
		tf.size = size;
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		dm.add(field, 1);
		return field;
		
	}
	
	public function kill() {
		Main.root.removeChild(this);
	}
//{
}












