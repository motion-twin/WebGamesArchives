package manager;

import Common;
import Protocol;

import process.Game;
import data.Settings;
import data.LevelDesign;
import data.DataManager;

/**
 * ...
 * @author Tipyx
 */
class LifeManager
{
	static var COUNTER					: Int;
	
	public static var TIME				: Int; // IN SECOND
	
	public static function INIT() {
		COUNTER = 0;
	}

	public static function GET_STRING_TIME():String {
		if (LevelDesign.GET_LIFE() < LevelDesign.GET_MAX_LIFES()) {
			var m = Std.int(TIME / 60);
			var s = TIME - 60 * m;
			
			return (m > 9 ? "" : "0") + m + ":" + (s > 9 ? "" : "0") + s;			
		}
		else
			return "";
	}
	
	public static function UPDATE() {
		COUNTER++;
		if (COUNTER >= Settings.FPS) {
			COUNTER = 0;
			if (LevelDesign.GET_LIFE() < LevelDesign.GET_MAX_LIFES()) {
				SET_LIFE();
				if (TIME <= 0) {
					DataManager.DO_PROTOCOL(ProtocolCom.DoGetUserData);
					SET_LIFE();
				}
			}
		}
	}

	static var SERVERTIME_DIFF : Float = 0;

	#if standalone
	public static function setServerTime( serverTime : Float ){
		SERVERTIME_DIFF = serverTime - Date.now().getTime();
	}
	#end
	
	public static function SET_LIFE() {
		var dt = Date.fromTime(Date.now().getTime() + SERVERTIME_DIFF - LevelDesign.GET_LAST_GIVING_LIFE());
		TIME = Std.int(Protocol.TIME_REFILL_LIFE * 60) - (dt.getSeconds() + dt.getMinutes() * 60);
		COUNTER = 0;
	}
}
