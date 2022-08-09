package mod;

import h2d.Sprite;
import mt.deepnight.HProcess;
import mt.deepnight.Process;

/**
 * ...
 * @author Tipyx
 */
class Module extends HProcess
{
	var inter		: h2d.Interactive;

	public function new(le:LE) {
		super(le);
		
		inter = new h2d.Interactive(Settings.STAGE_WIDTH, Settings.STAGE_HEIGHT);
		inter.backgroundColor = 0xFF000000;
		inter.alpha = 0.5;
		inter.cursor = hxd.System.Cursor.Default;
		inter.onClick = function(e) {
			destroy();
		}
		root.addChild(inter);
	}
	
	override function unregister() {
		inter.dispose();
		inter = null;
		
		super.unregister();
	}
}