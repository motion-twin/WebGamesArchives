import Protocole;
import mt.bumdum9.Lib;

private typedef Event = { f:Dynamic->Void };

class UserButon implements haxe.Public {//}
	
	static function addEvent(t:MC, type:String, f:Void->Void  ) {
		var a = Reflect.field(t, "events");
		if ( a == null ) {
			a = [];
			Reflect.setField(t, "events", a);
		}
		var func = function(e) { f(); };
		t.addEventListener(type, func );
		a.push(func);
	}
	
	public static function onClick(t:MC,f) {
		addEvent(t,flash.events.MouseEvent.CLICK,f);
	}
	public static function onOver(t:MC,f) {
		addEvent(t,flash.events.MouseEvent.MOUSE_OVER,f);
	}
	public static function onOut(t:MC,f) {
		addEvent(t,flash.events.MouseEvent.MOUSE_OUT,f);
	}
	
//{
}