package data;

import mt.net.FriendRequest.Friend;

import Common;

import Rock;
import manager.LifeManager;

/**
 * ...
 * @author Tipyx
 */

enum World {
	WEarth;
	WMoon;
}

typedef FamilyLoot = Data.FamilyLootCDB;

typedef LootData = {
	var name		: String;
	var namePNG		: String;
	var family		: FamilyLoot;
	var poprate		: Int;
	var levelMin	: Int;
	var levelMax	: Int;
}

//typedef LevelInfoUser = {
	//var numLevel	: Int;
	//var highScore	: Int;
	//var unlock		: Bool;
//}

class LevelDesign
{
	//public static var AR_LEVEL_USER	: Array<LevelInfoUser>	= [];
	
	public static var MAX_LEVEL_CLIENT				= 180;

	// Voir (et mettre à jour) VERSIONS.txt
	public static var MAX_VERSION_CLIENT			= 15;
	
	public static var USER_DATA(default,null)		: UserData;
	public static var URL_AVATAR					: Null<String>;
	
#if mBase
	public static var USER_LOCAL	: UserLocalData;
	static var so					: mt.SecureSO;
	static var soGuestId			: Null<Int>;
#end
	
	public static var FRIENDS 		: Array<FriendData> = [];
	
	public static var AR_LEVEL		: Array<LevelInfo>	= [];
	#if mBase
	static var AR_LEVEL_HASH		: Null<haxe.io.Bytes>;
	#end
	
	public static var AR_LOOT		: Array<LootData>	= [];
	
	public static function CREATE() {
		DataManager.CREATE();
	}
	
	public static function UNLOCK(newMaxLevel:Int) {
		USER_DATA.levelMax = newMaxLevel;
	}
	
	public static function GET_LEVEL(numLevel:Int):LevelInfo {
		if (AR_LEVEL.length == 0)
			throw "INIT A JSON FIRST !";
		
		for (l in AR_LEVEL)
			if (l.level == numLevel) {
				//if (!Common.VALIDATE_LEVEL(l))
					//throw "NOT VALIDATE LEVEL " + numLevel;
				//else
					return l;
			}
				
		throw "PAS DE LEVEL " + numLevel;
		
	}
	
	public static function GET_USER_HIGHSCORE(numLevel:Int):Null<Int> {
		return USER_DATA.arHighScore[numLevel];
	}
	
	public static function GET_MAXLEVEL():Int {
		var m = 0;
		for (l in AR_LEVEL)
			if (l.level > m)
				m = l.level;
		return m;
	}
	
	public static function TUTO_IS_DONE(n:Int):Bool {
		for (t in USER_DATA.tutoDone)
			if (t == n)
				return true;
				
		return false;
	}
	
	public static function GET_MAX_LIFES():Int {
		if (Common.HAS_FLAG(USER_DATA, UserFlags.UFFirstPurchase))
			return Protocol.MAX_LIFES + 1;
		else
			return Protocol.MAX_LIFES;
	}

	public static function GET_LEVEL_UNIVERS(numLevel:Int) : Int {
		var lvlInf = Lambda.find(AR_LEVEL,function(l) return l.level==numLevel);
		return GET_BIOME_UNIVERS(lvlInf.biome);
	}

	public static function GET_BIOME_UNIVERS(biome) : Null<Int> {
		if( biome == null ) return null;
		switch (biome) {
			case TypeBiome.TBClassic, TypeBiome.TBFreeze, TypeBiome.TBMagma: 
				return 0;
			case TypeBiome.TBWater, TypeBiome.TBCiv, TypeBiome.TBCentEarth: 
				return 1;
			case TypeBiome.TBNightmare, TypeBiome.TBLimbo :
				return 2;
		}
	}
	
	public static function UPDATE_USER_DATA (ud:UserData) {
		USER_DATA = ud;
		
	#if mBase
		if( USER_LOCAL.userData == null )
			USER_LOCAL.life = GET_MAX_LIFES();
		USER_LOCAL.userData = USER_DATA;
		
		SAVE_USERLOCAL();
	#end
		
		LifeManager.SET_LIFE();
		
		if (process.Levels.ME != null) {
			process.Levels.ME.uiBottom.setGold();
			process.Levels.ME.uiBottom.uiLife.updateLife();
			process.Levels.ME.uiBottom.updateHLMail(USER_DATA.requestsCount);
		}
	}
	
#if mBase
	static function userSO() : mt.SecureSO{
		if( so != null && soGuestId == Auth.me.getGuestId() )
			return so;

		if( so != null ){
			so = null;
			soGuestId = null;
		}
		
		soGuestId = Auth.me.getGuestId();
		return so = new mt.SecureSO({
			name: "udata_"+soGuestId,
			aesKey: App.current.config.aesKey,
			aesIv: App.current.config.aesIv,
			v2: true
		});
	}

	public static function LOAD_USERLOCAL() {
		USER_DATA = null;

		USER_LOCAL = userSO().get("d");
		
		if (USER_LOCAL == null) {
			USER_LOCAL = {
				mobileID		: null,
				numGames		: 0,
				life			: Protocol.MAX_LIFES,
				lastGivingLife	: Date.now().getTime(),
				nextFullLife	: null,
				userData		: USER_DATA,
				gamesBuffer		: []
			}
		}else{
			USER_DATA = USER_LOCAL.userData;
		}
	}
	
	static var SAVE_LOCK = false;
	public static function SAVE_USERLOCAL() {
		if (USER_LOCAL.life < LevelDesign.GET_MAX_LIFES()) {
			var dt = Date.now().getTime() - USER_LOCAL.lastGivingLife;
			var tRefill = DateTools.minutes(Protocol.TIME_REFILL_LIFE);
			var lifeCanBeGiven = Std.int(dt / tRefill);

			if (lifeCanBeGiven > 0) {
				USER_LOCAL.lastGivingLife += lifeCanBeGiven * tRefill;
				MobileServer.ADD_LIVES( lifeCanBeGiven );
			}
		}
		
		LifeManager.SET_LIFE();
		if (process.Levels.ME != null) {
			process.Levels.ME.uiBottom.setGold();
			process.Levels.ME.uiBottom.uiLife.updateLife();
		}
		
		var guestId = Auth.me.getGuestId();
		if( guestId == null )
			throw "Invalid user";

		var so = userSO();
		function saveToSO(){
			if( SAVE_LOCK ){
				haxe.Timer.delay(saveToSO,100);
				return;
			}
			SAVE_LOCK = true;
			Main.getWorker().enqueue(new mt.Worker.WorkerTask(function() {
				// auto-save in mt.SecureSO
				so.set("d", USER_LOCAL);
				SAVE_LOCK = false;
			}));
		}
		saveToSO();
	}
	
	public static function INCREMENT_GAME() {
		USER_LOCAL.numGames++;
		SAVE_USERLOCAL();
	}

	public static function CLEAN(){
		USER_LOCAL = null;
		USER_DATA = null;
		FRIENDS = [];
	}
	
	#if cpp
	static function LEVELS_FILE(){
		return openfl.utils.SystemPath.applicationStorageDirectory + "/" + "levels.dat";
	}

	static function MKHASH( b : haxe.io.Bytes ) : haxe.io.Bytes {
		return new haxe.crypto.Hmac( SHA1 ).make( haxe.io.Bytes.ofString("QssOQ3vSVOrOHskgUhZE3zZ20AompxoHDe"), b );
	}

	public static function LOAD_AR_LEVEL( onReady : Void->Void ){
		var arr = null;
		var hash = null;
		var task = new mt.Worker.WorkerTask(function(){
			try {
				var path = LEVELS_FILE();
				if( sys.FileSystem.exists(path) ){
					var b = sys.io.File.getBytes( path );

					hash = b.sub(0,20);
					var zBytes = b.sub(20,b.length-20);
					var bytes = haxe.zip.Uncompress.run(zBytes);
					if( MKHASH(bytes).compare(hash) != 0 )
						throw "bad levels data";
					arr = haxe.Unserializer.run(bytes.toString());
				}
			}catch(e:Dynamic){
				#if debug
				trace("load levels error: "+Std.string(e));
				#end
			}
		});
		task.onComplete = function(){
			if( arr != null && hash != null ){
				AR_LEVEL = arr;
				MAX_LEVEL_CLIENT = AR_LEVEL.length;
				AR_LEVEL_HASH = hash;
			}
			onReady();
		}
		Main.getWorker().enqueue( task );
	}
	#else
	public static function LOAD_AR_LEVEL( onReady : Void -> Void ){
		onReady();
	}
	#end
#end

	public static function SET_AR_LEVEL(ar:Array<LevelInfo>){
		ar = Common.SORT_AR_LEVEL(ar);

		AR_LEVEL = ar;
		MAX_LEVEL_CLIENT = AR_LEVEL.length;
		#if (mBase && cpp)
		Main.getWorker().enqueue( new mt.Worker.WorkerTask(function(){
			try {
				var path = LEVELS_FILE();
				var ser = haxe.io.Bytes.ofString( haxe.Serializer.run( ar ) );
				var hash = MKHASH( ser );

				if( AR_LEVEL_HASH == null || hash.compare(AR_LEVEL_HASH) != 0 ){
					trace("Save levels");
					AR_LEVEL_HASH = hash;
					var zBytes = haxe.zip.Compress.run( ser, 5 );

					var b = haxe.io.Bytes.alloc( zBytes.length + hash.length );
					b.blit(0,hash,0,hash.length);
					b.blit(hash.length,zBytes,0,zBytes.length);

					sys.io.File.saveBytes(path,b);
					mtnative.device.Device.noBackupFile(path);
				}
			}catch(e:Dynamic){
				#if debug
				trace("save levels error: "+Std.string(e));
				#end
			}
		}) );
		#end
	}

	public static function GET_LAST_GIVING_LIFE() {
	#if standalone
		return USER_DATA.lastGivingLife;
	#else
		return USER_LOCAL.lastGivingLife;
	#end
	}

	#if standalone
	public static function SET_LIFE(life:Int) {
		USER_DATA.life = life;
	}
	#end
	
	public static inline function GET_LIFE() {
	#if standalone
		return USER_DATA.life;
	#else
		return USER_LOCAL.life;
	#end
	}
	
	public static function WANT_HINT(): Bool {
	#if standalone
		return USER_DATA.flags.has(UserFlags.UFHint);
	#else
		return USER_LOCAL.userData.flags.has(UserFlags.UFHint);
	#end
	}
}
