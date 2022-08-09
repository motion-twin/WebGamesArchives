package mod;

/**
 * ...
 * @author Tipyx
 */
class ModDeleteLevel extends Module
{
	var bg					: h2d.Interactive;
	var lblEnter			: h2d.Text;
	var btnGo				: ui.Button;
	
	var wid			: Int;
	var hei			: Int;

	public function new(le:LE) {
		super(le);
		
		lblEnter = new h2d.Text(Settings.FONT_ARIAL_26);
		lblEnter.text = "Are you sure ?";
		
		wid = Std.int(lblEnter.textWidth + 20);
		hei = Std.int(lblEnter.textHeight);
		
		bg = new h2d.Interactive(wid, hei * 4);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		bg.addChild(lblEnter);
		
		btnGo = new ui.Button("Go !", null);
		btnGo.x = Std.int((bg.width - btnGo.w) / 2);
		btnGo.y = hei * 2.5;
		btnGo.onClick = function () {
			DataManager.DELETE(le.actualLevel.level, function () {
				destroy();
				le.goToLevel(1, false);
			} );
		}
		bg.addChild(btnGo);
	}
	
	override function unregister() {
		bg.dispose();
		bg = null;
		
		lblEnter.dispose();
		lblEnter = null;
		
		btnGo.destroy();
		btnGo = null;
		
		super.unregister();
	}
}