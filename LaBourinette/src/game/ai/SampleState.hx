package game.ai;

import game.PlayerData;

class SampleState {
	public static function enter(p:PlayerData) : Void {
	}

	public static function update(p:PlayerData) : Void {
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return SampleState._toString(SampleState);
	}

	public static function _toString<T>(t:Class<T>){
		return Std.string(t);
	}
}