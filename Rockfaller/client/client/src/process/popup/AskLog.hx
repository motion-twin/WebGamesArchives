package process.popup;

import mt.deepnight.deprecated.HProcess;

import data.Lang;
import data.Settings;
import ui.Button;
import process.popup.BasePopup.SizePopUp;

/**
 * ...
 * @author Tipyx
 */
class AskLog extends BasePopup
{
	public static var ME		: AskLog;
	
	var btnLogin				: Button;
	var btnLater				: Button;
	
	var laterAvailable			: Bool;

	public function new(hparent:HProcess, laterAvailable:Bool) {
		super(hparent, SizePopUp.SPUBig);
		
		ME = this;
		
		this.laterAvailable = laterAvailable;
		
		onClose = close;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideAskLog(hparent, this);
		});
	}
	
	
	override function init() {
		enableDeco = true;
		
		mt.device.EventTracker.view("ui.AskLog");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPAskLog);
		
		super.init();
		
	// TEXT
		var lblBenef = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
		lblBenef.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblBenef.textAlign = Center;
		lblBenef.text = Lang.GET_VARIOUS(TypeVarious.TVBenef);
		lblBenef.text = lblBenef.text.toLowerCase();
		lblBenef.x = Std.int((Settings.STAGE_WIDTH - lblBenef.maxWidth) * 0.5);
		lblBenef.y = Std.int(heiBG * 0.05);
		arHS.push(lblBenef);
		popUp.addChild(lblBenef);
		
		var lblSave = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblSave.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblSave.textAlign = Center;
		lblSave.text = Lang.GET_VARIOUS(TypeVarious.TVSave);
		lblSave.x = Std.int((Settings.STAGE_WIDTH - lblSave.maxWidth) * 0.5);
		lblSave.y = Std.int(lblBenef.y + lblBenef.height * 1.25 );
		arHS.push(lblSave);
		popUp.addChild(lblSave);
		
		var lblAchiev = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblAchiev.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblAchiev.textAlign = Center;
		lblAchiev.text = Lang.GET_VARIOUS(TypeVarious.TVAchiev);
		lblAchiev.x = Std.int((Settings.STAGE_WIDTH - lblAchiev.maxWidth) * 0.5);
		lblAchiev.y = Std.int(lblSave.y + lblSave.height /** 1.5 */);
		arHS.push(lblAchiev);
		popUp.addChild(lblAchiev);
		
		var lblFriend = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblFriend.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblFriend.textAlign = Center;
		lblFriend.text = Lang.GET_VARIOUS(TypeVarious.TVFriend);
		lblFriend.x = Std.int((Settings.STAGE_WIDTH - lblFriend.maxWidth) * 0.5);
		lblFriend.y = Std.int(lblAchiev.y + lblAchiev.height/* * 1.5 */);
		arHS.push(lblFriend);
		popUp.addChild(lblFriend);
		
		var lblForum = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblForum.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblForum.textAlign = Center;
		lblForum.text = Lang.GET_VARIOUS(TypeVarious.TVForum);
		lblForum.x = Std.int((Settings.STAGE_WIDTH - lblForum.maxWidth) * 0.5);
		lblForum.y = Std.int(lblFriend.y + lblFriend.height/* * 1.5 */);
		arHS.push(lblForum);
		popUp.addChild(lblForum);
		
		btnLogin = new Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBLogIn), function () {
			mt.device.User.login();
		});
		btnLogin.resize();
		btnLogin.x = Std.int(( Settings.STAGE_WIDTH - btnLogin.w) * 0.5);
		btnLogin.y = heiBG * 0.75;
		popUp.addChild(btnLogin);
		
		if (laterAvailable) {
			btnLater = new Button("btRed", data.Lang.GET_BUTTON(TypeButton.TBLater), function () {
				close();
			});
			btnLater.resize();
			btnLater.x = Std.int(( Settings.STAGE_WIDTH - btnLater.w) * 0.5);
			btnLater.y = btnLogin.y + btnLogin.h * 1.5;
			popUp.addChild(btnLater);			
		}
	}
	
	override function onResize() {
		if (btnLogin != null)
			btnLogin.destroy();
		btnLogin = null;
		
		if (btnLater != null)
			btnLater.destroy();
		btnLater = null;
		
		super.onResize();
	}
	
	override function unregister() {
		if (btnLogin != null)
			btnLogin.destroy();
		btnLogin = null;
		
		if (btnLater != null)
			btnLater.destroy();
		btnLater = null;
		
		ME = null;
		
		super.unregister();
	}
}