package mod;

/**
 * ...
 * @author Tipyx
 */
class ModStepScore extends Module
{
	var textInput1			: ui.InputText;
	var textInput2			: ui.InputText;
	var textInput3			: ui.InputText;
	var bg					: h2d.Interactive;
	var lblEnter			: h2d.Text;
	var btnGo				: ui.Button;
	
	var wid			: Int;
	var hei			: Int;

	public function new(le:LE) {
		super(le);
		
		lblEnter = new h2d.Text(Settings.FONT_ARIAL_26);
		lblEnter.text = "Enter the 3 Steps";
		
		wid = Std.int(lblEnter.textWidth + 20);
		hei = Std.int(lblEnter.textHeight);
		
		bg = new h2d.Interactive(wid, hei * 6);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		bg.addChild(lblEnter);
		
		textInput1 = new ui.InputText(wid, hei);
		textInput1.y = hei;
		textInput1.setPosInput(Std.int(bg.x), Std.int(bg.y + textInput1.y));
		textInput1.setText(Std.string(le.actualLevel.arStepScore[0]));
		bg.addChild(textInput1);
		
		textInput2 = new ui.InputText(wid, hei);
		textInput2.y = Std.int(hei * 2) + 10;
		textInput2.setPosInput(Std.int(bg.x), Std.int(bg.y + textInput2.y));
		textInput2.setText(Std.string(le.actualLevel.arStepScore[1]));
		bg.addChild(textInput2);
		
		textInput3 = new ui.InputText(wid, hei);
		textInput3.y = Std.int(hei * 3) + 20;
		textInput3.setPosInput(Std.int(bg.x), Std.int(bg.y + textInput3.y));
		textInput3.setText(Std.string(le.actualLevel.arStepScore[2]));
		bg.addChild(textInput3);
		
		btnGo = new ui.Button("Go !", null);
		btnGo.x = Std.int((bg.width - btnGo.w) / 2);
		btnGo.y = hei * 4.5 + 10;
		btnGo.onClick = function () {
			setStepsScore();
		}
		bg.addChild(btnGo);
	}
	
	function setStepsScore() {
		var step1 = Std.parseInt(textInput1.getText());
		var step2 = Std.parseInt(textInput2.getText());
		var step3 = Std.parseInt(textInput3.getText());
		
		if (step1 != null && step1 >= 0
		&&	step2 != null && step2 >= 0
		&&	step3 != null && step3 >= 0) {
			LE.ME.actualLevel.arStepScore = [step1, step2, step3];
			LE.ME.updateUI();
			destroy();
		}
		else {
			// TODO MESSAGE D'ERREUR
		}
	}
	
	override function unregister() {
		textInput1.destroy();
		textInput1 = null;
		
		textInput2.destroy();
		textInput2 = null;
		
		textInput3.destroy();
		textInput3 = null;
		
		bg.dispose();
		bg = null;
		
		lblEnter.dispose();
		lblEnter = null;
		
		btnGo.destroy();
		btnGo = null;
		
		super.unregister();
	}
	
}