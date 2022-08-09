package process.popup;

import mt.deepnight.deprecated.HProcess;
import mt.net.FriendRequest.Friend;

import Protocol;

import process.popup.BasePopup;
import process.popup.AskLife.FriendBadge;
import data.DataManager;
import data.LevelDesign;
import data.Settings;
import ui.Button;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class AskLife extends BasePopup
{
	public static var ME	: AskLife;
	
	static var OFFSET_Y		: Int		= 20;
	
	static var STEP			: Int		= 7;
	//static var STEP			: Int		= 8;
	
	static var AR_FRIENDS				: Array<{f:Friend, isSelected:Bool}>	= [];
	static var AR_INITIAL_FRIENDS		: Array<mt.net.FriendRequest.Friend>	= [];
	
	static var PREV_FRT		: FriendRequestType						= null;

	public static function CLEAR_CACHE(){
		AR_FRIENDS = [];
	}
	
	var interLeft			: h2d.Interactive;
	var interRight			: h2d.Interactive;
	var btnLeft				: mt.deepnight.slb.HSprite;
	var btnRight			: mt.deepnight.slb.HSprite;
	var hsCheck				: mt.deepnight.slb.HSprite;
	
	var btnLogin			: Button;
	
	public var isSelectedAll: Bool;
	
	var leftPage			: { p:h2d.Sprite, bf:Array<FriendBadge> };
	var mainPage			: { p:h2d.Sprite, bf:Array<FriendBadge> };
	var rightPage			: { p:h2d.Sprite, bf:Array<FriendBadge> };
	
	var actualNum			: Int;
	
	var btnAsk				: Button;
	var btnFB				: Button;
	
	var frt					: FriendRequestType;
	
	var bgInput				: h2d.Bitmap;
	var bgInputOffset		: h2d.Bitmap;
	var textInput			: mt.device.TextField;
	
	public function new(hparent:HProcess, frt:FriendRequestType) {
		ME = this;
		
		isSelectedAll = true;
		
		if (PREV_FRT == null || frt.getIndex() != PREV_FRT.getIndex())
			CLEAR_CACHE();
		
		this.frt = frt;
		PREV_FRT = frt;
		
		super(hparent, SizePopUp.SPUBig);
		
		onClose = close;
		
		if (AR_FRIENDS == null || AR_FRIENDS.length == 0 ) {
			if (mt.device.User.isLogged()) {
				mt.device.FriendRequest.friends(null, null, onFriends);				
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
		}
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideAskLife(hparent, this);
			if (End.ME != null) {
				End.ME.onClose();
			}
		});
	}
	
	function onFriends( arr : Array<mt.net.FriendRequest.Friend>/*, ?sort:Null<String>=null*/) {
		AR_INITIAL_FRIENDS = arr;
		AR_FRIENDS = [];
		if( arr != null )
			for ( f in arr ) {
				//if (sort == null || f.name.indexOf(sort) != -1) {
					switch (frt) {
						case FriendRequestType.R_AskLife :
							AR_FRIENDS.push( { f:f, isSelected:true } );
						case FriendRequestType.R_InviteFriend :
							if (f.invitable)
								AR_FRIENDS.push( { f:f, isSelected:true } );
						case FriendRequestType.R_GiveLife :
							throw "R_GiveLife is not allowed in AskLife";
					}					
				//}
			}
		
		if( !destroyAsked )
			initPages();
	}
	
	override function init() {
		switch (frt) {
			case FriendRequestType.R_AskLife :
				textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPAskYourFriends);
			case FriendRequestType.R_InviteFriend :
				textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPInviteFriends);
			case FriendRequestType.R_GiveLife :
				throw "R_GiveLife is not allowed in AskLife";
		}
		
		super.init();
		
		mt.device.EventTracker.view("ui.AskLifes");
		
		OFFSET_Y = Std.int(20 * Settings.STAGE_SCALE);
		
		isTweening = false;
		
	// SELECT
		var cSelect = new h2d.Sprite(popUp);
	
		var lblSelectAll = new h2d.Text(Settings.FONT_BENCH_NINE_90);
		lblSelectAll.filter = true;
		lblSelectAll.textColor = 0xFFEFB4;
		lblSelectAll.text = Lang.GET_VARIOUS(TypeVarious.TVSelectUnselectAll);
		lblSelectAll.y = Std.int( - lblSelectAll.textHeight * 0.5);
		arHS.push(lblSelectAll);
		cSelect.addChild(lblSelectAll);
		
		var hsBgCheck = Settings.SLB_UI.h_get("editorCheckbox");
		hsBgCheck.setCenterRatio(0.5, 0.5);
		hsBgCheck.filter = true;
		hsBgCheck.scaleX = hsBgCheck.scaleY = Settings.STAGE_SCALE;
		hsBgCheck.x = Std.int(lblSelectAll.x + lblSelectAll.width + hsBgCheck.width);
		arHS.push(hsBgCheck);
		cSelect.addChild(hsBgCheck);
		
		hsCheck = Settings.SLB_UI.h_get("editorValid");
		hsCheck.setCenterRatio(0.5, 0.5);
		hsCheck.filter = true;
		hsCheck.scaleX = hsCheck.scaleY = Settings.STAGE_SCALE;
		hsCheck.x = Std.int(hsBgCheck.x);
		hsCheck.visible = isSelectedAll;
		arHS.push(hsCheck);
		cSelect.addChild(hsCheck);
		
		var inter = new h2d.Interactive(hsBgCheck.width, hsBgCheck.height, cSelect);
		inter.setPos(hsBgCheck.x - inter.width * 0.5, -inter.height * 0.5);
		inter.onClick = onClickAskLife;
		arHS.push(inter);
		
		cSelect.x = Std.int((Settings.STAGE_WIDTH - cSelect.width) / 2);
		cSelect.y = Std.int(heiBG * 0.1);
		cSelect.visible = mt.device.User.isLogged();
		
	// BTN
		btnLeft = Settings.SLB_UI2.h_get("uiLeft");
		btnLeft.setCenterRatio(0, 0.5);
		btnLeft.scaleX = btnLeft.scaleY = Settings.STAGE_SCALE;
		btnLeft.filter = true;
		btnLeft.y = Std.int(heiBG / 2);
		popUp.add(btnLeft, 2);
		arHS.push(btnLeft);
		
		interLeft = new h2d.Interactive(btnLeft.width, btnLeft.height, popUp);
		interLeft.setPos(0, Std.int(btnLeft.y - interLeft.height / 2));
		interLeft.onPush = onPushAskLifeLeft;
		interLeft.onOver = onOverAskLifeLeft;
		interLeft.onOut = onOutAskLifeLeft;
		interLeft.onRelease = onReleaseAskLifeLeft;
		
		btnRight = Settings.SLB_UI2.h_get("uiLeft");
		btnRight.setCenterRatio(0, 0.5);
		btnRight.scaleX = -Settings.STAGE_SCALE;
		btnRight.scaleY = Settings.STAGE_SCALE;
		btnRight.x = Std.int(Settings.STAGE_WIDTH);
		btnRight.y = Std.int(heiBG / 2);
		btnRight.filter = true;
		popUp.add(btnRight, 2);
		arHS.push(btnRight);
		
		interRight = new h2d.Interactive(btnRight.width, btnRight.height, popUp);
		interRight.setPos(Std.int(Settings.STAGE_WIDTH - interRight.width), Std.int(btnLeft.y - interRight.height / 2));
		interRight.onPush = onPushAskLifeRight;
		interRight.onOver = onOverAskLifeRight;
		interRight.onRelease = onReleaseAskLifeRight;
		interRight.onOut = onOutAskLifeRight;
		
		btnAsk = new Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBAsk), function () {
			sendSpam();
		});
		btnAsk.resize();
		btnAsk.x = Std.int((Settings.STAGE_WIDTH - btnAsk.w) * 0.5);
		btnAsk.y = Std.int(heiBG * 0.9 - btnAsk.height * 0.5);
		btnAsk.visible = mt.device.User.isLogged();
		popUp.addChild(btnAsk);
		
	#if (mBase && nativeAuth)
		btnFB = new Button("btFacebook", "", function () {
			mt.device.Facebook.getToken(true,function(s){
				if( s != null )
					mt.device.FriendRequest.friends(null, null, onFriends);	
			});
		});
		btnFB.resize();
		btnFB.x = Std.int(btnAsk.x + btnAsk.w * 1.1);
		btnFB.y = Std.int(btnAsk.y + btnAsk.h * 0.5 - btnFB.h * 0.5);
		btnFB.visible = mt.device.User.isLogged() && !mtnative.nativeAuth.Facebook.isLogged();
		popUp.addChild(btnFB);
	#end
	
	// SEARCH
		bgInput = new h2d.Bitmap(h2d.Tile.fromColor(0xFF18140C, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(heiBG * 0.04)));
		bgInput.x = Std.int(Settings.STAGE_WIDTH * 0.25);
		bgInput.y = Std.int(heiBG * 0.16);
		popUp.addChild(bgInput);
		
		bgInputOffset = new h2d.Bitmap(h2d.Tile.fromColor(0xFF0A0905, Std.int(bgInput.width), Std.int(bgInput.height * 0.1)));
		bgInputOffset.x = Std.int(bgInput.x);
		bgInputOffset.y = Std.int(bgInput.y - bgInputOffset.height);
		popUp.addChild(bgInputOffset);
		
		textInput = new mt.device.TextField();
		textInput.textColor = 0xFFFFFFFF;
		textInput.textSize = Settings.STAGE_SCALE * 30;
		textInput.width = Std.int(Settings.STAGE_WIDTH * 0.5);
		textInput.x = Std.int(Settings.STAGE_WIDTH * 0.25);
		textInput.onTextChanged = function (str) {
			AR_FRIENDS = [];
			if( AR_INITIAL_FRIENDS != null )
				for ( f in AR_INITIAL_FRIENDS ) {
					if (f.name.toLowerCase().indexOf(str.toLowerCase()) != -1) {
						switch (frt) {
							case FriendRequestType.R_AskLife :
								AR_FRIENDS.push( { f:f, isSelected:true } );
							case FriendRequestType.R_InviteFriend :
								if (f.invitable)
									AR_FRIENDS.push( { f:f, isSelected:true } );
							case FriendRequestType.R_GiveLife :
								throw "R_GiveLife is not allowed in AskLife";
						}					
					}
				}
			
			if( !destroyAsked )
				initPages();
		}
		
		onEndAnim = function () {
			textInput.y = Std.int(bgInput.y + popUp.y);
		}
		
	// BADGE FRIEND
		actualNum = 0;
		
		mainPage = { p:new h2d.Sprite(), bf:[] };
		mainPage.p.y = heiBG * 0.275;
		popUp.addChild(mainPage.p);
		leftPage = { p:new h2d.Sprite(), bf:[] };
		leftPage.p.x = Std.int(-Settings.STAGE_WIDTH);
		leftPage.p.y = heiBG * 0.275;
		popUp.addChild(leftPage.p);
		rightPage = { p:new h2d.Sprite(), bf:[] };
		rightPage.p.x = Std.int(Settings.STAGE_WIDTH);
		rightPage.p.y = heiBG * 0.275;
		popUp.addChild(rightPage.p);
		
		if (btnLogin != null) {
			btnLogin.resize();
			btnLogin.x = Std.int((Settings.STAGE_WIDTH - btnLogin.w) * 0.5);
			btnLogin.y = Std.int((Settings.STAGE_HEIGHT - btnLogin.h) * 0.5);
		}
		
	#if debug
		//LevelDesign.AR_FRIENDS = [];
		////for (i in 0...500) {
		//for (i in 0...50) {
			//LevelDesign.AR_FRIENDS.push( {isSelected:true, f:{ net: 0, id: "test", name: Std.string(i), avatar: "https://imgup.motion-twin.com/twinoid/3/9/9816c156_115.jpg", invitable: false }} );
		//}
	#end
		
		btnLeft.visible = interLeft.visible = false;
		btnRight.visible = interRight.visible = false;
		
		initPages();
	}
	
	function onClickAskLife(e) {
		if (!isTweening) {
			isSelectedAll = !isSelectedAll;
			hsCheck.visible = isSelectedAll;
			toggleSelectAll();
		}
	}
	
	function onPushAskLifeLeft(e) {
		btnLeft.set("uiLeftActive");
	}
	
	function onOverAskLifeLeft(e) {
		btnLeft.set("uiLeftOver");
	}
	
	function onOutAskLifeLeft(e) {
		btnLeft.set("uiLeft");
	}
	
	function onReleaseAskLifeLeft(e) {
		btnLeft.set("uiLeft");
		
		if (!isTweening && interLeft.visible) {
			var oldRightPage = rightPage;
			var oldMainPage = mainPage;
			var oldLeftPage = leftPage;
			
			isTweening = true;
			
			function onUpdate (e) {
				for (fb in mainPage.bf)
					fb.setPosBE();				
			}
			tweener.create().to(0.2 * Settings.FPS, mainPage.p.x = mainPage.p.x + Settings.STAGE_WIDTH).onUpdate = onUpdate;
			function onComplete() {
				isTweening = false;
				rightPage = oldMainPage;
				mainPage = oldLeftPage;
				actualNum -= STEP;
				
				leftPage = oldRightPage;
				leftPage.p.x = Std.int(-Settings.STAGE_WIDTH);
				if (actualNum > 0) {
					loadPage(actualNum - STEP, leftPage);						
				}
				
				btnLeft.visible = interLeft.visible = actualNum > 0;
				btnRight.visible = interRight.visible = actualNum + STEP < AR_FRIENDS.length;
			}
			function onUpdate2 (e) {
				for (fb in leftPage.bf)
					fb.setPosBE();
			}
			var t2 = tweener.create().to(0.2 * Settings.FPS, leftPage.p.x = leftPage.p.x + Settings.STAGE_WIDTH);
			t2.onComplete = onComplete;
			t2.onUpdate = onUpdate2;
		}
	}
	
	function onPushAskLifeRight(e) {
		btnRight.set("uiLeftActive");
	}
	
	function onOverAskLifeRight(e) {
		btnRight.set("uiLeftOver");
	}
	
	function onOutAskLifeRight(e) {
		btnRight.set("uiLeft");
	}
	
	function onReleaseAskLifeRight(e) {
		btnRight.set("uiLeft");
		
		if (!isTweening && interRight.visible) {
			var oldRightPage = rightPage;
			var oldMainPage = mainPage;
			var oldLeftPage = leftPage;
			
			isTweening = true;
			
			function onUpdate (e) {
				for (fb in mainPage.bf)
					fb.setPosBE();				
			}
			tweener.create().to(0.2 * Settings.FPS, mainPage.p.x = mainPage.p.x - Settings.STAGE_WIDTH).onUpdate = onUpdate;
			function onComplete() {
				isTweening = false;
				leftPage = oldMainPage;
				mainPage = oldRightPage;
				actualNum += STEP;
				
				rightPage = oldLeftPage;
				rightPage.p.x = Std.int(Settings.STAGE_WIDTH);
				loadPage(actualNum + STEP, rightPage);
				
				btnLeft.visible = interLeft.visible = actualNum > 0;
				btnRight.visible = interRight.visible = actualNum + STEP < AR_FRIENDS.length;
			}
			function onUpdate2 (e) {
				for (fb in rightPage.bf)
					fb.setPosBE();
			}
			var t2 = tweener.create().to(0.2 * Settings.FPS, rightPage.p.x = rightPage.p.x - Settings.STAGE_WIDTH);
			t2.onComplete = onComplete;
			t2.onUpdate = onUpdate2;
		}
	}
	
	function initPages(){
		loadPage(actualNum, mainPage);
		
		if( AR_FRIENDS.length > STEP ){
			btnRight.visible = interRight.visible = true;
			loadPage(actualNum + STEP, rightPage);
		}else {
			btnRight.visible = interRight.visible = false;
		}
		
		loadPage(actualNum + STEP, leftPage);
	}
	
	function loadPage(n:Int, page:{ p:h2d.Sprite, bf:Array<FriendBadge> }) {
		for (fb in page.bf) {
			fb.destroy();
			fb = null;
		}
		
		page.bf = [];
		
		if (n >= AR_FRIENDS.length)
			n = 0;
			
		var nMax = (n + STEP) >= AR_FRIENDS.length ? AR_FRIENDS.length : (n + STEP);
		
		var j = 0;
		
		for (i in n...nMax) {
			var fb = new FriendBadge(this, AR_FRIENDS[i]);
			fb.x = Std.int(Settings.STAGE_WIDTH * 0.5 - fb.wid * 0.5);
			fb.y = j * (fb.hei + OFFSET_Y);
			page.p.addChild(fb);
			page.bf.push(fb);
			j++;
			fb.setPosBE();
		}
	}
	
	function toggleSelectAll() {
		for (f in AR_FRIENDS)
			f.isSelected = isSelectedAll;
		
		for (fb in mainPage.bf)
			fb.checkSelectAll();
		
		for (fb in leftPage.bf)
			fb.checkSelectAll();
		
		for (fb in rightPage.bf)
			fb.checkSelectAll();
	}
	
	function sendSpam() {
		var arOut = [];
		for (f in AR_FRIENDS) {
			if (f.isSelected)
				arOut.push(f.f);
		}
		trace(arOut.length);
		var id = frt.getIndex();
		var req = DataManager.GET_REQ_DATA(id);
		mt.device.FriendRequest.request(id, req.message, arOut, req.data, function () {
			onClose();
		});
	}
	
	override function onResize() {
		if (interLeft != null) {
			interLeft.dispose();
			interLeft = null;			
		}
		
		if (interRight != null) {
			interRight.dispose();
			interRight = null;			 
		}
		
		if (btnAsk != null) {
			btnAsk.destroy();
			btnAsk = null;
		}
		
		if (btnFB != null) {
			btnFB.destroy();
			btnFB = null;
		}
		
		if (mainPage != null) {
			for (fb in mainPage.bf) {
				fb.destroy();
				fb = null;
			}
			
			mainPage.p.dispose();
			mainPage = null;	
			
			for (fb in leftPage.bf) {
				fb.destroy();
				fb = null;
			}
			
			leftPage.p.dispose();
			leftPage = null;
			
			for (fb in rightPage.bf) {
				fb.destroy();
				fb = null;
			}
			
			rightPage.p.dispose();
			rightPage = null;
		}
		
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		if (bgInput != null)
			bgInput.dispose();
		bgInput = null;
		
		if (bgInputOffset != null)
			bgInputOffset.dispose();
		bgInputOffset = null;
		
		if (textInput != null)
			textInput.destroy();
		textInput = null;
		
		super.onResize();
	}
	
	override function unregister() {
		if (interLeft != null) {
			interLeft.dispose();
			interLeft = null;			
		}
		
		if (interRight != null) {
			interRight.dispose();
			interRight = null;			 
		}
		
		if (btnAsk != null) {
			btnAsk.destroy();
			btnAsk = null;
		}
		
		if (btnFB != null) {
			btnFB.destroy();
			btnFB = null;
		}
		
		for (fb in mainPage.bf) {
			fb.destroy();
			fb = null;
		}
		
		mainPage.p.dispose();
		mainPage = null;
		
		for (fb in leftPage.bf) {
			fb.destroy();
			fb = null;
		}
		
		leftPage.p.dispose();
		leftPage = null;
		
		for (fb in rightPage.bf) {
			fb.destroy();
			fb = null;
		}
		
		rightPage.p.dispose();
		rightPage = null;
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		if (bgInput != null)
			bgInput.dispose();
		bgInput = null;
		
		if (bgInputOffset != null)
			bgInputOffset.dispose();
		bgInputOffset = null;
		
		if (textInput != null)
			textInput.destroy();
		textInput = null;
		
		ME = null;
		
		AR_FRIENDS = [];
		
		super.unregister();
	}
}

class FriendBadge extends h2d.Sprite   {
	var askLife					: AskLife;
	var friend					: {f:Friend, isSelected:Bool};
	var nameId					: String;
	
	var size					: Int;
	
	var hsBG					: mt.deepnight.slb.HSpriteBE;
	var hsBgAvatar				: mt.deepnight.slb.HSpriteBE;
	var bmpAvatar				: h2d.Bitmap;
	var lblName					: h2d.Text;
	var hsBgCheck				: mt.deepnight.slb.HSpriteBE;
	var hsCheck					: mt.deepnight.slb.HSpriteBE;
	var inter					: h2d.Interactive;
	
	public var wid				: Int;
	public var hei				: Int;
	
	public function new(askLife:AskLife, friend:{f:Friend, isSelected:Bool}) {
		super();
		
		this.askLife = askLife;
		this.friend = friend;
		nameId = friend.f.name;
		
		if (nameId.length > 20)
			nameId = nameId.substr(0, 20);
			
		hsBG = Settings.SLB_UI.hbe_get(askLife.bm, "bgDesc");
		hsBG.setCenterRatio(0, 0.5);
		hsBG.scaleX = hsBG.scaleY = Settings.STAGE_SCALE * 0.75;
		
		wid = Std.int(hsBG.width);
		hei = Std.int(hsBG.height);
		
		hsBgAvatar = Settings.SLB_UI.hbe_get(askLife.bm, "uiBgAvatar");
		size = Std.int(hsBgAvatar.width * 0.90);
		hsBgAvatar.setCenterRatio(0.5, 0.5);
		hsBgAvatar.scaleX = hsBgAvatar.scaleY = Settings.STAGE_SCALE * 0.5;
		
		if (friend.f.avatar != null)
			DataManager.DOWNLOAD_AVATAR(askLife, friend.f.avatar, onLoadAvatar);
			
		//lblName = new h2d.Text(Settings.FONT_MOUSE_DECO_36);
		lblName = new h2d.Text(Settings.FONT_BENCH_NINE_50);
		lblName.filter = true;
		#if flash
		lblName.text = nameId;
		#else
		if( haxe.Utf8.validate(nameId) )
			lblName.text = nameId;
		else
			lblName.text = "";
		#end
		this.addChild(lblName);
		
		hsBgCheck = Settings.SLB_UI.hbe_get(askLife.bm, "editorCheckbox");
		hsBgCheck.setCenterRatio(0.5, 0.5);
		hsBgCheck.scaleX = hsBgCheck.scaleY = Settings.STAGE_SCALE * 0.75;
		
		hsCheck = Settings.SLB_UI.hbe_get(askLife.bm, "editorValid");
		hsCheck.setCenterRatio(0.5, 0.5);
		hsCheck.scaleX = hsCheck.scaleY = Settings.STAGE_SCALE * 0.75;
		hsCheck.visible = friend.isSelected;
		
		inter = new h2d.Interactive(hsBG.width, hsBG.height);
		inter.setPos(0, -hsBG.height * 0.5);
		inter.onClick = onClickFriendBadge;
		this.addChild(inter);
	}

	function onLoadAvatar( t ){
		if( t == null || hsBgAvatar == null || hsBG == null)
			return;

		bmpAvatar = new h2d.Bitmap(t);
		bmpAvatar.filter = true;
		bmpAvatar.tile = bmpAvatar.tile.center();
		bmpAvatar.scaleX = hsBgAvatar.width / bmpAvatar.tile.width * 0.9;
		bmpAvatar.scaleY = hsBgAvatar.height / bmpAvatar.tile.height * 0.9;
		bmpAvatar.x = hsBgAvatar.width * 0.7;
		bmpAvatar.y = -hsBgAvatar.height * 0.1;
		this.addChild(bmpAvatar);
	}
	
	public function setPosBE() {
		var newX = (parent != null ? parent.x : 0) + x;
		var newY = (parent != null ? parent.y : 0) + y;
		
		hsBG.x = newX;
		hsBG.y = newY;
		
		hsBgAvatar.x = Std.int(newX + hsBgAvatar.width * 0.7);
		hsBgAvatar.y = Std.int(newY - hsBgAvatar.height * 0.1);
		
		lblName.x = Std.int(hsBgAvatar.width * 1.5);
		lblName.y = Std.int( -lblName.textHeight * 0.6);
		
		hsBgCheck.x = Std.int(newX + hsBG.width - hsBgCheck.width * 0.7);
		hsBgCheck.y = Std.int(newY - hsBgAvatar.height * 0.1);
		
		hsCheck.x = Std.int(hsBgCheck.x);
		hsCheck.y = Std.int(hsBgCheck.y);
	}
	
	function onClickFriendBadge(e) {
		if (!askLife.isTweening) {
			friend.isSelected = !friend.isSelected;
			hsCheck.visible = friend.isSelected;
		}
	}
	
	public function checkSelectAll() {
		friend.isSelected = askLife.isSelectedAll;
		hsCheck.visible = friend.isSelected;
	}
	
	public function destroy() {
		hsBG.dispose();
		hsBG = null;
		
		hsBgAvatar.dispose();
		hsBgAvatar = null;
		
		if (bmpAvatar != null) {
			bmpAvatar.dispose();
			bmpAvatar = null;
		}
		
		lblName.dispose();
		lblName = null;
		
		hsBgCheck.dispose();
		hsBgCheck = null;
		
		hsCheck.dispose();
		hsCheck = null;
		
		inter.dispose();
		inter = null;
	}
}
