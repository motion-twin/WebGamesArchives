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
class AskMobile extends BasePopup
{
	var btnApple				: Button;
	var btnGoogle				: Button;
	var btnAmazon				: Button;
	
	public function new(hparent:HProcess) {
		super(hparent, SizePopUp.SPUNormal);
		
		onClose = close;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideAskMobile(hparent, this);
		});
	}
	
	
	override function init() {
		enableDeco = true;
		
		mt.device.EventTracker.view("ui.AskLog");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPPlayMobile);
		
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
		lblSave.text = Lang.GET_VARIOUS(TypeVarious.TVGameAvailable);
		lblSave.x = Std.int((Settings.STAGE_WIDTH - lblSave.maxWidth) * 0.5);
		lblSave.y = Std.int(lblBenef.y + lblBenef.height * 1.25 );
		arHS.push(lblSave);
		popUp.addChild(lblSave);
		
		var lblAchiev = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblAchiev.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblAchiev.textAlign = Center;
		lblAchiev.text = Lang.GET_VARIOUS(TypeVarious.TVGetGold);
		lblAchiev.x = Std.int((Settings.STAGE_WIDTH - lblAchiev.maxWidth) * 0.5);
		lblAchiev.y = Std.int(lblSave.y + lblSave.height);
		arHS.push(lblAchiev);
		popUp.addChild(lblAchiev);
		
		var lblFriend = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblFriend.maxWidth = Settings.STAGE_WIDTH * 0.9;
		lblFriend.textAlign = Center;
		lblFriend.text = Lang.GET_VARIOUS(TypeVarious.TVMoreLifes);
		lblFriend.x = Std.int((Settings.STAGE_WIDTH - lblFriend.maxWidth) * 0.5);
		lblFriend.y = Std.int(lblAchiev.y + lblAchiev.height);
		arHS.push(lblFriend);
		popUp.addChild(lblFriend);
		
		btnApple = new Button("appleBt", function () {
			openfl.Lib.getURL(new openfl.net.URLRequest("https://itunes.apple.com/en/app/id1004340128?mt=8"));
		});
		btnApple.resize();
		btnApple.x = Std.int(Settings.STAGE_WIDTH / 4 - btnApple.w * 0.5);
		btnApple.y = Std.int(lblFriend.y + lblFriend.height * 1.5);
		popUp.addChild(btnApple);
		
		btnGoogle = new Button("googleBt", function () {
			openfl.Lib.getURL(new openfl.net.URLRequest("https://play.google.com/store/apps/details?id=com.motiontwin.rockfaller&referrer=utm_source%3DrockfallerWeb%26utm_medium%3DingameButton%26utm_campaign%3DrockfallerWeb2mobile"));
		});
		btnGoogle.resize();
		btnGoogle.x = Std.int(Settings.STAGE_WIDTH / 2 - btnGoogle.w * 0.5);
		btnGoogle.y = Std.int(lblFriend.y + lblFriend.height * 1.5);
		popUp.addChild(btnGoogle);
		
		btnAmazon = new Button("amazonBt", function () {
			openfl.Lib.getURL(new openfl.net.URLRequest("http://www.amazon.com/gp/mas/dl/android?p=com.motiontwin.rockfaller"));
		});
		btnAmazon.resize();
		btnAmazon.x = Std.int(Settings.STAGE_WIDTH * 3 / 4 - btnAmazon.w * 0.5);
		btnAmazon.y = Std.int(lblFriend.y + lblFriend.height * 1.5);
		popUp.addChild(btnAmazon);
	}
	
	override function onResize() {
		if (btnApple != null)
			btnApple.destroy();
		btnApple = null;
		
		if (btnGoogle != null)
			btnGoogle.destroy();
		btnGoogle = null;
		
		if (btnAmazon != null)
			btnAmazon.destroy();
		btnAmazon = null;
		
		super.onResize();
	}
	
	override function unregister() {
		if (btnApple != null)
			btnApple.destroy();
		btnApple = null;
		
		if (btnGoogle != null)
			btnGoogle.destroy();
		btnGoogle = null;
		
		if (btnAmazon != null)
			btnAmazon.destroy();
		btnAmazon = null;
		
		super.unregister();
	}
}