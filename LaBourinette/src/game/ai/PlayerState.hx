package game.ai;

typedef PlayerState = {
	function enter(p:game.PlayerData) : Void;
	function update(p:game.PlayerData) : Void;
	function leave(p:game.PlayerData) : Void;
	function toString(p:game.PlayerData) : String;
}