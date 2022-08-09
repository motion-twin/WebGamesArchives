package process.popup;

import data.Lang;
import Protocol;
import ui.Button;

import process.popup.BasePopup;
import data.Settings;
import data.DataManager;
import data.LevelDesign;
import mt.deepnight.deprecated.HProcess;

/**
 * ...
 * @author Tipyx
 */
class Error extends BasePopup
{
	public static var ME			: Error;
	
	var btnReload					: ui.Button;

	public function new(hparent:HProcess, pe:ProtocolError) 
	{
		super(hparent, SizePopUp.SPUNormal);
		
		disableCloseBtn();
	}
	
	override function init() {
		super.init();
		
		var lblError = new h2d.Text(Settings.FONT_BENCH_NINE_90, popUp);
		lblError.text = Lang.GET_VARIOUS(TypeVarious.TVReloadGame);
		lblError.maxWidth = Settings.STAGE_WIDTH * 0.75;
		lblError.textAlign = h2d.Text.Align.Center;
		lblError.x = Std.int((Settings.STAGE_WIDTH - lblError.maxWidth) * 0.5);
		lblError.y = Std.int(heiBG * 0.4);
		
		btnReload = new Button("btRed", Lang.GET_BUTTON(TypeButton.TBReload), function () {
			openfl.Lib.getURL(new flash.net.URLRequest("/"), "_self");
		});
		
		btnReload.resize();
		btnReload.x = Std.int((Settings.STAGE_WIDTH - btnReload.w) * 0.5 );
		btnReload.y = Std.int(heiBG * 0.7);
		popUp.addChild(btnReload);
	}
	
	override function onResize() {
		if (btnReload != null) {
			btnReload.destroy();
			btnReload = null;
		}
		
		super.onResize();
	}
}