package process.popup;

import mt.deepnight.deprecated.HProcess;
import mt.net.FriendRequest.ListResp;

import Protocol;

import process.popup.BasePopup;
import data.LevelDesign;
import data.DataManager;
import data.Settings;
import data.Lang;
import ui.Button;

/**
 * ...
 * @author Tipyx
 */
class Mail extends BasePopup
{
	public static var ME	: Mail;
	
	static var OFFSET_Y		: Int		= 20;
	
	var arMB				: Array<MailBadge>;
	
	var btnLogin			: Button;
	var lblNoNotif			: h2d.Text;
	var lblTuto				: h2d.Text;

	public function new(hparent:HProcess) {
		ME = this;
		
		arMB = [];
		
		super(hparent, SizePopUp.SPUBig);
		
		onClose = close;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideMail(hparent, this); 
			data.DataManager.DO_PROTOCOL( DoGetRequestsCount );
		});
	}
	
	override function init() {
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPNotifications);
		
		super.init();
		
		mt.device.EventTracker.view("ui.Inbox");
		
		OFFSET_Y = Std.int(heiBG / 50);
		//OFFSET_Y  = 0;
		
	#if debug
		//var arFriend = [
			//{ net: 0, id: "test", name: "Ami", avatar: "https://imgup.motion-twin.com/twinoid/3/9/9816c156_115.jpg", invitable: false },
			//{ net: 0, id: "test", name: "Copain", avatar: "https://imgup.motion-twin.com/twinoid/4/f/3fff3a21_25.jpg", invitable: false },
			//{ net: 0, id: "test", name: "Pote", avatar: "http://imgup.motion-twin.com/twinoid/7/6/6671bffc_1.jpg", invitable: false },
			//{ net: 0, id: "test", name: "Bro", avatar: "http://imgup.motion-twin.com/twinoid/2/9/1f9bdded_55_100x100.jpg", invitable: false },
			//{ net: 0, id: "test", name: "Sensei", avatar: "http://imgup.motion-twin.com/twinoid/9/a/e147235b_2_100x100.gif", invitable: false }
		//];
	//
		//var listResp:ListResp = [];
		//
		//for (i in 0...1)
			//listResp.push( { i:i, f:arFriend[Std.random(arFriend.length)], t:FriendRequestType.R_AskLife.getIndex(), d:null } );
			//
		//for (i in 0...16)
			//listResp.push( {i:i, f:arFriend[Std.random(arFriend.length)], t:FriendRequestType.R_GiveLife.getIndex(), d:null } );
		//
		//return;
	#end
		
		if (mt.device.User.isLogged()) {
			lblNoNotif = new h2d.Text(Settings.FONT_BENCH_NINE_90);
			lblNoNotif.filter = true;
			lblNoNotif.textColor = 0xFFEFB4;
			lblNoNotif.text = Lang.GET_VARIOUS(TypeVarious.TVLoading);
			lblNoNotif.x = Std.int((Settings.STAGE_WIDTH - lblNoNotif.textWidth) * 0.5);
			lblNoNotif.y = Std.int(heiBG * 0.5);
			arHS.push(lblNoNotif);
			popUp.addChild(lblNoNotif);
			
			if (!LevelDesign.TUTO_IS_DONE( -2)) {
				lblTuto = new h2d.Text(Settings.FONT_BENCH_NINE_50);
				lblTuto.maxWidth = Std.int(Settings.STAGE_WIDTH * 0.75);
				lblTuto.text = Lang.GET_VARIOUS(TypeVarious.TVGiveLifes);
				lblTuto.x = Std.int((Settings.STAGE_WIDTH - lblTuto.maxWidth) / 2);
				lblTuto.y = Std.int(heiBG * 0.1 - lblTuto.textHeight * 0.5);
				lblTuto.textAlign = Center;
				arHS.push(lblTuto);
				popUp.add(lblTuto, 1);
				
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(-2));
			}
			
			mt.device.FriendRequest.list(function (listResp:mt.net.FriendRequest.ListResp) {
				showRequest(listResp);
			});
		}
		else {
			btnLogin = new Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBLogIn), function () {
				mt.device.User.login();
			});
			btnLogin.resize();
			btnLogin.x = Std.int((Settings.STAGE_WIDTH - btnLogin.w) * 0.5);
			btnLogin.y = Std.int((Settings.STAGE_HEIGHT - btnLogin.h) * 0.5);
			popUp.addChild(btnLogin);
		}
		
		//showRequest(listResp);
	}
	
	function showRequest(listResp:ListResp) {
		if (listResp != null && listResp.length > 0) {
			lblNoNotif.visible = false;
			
		// PACKAGE
			var arAskLife:ListResp = [];
			var arGiveLife:ListResp = [];
			
			for (r in listResp) {
				if (r.t == FriendRequestType.R_AskLife.getIndex())
					arAskLife.push(r);
				else if (r.t == FriendRequestType.R_GiveLife.getIndex())
					arGiveLife.push(r);
			}
			
		// BADGE LIFE
			arMB = [];
			
			var rank = 0;
			
			var offsetY = 0.;
			if (lblTuto != null)
				offsetY += Std.int(lblTuto.y + lblTuto.textHeight * 2);
			else
				offsetY = heiBG * 0.1;
			
			if (arAskLife.length > 0) {
				var mb = new MailBadge(FriendRequestType.R_AskLife, arAskLife);
				mb.x = Std.int((Settings.STAGE_WIDTH - mb.wid) * 0.5);
				mb.y = Std.int(offsetY + (rank + 0.5) * (mb.hei + OFFSET_Y));
				arMB.push(mb);
				popUp.addChild(mb);
				rank++;
			}
			
			while (arGiveLife.length > 0 && arMB.length < (lblTuto != null ? 4 : 5)) {
				var max = 5 > arGiveLife.length ? arGiveLife.length : 5;
				var ar = [];
				for (i in 0...max) {
					ar.push(arGiveLife.shift());
				}
				
				var mb = new MailBadge(FriendRequestType.R_GiveLife, ar);
				mb.x = Std.int((Settings.STAGE_WIDTH - mb.wid) * 0.5);
				mb.y = Std.int(offsetY + (rank + 0.5) * (mb.hei + OFFSET_Y));
				arMB.push(mb);
				popUp.addChild(mb);
				rank++;
			}			
		}
		else {
			lblNoNotif.text = Lang.GET_VARIOUS(TypeVarious.TVNoNotif);
			lblNoNotif.x = Std.int((Settings.STAGE_WIDTH - lblNoNotif.textWidth) * 0.5);
		}
	}
	
	override function onResize() {
		for (mb in arMB) {
			mb.destroy();
		}
		
		arMB = [];
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		super.onResize();
	}
	
	override function unregister() {
		for (mb in arMB) {
			mb.destroy();
		}
		
		arMB = [];
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		ME = null;
		
		super.unregister();
	}
}

class MailBadge extends h2d.Sprite {
	var ft					: FriendRequestType;
	
	var hsBG				: mt.deepnight.slb.HSprite;
	var btnValid			: ui.Button;
	var hsValid				: mt.deepnight.slb.HSprite;
	var arHsBgAvatar		: Array<mt.deepnight.slb.HSprite>;
	var arBmpAvatar			: Array<h2d.Bitmap>;
	var hsText				: h2d.Text;
	
	var size				: Int;
	
	public var wid			: Int;
	public var hei			: Int;
	
	public function new(ft:FriendRequestType, lr:ListResp) {
		super();
		
		this.ft = ft;
		
		hsBG = Settings.SLB_UI.h_get("bgDesc");
		hsBG.scaleX = hsBG.scaleY = Settings.STAGE_SCALE * 1.5;
		hsBG.setCenterRatio(0, 0.5);
		hsBG.filter = true;
		this.addChild(hsBG);
		
		wid = Std.int(hsBG.width);
		hei = Std.int(hsBG.height);
		
	// BUTTON
		btnValid = new ui.Button("uiBtOk", "", function () {
			var arOut = [];
			for (r in lr)
				arOut.push(r.i);
			mt.device.FriendRequest.accept(arOut, DataManager.GET_REQ_DATA, function (d) {
				var result:Array<FriendRequestResult> = cast d;
				if (result!=null && result.length > 0) {
					#if mBase
					for (r in result) {
						if (r.addLife != null )
							MobileServer.ADD_LIVES( r.addLife );
					}
					data.LevelDesign.SAVE_USERLOCAL();
					#else
					var maxLife = 0;
					for (r in result) {
						if (r.newLife > maxLife)
							maxLife = r.newLife;
					}
					LevelDesign.SET_LIFE(maxLife);
					#end
					
					Levels.ME.uiBottom.uiLife.update();
					Levels.ME.uiBottom.uiLife.updateLife();
				}
				
				closeAnim();
			});
		});
		btnValid.resize();
		btnValid.x = Std.int(hsBG.width - btnValid.w - 20 * Settings.STAGE_SCALE);
		btnValid.y = Std.int( - 10 * Settings.STAGE_SCALE - btnValid.h * 0.5);
		this.addChild(btnValid);
		
		hsValid = Settings.SLB_UI.h_get("editorValid");
		hsValid.setCenterRatio(0.5, 0.5);
		hsValid.scaleX = hsValid.scaleY = Settings.STAGE_SCALE;
		hsValid.x = Std.int(btnValid.x + btnValid.w * 0.5);
		hsValid.y = Std.int(btnValid.y + btnValid.h * 0.5);
		hsValid.visible = false;
		this.addChild(hsValid);
		
	// Text
		//var hsText = new h2d.Text(Settings.FONT_BENCH_NINE_50);
		hsText = new h2d.Text(Settings.FONT_BENCH_NINE_40);
		hsText.lineSpacing = Std.int( -10 * Settings.STAGE_SCALE);
		hsText.x = Std.int(20 * Settings.STAGE_SCALE);
		hsText.y = Std.int(-hei * 0.5);
		hsText.maxWidth = Std.int(btnValid.x - btnValid.w - 40 * Settings.STAGE_SCALE);
		switch (ft) {
			case FriendRequestType.R_AskLife :
				if (lr.length == 1)
					hsText.text = Lang.GET_SOCIAL(TypeSocial.TSAsk(lr[0].f.name));
				else
					hsText.text = Lang.GET_SOCIAL(TypeSocial.TSAsks(lr.length));
			case FriendRequestType.R_GiveLife :
				if (lr.length == 1)
					hsText.text = Lang.GET_SOCIAL(TypeSocial.TSGive(lr[0].f.name));
				else
					hsText.text = Lang.GET_SOCIAL(TypeSocial.TSGives(lr.length));
			case FriendRequestType.R_InviteFriend :
		}
		this.addChild(hsText);
		
	// AVATAR
		size = Std.int(Settings.SLB_UI.getFrameData("uiBgBt").wid * 0.9);
		
		arHsBgAvatar = [];
		arBmpAvatar = [];
		
		var j = 0;
		for (i in 0...lr.length) {
			var f = lr[i].f;
			var hsBgAvatar = Settings.SLB_UI.h_get("uiBgAvatar");
			hsBgAvatar.setCenterRatio(0.5, 0.5);
			hsBgAvatar.filter = true;
			hsBgAvatar.scaleX = hsBgAvatar.scaleY = Settings.STAGE_SCALE * 0.75;
			hsBgAvatar.x = Std.int(20 * Settings.STAGE_SCALE + (i + 0.5) * (hsBgAvatar.width + 20 * Settings.STAGE_SCALE));
			hsBgAvatar.y = Std.int(hsBgAvatar.height * 0.2);
			arHsBgAvatar.push(hsBgAvatar);
			this.addChild(hsBgAvatar);
			
			if (f.avatar != null) {
				DataManager.DOWNLOAD_AVATAR(Mail.ME, f.avatar, function(t) {
					if (t != null && hsBgAvatar.parent != null && hsBG != null) {
						var bmpAvatar = new h2d.Bitmap(t);
						bmpAvatar.filter = true;
						bmpAvatar.tile = bmpAvatar.tile.center();
						bmpAvatar.scaleX = hsBgAvatar.width / bmpAvatar.tile.width * 0.9;
						bmpAvatar.scaleY = hsBgAvatar.height / bmpAvatar.tile.height * 0.9;
						bmpAvatar.x = hsBgAvatar.x;
						bmpAvatar.y = hsBgAvatar.y;
						hsBgAvatar.addChild(bmpAvatar);
						this.addChild(bmpAvatar);
						arBmpAvatar.push(bmpAvatar);
					}
				});
			}
			j++;
			if (j == 7)
				break;
		}
	}
	
	function closeAnim() {
		if (hsValid != null)
			hsValid.visible = true;
		if (btnValid != null)
			btnValid.visible = false;
	}
	
	public function destroy() {
		hsBG.dispose();
		hsBG = null;
		
		btnValid.destroy();
		btnValid = null;
		
		hsValid.dispose();
		hsValid = null;
		
		for (hs in arHsBgAvatar) {
			hs.dispose();
			hs = null;
		}
		
		for (bmp in arBmpAvatar) {
			bmp.dispose();
			bmp = null;
		}
		
		hsText.dispose();
		hsText = null;
	}
}
