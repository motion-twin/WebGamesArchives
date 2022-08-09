package mt.deepnight.deprecated;

import js.Dom;

class JsChaos {
	public static function addWheelEvent(dom:js.HtmlDom, cb:Dynamic->Bool) {
		addEvent(dom, "DOMMouseScroll", "onmousewheel", cb);
	}
	
	public static function addClickEvent(dom:js.HtmlDom, cb:Dynamic->Bool) {
		addEvent(dom, "click", "click", cb);
	}
	
	private static function addEvent(dom:js.HtmlDom, e1:String, e2:String, cb:Dynamic->Bool) {
		if (dom==null)
			throw "invalid DOM";
			
		if( untyped(dom).addEventListener )
			untyped(dom).addEventListener(e1,cb,false);
		else
			if( untyped(dom).attachEvent )
				untyped(dom).attachEvent(e2,cb,false);
	}
	
	
	public static function getWheelDelta(event:Dynamic) : Int {
		var delta = 0.0;
		
		if (event.wheelDelta) { // IE/Opera
			delta = event.wheelDelta/120;
			if ( untyped(js.Lib.window).opera)
				delta = -delta; // Opera
		}
		else
			if (event.detail) // Firefox
				delta = -event.detail/3;
		return Math.round(delta); //Safari Round
	}
	
	public static function blockEvent(event:Dynamic) {
		if( event == null )
			event = untyped(js.Lib.window).event; // IE
			
		event.cancelBubble = true;
		event.returnValue = false;
		event.cancel = true;
		
		if( event.stopPropagation != null )
			event.stopPropagation();
			
		if( event.preventDefault != null )
			event.preventDefault();
			
		return false;
	}

	public static function reloadPage() {
		untyped(js.Lib.document).location.reload(true);
	}

}
