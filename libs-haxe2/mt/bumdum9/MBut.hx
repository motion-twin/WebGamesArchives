package mt.bumdum9;
import mt.bumdum9.Lib;

//private typedef EVD = flash.events.EventDispatcher;
private typedef EVD = SP;
private typedef ACT = Void->Void;

class MBut implements haxe.Public {

	static var EVENTS = [];
	
	/**
	 * Make a  button
	 * @param	button
	 * @param	action
	 * @param	?over
	 * @param	?out
	 */
	static function makeBut(button:EVD,action:ACT,?over:ACT,?out:ACT) {
		if( action!=null ) 	onClick(button, action);
		if( over!=null ) 	onOver(button, over);
		if( out!=null )		onOut(button, out);
	}
	
	/**
	 * Make a simple button from
	 * a MC with 2 frames + _txt field
	 * @param	button
	 * @param	action
	 * @param	?over
	 * @param	?out
	 */
	static function makeSimpleButton(button:MC, action:ACT, ?text:Null<String>) {
		var button : SimpleButton = cast button;
		if( text != null ) button._txt.text = text;
		if( action != null ) 	onClick(button, action);
		onOver(button, function() {
			button.gotoAndStop(2);
			if( text != null ) button._txt.text = text;
		});
		onOut(button, function() {
			button.gotoAndStop(1);
			if( text != null ) button._txt.text = text;
		});
	}
	
	static function setEvent(t:EVD, cb:ACT, event:String){
		var fcb = function(_) { cb(); }
		t.addEventListener( event, fcb );
		EVENTS.push( { t:t, cb:fcb, type:event } );
		t.tabEnabled = false;
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
		t.useHandCursor = false;
		t.buttonMode = false;
		t.mouseEnabled = false;
		
	}

	static function removeAllEvents() {
		for ( ev in EVENTS ) ev.t.removeEventListener( ev.type, ev.cb );
		EVENTS = [];
	}
	
	static function onClick(t:EVD, cb:ACT) {
		setEvent(t, cb, flash.events.MouseEvent.CLICK);
		t.useHandCursor = true;
		t.buttonMode = true;
		t.mouseEnabled = true;
		t.mouseChildren = false;
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

private typedef SimpleButton = {>MC,_txt:TF}


