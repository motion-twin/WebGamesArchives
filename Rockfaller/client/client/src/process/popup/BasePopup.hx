package process.popup ;

import data.Lang;
import h2d.Interactive;
import h2d.Sprite;
import mt.deepnight.deprecated.HProcess;
import mt.deepnight.slb.HSpriteBE;
import mt.deepnight.slb.HSprite;
import process.popup.BasePopup.RankBadge;
import ui.Button.TypeButton;

import Common;
import Protocol;

import data.Settings;
import data.LevelDesign;
import data.DataManager;
import Rock;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */

enum SizePopUp {
	SPUSmall;
	SPUNormal;
	SPUBig;
}

class BasePopup extends mt.deepnight.deprecated.HProcess {
	var arHS		: Array<h2d.Sprite>;
	
	var arBE		: Array<HSpriteBE>;
	
	public var bm			: h2d.SpriteBatch;
	var hsChainExtendLeft	: HSpriteBE;
	var hsChainLeft			: HSpriteBE;
	var hsChainExtendRight	: HSpriteBE;
	var hsChainRight		: HSpriteBE;
	
	var heiBG		: Int;
	var speed		: Float;
	var speedFall	: Float;
	
	public var popUp	: h2d.Layers;
	
	public var tweener	: mt.motion.Tweener;
	var btnClose	: ui.Button;
	
	var isCome		: Bool;
	var inter		: Interactive;
	
	public var onClose		: Void->Void;
	
	var onEndAnim	: Void->Void;
	
	var hparent		: mt.deepnight.deprecated.HProcess;
	var enableDeco	: Bool;
	
	var hsStonesTopLeft		: HSpriteBE;
	var hsStonesTopRight	: HSpriteBE;
	
	public var isTweening	: Bool;
	var size				: SizePopUp;
	
	var textLabel			: String;
	
	function new(hparent:mt.deepnight.deprecated.HProcess, size:SizePopUp) {
		super();
		
		this.hparent = hparent;
		this.size = size;
		
		tweener = new mt.motion.Tweener();
		
		inter = new h2d.Interactive(1, 1);
		inter.backgroundColor = 0xFF000000;
		inter.alpha = 0;
		inter.cursor = hxd.System.Cursor.Default;
		root.add(inter, 0);
		
		tweener.create().to(0.2 * Settings.FPS, inter.alpha = 0.75);
		
		popUp = new h2d.Layers();
		root.add(popUp, 0);
		
		btnClose = new ui.Button("btClose", "", function () {
			if (onClose != null)
				onClose();
		});
		popUp.add(btnClose, 2);
		
		bm = new h2d.SpriteBatch(Settings.SLB_UI.tile, popUp);
		
		hsChainExtendLeft = Settings.SLB_UI.hbe_get(bm, "chainTaut");
		hsChainExtendLeft.setCenterRatio(0.5, 0.98);
		hsChainExtendLeft.changePriority(10);
		
		hsChainLeft = Settings.SLB_UI.hbe_get(bm, "chainTaut");
		hsChainLeft.setCenterRatio(0.5, 1);
		hsChainLeft.changePriority(10);
		
		hsChainExtendRight = Settings.SLB_UI.hbe_get(bm, "chainTaut");
		hsChainExtendRight.setCenterRatio(0.5, 0.98);
		hsChainExtendRight.changePriority(10);
		
		hsChainRight = Settings.SLB_UI.hbe_get(bm, "chainTaut");
		hsChainRight.setCenterRatio(0.5, 1);
		hsChainRight.changePriority(10);
		
		arHS = [];
		arBE = [];
		
		speedFall = 0.5;
		
		isCome = false;
		
		enableDeco = false;
		
		onResize();
	}
	
	function init() {
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		arHS = [];
		
		for (be in arBE) {
			be.dispose();
			be = null;
		}
		arBE = [];
		
	// CHAINS
		hsChainExtendLeft.scaleX = hsChainExtendLeft.scaleY = Settings.STAGE_SCALE;
		hsChainLeft.scaleX = hsChainLeft.scaleY = Settings.STAGE_SCALE;
		hsChainExtendLeft.x = hsChainLeft.x = Settings.STAGE_WIDTH / 5;
		
		hsChainExtendRight.scaleX = hsChainExtendRight.scaleY = Settings.STAGE_SCALE;
		hsChainRight.scaleX = hsChainRight.scaleY = Settings.STAGE_SCALE;
		hsChainExtendRight.x = hsChainRight.x = Settings.STAGE_WIDTH * 4 / 5;
		
	// BG
		var id = switch (size) {
			case SizePopUp.SPUSmall		: "popUpBgSmall";
			case SizePopUp.SPUNormal	: "popUpBg";
			case SizePopUp.SPUBig		: "pageBg";
		}
		
		var scaling = mt.Metrics.w() / Settings.SLB_UI.getFrameData(id).wid;
		
		var hsBG = Settings.SLB_UI.hbe_get(bm, id);
		hsBG.scaleX = hsBG.scaleY = scaling;
		hsBG.changePriority(9);
		arBE.push(hsBG);
		
		heiBG = Std.int(hsBG.height);
		
		hsChainLeft.y = Std.int(hsChainLeft.height * 0.1);
		hsChainExtendLeft.y = hsChainLeft.y - hsChainLeft.height;
		hsChainRight.y = Std.int(hsChainRight.height * 0.1);
		hsChainExtendRight.y = hsChainRight.y - hsChainRight.height;
		
		var widFade = Std.int(Settings.SLB_UI.getFrameData("popUpUp").wid);
		
		var hsFadeTop = Settings.SLB_UI.hbe_get(bm, "popUpUp");
		hsFadeTop.setCenterRatio(0, 1);
		hsFadeTop.scaleX = Settings.STAGE_WIDTH / widFade;
		hsFadeTop.scaleY = Settings.STAGE_SCALE;
		hsFadeTop.changePriority(8);
		
		var hsFadeBot = Settings.SLB_UI.hbe_get(bm, "popUpUp");
		hsFadeBot.setCenterRatio(0, 1);
		hsFadeBot.scaleX = Settings.STAGE_WIDTH / widFade;
		hsFadeBot.scaleY = -Settings.STAGE_SCALE;
		hsFadeBot.y = heiBG;
		hsFadeBot.changePriority(8);
		
		arBE.push(hsFadeTop);
		arBE.push(hsFadeBot);
		
		if (enableDeco)
			showDeco();
		
		var widStrip = Std.int(Settings.SLB_UI.getFrameData("popUpGlyphe").wid * Settings.STAGE_SCALE);
		
		var numStrip = Std.int(Settings.STAGE_WIDTH / widStrip) + 1;
		
		for (i in 0...numStrip + 1) {
			var hsStrip = Settings.SLB_UI.hbe_get(bm, "popUpGlyphe");
			hsStrip.scaleX = hsStrip.scaleY = Settings.STAGE_SCALE;
			hsStrip.x = i * widStrip;
			hsStrip.changePriority(7);
			
			var tp = createTinyProcess();
			tp.onUpdate = function () {
				if (hsStrip == null)
					tp.destroy();
				else {
					if (hsStrip.x <= -widStrip)
						hsStrip.x = numStrip * widStrip;
					
					hsStrip.x -= speed;					
				}
			}
			
			arBE.push(hsStrip);
		}
		
		for (i in 0...numStrip + 1) {
			var hsStrip = Settings.SLB_UI.hbe_get(bm, "popUpGlyphe");
			hsStrip.scaleX = Settings.STAGE_SCALE;
			hsStrip.scaleY = -Settings.STAGE_SCALE;
			hsStrip.x = i * widStrip - widStrip;
			hsStrip.y = heiBG;
			hsStrip.changePriority(7);
			
			var tp = createTinyProcess();
			tp.onUpdate = function () {
				if (hsStrip == null)
					tp.destroy();
				else {
					if (hsStrip.x >= widStrip * numStrip)
						hsStrip.x = -widStrip;
					
					hsStrip.x += speed;
				}
			}
			
			arBE.push(hsStrip);
		}
		
		var hsNutTL = getNut();
		hsNutTL.x = Std.int(Settings.STAGE_WIDTH / 20);
		hsNutTL.y = Std.int(heiBG / 10);
		
		var hsNutTR = getNut();
		hsNutTR.x = Std.int(Settings.STAGE_WIDTH * 19 / 20);
		hsNutTR.y = Std.int(heiBG / 10);
		
		var hsNutBL = getNut();
		hsNutBL.x = Std.int(Settings.STAGE_WIDTH / 20);
		hsNutBL.y = Std.int(heiBG * 9 / 10);
		
		var hsNutBR = getNut();
		hsNutBR.x = Std.int(Settings.STAGE_WIDTH * 19 / 20);
		hsNutBR.y = Std.int(heiBG * 9 / 10);
		
	// BTN CLOSE
		btnClose.resize();
	#if mBase
		if (mt.Metrics.px2cm(btnClose.w) < 2)
			btnClose.resize(Settings.STAGE_SCALE * 2);
	#end
		btnClose.x = Std.int(Settings.STAGE_WIDTH - btnClose.w * 1.5);
		btnClose.y = Std.int(-btnClose.h * 0.5);
		
	// LABEL POPUP
		var lblPopup = new h2d.Text(Settings.FONT_BIRMINGHAM_BMF_120);
		lblPopup.text = textLabel;
		lblPopup.text = lblPopup.text.toLowerCase();
		if (lblPopup.textWidth > Settings.STAGE_WIDTH * 0.75) {
			lblPopup.scaleX = lblPopup.scaleY = (Settings.STAGE_WIDTH * 0.75) / lblPopup.textWidth;
		}
		lblPopup.textColor = 0xFFEFB4;
		lblPopup.x = Std.int((Settings.STAGE_WIDTH - lblPopup.textWidth * lblPopup.scaleX) * 0.5);
		lblPopup.y = -Std.int(lblPopup.textHeight * lblPopup.scaleY);
		arHS.push(lblPopup);
		popUp.add(lblPopup, 1);
		
		if (enableDeco) {
			hsStonesTopLeft.x = lblPopup.x;
			hsStonesTopRight.x = Std.int((Settings.STAGE_WIDTH + lblPopup.textWidth) * 0.5);			
		}
		
		popUp.y = Std.int((Settings.STAGE_HEIGHT - (heiBG - lblPopup.textHeight * lblPopup.scaleY)) * 0.5);
		
		if (!isCome) {
			SoundManager.POPIN_SFX(this);
			
			popUp.y -= Settings.STAGE_HEIGHT;
			
			isTweening = true;
			
			var popupY = Std.int((Settings.STAGE_HEIGHT - (heiBG - lblPopup.textHeight * lblPopup.scaleY)) * 0.5);
	
			var t = tweener.create();
			function onComplete() {
				isCome = true;
				isTweening = false;
				hsChainLeft.a.play("chainAnim").setCurrentAnimSpeed(0.75);
				hsChainRight.a.play("chainAnim").setCurrentAnimSpeed(0.75);
				FX.DO_GENERAL_SHAKE(0, 10);
			}
			t.to(speedFall * Settings.FPS, popUp.y = popupY).ease(mt.motion.Ease.easeInCubic).onComplete = onComplete;
			t.to(0.1 * Settings.FPS, popUp.y = popupY - 20 * Settings.STAGE_SCALE);
			t.to(0.1 * Settings.FPS, popUp.y = popupY).onComplete = endAnimTween;
		}
	}
	
	function endAnimTween() {
		if (onEndAnim != null)
			onEndAnim();
	}
	
	function showDeco() {
		// only in rare situations
		var widstoneBot = Std.int(Settings.SLB_UI.getFrameData("stonesPopupBottom").wid);
		
		var hsStonesBot = Settings.SLB_UI.hbe_get(bm, "stonesPopupBottom");
		hsStonesBot.setCenterRatio(0, 0);
		hsStonesBot.scaleX = Settings.STAGE_WIDTH / widstoneBot;
		hsStonesBot.scaleY = hsStonesBot.scaleX;
		hsStonesBot.y = heiBG;
		hsStonesBot.changePriority(7);
		arBE.push(hsStonesBot);
		
		hsStonesTopLeft = Settings.SLB_UI.hbe_get(bm, "stonesPopupTopLeft");
		hsStonesTopLeft.setCenterRatio(1, 1);
		hsStonesTopLeft.scaleX = hsStonesBot.scaleX;
		hsStonesTopLeft.scaleY = hsStonesBot.scaleX;
		hsStonesTopLeft.changePriority(7);
		arBE.push(hsStonesTopLeft);
		
		hsStonesTopRight = Settings.SLB_UI.hbe_get(bm, "stonesPopupTopRight");
		hsStonesTopRight.setCenterRatio(0, 1);
		hsStonesTopRight.scaleX = hsStonesBot.scaleX;
		hsStonesTopRight.scaleY = hsStonesBot.scaleX;
		hsStonesTopRight.changePriority(7);
		arBE.push(hsStonesTopRight);
		
		var hsGear = Settings.SLB_UI2.h_get("gearPopup");
		hsGear.setCenterRatio(0.5, 0.5);
		hsGear.scaleX = hsGear.scaleY = Settings.STAGE_SCALE;
		hsGear.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		hsGear.y = Std.int(heiBG - hsGear.height * 0.25);
		hsGear.filter = true;
		popUp.addChild(hsGear);
		hsGear.toBack();
		arHS.push(hsGear);
		
		var tp = createTinyProcess();
		tp.onUpdate = function () {
			if (hsGear == null)
				tp.destroy();
			else
				hsGear.rotation += 0.02;
		}
	}
	
	function disableCloseBtn() {
		btnClose.visible = false;
	}
	
	function getNut():HSpriteBE {
		var hsNut = Settings.SLB_UI.hbe_get(bm, "ecrou");
		hsNut.scaleX = hsNut.scaleY = Settings.STAGE_SCALE;
		hsNut.setCenterRatio(0.5, 0.5);
		hsNut.changePriority(6);
		arBE.push(hsNut);
		
		return hsNut;
	}
	
	function animEnd(f:Void->Void) {
		if (!isTweening) {
			isTweening = true;
			
			tweener.create().to(0.2 * Settings.FPS, inter.alpha = 0);
			
			SoundManager.POPOUT_SFX();
			
			var t = tweener.create();
			t.to(0.1 * Settings.FPS, popUp.y += -20 * Settings.STAGE_SCALE);
			function onComplete() {
				f();
			}
			t.to(0.25 * Settings.FPS, popUp.y = Std.int((Settings.STAGE_HEIGHT - heiBG) / 2) - Settings.STAGE_HEIGHT).onComplete = onComplete;	
		}
	}
	
	override function unregister() {
		tweener.dispose();
		tweener = null;
		
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		
		hsChainExtendLeft.dispose();
		hsChainExtendLeft = null;
		
		hsChainLeft.dispose();
		hsChainLeft = null;
		
		hsChainExtendRight.dispose();
		hsChainExtendRight = null;
		
		hsChainRight.dispose();
		hsChainRight = null;
		
		arHS = [];
		
		btnClose.destroy();
		btnClose = null;
		
		inter.dispose();
		inter = null;
		
		super.unregister();
	}
	
	override function onResize() {
		//speed = 1 * Settings.STAGE_SCALE;
		speed = 0.3 * Settings.STAGE_SCALE;
		
		inter.scaleX = Settings.STAGE_WIDTH + 50 * Settings.STAGE_SCALE;
		inter.scaleY = Settings.STAGE_HEIGHT  + 50 * Settings.STAGE_SCALE;
		inter.x = - 25 * Settings.STAGE_SCALE;
		inter.y = - 25 * Settings.STAGE_SCALE;
		
		init();
		
		super.onResize();
	}
	
	override function update() {
	
		
		super.update();
		if( Settings.SLB_UI != null )
			Settings.SLB_UI.updateChildren();
		tweener.update();
	}
	
}

typedef Pack = {
	var container	: h2d.Sprite;
	var rb1			: RankBadge;
	var rb2			: RankBadge;
	var rb3			: RankBadge;
}

class ModFriend extends h2d.Layers {
	var hparent			: HProcess;
	var level			: Int;
	var bpu				: BasePopup;
	
	var bm				: h2d.SpriteBatch;
	var bgGlobal		: mt.deepnight.slb.HSprite;
	var btnInvite		: ui.Button;
	
	var arRB			: Array<RankBadge>;
	
	var i = 0;
	var j = 0;
	
	var maxPage			: Int;
	var actualPage		: Int;
	
	var pack1			: Pack;
	var pack2			: Pack;
	var actualPack		: Pack;
	var otherPack		: Pack;
	
	var arFriend		: Array<FriendData>;
	
	var leftArrow		: mt.deepnight.slb.HSprite;
	var interLeft		: h2d.Interactive;
	var rightArrow		: mt.deepnight.slb.HSprite;
	var interRight		: h2d.Interactive;
	
	var isTweening		: Bool;
	
	public function new(hparent:HProcess, bpu:BasePopup, level:Int) {
		super();
		
		this.bpu = bpu;
		this.level = level;
		this.hparent = hparent;
		
		isTweening = false;
		
		bm = new h2d.SpriteBatch(Settings.SLB_UI.tile);
		this.add(bm, 1);
		
		bgGlobal = Settings.SLB_NOTRIM.h_get("bgLeaderboard");
		bgGlobal.scaleX = bgGlobal.scaleY = Settings.STAGE_WIDTH / bgGlobal.width;
		this.add(bgGlobal, 0);
		
		btnInvite = new ui.Button("btGreen", Lang.GET_BUTTON(TypeButton.TBInvite), function () {
			ProcessManager.ME.showAskLife(hparent, FriendRequestType.R_InviteFriend);
		});
		btnInvite.resize();
		btnInvite.scaleX = btnInvite.scaleY = 0.5;
		btnInvite.x = Std.int((Settings.STAGE_WIDTH - btnInvite.w * 0.5) * 0.5);
		btnInvite.y = Std.int(bgGlobal.height * 0.1);
		this.add(btnInvite, 0);
		
		arFriend = [];
		if( LevelDesign.FRIENDS != null ){
			for (f in LevelDesign.FRIENDS) {
				if (f.highscore != null && f.highscore[level] != null)
					arFriend.push(f);
			}
		}
		
		//arFriend = arFriend.concat(arFriend);
		//arFriend = arFriend.concat(arFriend);
		//arFriend.push(arFriend[0]);
		//arFriend.push(arFriend[0]);
		
		if (LevelDesign.USER_DATA.arHighScore != null && LevelDesign.USER_DATA.arHighScore[level] != null)
			arFriend.push( { id:0, name:Lang.GET_VARIOUS(TypeVarious.TVMe), avatar:LevelDesign.URL_AVATAR, levelMax:LevelDesign.GET_MAXLEVEL(), highscore:LevelDesign.USER_DATA.arHighScore });
		
		arFriend.sort(function(f1, f2) {
			return f2.highscore[level] - f1.highscore[level];
		});
		
		if (arFriend.length > 3) {
			leftArrow = Settings.SLB_NOTRIM.h_get("uiArrow");
			leftArrow.setCenterRatio(0.3, 1);
			leftArrow.scaleX = leftArrow.scaleY = Settings.STAGE_SCALE;
			leftArrow.rotation = 3.14 / 2;
			leftArrow.y = Std.int(bgGlobal.height * 0.5);
			this.add(leftArrow, 2);
			
			interLeft = new h2d.Interactive(leftArrow.width, bgGlobal.height);
			interLeft.onClick = onClickLeft;
			this.add(interLeft, 2);
			
			rightArrow = Settings.SLB_NOTRIM.h_get("uiArrow");
			rightArrow.setCenterRatio(0.7, 1);
			rightArrow.scaleX = rightArrow.scaleY = Settings.STAGE_SCALE;
			rightArrow.rotation = -3.14 / 2;
			rightArrow.x = Std.int(Settings.STAGE_WIDTH);
			rightArrow.y = Std.int(bgGlobal.height * 0.5);
			this.add(rightArrow, 2);
			
			interRight = new h2d.Interactive(leftArrow.width, bgGlobal.height);
			interRight.x = Std.int(Settings.STAGE_WIDTH - interRight.width);
			interRight.onClick = onClickRight;
			this.add(interRight, 2);
		}
		
		arRB = [];
		
		maxPage = Std.int((arFriend.length - 1) / 3) + 1;
		trace("maxPage : " + maxPage);
		
		var actualRank = 0;
		for (i in 0...arFriend.length)
			if (arFriend[i].name == Lang.GET_VARIOUS(TypeVarious.TVMe))
				actualRank = i;
				
		trace("actualRank (in array) : " + actualRank);
		
		actualPage = Std.int(actualRank / 3);
		trace("actualPage : " + actualPage);
			
		pack1 = { container:null, rb1:null, rb2:null, rb3:null };
		pack2 = { container:null, rb1:null, rb2:null, rb3:null };
		
		createPack(pack1, actualPage);
		createPack(pack2, actualPage + 1);
		
		actualPack = pack1;
		otherPack = pack2;
		pack2.container.x = Settings.STAGE_WIDTH;
		
		if (leftArrow != null)
			leftArrow.visible = interLeft.visible = actualPage > 0;
		if (rightArrow != null)
			rightArrow.visible = interRight.visible = actualPage < maxPage - 1;
			
		if (arFriend.length == 0) {
			btnInvite.scaleX = btnInvite.scaleY = 1;
			btnInvite.x = Std.int((Settings.STAGE_WIDTH - btnInvite.w) * 0.5);
			btnInvite.y = Std.int(bgGlobal.height * 0.4);
		}
	}
	
	function createPack(pack:Pack, page:Int) {
		var cPack = new h2d.Sprite();
		this.add(cPack, 1);
		
		pack.container = cPack;
		
		for (i in (page * 3)...((page + 1) * 3)) {
			var rb = createRankFriend(cPack);
			rb.y = Std.int(bgGlobal.height * 0.3);
			rb.set(arFriend[i], i);
			if (pack.rb1 == null) {
				pack.rb1 = rb;
				rb.x = Std.int(Settings.STAGE_WIDTH * 0.25 - rb.wid * 0.5);
			}
			else if (pack.rb2 == null) {
				pack.rb2 = rb;
				rb.x = Std.int(Settings.STAGE_WIDTH * 0.5 - rb.wid * 0.5);
			}
			else if (pack.rb3 == null) {
				pack.rb3 = rb;
				rb.x = Std.int(Settings.STAGE_WIDTH * 0.75 - rb.wid * 0.5);
			}				
		}
	}
	
	function createRankFriend(parent:h2d.Sprite):RankBadge {
		var rb = new RankBadge(Std.int(bgGlobal.height * 0.6), hparent, level, bm);
		parent.addChild(rb);
		
		arRB.push(rb);
		
		return rb;
	}
	
	function onClickLeft(e) {
		if (actualPage > 0 && !isTweening) {
			actualPage--;
			
			isTweening = true;
			
			otherPack.container.x = - Settings.STAGE_WIDTH;
			
			bpu.tweener.create().to(0.2 * Settings.FPS, actualPack.container.x += Settings.STAGE_WIDTH);
			bpu.tweener.create().to(0.2 * Settings.FPS, otherPack.container.x += Settings.STAGE_WIDTH).onComplete = function () {
				var old = actualPack;
				actualPack = otherPack;
				otherPack = old;
				isTweening = false;
			};
			
			loadNewRB(otherPack, actualPage);
			
			if (leftArrow != null)
				leftArrow.visible = interLeft.visible = actualPage > 0;
			if (rightArrow != null)
				rightArrow.visible = interRight.visible = actualPage < maxPage - 1;
		}
	}
	
	function onClickRight(e) {
		if (actualPage < maxPage - 1 && !isTweening) {
			actualPage++;
			
			isTweening = true;
			
			otherPack.container.x = Settings.STAGE_WIDTH;
			
			bpu.tweener.create().to(0.2 * Settings.FPS, actualPack.container.x -= Settings.STAGE_WIDTH);
			bpu.tweener.create().to(0.2 * Settings.FPS, otherPack.container.x -= Settings.STAGE_WIDTH).onComplete = function () {
				var old = actualPack;
				actualPack = otherPack;
				otherPack = old;
				isTweening = false;
			};
			
			loadNewRB(otherPack, actualPage);
			
			if (leftArrow != null)
				leftArrow.visible = interLeft.visible = actualPage > 0;
			if (rightArrow != null)
				rightArrow.visible = interRight.visible = actualPage < maxPage - 1;
		}
	}
	
	function loadNewRB(pack:Pack, page:Int) {
		pack.rb1.set(arFriend[page * 3], page * 3);
		pack.rb2.set(arFriend[page * 3 + 1], page * 3 + 1);
		pack.rb3.set(arFriend[page * 3 + 2], page * 3 + 2);
	}
	
	public function destroy() {
		bgGlobal.dispose();
		bgGlobal = null;
		
		btnInvite.destroy();
		btnInvite = null;
		
		if (leftArrow != null) {
			leftArrow.dispose();
			leftArrow = null;
			
			interLeft.dispose();
			interLeft = null;
			
			rightArrow.dispose();
			rightArrow = null;
			
			interRight.dispose();
			interRight = null;			
		}
		
		for (rb in arRB) {
			rb.destroy();
			rb = null;
		}
		
		arRB = null;
	}
	
	public function update() {
		for (rb in arRB) {
			rb.update();
		}
	}
}

class RankBadge extends h2d.Sprite {
	var bg			: HSpriteBE;
	var phAvatar	: HSprite;
	var lblRank		: h2d.Text;
	var lblName		: h2d.Text;
	var lblScore	: h2d.Text;
	var bmpAvatar	: h2d.Bitmap;
	
	var hparent		: HProcess;
	var level		: Int;
	
	public var wid	: Int;
	public var hei	: Int;
	
	public function new(hei:Int, hparent:HProcess, level:Int, bm:h2d.SpriteBatch) {
		super();
		
		this.hei = hei;
		this.level = level;
		this.hparent = hparent;
		
		bg = Settings.SLB_UI.hbe_get(bm, "bgSmallboard");
		bg.scaleX = bg.scaleY = hei / bg.width;
		//this.addChild(bg);
		
		phAvatar = Settings.SLB_NOTRIM.h_get("avatar");
		phAvatar.scaleX = phAvatar.scaleY = (bg.height * 0.4) / phAvatar.height;
		phAvatar.x = Std.int(bg.width - phAvatar.width);
		this.addChild(phAvatar);
	}
	
	public function set(f:FriendData, rank:Int) {
		bg.visible = f != null;
		
		wid = Std.int(bg.width);
		
		phAvatar.visible = f != null;
		
		if (bmpAvatar != null)
			bmpAvatar.dispose();
		if (f != null) {
			DataManager.DOWNLOAD_AVATAR(hparent, f.avatar, function (t) {
				if (t != null && phAvatar != null) {
					phAvatar.visible = false;
					bmpAvatar = new h2d.Bitmap(t);
					bmpAvatar.filter = true;
					bmpAvatar.scaleX = (bg.width * 0.4) / bmpAvatar.tile.width;
					bmpAvatar.scaleY = (bg.height * 0.4) / bmpAvatar.tile.height;
					bmpAvatar.x = Std.int(bg.width - bmpAvatar.width);
					this.addChild(bmpAvatar);
				}
			});
		}
		
		if (lblRank == null) {
			lblRank = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
			lblRank.x = Std.int(bg.width * 0.1);
			this.addChild(lblRank);
		}
		lblRank.text = (rank + 1) + ".";
		lblRank.visible = f != null;
		
		if (lblName == null) {
			lblName = new h2d.Text(Settings.FONT_BENCH_NINE_50);
			lblName.textColor = 0xFFA55B2E;
			lblName.x = Std.int(bg.width * 0.1);
			lblName.y = Std.int(bg.height * 0.45);
			this.addChild(lblName);
		}
		if (f != null) {
			var nameId = f.name;
			if (nameId.length > 10) {
				nameId = nameId.substr(0, 10);
				nameId += "...";
			}
			lblName.text = nameId;
		}
		lblName.visible = f != null;
		
		if (lblScore == null) {
			lblScore = new h2d.Text(Settings.FONT_BENCH_NINE_70);
			lblScore.x = Std.int(bg.width * 0.1);
			lblScore.y = Std.int(bg.height * 0.675);
			this.addChild(lblScore);
		}
		if (f != null)
			lblScore.text = Std.string(f.highscore[level]);
		lblScore.visible = f != null;
	}
	
	public function destroy() {
		bg.dispose();
		bg = null;
		
		phAvatar.dispose();
		phAvatar = null;
		
		lblRank.dispose();
		lblRank = null;
		
		lblName.dispose();
		lblName = null;
		
		lblScore.dispose();
		lblScore = null;
		
		if (bmpAvatar != null)
			bmpAvatar.dispose();
		bmpAvatar = null;
	}
	
	public function update() {
		bg.x = this.x + parent.x;
		bg.y = this.y + parent.y;
	}
}
