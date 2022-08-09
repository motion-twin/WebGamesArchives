package mt.gx.as;

/**
 * Courtesy to master chief bumdum
 */

/**
 * Not all event dispatchers will work, for example bitmap does not dispatch event correctly
 */
private typedef EVD = flash.display.Sprite;
private typedef ACT = Void->Void;

@:publicFields
class Button  {

	static var EVENTS = [];
	static var TXT_EVENTS = [];
	
	/**
	 * Makes a button out of anything
	 */
	static function button(button:EVD,action:ACT,?over:ACT=null,?out:ACT=null) {
		if( action!=null ) 	onClick(button, action);
		if ( over != null ) onOver(button, over);
		if ( out != null )	onOut(button, out);
	}
	
	static function setEvent(t:EVD, cb:ACT, event:String){
		var fcb = function(_) { cb(); }
		t.addEventListener( event, fcb );
		EVENTS.push( { t:t, cb:fcb, type:event } );
		
		trySetBool(t, "tabEnabled", false);
	}
	
	static function trySetBool<T>(t:T,f,v)
	{
		if ( Reflect.hasField(t, f)) 
			Reflect.setProperty( t , f, v);
	}
	
	static function removeEvent(t:EVD, ev:EventData) {
		t.removeEventListener( ev.type, ev.cb );
		EVENTS.remove(ev);
	}
	
	static function removeEvents(t:EVD) {
		var id = 0;
		while( id < EVENTS.length ){
			var ev = EVENTS[id];
			id++;
			if ( ev.t != t ) continue;
			t.removeEventListener( ev.type, ev.cb );
			EVENTS.splice(--id, 1);
		}
		
		trySetBool(t, "useHandCursor", false);
		trySetBool(t, "buttonMode", false);
		trySetBool(t, "mouseEnabled", false);
	}

	static function removeAllEvents() {
		for ( ev in EVENTS ) ev.t.removeEventListener( ev.type, ev.cb );
		EVENTS = [];
	}
	
	static function onClick(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.CLICK);
		
		trySetBool(t, "useHandCursor", true);
		trySetBool(t, "buttonMode", true);
		trySetBool(t, "mouseEnabled", true);
		trySetBool(t, "mouseChildren", false);
	}
	
	
	static function setEventText(t:flash.text.TextField, cb:ACT, event:String){
		var fcb = function(_) { cb(); }
		t.addEventListener( event, fcb );
		TXT_EVENTS.push( { t:t, cb:fcb, type:event } );
	}
	
	static function onClickText(t:flash.text.TextField, cb:ACT) {
		setEventText(t, cb, flash.events.MouseEvent.CLICK);
		
		trySetBool(t, "useHandCursor", true);
		trySetBool(t, "buttonMode", true);
		trySetBool(t, "mouseEnabled", true);
		trySetBool(t, "mouseChildren", false);
	}
	
	static function onOver(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.MOUSE_OVER);
	}
	static function onOut(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.MOUSE_OUT);
	}
	static function onMouseDown(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.MOUSE_DOWN);
	}
	static function onMouseUp(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.MOUSE_UP);
	}

}

private typedef EventData = {
	t		: EVD,
	cb		: Dynamic->Void,
	type	: String,
}



