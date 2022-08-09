package m;

import flash.display.Sprite;
import mt.deepnight.Lib;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import mt.SecureSO;
import ui.*;

class Twinoid extends MenuBase {
	var back		: BackButton;
	var menu		: VGroup;
	var button		: Button;
	var loading		: Null<MenuLabel>;
	var loadCount	: Int;

	public function new() {
		super();

		loadCount = 0;

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 5;

		button = new BigMenuButton(wrapper, "Uppercup-Football.com", function() {
			Ga.pageview("/extern/uppercupCode");
			flash.Lib.getURL( new flash.net.URLRequest("http://uppercup-football.com#code") );
		});

		var texts = new TextGroup(menu);
		texts.addText(Lang.CodeExplanation);

		loading = new MenuLabel(wrapper, Lang.Loading, 1);

		#if !webDemo
		getCode(new HGroup(menu), Lang.Code_PlayedGame, "j564ke3r10g0uiernurfgn8euyeue67");
		if( isUnlocked() )
			getCode(new HGroup(menu), Lang.Code_UnlockedGame, "gve0tgnijfdghm9dynILMghjmk4621P");

		if( playerCookie.data.wonNormal )
			getCode(new HGroup(menu), Lang.Code_WinNormal, "er4531lgnerigherklnerjlaztu5460");

		if( playerCookie.data.wonHard )
			getCode(new HGroup(menu), Lang.Code_WinHard, "k41gerky053r9jkhbeioze6574oplx9");

		if( playerCookie.data.wonEpic )
			getCode(new HGroup(menu), Lang.Code_WinEpic, "obepczi0645epo1sjld3ihgfklghdf1");
		#end

		back = new BackButton(wrapper, onBack);

		onResize();
	}

	#if !webDemo
	function getCode(g:HGroup, name:String, token:String) {
		loadCount++;
		g.removeBorders();
		g.setHeight(26);

		if( !Lib.isAir() ) {
			onCodeData(g, name, token, null);
			return;
		}

		var r = new haxe.Http("https://twinoid.com/generateGoalCode");
		var sso = new SecureSO({ name:"twinoid", aesKey:"C0ACE17B954C6037454FC6FF100A2205", aesIv:"F93F111655192668BF70BE2CA2B92454" });
		var deviceId = sso.deviceId();
		r.addParameter("token", token);
		r.addParameter("deviceId", deviceId);
		r.addParameter("chk", haxe.crypto.Sha1.encode( "NorbyispoohahocejodFeulUbceyrec!"+token+deviceId ));
		r.request(true);
		r.onData = onCodeData.bind(g, name, token);
		r.onError = onCodeError.bind(token);
	}
	#end

	function decreaseLoadCount() {
		loadCount--;
		if( loadCount<=0 && loading!=null ) {
			loading.destroy();
			loading = null;
		}
	}

	function onCodeData(g:HGroup, name:String, token:String, data:String) {
		var l = new MenuLabel(g, name);
		l.setStyle(LS_GoldDark);
		l.setHAlign(Left);
		l.setWidth(280);
		if( data!=null ) {
			var json = haxe.Json.parse(data);
			var l = new MenuLabel(g, json.code);
			l.setStyle(LS_Gold);
			l.setWidth(100);
			l.setHAlign(Right);
		}
		else {
			var l = new MenuLabel(g, "Error");
			l.setStyle(LS_Gold);
			l.setWidth(100);
			l.setHAlign(Right);
		}

		g.forceRenderNow();
		menu.forceRenderNow();
		decreaseLoadCount();
		onResize();
	}

	function onCodeError(token:String, msg:String) {
		decreaseLoadCount();
		popUp(Lang.NetworkError);
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}


	override function unregister() {
		super.unregister();

		menu.destroy();
		back.destroy();

		if( loading!=null )
			loading.destroy();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new Settings(false), false);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		if( loading!=null ) {
			loading.x = Std.int(getWidth()*0.5 - loading.getWidth()*0.5);
			loading.y = Std.int(getHeight()*0.9 - loading.getHeight()*0.5);
		}

		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.4-menu.getHeight()*0.5);

		button.x = Std.int(getWidth()*0.5-button.getWidth()*0.5);
		button.y = menu.y + menu.getHeight() + 20;
	}
}