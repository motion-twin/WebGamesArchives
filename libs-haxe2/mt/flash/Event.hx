package mt.flash;

#if !old_mt_events

class Event {
	
	public static function onOver( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.MOUSE_OVER, tmp);
		return tmp;
	}
	
	public static function onOut( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.MOUSE_OUT, tmp);
		return tmp;
	}

	public static function onDown( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, tmp);
		return tmp;
	}

	public static function onUp( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.MOUSE_UP, tmp);
		return tmp;
	}

	public static function onMove( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, tmp);
		return tmp;
	}
	
	public static function onClick( i : flash.display.InteractiveObject, f : Void -> Void ) {
		var tmp = function(_:flash.events.MouseEvent) f();
		i.addEventListener(flash.events.MouseEvent.CLICK, tmp);
		return tmp;
	}
	
	public static function onKeyDown( i : flash.display.InteractiveObject, f : flash.events.KeyboardEvent -> Void ) {
		i.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, f);
	}
	
	public static function onKeyUp( i : flash.display.InteractiveObject, f : flash.events.KeyboardEvent -> Void ) {
		i.addEventListener(flash.events.KeyboardEvent.KEY_UP, f);
	}

	public static function noMouse( i : flash.display.Sprite ) {
		i.mouseEnabled = false;
		i.mouseChildren = false;
	}
	
}

#else
// compile with -D old_mt_events

import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.EventDispatcher;

typedef MEvent = Event<MouseEvent,flash.display.InteractiveObject>;
typedef KEvent = Event<KeyboardEvent,flash.display.InteractiveObject>;

class Event<T,Target : EventDispatcher> {

	var name : String;
	var onAdd : Target -> Void;

	function new(name,onAdd) {
		this.name = name;
		this.onAdd = if( onAdd == null ) function(_) {} else onAdd;
	}

	public function bind( t : Target, f : Void -> Void ) {
		t.addEventListener(name,function(_) { f(); });
		onAdd(t);
	}

	public function ebind( t : Target, f : T -> Void ) {
		t.addEventListener(name,f);
		onAdd(t);
	}

	public function lazyBind( t : Target, fval : Void -> Void ) {
		for( f in Type.getInstanceFields(Type.getClass(t)) )
			if( Reflect.field(t,f) == fval ) {
				t.addEventListener(name,function(e) {
					Reflect.field(t,f)();
				});
				onAdd(t);
				return;
			}
		throw "Function value for event "+name+" not found in "+t.toString();
	}

	public function elazyBind( t : Target, fval : T -> Void ) {
		for( f in Type.getInstanceFields(Type.getClass(t)) )
			if( Reflect.field(t,f) == fval ) {
				t.addEventListener(name,function(e) {
					Reflect.field(t,f)(e);
				});
				onAdd(t);
				return;
			}
		throw "Function value for event "+name+" not found in "+t.toString();
	}

	public function toString() {
		return "Event:"+name;
	}

	static function mouseEnable( t : flash.display.InteractiveObject ) {
		if( !t.mouseEnabled )
			t.mouseEnabled = true;
	}

	static function dcEnable( t : flash.display.InteractiveObject ) {
		if( !t.mouseEnabled )
			t.mouseEnabled = true;
		if( !t.doubleClickEnabled )
			t.doubleClickEnabled = true;
	}

	public static var click = new MEvent(MouseEvent.CLICK,mouseEnable);
	public static var doubleClick = new MEvent(MouseEvent.DOUBLE_CLICK,dcEnable);
	public static var over = new MEvent(MouseEvent.MOUSE_OVER,mouseEnable);
	public static var out = new MEvent(MouseEvent.MOUSE_OUT,mouseEnable);
	public static var down = new MEvent(MouseEvent.MOUSE_DOWN,mouseEnable);
	public static var up = new MEvent(MouseEvent.MOUSE_UP,mouseEnable);
	public static var move = new MEvent(MouseEvent.MOUSE_MOVE,mouseEnable);
	public static var keydown = new KEvent(KeyboardEvent.KEY_DOWN,null);
	public static var keyup = new KEvent(KeyboardEvent.KEY_UP,null);

	public static function drag( t : flash.display.InteractiveObject, f : Void -> Void ) {
		#if flash9
		var stage = flash.Lib.current.stage;
		var mouseX = stage.mouseX;
		var mouseY = stage.mouseY;
		var fevent = function(e) {
			if( mouseX != stage.mouseX || mouseY != stage.mouseY ) {
				mouseX = stage.mouseX;
				mouseY = stage.mouseY;
				f();
			}
		};
		var stop = null;
		stop = function(e) {
			t.removeEventListener(flash.events.Event.ENTER_FRAME,fevent);
			stage.removeEventListener(MouseEvent.MOUSE_UP,stop);
		};
		t.addEventListener(flash.events.Event.ENTER_FRAME,fevent);
		stage.addEventListener(MouseEvent.MOUSE_UP,stop);
		#end
	}

}

#end