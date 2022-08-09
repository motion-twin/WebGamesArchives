package ui.side;

import mt.flash.BitmapLoader;
import com.GameData;
import com.Protocol;
import mt.MLib;
import mt.data.GetText;
import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import flash.display.BitmapData;
import h2d.SpriteBatch;


class Contacts extends ui.SideMenu {
	public static var CURRENT : Contacts;

	var avatars			: Array<{id:Int, bt:ui.side.Button, bmp:h2d.Bitmap}>;
	var tileCache		: Map<Int, h2d.Tile>;
	var asize			: Int = 64;
	var isLoadingAvatar	: Bool = false;
	var friends			: Map<Int, FriendHotel>;
	var fronts			: SpriteBatch;
	var from			: Int;
	#if debug
	var limit = 4;
	#else
	var limit = 40;
	#end

	public function new() {
		CURRENT = this;
		from = 0;

		#if debug
		mt.flash.BitmapLoader.MAX_CACHE = 12;
		#end

		super();

		tileCache = new Map();
		friends = new Map();
		name = "Contacts";
		avatars = new Array();
		bhei = asize+25;

		fronts = new h2d.SpriteBatch(Assets.tiles.tile);
		wrapper.add(fronts, 1);
		fronts.filter = true;

		onResize();
	}


	#if !connected
	function fillWithFakeFriends() {
		addTitle(cast "Fake friends");
		friends = new Map();
		#if !trailer
		var rseed = new mt.Rand(0);
		for(i in 0...100)
			addFakeFriend(i, rseed);
		var all = Lambda.array(friends);
		all.sort( function(a,b) return -Reflect.compare(a.hotel.score, b.hotel.score) );
		var i = 1;
		for(f in all)
			addFriend(f);
		#end

		fronts.toFront();
	}
	#end


	function addBaseElements() {
		addTitle(Lang.t._("Hotel ranking"));
		addText(Lang.t._("You can visit your friends hotels to get LOVE from them! You get more love from bigger hotels."));
		addText(Lang.t._("Each hotel has a score that depends on the number of stars, rooms, etc."));

		#if mBase
		if( !mt.device.User.isLogged() ) {
			addButton("iconUse", Lang.t._("You must connect to visit your friends hotels. Click here to connect now!"), Const.TEXT_GOLD, function() {
				mt.device.User.login();
				close();
			});
		}
		else if( !mt.device.Facebook.isLogged() ) {
			addButton("facebook", Lang.t._("Connect with Facebook to visit your friends hotels!"), 0xffffff, function() {
				mt.device.Facebook.connect( function(v) {
					if( !destroyed )
						invalidate();
				});
				close();
			});
		}
		else {
			addButton("itemRadio", Lang.t._("Tell my Facebook friends about this game :)"), 0xffffff, function() {
				mt.device.Facebook.showShareLinkDialog(
					"https://apps.facebook.com/monster-hotel/",
					"https://data-monsterhotel.twinoid.com/img/screenshots/ogFb.png"
				);
				close();
			});
		}
		#elseif connected
		if( Main.ME.hdata.facebook )
			addButton("itemRadio", Lang.t._("Tell my Facebook friends about this game :)"), 0xffffff, function() {
				mt.device.Facebook.showShareLinkDialog(
					"https://apps.facebook.com/monster-hotel/",
					"https://data-monsterhotel.twinoid.com/img/screenshots/ogFb.png"
				);
				close();
			});
		#end
	}

	#if connected
	function loadFriends() {
		clearContent();

		// Real friends
		addBaseElements();
		addText(Lang.t._("Loading..."));
		friends = new Map();

		mt.device.Facebook.getToken(false, function(fbToken){
			Game.ME.sendMiscCommand( MC_Friends({fbToken: fbToken}) );
		});
	}
	#end

	#if connected
	public function onFriendsLoaded(resp : Array<FriendHotel>, ?from=0) {
		if( destroyed || !isOpen )
			return;

		this.from = MLib.clamp(from, 0, resp.length);
		clearContent();
		addBaseElements();

		if( resp==null ) {
			new ui.Notification( Lang.t._("Error: could not load friend list :("), 0xFF0000);
			close();
		}
		else {
			resp.sort( function(a,b) return -Reflect.compare(a.hotel.score, b.hotel.score) );
			if( from>0 && resp.length>limit )
				addButton("arrowUp", Lang.t._("Previous friends"), 0xffffff, function() {
					onFriendsLoaded(resp, from-limit);
				});
			var i = 0;
			for ( f in resp ) {
				if( i>=from && i<from+limit ) {
					friends.set(f.owner.id, f);
					addFriend(f);
				}
				i++;
			}
			if( i>from+limit )
				addButton("arrowDown", Lang.t._("Next friends"), 0xffffff, function() {
					onFriendsLoaded(resp, from+limit);
				});
		}
	}
	#end


	function addFriend(f:FriendHotel) {
		#if connected
		var isMe = f.hotel.id==Game.ME.hdata.realHotelId;
		#else
		var isMe = false;
		#end

		var b =
			if( isMe )
				createButton(function() {
					if( Game.ME.isVisitMode() ) {
						#if connected
						new ui.Loading( Game.ME.sendMiscCommand.bind( MC_EndVisit ) );
						Main.ME.currentVisit = null;
						#end
					}
				});
			else
				createButton( function() {
					locked = true;
					#if !connected
					new ui.Notification(cast "Unsupported on this version", 0xFF0000, "iconRemove");
					#else
					var uid = f.owner.id;
					Game.ME.flushNetworkBuffer();
					new ui.Loading( Game.ME.sendMiscCommand.bind( MC_Visit(uid) ), function() {
						locked = false;
					} );
					#end
				});

		if( !isMe || Game.ME.isVisitMode() )
			b.enableRollover();

		// Ranking
		//var e = b.addTextHuge("rank", cast Std.string(rank), 60);
		//e.alpha = 0.6;
		//e.textColor = isMe ? Const.TEXT_GOLD : Const.TEXT_GRAY;
		//e.x = wid - e.textWidth*e.scaleX - 20;
		//e.y = bhei*0.5 - e.textHeight*e.scaleY*0.5;

		// Score
		var e = b.addTextHuge("score", cast Game.ME.prettyNumber(f.hotel.score), 40);
		e.alpha = 0.6;
		e.textColor = isMe ? Const.TEXT_GOLD : Const.TEXT_GRAY;
		e.x = wid - e.textWidth*e.scaleX - 20;
		e.y = bhei*0.5 - e.textHeight*e.scaleY*0.5;

		// User name
		var e = b.addTextHuge("oname", cast f.owner.name, 30);
		e.textColor = isMe ? Const.TEXT_GOLD : 0xFFFFFF;
		e.x = 10 + asize + 10;
		e.y = 5;

		if( !isMe && shotel.featureUnlocked("love") && shotel.canGetLoveFromHotel(f.hotel.id) ) {
			var i = b.addElement("love", "moneyLove");
			i.tile.setCenterRatio(0,0.5);
			i.setScale(0.35);
			i.x = e.x + e.textWidth*e.scaleX + 3;
			i.y = e.y + e.textHeight*e.scaleY*0.5;
		}

		// Hotel name
		var e = b.addText("hname", cast "\""+f.hotel.name+"\"", 14);
		e.x = 10 + asize + 10;
		e.y = 36;
		e.textColor = isMe ? Const.TEXT_GOLD : Const.TEXT_GRAY;

		// Stars
		var star = Const.getStarFromLevel(f.hotel.level);
		if( star!=null ) {
			var swid = 22;
			if( star.frame>0 )
				for(i in 0...5) {
					var e = b.addElement("bgStar"+i, "star", star.frame-1, 0.5,0.5);
					e.setScale(swid/e.width);
					e.x = asize + 30 + i*swid;
					e.y = 64;
				}
			for(i in 0...star.n) {
				var e = b.addElement("frontStar"+i, "star", star.frame, 0.5,0.5);
				e.setScale(swid/e.width);
				e.x = asize + 30 + i*swid;
				e.y = 64;
			}
		}

		b.position();

		var e = Assets.tiles.addBatchElement(fronts, isMe?"sideIcon":"sideIconOff",0, 0.5,0.5);
		e.x = 10 + asize*0.5;
		e.y = b.getY() + bhei*0.5;
		e.setSize(asize, asize);

		var bmp = new h2d.Bitmap();
		wrapper.add(bmp, 0);
		bmp.name = "bitmap."+f.owner.name;
		bmp.emit = true;
		bmp.filter = true;
		bmp.x = 10 + asize*0.5;
		bmp.y = b.getY() + bhei*0.5;

		//bmp.tile = getCachedAvatar(f.owner.id);
		//bmp.tile = TILE_CACHE.exists(f.owner.id) && TILE_CACHE.get(f.owner.id).ready ? TILE_CACHE.get(f.owner.id).t : null;
		//bmp.visible = bmp.tile!=null;
		bmp.visible = false;

		avatars.push({
			id		: f.owner.id,
			bt		: b,
			bmp		: bmp,
		});
	}


	function onDownloadError(err:String, f:FriendHotel) {
		if( destroyed || Game.ME==null || Game.ME.destroyed )
			return;

		#if connected
		Game.ME.netLog("ERROR: "+f.owner.name+" ("+err+")", 0xFF0000);
		#end

		isLoadingAvatar = false;
		for(a in avatars)
			if( a.id==f.owner.id ) {
				a.bmp.tile = Assets.tiles.getTile("iconRemove");
				a.bmp.tile.setCenterRatio(0.5,0.5);
				break;
			}
	}


	//function downloadNext() {
		//if( cd.has("download") )
			//return;
//
		//for(i in getMinIndex()...getMaxIndex()+1) {
			//var a = avatars[i];
			//var fh = friends.get(a.id);
			//if( a!=null && getCachedAvatar(fh)==null ) {
				//downloadAvatar(fh);
				////cd.set("download", Const.seconds(0.3));
				////break;
			//}
		//}
	//}

	function getCachedAvatar(fid:Int) : h2d.Tile {
		if( tileCache.exists(fid) ) {
			var t = tileCache.get(fid);
			if( t!=null && mt.flash.BitmapLoader.isValid(t) )
				return t;
		}
		return null;
	}

	function setCachedAvatar(fid:Int, tile:h2d.Tile) {
		if ( tile == null )
			tile = Assets.tiles.getTile("iconRemove");

		tile.setCenterRatio(0.5, 0.5);
		tileCache.set(fid, tile);
		isLoadingAvatar = false;

		for(a in avatars)
			if( a.id==fid ) {
				a.bmp.tile = tile;
				break;
			}
	}

	function downloadAvatar(f:FriendHotel) {
		#if debug
		var url = "http://dummyimage.com/400x400/000/fff&text=user"+f.owner.id;
		#else
		var url = f.owner.avatar;
		#end
		isLoadingAvatar = true;
		mt.flash.BitmapLoader.download(url, function(t) setCachedAvatar(f.owner.id,t), function() return !destroyed, FitCropSquare(asize));
		//var url = f.owner.avatar;
//
		//if( isLoadingAvatar )
			//return;
//
		//TILE_CACHE.set(f.owner.id, {
			//t		: null,
			//ready	: false,
		//});
//
		//if( url==null )
			//return;
//
		//var l = new flash.display.Loader();
		//isLoadingAvatar = true;
//
		//#if flash
		//l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.NETWORK_ERROR, function(e:flash.events.IOErrorEvent) onDownloadError(e.text, f) );
		//#end
		//l.contentLoaderInfo.addEventListener( flash.events.SecurityErrorEvent.SECURITY_ERROR, function(e:flash.events.SecurityErrorEvent) onDownloadError(e.text, f) );
		//l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e:flash.events.IOErrorEvent) onDownloadError(e.text, f) );
		//l.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, function(e:flash.events.Event) {
			//// Download complete
			//try {
				//var li : flash.display.LoaderInfo = cast e.target;
				//var bmp : flash.display.Bitmap = cast li.content;
				//var bd = bmp.bitmapData;
				//bmp.bitmapData = null;
				//if( destroyAsked || !isOpen )
					//bd.dispose();
				//else {
					//var s = MLib.fmin( asize/bd.width, asize/bd.height );
					//var bd = mt.deepnight.Lib.scaleBitmap(bd, s, true);
					//var t = h2d.Tile.fromFlashBitmap( bd );
					//t.setCenterRatio(0.5, 0.5);
					//TILE_CACHE.get(f.owner.id).t = t;
					//TILE_CACHE.get(f.owner.id).ready = true;
					//for(a in avatars)
						//if( a.id==f.owner.id ) {
							//a.bmp.tile = t;
							//break;
						//}
				//}
			//}
			//catch(e:Dynamic) {
				//onDownloadError(e, f);
			//}
			//isLoadingAvatar = false;
		//});
//
		//for(url in Const.DOMAINS)
			//flash.system.Security.allowDomain(url);
		//var ctx = new flash.system.LoaderContext(true);
		//var r = new flash.net.URLRequest(url);
		//l.load(r, ctx);
	}


	override public function close() {
		super.close();
		clearContent();
	}


	override public function open() {
		super.open();

		#if connected
		loadFriends();
		#else
		fillWithFakeFriends();
		#end

		ui.HudMenu.CURRENT.setHighlight("contacts");
	}

	#if !connected
	function addFakeFriend(uid:Int, rseed:mt.Rand) {
		var name = com.SClient.randomName(rseed.random);
		var clean = StringTools.replace(name, "-", "");
		clean = StringTools.replace(clean, " ", "");
		clean = StringTools.replace(clean, "'", "");
		var l = Lib.irnd(0,20);
		friends.set(uid, {
			friend: {
				id: "ID_"+uid,
				net: 0,
			},
			owner: {
				id: uid,
				name		: name,
				avatar		: "http://dummyimage.com/128x128/"+mt.deepnight.Color.randomColor(rseed.range(0,1),0.7,0.75)+"/ffffff."+clean+".png",
			},
			hotel: {
				id			: -uid,
				name: "Hotel "+name,
				level: l,
				score: l*1000 + irnd(0,200)*5,
			}
		});
	}
	#end

	function addButton(icon:String, label:LocaleString, ?sub:LocaleString, col:Int, cb:Void->Void) {
		var b = createButton(function() {
			Assets.SBANK.click1(1);
			if( !Game.ME.tuto.commandLocked("side") )
				cb();
		});
		b.enableRollover();
		b.autoHide = false;

		var iwid = 64;

		var icon = b.addElement("icon", icon);
		icon.setScale( iwid/icon.height );
		icon.tile.setCenterRatio(0.5,0.5);
		icon.x = 10 + iwid*0.5;
		icon.y = bhei*0.5;

		var th = 0.;

		// Label
		var label = b.addText("name", label, 21);
		label.x = icon.x + iwid*0.5 + 10;
		label.maxWidth = (wid - label.x - 10 ) / label.scaleX;
		label.textColor = col;
		th += label.textHeight*label.scaleY;

		// Sub
		if( sub!=null ) {
			var tf = b.addText("sub", sub, 17);
			tf.x = label.x;
			tf.maxWidth = (wid - tf.x - 10 ) / tf.scaleX;
			tf.y = label.y + label.textHeight*label.scaleY;
			tf.textColor = Const.TEXT_GRAY;
			th += tf.textHeight*tf.scaleY;

			tf.y += bhei*0.5 - th*0.5;
		}

		label.y += bhei*0.5 - th*0.5;

		b.position();
	}

	override function clearContent() {
		super.clearContent();

		fronts.removeAllElements();

		for(a in avatars)
			a.bmp.dispose();
		avatars = [];
	}

	override function refresh() {
		super.refresh();
	}


	override function onResize() {
		super.onResize();
	}


	//public static function clearTileCache() {
		//for(e in TILE_CACHE)
			//if( e.t!=null )
				//e.t.dispose();
		//TILE_CACHE = null;
	//}

	override function onDispose() {
		super.onDispose();

		tileCache = null;

		for(e in avatars)
			e.bmp.dispose();
		avatars = null;

		fronts.dispose();
		fronts = null;

		friends = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	inline function getMinIndex() {
		return MLib.max(0, Std.int(-wrapper.y/(bhei*wrapper.scaleY)) - 1);
	}
	inline function getMaxIndex() {
		return MLib.max(0, Std.int((-wrapper.y+h())/(bhei*wrapper.scaleY)) - 1);
	}

	override function update() {
		super.update();

		if( isOpen )
			for(a in avatars) {
				if( a.bmp.visible && !a.bt.vis )
					a.bmp.visible = false;

				if( MLib.fabs(drag.dy)<=0.2 && !a.bmp.visible && a.bt.vis ) {
					var t = getCachedAvatar(a.id);
					if( t!=null || t==null && !isLoadingAvatar ) {
						a.bmp.visible = a.bt.vis;
						downloadAvatar( friends.get(a.id) );
					}
				}
			}
	}
}
