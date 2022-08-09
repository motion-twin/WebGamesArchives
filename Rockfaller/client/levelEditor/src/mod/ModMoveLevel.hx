package mod;

/**
 * ...
 * @author Tipyx
 */
class ModMoveLevel extends Module
{
	var textInput			: ui.InputText;
	var bg					: h2d.Interactive;
	var lblEnter			: h2d.Text;
	var btnGo				: ui.Button;
	
	var wid			: Int;
	var hei			: Int;

	public function new(le:LE) {
		super(le);
		
		lblEnter = new h2d.Text(Settings.FONT_ARIAL_26);
		lblEnter.text = "Move to...";
		
		wid = Std.int(lblEnter.textWidth + 20);
		hei = Std.int(lblEnter.textHeight);
		
		bg = new h2d.Interactive(wid, hei * 6);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		bg.addChild(lblEnter);
		
		textInput = new ui.InputText(wid, hei);
		textInput.y = hei;
		textInput.setPosInput(Std.int(bg.x), Std.int(bg.y + textInput.y));
		bg.addChild(textInput);
		
		btnGo = new ui.Button("Go !", null);
		btnGo.x = Std.int((bg.width - btnGo.w) / 2);
		btnGo.y = hei * 4.5;
		btnGo.onClick = function () {
			var numLevel = Std.parseInt(textInput.getText());
			
			if (numLevel != le.actualLevel.level) {
				DataManager.MOVE(le.actualLevel.level, numLevel, function () {
					destroy();
					le.goToLevel(numLevel, false);
				} );				
			}
			else
				destroy();
		}
		bg.addChild(btnGo);
	}
	
	override function unregister() {
		textInput.destroy();
		textInput = null;
		
		bg.dispose();
		bg = null;
		
		lblEnter.dispose();
		lblEnter = null;
		
		btnGo.destroy();
		btnGo = null;
		
		super.unregister();
	}
}