package ui;

import com.Protocol;
import com.*;
import mt.MLib;
import mt.data.GetText;
import h2d.SpriteBatch;
import h2d.TextBatchElement;
import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import flash.display.BitmapData;

#if( prod && connected )
import mt.net.FriendRequest;
#else
typedef Friend = {
	net: Int,
	id: String,
	name: String,
	avatar: String,
	?invitable: Bool
}
#end

typedef FriendButton = {
	friendIdx	: Int,
	wrapper		: h2d.Sprite,
	i			: h2d.Interactive,
	avatar		: h2d.Bitmap,
	bg			: h2d.Bitmap,
	tf			: h2d.Text,
	check		: HSprite,
}

class Friends extends H2dProcess {
	public static var CURRENT : Friends = null;

	var g(get,never)		: Game;
	var request				: HotelFriendRequest;
	var allFriends			: Array<Friend>;
	var hotelFriends		: Array<Friend>;
	var actives				: Map<String,Bool>;
	var cachedAvatars		: Map<String,h2d.Tile>;
	var friendButtons		: Array<FriendButton>;
	var drag				: { clicking:Bool, x:Float, y:Float, dy:Float, active:Bool };
	var isLoading			: Bool;

	var wrapper				: h2d.Sprite;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	var list				: h2d.Sprite;
	var winBg				: BatchElement;
	var cbl					: BatchElement;
	var cbr					: BatchElement;
	var closeBt				: h2d.Interactive;
	var ctrap				: h2d.Interactive;
	var winCtrap			: h2d.Interactive;
	var listMask			: h2d.Mask;
	var tshader				: h2d.Drawable.DrawableShader;

	var showAll				: Bool;
	var asize = 64;
	var bwid = 400;
	var bhei = 64;
	var thei = 120;
	var lines = 6;
	var padding = 20;

	public function new(req:HotelFriendRequest, ?label:String) {
		CURRENT = this;

		super();
		Main.ME.uiWrapper.add(root, Const.DP_TOP_POP_UP);

		request = req;
		actives = new Map();
		cachedAvatars = new Map();
		Assets.SBANK.click2(1);

		#if connected
		var t = switch(request){
			case HFR_AskLove: "AskLove";
			case HFR_ReturnLove: "ReturnLove";
			case HFR_SendGem: "SendGem";
			case HFR_SendGold: "SendGold";
			case HFR_SendLove: "SendLove";
			case HFR_ComeBack: "ComeBack";
		}
		mt.device.EventTracker.view("ui.Friends:"+t);
		#end

		var sub : String = null;
		if( label==null ) {
			switch( request ) {
				case HFR_SendGem :
					label = Lang.t._("Would you like to help your friends by sending them a free GEM?");
					sub = Lang.t._("The gem sent to your friends are NOT taken from yours, they are totally free.");

				case HFR_SendGold :
					label = Lang.t._("Would you like to help your friends by sending them ::n:: GOLD?", {n:GameData.SOCIAL_GOLD});
					sub = Lang.t._("The gold sent to your friends is NOT taken from yours, it's totally free.");

				case HFR_SendLove :
					label = Lang.t._("Would you like to help your friends by sending them LOVE?");
					sub = Lang.t._("The love sent to your friends is NOT taken from yours, it's totally free.");

				case HFR_AskLove, HFR_ReturnLove, HFR_ComeBack : "???";
			}
		}

		ui.Tutorial.ME.clear();
		Game.ME.pause();

		isLoading = false;

		showAll = true;
		drag = { clicking:false, x:0, y:0, dy:0, active:false }
		allFriends = [];
		hotelFriends = [];
		friendButtons = [];
		name = 'Friends';

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.backgroundColor = alpha(0x0,0.85);
		ctrap.onWheel = onWheel;
		ctrap.onPush = onPush;
		ctrap.onRelease = function(e) {
			if( cd!=null && !cd.has("drag") )
				onCancel();

			onRelease(e);
		}

		wrapper = new h2d.Sprite(root);

		sb = new h2d.SpriteBatch(Assets.tiles.tile, wrapper);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, wrapper);
		tsb.filter = true;

		winBg = Assets.tiles.addColoredBatchElement(sb, "white", Const.BLUE, 0.9);

		var e = Assets.tiles.addBatchElement(sb, "enluminure", 0);
		e.tile.setCenter(10,10);
		var e = Assets.tiles.addBatchElement(sb, "enluminure", 0);
		e.tile.setCenter(10,10);
		e.rotation = MLib.PI*0.5;
		e.x = winWid();

		var e = Assets.tiles.addBatchElement(sb, "enluminure", 0);
		cbr = e;
		e.tile.setCenter(10,10);
		e.rotation = MLib.PI;
		e.x = winWid();

		var e = Assets.tiles.addBatchElement(sb, "enluminure", 0);
		cbl = e;
		e.tile.setCenter(10,10);
		e.rotation = MLib.PI*1.5;

		winCtrap = new h2d.Interactive(4,4, wrapper);
		winCtrap.onWheel = onWheel;
		winCtrap.onPush = onPush;
		winCtrap.onRelease = onRelease;
		listMask = new h2d.Mask(800,listHei(), wrapper);
		list = new h2d.Sprite(listMask);

		// Title icon
		var k = switch(request){
			case HFR_AskLove: "moneyLove";
			case HFR_ReturnLove: "moneyLove";
			case HFR_SendGem: "moneyGem";
			case HFR_SendGold: "moneyGold";
			case HFR_SendLove: "moneyLove";
			case HFR_ComeBack: "iconMailSmall";
		}
		var isize = 64;
		var i = Assets.tiles.addBatchElement(sb,k,0, 0.5,0.5);
		i.x = padding + isize*0.5;
		i.y = padding + thei*0.5;
		i.setScale( MLib.fmin(isize/i.width, isize/i.height) );

		// Title
		var y : Float = padding;
		var title = Assets.createBatchText(tsb, Assets.fontHuge, 32, label);
		title.x = Std.int( padding + isize + 10 );
		title.maxWidth = (winWid()-title.x-padding)/title.scaleX;

		// Sub title
		if( sub!=null ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 19, Const.TEXT_GRAY, sub);
			tf.x = Std.int( padding + isize + 10 );
			tf.maxWidth = (winWid()-tf.x-padding)/tf.scaleX;

			var th = tf.textHeight*tf.scaleY + title.textHeight*title.scaleY;
			title.y = y + thei*0.5 - th*0.5 - 5;
			tf.y = title.y + title.textHeight*title.scaleY;
		}
		else
			title.y = y + thei*0.5 - title.textHeight*title.scaleY*0.5 - 5;
		y += thei;

		// Buttons & positioning
		var x : Float = padding;
		var w = bwid*0.75;
		createTab(x, y, w, Lang.t._("All my friends"), onShowAll, function() return showAll);
		x+=w;
		createTab(x, y, w, Lang.t._("MonsterHotel friends"), onShowOnlyPlayers, function() return !showAll);
		x+=w;

		var w = bwid*0.25;
		createButton(x, y, w, null, "check", onSelectAll);
		x+=w;
		createButton(x, y, w, null, "uncheck", onSelectNone);

		y+=bhei;
		listMask.x = padding;
		listMask.y = y;
		y+=listHei()+1;

		// Select all/none + Facebook
		//#if (mBase && nativeAuth)
		//var w = bwid/3;
		//createButton(0x3b5998, 0, y, w, Lang.t._("Facebook friends"), onFacebook);
		//createButton(w, y, w, Lang.t._("All ||Label for a 'select everything' button"), onSelectAll);
		//createButton(w*2, y, w, Lang.t._("None ||Label for a 'select nothing' button"), onSelectNone);
		//#else
		//#end
		createButton(padding, y, bwid*2, Lang.t._("Send!"), onSend);

		var listBg = Assets.tiles.addColoredBatchElement(sb, "white", Color.brightnessInt(Const.BLUE,-0.2));
		listBg.setPos(padding, listMask.y);
		listBg.setSize(bwid*2, listHei());

		// Init friend buttons
		for(i in 0...(lines+1)*2) {
			var s = new h2d.Sprite(list);
			var fb : FriendButton = {
				friendIdx	: -1,
				wrapper		: s,
				i			: null,
				avatar		: null,
				bg			: null,
				tf			: null,
				check		: null,
			}
			friendButtons[i] = fb;

			// Base bg
			fb.bg = Assets.tiles.getColoredH2dBitmap("white", Color.brightnessInt(Const.BLUE,-0.1), s);
			fb.bg.setSize(bwid + (i%2==0?-5:0), bhei);

			// Avatar
			fb.avatar = new h2d.Bitmap(s);
			fb.avatar.filter = true;
			fb.avatar.x = Std.int( 10 + bhei*0.5 );
			fb.avatar.y = Std.int( bhei*0.5 );

			// Name
			fb.tf = Assets.createText(32, 0xffffff, "???", s, tshader);
			if( tshader==null )
				tshader = fb.tf.shader;
			fb.tf.maxWidth = bwid/fb.tf.scaleX-10;
			fb.tf.x = Std.int( fb.avatar.x + bhei*0.5 + 10 );

			// Checkbox
			fb.check = Assets.tiles.h_get("check", s);
			fb.check.filter = true;
			fb.check.setCenterRatio(1, 0.5);
			fb.check.x = bwid;
			fb.check.y = Std.int( bhei*0.5 );
			fb.check.scale(0.85);

			// Interactive
			fb.i = new h2d.Interactive(bwid, bhei, s);
			fb.i.onRelease = function(_) {
				onClickFriend(fb);
				onRelease(null);
			}
			fb.i.onPush = onPush;
			fb.i.onWheel = onWheel;
		}

		// Fill friend list
		#if( prod && connected )
		loadFriends();
		#elseif !connected
		for(i in 0...50)
			addFakeFriend();
		allFriends.sort( function(a,b) return Reflect.compare(a.name, b.name) );
		hotelFriends.sort( function(a,b) return Reflect.compare(a.name, b.name) );
		#end

		closeBt = new h2d.Interactive(48,48, wrapper);
		var b = Assets.tiles.getH2dBitmap("iconRemove", true, closeBt);
		b.width = closeBt.width;
		b.height = closeBt.height;
		closeBt.onClick = function(_) {
			Assets.SBANK.click1(1);
			onCancel();
		}

		// Animate open
		wrapper.y = h();
		onResize();
	}

	inline function isActive(f:Friend) {
		return actives.exists(f.id) ? actives.get(f.id) : true;
	}

	inline function listHei() return lines*bhei;
	inline function winWid() return bwid*2 + padding*2;
	inline function winHei() return listHei() + bhei*2 + padding*2 + thei;

	inline function getFriends() : Array<Friend> {
		return showAll ? allFriends : hotelFriends;
	}

	inline function get_g() return Game.ME;

	function onSend() {
		var all = getFriends().filter( function(f) return isActive(f) );
		if( all.length>0 ) {
			#if( prod && connected )
			var d = ui.side.Inbox.getReqData( Type.enumIndex(request) );
			mt.device.FriendRequest.request( request.getIndex(), d.message, all, d.data, function() {
				switch( request ) {
					case HFR_AskLove, HFR_ComeBack :
						new ui.Notification( Lang.t._("Your request has been sent!"), "iconMail" );

					case HFR_SendGem, HFR_SendGold, HFR_SendLove, HFR_ReturnLove :
						new ui.Notification( Lang.t._("Your gift has been sent!"), "iconMail" );
				}
			});
			#end
			onCancel();
		}
	}

	function loading(str:LocaleString) {
		isLoading = true;
		list.y = 0;
		drag.dy = 0;
		drag.clicking = false;
		drag.active = false;

		var tf = Assets.createText(40, str, list);
		tf.textColor = Const.TEXT_GOLD;
		tf.x = bwid*2*0.5 - tf.width*tf.scaleX*0.5;
		tf.y = listMask.height*0.5 - tf.height*tf.scaleY*0.5;

		createChildProcess( function(p) {
			if( !isLoading ) {
				tf.dispose();
				p.destroy();
			}
		});
	}

	#if( prod && connected )
	function loadFriends() {
		if( allFriends.length>0 )
			return;

		loading( Lang.t._("Loading your friend list...") );
		mt.device.FriendRequest.friends(null, null, onFriendsLoaded);
	}
	#end

	#if (mBase && nativeAuth)
	function onFacebook() {
		if( isLoading )
			return;

		loading( Lang.t._("Waiting for facebook login...") );

		if( !mtnative.nativeAuth.Facebook.isLogged() )
			mt.device.Facebook.getToken( true, function(_) loadFriends() );
	}
	#end

	function invalidateAll() {
		for(fb in friendButtons)
			setButton(fb, -1);
	}

	function onShowAll() {
		showAll = true;
		invalidateAll();
	}

	function onShowOnlyPlayers() {
		showAll = false;
		invalidateAll();
	}

	function onSelectAll() {
		for(f in allFriends)
			if( !isActive(f) )
				actives.set(f.id, true);
	}

	function onSelectNone() {
		for(f in allFriends)
			if( isActive(f) )
				actives.set(f.id, false);
	}

	#if( prod && connected )
	function onFriendsLoaded(resp : Array<Friend>) {
		if( destroyed )
			return;

		if( resp==null ) {
			new ui.Notification( Lang.t._("Error: could not load friend list :("), 0xFF0000);
			destroy();
		}
		else {
			isLoading = false;
			resp.sort( function(a,b) return Reflect.compare(a.name, b.name) );
			for ( f in resp )
				addFriend(f);

			list.y = 500;
			invalidateAll();
		}
	}
	#end

	function onCancel() {
		destroy();
	}


	function onPush(_) {
		var m = g.getMouse();
		drag.x = m.ux;
		drag.y = m.uy;
		drag.clicking = true;
		drag.active = false;
	}

	function onRelease(_) {
		drag.clicking = false;
		drag.active = false;
	}

	function onWheel(e:hxd.Event) {
		drag.dy += -e.wheelDelta*12;
	}

	function addFriend(f:Friend) {
		allFriends.push(f);
		if( !f.invitable )
			hotelFriends.push(f);
	}

	#if !connected
	var uniq = 0;
	function addFakeFriend() {
		var inv = Std.random(100)<70;
		addFriend({
			name		: com.SClient.randomName(Std.random) + (inv?"":" (hotel)"),
			avatar		: "http://local.monster-hotel.net/img/screenshots/01.png",
			net			: 0,
			id			: "ID_"+(uniq++),
			invitable	: inv,
		});
	}
	#end


	function setButton(fb:FriendButton, friendIdx:Int) {
		var changed = fb.friendIdx!=friendIdx;

		fb.friendIdx = friendIdx;

		var f = getFriends()[friendIdx];
		fb.wrapper.visible = f!=null;

		if( f!=null ) {
			var active = isActive(f);
			if( changed ) {
				fb.tf.setScale( 0.9 * (f.name.length>=15 ? 0.75 : 1) );
				fb.tf.text = f.name;
				fb.tf.y = Std.int( bhei*0.5 - fb.tf.height*0.5*fb.tf.scaleY );
			}
			if( active && fb.check.groupName=="uncheck" )
				fb.check.set("check");
			if( !active && fb.check.groupName=="check" )
				fb.check.set("uncheck");
			fb.check.alpha = active ? 1 : 0.25;
			fb.tf.alpha = active ? 1 : 0.5;
			fb.tf.textColor = active ? 0xFFFFFF : 0xCF3034;
			fb.avatar.alpha = active ? 1 : 0.08;
			fb.bg.alpha = active ? 1 : 0.6;

			// Avatar init / download
			var t = getCachedAvatar(f);
			if ( changed && t == null ) {
				mt.flash.BitmapLoader.download(f.avatar, function(t) setCachedAvatar(f,t), function() return !destroyed, FitCropSquare(asize));
			}

			if ( fb.avatar.tile != t ) {
				fb.avatar.visible = t != null;
				fb.avatar.setScale( (bhei - 1) / asize );
				fb.avatar.tile = t;
			}
		}

	}


	function onClickFriend(f:FriendButton) {
		if( destroyed )
			return;

		var f = getFriends()[f.friendIdx];
		if( !cd.has("drag") && f!=null ) {
			actives.set(f.id, !isActive(f));
			Assets.SBANK.click1(1);
		}
	}


	public function createButton(x:Float,y:Float, ?bwid:Float, label:Null<LocaleString>, ?iconId:String, cb:Void->Void) {
		if( bwid==null )
			bwid = this.bwid;
		bwid--;

		var bg = Assets.tiles.addBatchElement(sb, "btnAction",0);
		bg.setPos(x,y);
		bg.setSize(bwid, bhei);

		if( label!=null ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 32, Const.BLUE, label);
			tf.maxWidth = bwid/tf.scaleX-10;
			tf.x = Std.int( x + bwid*0.5 - tf.textWidth*tf.scaleX*0.5 );
			tf.y = Std.int( y + bhei*0.5 - tf.textHeight*tf.scaleY*0.5 );
		}

		if( iconId!=null ) {
			var w = bhei-30;
			var i = Assets.tiles.addBatchElement(sb, iconId, 0, 0.5,0.5);
			i.x = x + bwid*0.5;
			i.y = y + bhei*0.5;
			i.setScale(w/i.width);
		}

		var i = new h2d.Interactive(bwid, bhei, wrapper);
		i.setPos(x,y);
		i.onRelease = function(e) {
			if( destroyed )
				return;

			if( !cd.has("drag") ) {
				Assets.SBANK.click1(1);
				cb();
			}

			onRelease(e);
		}
		i.onPush = onPush;
		#if !mobile
		i.onWheel = onWheel;
		//i.onOver = function(_) bg.color = h3d.Vector.fromColor(alpha(0xFFFFFF), 0.7);
		//i.onOut = function(_) bg.color = null;
		#end
	}

	public function createTab(x:Float,y:Float, ?bwid:Float, label:String, cb:Void->Void, isActive:Void->Bool) {
		if( bwid==null )
			bwid = this.bwid;
		bwid--;

		var bg = Assets.tiles.addColoredBatchElement(sb, "white", 0x620D00);
		bg.setPos(x,y);
		bg.setSize(bwid, bhei);

		var on = Assets.tiles.addBatchElement(sb, "roomOver",0);
		on.visible = false;
		on.setPos(x-5,y-2);
		on.setSize(bwid+10, bhei+4);

		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 32, Const.TEXT_GOLD, label);
		tf.maxWidth = bwid/tf.scaleX-10;
		tf.x = Std.int( x + bwid*0.5 - tf.textWidth*tf.scaleX*0.5 );
		tf.y = Std.int( y + bhei*0.5 - tf.textHeight*tf.scaleY*0.5 );
		tf.alpha = 0.5;

		var i = new h2d.Interactive(bwid, bhei, wrapper);
		i.setPos(x,y);
		i.onRelease = function(e) {
			if( destroyed || isActive() )
				return;

			if( !cd.has("drag") ) {
				Assets.SBANK.click1(1);
				Assets.SBANK.slide1(0.5);
				cb();
			}

			onRelease(e);
		}
		i.onPush = onPush;
		#if !mobile
		i.onWheel = onWheel;
		//i.onOver = function(_) bg.color = h3d.Vector.fromColor(alpha(0xFFFFFF), 0.7);
		//i.onOut = function(_) bg.color = null;
		#end

		createChildProcess( function(_) {
			if( isActive() && !on.visible ) {
				on.visible = true;
				tf.alpha = 1;
			}
			if( !isActive() && on.visible ) {
				on.visible = false;
				tf.alpha = 0.5;
			}
		}, true);
	}

	function setCachedAvatar(f:Friend, tile:h2d.Tile) {
		if ( tile == null )
			tile = Assets.tiles.getTile("iconRemove");

		tile.setCenterRatio(0.5, 0.5);
		cachedAvatars.set(f.id, tile);
	}

	function getCachedAvatar(f:Friend) {
		var t = cachedAvatars.get(f.id);
		if( !mt.flash.BitmapLoader.isValid(t) )
			return null;
		return t;
	}

	override function onResize() {
		super.onResize();

		if( wrapper!=null ) {
			var wid = winWid();
			var hei = winHei();

			listMask.width = wid;

			winCtrap.setSize(wid,hei);
			winBg.setSize(wid,hei);
			cbl.y = hei;
			cbr.y = hei;

			closeBt.x = wid - closeBt.width*0.5;
			closeBt.y = winCtrap.y - closeBt.height*0.5;

			//wrapper.setScale(1);
			//if( hei>h() )
				//wrapper.setScale( h()/wrapper.height );
			wrapper.setScale( MLib.fmin( w()*0.9/wrapper.width, h()*0.9/wrapper.height ) );
			wrapper.x = Std.int( w()*0.5 - wrapper.width*0.5 );
			tw.create(wrapper.y, Std.int( h()*0.5 - wrapper.height*0.5 + 20*wrapper.scaleY ), 300);

			ctrap.width = w();
			ctrap.height = h();
		}
	}


	override function onDispose() {
		super.onDispose();

		for(fb in friendButtons)
			if( fb.avatar!=null  )
				fb.avatar.dispose();

		friendButtons = null;
		allFriends = null;
		hotelFriends = null;

		ctrap.dispose();
		ctrap = null;

		wrapper = null;
		sb = null;
		tsb = null;

		listMask = null;
		list = null;
		closeBt = null;
		winBg = null;
		winCtrap = null;
		cbl = null;
		cbr = null;
		//title = null;

		tshader = null;

		if( Game.ME!=null )
			Game.ME.resume();

		if( CURRENT==this )
			CURRENT = null;
	}


	override function update() {
		super.update();

		// Drag
		var m = g.getMouse();
		if( !isLoading && drag.clicking ) {
			drag.dy*=0.6;
			var d = mt.Metrics.cm2px(0.4);
			if( !drag.active && Lib.distanceSqr(m.ux, m.uy, drag.x, drag.y)>=d*d )
				drag.active = true;

			if( drag.active ) {
				drag.dy+= (m.uy - drag.y)*0.7;
				drag.y = m.uy;
				cd.set("drag", 3);
				cd.unset("attach");
			}
		}

		list.y+=drag.dy;

		drag.dy*=0.8;
		if( MLib.fabs(drag.dy)<=0.05 )
			drag.dy = 0;

		if( !isLoading ) {
			// Top limit
			var y = 0;
			if( list.y>y )
				list.y += (y-list.y) * 0.4;

			// Bottom limit
			var y = listHei()*0.8 - ( bhei * getFriends().length/2 );
			if( list.y<y )
				list.y += (y-list.y) * 0.4;
		}

		// Avatar display & download
		var cy = Std.int( -list.y/bhei );
		for(i in 0...friendButtons.length) {
			var fb = friendButtons[i];
			fb.wrapper.x = (i%2)*bwid;
			fb.wrapper.y = (cy+Std.int(i/2)) * bhei;
			setButton( fb, cy*2 + i );
		}
	}
}
