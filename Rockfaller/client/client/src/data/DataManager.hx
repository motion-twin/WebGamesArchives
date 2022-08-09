package data;

import Common;
import Protocol;

import Data;

import process.*;
import manager.LifeManager;
import manager.SoundManager;
import mt.deepnight.deprecated.Process;

/**
 * ...
 * @author Tipyx
 */

typedef NameLoot = {
	var _loot : Array<{_namePNG:String, _fr:String, _en:String}>;
}

class DataManager
{

	public static function API_URL(){
		return "/api/v"+LevelDesign.MAX_VERSION_CLIENT;
	}

	public static function CREATE() {
		Data.load(mt.data.CastleLoader.getCdb("data.cdb", "data"));
		
		var js = openfl.Assets.getBytes("data/loot.json");
		var nameLoot:NameLoot = haxe.Json.parse(js.toString());
		
		function getName(namePNG:String, lang:String):String {
			for (nl in nameLoot._loot) {
				if (nl._namePNG == namePNG) {
					switch (lang) {
						case "fr" :	return nl._fr;
						default :	return nl._en;

					}
				}
			}
			
			return "";
		}
		
		LevelDesign.AR_LOOT = [];
		
		for (l in Data.Loot.all) {
			var ar = l.popLevels.split("-");
			var arInt = [];
			for (s in ar) {
				arInt.push(Std.parseInt(s));
			}
			for (level in arInt)
				if (level == null)
					throw "BUG IN LOOT LEVELS";
			if (arInt.length != 2 || arInt[0] >= arInt[1])
				throw "BUG IN LOOT LEVELS";
			
			LevelDesign.AR_LOOT.push( {	namePNG		: Std.string(l.id),
										name		: getName(Std.string(l.id), Lang.LANG),
										family		: LevelDesign.FamilyLoot.createByIndex(l.family.getIndex()),
										poprate		: l.poprate,
										levelMin	: arInt[0],
										levelMax	: arInt[1]
			});
		}
	}
	
	public static function DO_PROTOCOL(p:ProtocolCom, customOnError:Dynamic->Void = null) {
		trace(p);
	#if standalone
		var s = Type.enumIndex(p);
		mt.net.Codec.requestUrl( API_URL() + "/" + s, p, onFromServer, customOnError == null ? onError : customOnError);
	#else
		MobileServer.DO_PROTOCOL(p);
	#end
		Main.ME.showLoading();
	}
	
	public static function onFromServer(d:ProtocolCom) {
		Main.ME.hideLoading();
		trace(d);
		switch (d) {
			case ProtocolCom.SendInitData(d):
				LevelDesign.URL_AVATAR = d.avatar;
				#if standalone
				LifeManager.setServerTime(d.now);
				#end
				LevelDesign.UPDATE_USER_DATA(d.userData);
				LevelDesign.SET_AR_LEVEL( d.levels );
				LevelDesign.FRIENDS = d.friends;
				
			case ProtocolCom.SendLevels(ar) :
				LevelDesign.SET_AR_LEVEL( ar );
				
			case ProtocolCom.SendUserData(ud) :
				LevelDesign.UPDATE_USER_DATA(ud);
				
			case ProtocolCom.SendRequestCount(count):
				LevelDesign.USER_DATA.requestsCount = count;
				if (process.Levels.ME != null)
					process.Levels.ME.uiBottom.updateHLMail( LevelDesign.USER_DATA.requestsCount );
				
			case ProtocolCom.SendValidLaunchGame(ud) :
				LevelDesign.UPDATE_USER_DATA(ud);
				if (process.popup.GoalLevels.ME != null)
					process.popup.GoalLevels.ME.goToLevel();
				
			case ProtocolCom.SendValidEndGame(ud, serverTime) :
				#if standalone
				LifeManager.setServerTime(serverTime);
				mt.device.User.syncGoals();
				#end
				LevelDesign.UPDATE_USER_DATA(ud);
				if (process.popup.End.ME != null)
					process.popup.End.ME.isSendGameGood = true;
				
			case ProtocolCom.SendValidPurchaseMoves(ud) :
				if (process.popup.BoosterMoves.ME != null)
					process.popup.BoosterMoves.ME.validPurchase();
				LevelDesign.UPDATE_USER_DATA(ud);
				
			case ProtocolCom.SendValidPurchasePickaxe(ud) :
				if (process.popup.BoosterPickaxe.ME != null)
					process.popup.BoosterPickaxe.ME.validPurchase();
				LevelDesign.UPDATE_USER_DATA(ud);
				
			case ProtocolCom.SendValidPurchaseLife(ud) :
				if (process.popup.Life.ME != null)
					process.popup.Life.ME.validPurchase();
				LevelDesign.UPDATE_USER_DATA(ud);
				
			case ProtocolCom.SendTransactionData(isGood, ud) :
				LevelDesign.UPDATE_USER_DATA(ud);
				if (process.popup.Shop.ME != null && isGood)
					process.popup.Shop.ME.validPurchase();
					
			case ProtocolCom.SendUsePickaxe(canUse) :
				Game.ME.uiTop.btnPickaxe.enablePickaxe(canUse);
			
			case ProtocolCom.SendValidMobileAPI :
			
			case ProtocolCom.PCDone :
				
			case ProtocolCom.PCError(err, stack) :
				trace(err);
				switch (err) {
					case ProtocolError.PEProtocolNotHandled(p) :
					case ProtocolError.PEUserNotAdmin :
						throw "You're not allowed to do that ! è_é";
					case ProtocolError.PEUserInfoNull :
						throw "User Info Null";
					case ProtocolError.PEUserHasNotEnoughMoney(ud) :
						LevelDesign.UPDATE_USER_DATA(ud);
						if (process.popup.BoosterMoves.ME != null)
							ProcessManager.ME.showShop(process.popup.BoosterMoves.ME);
						else if (process.popup.BoosterPickaxe.ME != null)
							ProcessManager.ME.showShop(process.popup.BoosterPickaxe.ME);
						else if (process.popup.Life.ME != null)
							ProcessManager.ME.showShop(process.popup.Life.ME);
					case ProtocolError.PEUserHasNoLife(ud) :
						LevelDesign.UPDATE_USER_DATA(ud);
						if (process.Levels.ME != null) {
							if (process.popup.GoalLevels.ME != null)
								process.popup.GoalLevels.ME.onClose();
							process.ProcessManager.ME.showLife(process.Levels.ME);
						}
						else if (process.Game.ME != null)
							process.ProcessManager.ME.showLife(process.Game.ME);
					case ProtocolError.PEUserHasNoPickaxe :
						throw "No Pickaxe Available";
					case ProtocolError.PELevelForbidden(lvl, ud) :
						LevelDesign.UPDATE_USER_DATA(ud);
						#if !debug
						if (process.Game.ME != null)
							ProcessManager.ME.goTo(process.Game.ME, process.Levels, [LevelDesign.USER_DATA.levelMax, false]);
						#end
					case ProtocolError.PENotLevelToDelete(lvl), ProtocolError.PENotLevelToMove(lvl) :
				}
				trace(stack);
				
			case ProtocolCom.DoGetLevelsForEditor, ProtocolCom.DoSaveLevel, ProtocolCom.DoTestLE,
					ProtocolCom.DoTestLevel, ProtocolCom.DoGetUserData, ProtocolCom.DoSendGame,
					ProtocolCom.DoLaunchGame, ProtocolCom.DoUpdateMusic, ProtocolCom.DoUpdateSFX,
					ProtocolCom.DoUsePickaxe, ProtocolCom.DoBuyPickaxes, ProtocolCom.DoBuyMoves,
					ProtocolCom.DoBuyLifes, ProtocolCom.SendDataBouiller, ProtocolCom.DoUpdateTuto,
					ProtocolCom.DoMoveLevel, ProtocolCom.DoDeleteLevel, ProtocolCom.DoCheckTransaction, 
					ProtocolCom.DoGetRequestsCount, ProtocolCom.DoGetInitData, ProtocolCom.DoMobileAPI,
					ProtocolCom.DoCheckPickaxe, ProtocolCom.DoUpdateHint :
			trace("not handled : " + d);
		}
	}
	
	public static function onError(d:Dynamic) {
		trace("onError");
		trace(d);
	}
	
	public static function GET_REQ_DATA(reqInt:Int):{message:String, data:Null<String>} {
		return switch( Type.createEnumIndex(FriendRequestType,reqInt) ) {
			case FriendRequestType.R_GiveLife :
				{ message: data.Lang.GET_SOCIAL(TSReqGiveLife), data:null};
			case FriendRequestType.R_AskLife :
				{ message: data.Lang.GET_SOCIAL(TSReqAskLife), data:null};
			case FriendRequestType.R_InviteFriend :
				{ message: data.Lang.GET_SOCIAL(TSReqInvite), data:null};
		}
		return null;
	}
	
	public static function SEND_ACTUAL_FPS_RATE(step:String) {
		var o = {};
		Reflect.setField(o,"fps", mt.MLib.round(Main.ME.avgFps));
		Reflect.setField(o,"step", step);
		Reflect.setField(o,"w", Settings.STAGE_WIDTH);
		Reflect.setField(o,"h", Settings.STAGE_HEIGHT);
		#if flash
		Reflect.setField(o,"soft",!h3d.Engine.getCurrent().driver.isHardware());
		Reflect.setField(o,"caps",haxe.Json.parse(mt.Lib.getNativeCaps()));
		#end
		mt.device.EventTracker.twTrack("fps+", o);
	}
	
	public static function SEND_GAMEDATA(level:Int, score:Int, success:Bool, giveUp:Bool, cheat:Bool) {
		if (!success)
			Game.ME.arLoots = [];
			
		var teg = null;
		
		if (success)
			teg = TypeEndGame.TEGVictory;
		else if (giveUp)
			teg = TypeEndGame.TEGGiveUp;
		else
			teg = TypeEndGame.TEGDefeat;
		
		#if mBase
		LevelDesign.INCREMENT_GAME();
		#end
		
		var movesLeftEnd = Game.ME.movesLeftEnd != null ? Game.ME.movesLeftEnd.get() : 0;
		
		var gd = {
		#if standalone
			mobileID			: null,
			date				: null,
		#else
			mobileID			: (LevelDesign.USER_LOCAL.mobileID&0x7FFF)<<16 | (LevelDesign.USER_LOCAL.numGames&0xFFFF),
			date				: Date.now(),
		#end
			level				: level,
			version				: LevelDesign.GET_LEVEL(level).version,
			success				: teg,
			score				: score,
			boosterUsed			: Game.ME.pickaxeUsed,
			addMovesUsed		: Game.ME.addMovesUsed,
			movesUsed			: (Game.ME.levelInfo.numMoves - movesLeftEnd) + Game.ME.addMovesUsed * 5,
			arAssets			: Game.ME.goalManager.arRockRecovered,
			arLoots				: Game.ME.arLoots,
		}
		
		if (!cheat)
			DataManager.DO_PROTOCOL(ProtocolCom.DoSendGame(gd));
	}
	
	static var CACHE_AVATAR		= new Map<String, Null<h2d.Tile>>();
	static var WAIT				= 0;
	static var QUEUE			: Array<{process: Process, url:String, onLoad: h2d.Tile->Void}> = [];

	static function QPOP(){
		var n = QUEUE.shift();
		if( n != null && n.url != null ){
			if( CACHE_AVATAR.get(n.url) != null )
				DOWNLOAD_AVATAR( n.process, n.url, n.onLoad );
			else
				haxe.Timer.delay(function() DOWNLOAD_AVATAR( n.process, n.url, n.onLoad ), 70);
		}
	}
	
	
	static var MAX_AVATAR_CACHE = 60;
	static function GC_AVATAR_CACHE() {
		var count = Lambda.count(CACHE_AVATAR,function(tile) return tile!=null);
		var todoClean = count - MAX_AVATAR_CACHE;
		if ( todoClean > 0 ) 
			CLEAN_AVATAR_CACHE( todoClean );
					
		if ( todoClean > 0 ) {
			// call textureGC to dispose textures not used on last frame
			h3d.Engine.getCurrent().mem.startTextureGC( 1 );
			// retry
			CLEAN_AVATAR_CACHE( todoClean );
		}
	}
	
	static function CLEAN_AVATAR_CACHE( todoClean : Int ) {
		//trace("Try to clean: "+todoClean+" avatars");
		for ( k in CACHE_AVATAR.keys() ) {
			if ( todoClean <= 0 )
				break;
			
			var tile = CACHE_AVATAR.get(k);
			if ( tile == null ) 
				continue;
			
			var tex = tile.getTexture();
			// if texture is not used anymore, texture should be already disposed on GPU by Engine (after X frames)
			// then, clean CPU bitmap
			if ( tex != null && tex.isDisposed() ) {
				tex.destroy(true);
				//trace("remove diposed tex from cache (url=" + k + ")");
				CACHE_AVATAR.remove(k);
				todoClean--;
			}
		}
	}

	public static function DOWNLOAD_AVATAR(process: Process, url:Null<String>, onLoad:h2d.Tile-> Void) {
		if (url == null || process==null || process.destroyAsked ){
			QPOP();
			return;
		}
		
		var t = CACHE_AVATAR.get(url);
		if( t != null ){
			onLoad( t );
			QPOP();
			return;
		}

		var alreadyLoading = CACHE_AVATAR.exists(url);
		if ( !alreadyLoading && WAIT < 2 ) {
			GC_AVATAR_CACHE();
			WAIT++;
			CACHE_AVATAR.set( url, null );

			var l = new flash.display.Loader();
	
			var ctx = new flash.system.LoaderContext(true);
			var r = new flash.net.URLRequest(url);
			l.load(r, ctx);

			function onError(_) {
				CACHE_AVATAR.remove( url );
				WAIT--;
				QPOP();
			}
			
			#if flash
			l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.NETWORK_ERROR, onError );
			#end
			l.contentLoaderInfo.addEventListener( flash.events.SecurityErrorEvent.SECURITY_ERROR, onError );
			l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, onError );
			l.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, function(e:flash.events.Event) {
				GC_AVATAR_CACHE();
				
				// Download complete
				try {
					var li : flash.display.LoaderInfo = cast e.target;
					var bmp : flash.display.Bitmap = cast li.content;
					var bd = bmp.bitmapData;
					bd = mt.deepnight.Lib.scaleBitmap(bd, 1, true);
					t = h2d.Tile.fromFlashBitmap(bd);
					CACHE_AVATAR.set( url, t );
					
					if( !process.destroyAsked )
						onLoad(t);
				}
				catch (e:Dynamic) {
					
				}
				WAIT--;
				QPOP();
			});
		}else{
			QUEUE.push( {process: process, url: url, onLoad: onLoad} );
		}
	}
}
