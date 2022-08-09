package events;
import entities.Entity;
import flash.events.Event;

/**
 * ...
 * @author 01101101
 */

typedef GE = GameEvent;
class GameEvent extends Event {
	
	inline static public var GENERATE_ROAD:String = "generate_road";
	inline static public var PAINT_ENTITY:String = "paint_entity";
	inline static public var SPAWN_ENTITY:String = "spawn_entity";
	inline static public var KILL_ENTITY:String = "kill_entity";
	inline static public var LOCK_ROAD:String = "lock_road";
	inline static public var UNLOCK_ROAD:String = "unlock_road";
	inline static public var CANCEL_SHOT:String = "cancel_shot";
	inline static public var KILL_BONUSES:String = "kill_bonuses";
	
	public var data:Dynamic;
	
	public function new (type:String, ?_data:Dynamic = null, ?bubbles:Bool = false, ?cancelable:Bool = false) {
		data = _data;
		super(type, bubbles, cancelable);
	}
	
	public override function clone () :GameEvent {
		return new GameEvent(type, data, bubbles, cancelable);
	}
	
	public override function toString () :String {
		return formatToString("GameEvent", "data", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}

class SpawnData {
	
	public var entity:Entity;
	public var params:Dynamic;
	
	public function new (entity:Entity, params:Dynamic) {
		this.entity = entity;
		this.params = params;
	}
	
}
