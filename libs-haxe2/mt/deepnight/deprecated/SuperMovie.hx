package mt.deepnight.deprecated;

typedef EventData = {
	cb		: Dynamic->Void,
	type	: String,
}

class SuperMovie {
	
	// *** EVENTS
	private static function registerEvent(t:flash.events.EventDispatcher, cb:Void->Void, event:String) : EventData {
		var fcb = function(_) { cb(); }
		t.addEventListener( event, fcb );
		return { cb:fcb, type:event };
	}

	public static function removeEvent(t:flash.events.EventDispatcher, edata:EventData) {
		t.removeEventListener( edata.type, edata.cb );
	}
	
	public static function onClick(t:flash.events.EventDispatcher, cb:Void->Void) : EventData {
		return registerEvent(t, cb, flash.events.MouseEvent.CLICK);
	}
		
	public static function onMouseUp(t:flash.events.EventDispatcher, cb:Void->Void) : EventData {
		return registerEvent(t, cb, flash.events.MouseEvent.MOUSE_UP);
	}
	
	public static function onMouseDown(t:flash.events.EventDispatcher, cb:Void->Void) : EventData {
		return registerEvent(t, cb, flash.events.MouseEvent.MOUSE_DOWN);
	}

	public static function onOver(t:flash.events.EventDispatcher, cb:Void->Void) : EventData {
		return registerEvent(t, cb, flash.events.MouseEvent.MOUSE_OVER);
	}

	public static function onOut(t:flash.events.EventDispatcher, cb:Void->Void) : EventData {
		return registerEvent(t, cb, flash.events.MouseEvent.MOUSE_OUT);
	}
	
	public static function onWheel(t:flash.events.EventDispatcher, cb:Float->Void, ?multiplicator=1.0) : EventData {
		var fcb = function(event:flash.events.MouseEvent) { cb(event.delta*multiplicator); }
		t.addEventListener( flash.events.MouseEvent.MOUSE_WHEEL, fcb );
		return return { cb:fcb, type:flash.events.MouseEvent.MOUSE_WHEEL };
	}
	
	
	// *** MISC
	
	public static function remove(t:flash.display.DisplayObjectContainer) {
		if (t==null || t.parent==null) return;
		t.parent.removeChild(t);
	}
	
	public static function disableMouse(t:flash.display.DisplayObjectContainer) {
		t.mouseEnabled = false;
		t.mouseChildren = false;
	}

	public static function enableMouse(t:flash.display.DisplayObjectContainer) {
		t.mouseEnabled = true;
		t.mouseChildren = true;
	}

	
	public static function handCursor(t:flash.display.Sprite, fl:Bool) {
		t.useHandCursor = fl;
		t.buttonMode = fl;
		if(fl)
			enableMouse(t);
		else
			disableMouse(t);
	}
	
	
	public static function hasFrame(t:flash.display.MovieClip, frame:String) {
		for (fl in t.currentLabels)
			if (fl.name==frame)
				return true;
		return false;
	}
}
