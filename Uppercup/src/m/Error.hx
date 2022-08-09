package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.deepnight.Color;
import mt.deepnight.mui.Window;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.deepnight.mui.VGroup;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Error extends MenuBase {
	var log			: VGroup;

	public function new(err:String) {
		super();

		log = new VGroup(wrapper);
		log.color = 0x880000;
		var l = log.label(err);
		l.setFont(m.Global.ME.getFont().id, m.Global.ME.getFont().size);
		l.multiline = true;
		l.setWidth(300);

		root.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(_) onContinue() );

		onResize();
	}


	override function unregister() {
		super.unregister();

		log.destroy();
	}

	function onContinue() {
		Global.ME.run(this, function() new Logo(), true);
	}

	override function onResize() {
		super.onResize();

		if( log==null )
			return;

		var w = getWidth();
		var h = getHeight();
		log.x = w*0.5 - log.getWidth()*0.5;
		log.y = h*0.5 - log.getHeight()*0.5;
	}
}