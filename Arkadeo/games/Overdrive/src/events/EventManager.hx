package events;

import flash.errors.Error;
import flash.events.EventDispatcher;

/**
 * ...
 * @author 01101101
 */

 typedef EM = EventManager;
class EventManager extends EventDispatcher
{
	
	static public var instance (getInstance, null):EventManager;
	static private var safe:Bool;
	
	public function new () {
		super();
		if (safe)	instance = this;
		else		throw new Error("EventManager already instanciated. Use EventManager.instance instead.");
	}
	
	static private function getInstance () :EventManager {
		if (instance == null) {
			safe = true;
			new EventManager();
			safe = false;
		}
		return instance;
	}
	
}
