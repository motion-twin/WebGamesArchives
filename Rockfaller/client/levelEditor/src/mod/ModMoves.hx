package mod;

/**
 * ...
 * @author Tipyx
 */
class ModMoves extends Module
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
		lblEnter.text = "Enter a number";
		
		wid = Std.int(lblEnter.textWidth + 20);
		hei = Std.int(lblEnter.textHeight);
		
		bg = new h2d.Interactive(wid, hei * 4);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		bg.addChild(lblEnter);
		
		textInput = new ui.InputText(wid, hei);
		textInput.setPosInput(Std.int(bg.x), Std.int(bg.y + hei));
		textInput.y = hei;
		textInput.setText(Std.string(le.actualLevel.numMoves));
		bg.addChild(textInput);
		
		btnGo = new ui.Button("Go !", null);
		btnGo.x = Std.int((bg.width - btnGo.w) / 2);
		btnGo.y = hei * 2.5;
		btnGo.onClick = function () {
			setMoves();
		}
		bg.addChild(btnGo);
	}
	
	function setMoves() {
		var numMoves = Std.parseInt(textInput.getText());
		trace(numMoves);
		
		if (numMoves != null && numMoves > 0) {
			LE.ME.actualLevel.numMoves = numMoves;
			LE.ME.updateUI();
			destroy();
		}
		else {
			// TODO MESSAGE D'ERREUR
		}
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