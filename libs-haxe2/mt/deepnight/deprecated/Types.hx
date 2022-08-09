package mt.deepnight.deprecated;
import Type;

typedef MC = flash.display.MovieClip;
typedef SPR = flash.display.Sprite;
typedef BMP = flash.display.Bitmap;
typedef BD = flash.display.BitmapData;
typedef TF = flash.text.TextField;
typedef PT = flash.geom.Point;
typedef EL = flash.events.MouseEvent;

class Types {
	public static function traceFields(o:Dynamic) {
		var list = new List();
		var fields = if(Type.getClass(o)!=null ) Type.getInstanceFields(Type.getClass(o)) else Reflect.fields(o);
		for (k in fields) {
			if (k==null)
				continue;
			if (!Reflect.hasField(o,k))
				continue;
			var v = Reflect.field(o,k);
			var t = Type.typeof(v);
			if (t==TFunction)
				continue;
			list.add(k+" = "+v);
		}
		return "\n\t"+list.join("\n\t");
	}
}
