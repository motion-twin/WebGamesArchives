import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;

class Cs implements haxe.Public {//}
	
	static var mcw = 660;
	static var mch = 400;

	
	static var SQ = 24;
	static var XMAX = 20;
	static var YMAX = 10;
	static var DIR = [[1, 0], [0, 1], [ -1, 0], [0, -1]];
	
	
	static function getField(color=0xFFFFFF,size=8,font="nokia",align=-1) {
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
	
	static function rep(str:String, a:String, ?b:String, ?c:String, ?d:String) {
		
		var va = Std.parseInt(a), vb = Std.parseInt(b), vc = Std.parseInt(c);
		if( a != null && va == null )
			va = Std.parseInt(a.split(">")[1]);
		if( b != null && vb == null )
			vb = Std.parseInt(b.split(">")[1]);
		if( c != null && vc == null )
			vc = Std.parseInt(c.split(">")[1]);
		
		str = str.split("$a").join(a);
		str = str.split("$b").join(b);
		str = str.split("$c").join(c);
		str = str.split("$d").join(d);
		
		str = str.split("$pa").join(va == 1?"":"s");
		str = str.split("$pb").join(vb == 1?"":"s");
		str = str.split("$pc").join(vc == 1?"":"s");
		
		str.split("\n").join("<br/><br/>");
		
		str = str.split("$oa").join(va==1?"":a);
		str = str.split("$ob").join(vb==1?"":b);
		str = str.split("$oc").join(vc==1?"":c);

		
		//str = str.split("$a").join( HTML.col(a, 0x00FF00));
		//str = str.split("$b").join( HTML.col(b, 0x00FF00));
		//str = str.split("$c").join( HTML.col(c, 0x00FF00));

		return 	str;
	}
	
	static function getRandomLoc():Location {
		return {
			wid:Std.random(14),
			bg:Std.random(5),
			mood:Std.random(5),
			colorSet:Std.random(5),
			seed:Std.random(10000),
		}
	}
	
	static function getGameInit(a,opp):GameInit {
		return {
			heroes:a,
			opponents:opp,
			loc:Cs.getRandomLoc(),
			tuto:false,	// TUTO
		}
	}
	
	static function gnum(n:Int) {
		return "<span class='number'>" + n + "</span>";
	}
	
	/*
haxe -swf swf/all.swf -swf-lib swf/monsters.swf -swf-lib swf/heroes.swf flash.Boot
haxe -lib format -cp src --macro mt.player.Boot.make('swf/all.swf')
	*/
	
	
//{
}