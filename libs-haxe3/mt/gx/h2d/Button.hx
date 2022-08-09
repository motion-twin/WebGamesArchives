package mt.gx.h2d;

/**
 * Courtesy to master chief bumdum
 */

/**
 * Not all event dispatchers will work, for example bitmap does not dispatch event correctly
 */
private typedef EVD = h2d.Drawable;
private typedef ACT = hxd.Event -> Void;

@:publicFields
class Button {
	//
	//Makes a button out of anything
	static function button(button:EVD, action:ACT, ?over:ACT = null, ?out:ACT = null) : h2d.Interactive {
		var interact = new h2d.Interactive(button.width, button.height);
		button.addChild( interact );
		
		if( action!=null ) 	onClick(interact, action);
		if ( over != null ) onOver(interact, over);
		if ( out != null )	onOut(interact, out);
		
		return interact;
	}
	
	static function onClick(t:h2d.Interactive, cb:ACT) {
		t.onClick = cb;
	}
	
	static function onOver(t:h2d.Interactive, cb:ACT) {
		t.onOver = cb;
	}
	static function onOut(t:h2d.Interactive, cb:ACT) {
		t.onOut = cb;
	}
}



