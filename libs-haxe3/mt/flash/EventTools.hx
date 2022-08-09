package mt.flash;

import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.Event;

typedef InteractionEvent = #if touch_events flash.events.TouchEvent #else flash.events.MouseEvent #end
class EventTools
{
	#if touch_events
	public static var OVER_EVENT 	= flash.events.TouchEvent.TOUCH_ROLL_OVER;
	public static var OUT_EVENT 	= flash.events.TouchEvent.TOUCH_ROLL_OUT;
	public static var DOWN_EVENT 	= flash.events.TouchEvent.TOUCH_BEGIN;
	public static var UP_EVENT 	= flash.events.TouchEvent.TOUCH_END;
	public static var MOVE_EVENT 	= flash.events.TouchEvent.TOUCH_MOVE;
	public static var CLICK_EVENT 	= flash.events.TouchEvent.TOUCH_TAP;
	#else
	public static var OVER_EVENT 	= flash.events.MouseEvent.MOUSE_OVER;
	public static var OUT_EVENT 	= flash.events.MouseEvent.MOUSE_OUT;
	public static var DOWN_EVENT 	= flash.events.MouseEvent.MOUSE_DOWN;
	public static var UP_EVENT 	= flash.events.MouseEvent.MOUSE_UP;
	public static var MOVE_EVENT 	= flash.events.MouseEvent.MOUSE_MOVE;
	public static var CLICK_EVENT 	= flash.events.MouseEvent.CLICK;
	#end

	inline static function stage()
	{
		return flash.Lib.current.stage;
	}
	
	static var listenerMap:Map<InteractiveObject, Map<String, Array<Event->Void>>> = new Map();
	
	public static function dispose() 
	{
		mt.Console.log("EventTools dispose ");	
		for ( e in listenerMap.keys() )
			unlistenAll(e);
		unlistenAll(stage());
		listenerMap = new Map();
	}
	
	public static function clean( p_target:InteractiveObject )
	{
		mt.Console.log("EventTools cleaning...");
			
		if ( Std.is(p_target, flash.display.DisplayObjectContainer) )
		{
			var l = mt.flash.Lib.listAllChildren(cast p_target);
			for ( o in l )
				if( Std.is(o, InteractiveObject) )
					unlistenAll(cast o);
			l = null;
		}
		else
		{
			unlistenAll(p_target);
		}
	}
	
	public static function dumpObjects()
	{
		var s = "===== LISTENERS OBJECTS =======\n";
		for ( o in listenerMap.keys() )
		{
			s += mt.flash.Lib.printHierarchy(o) + "\n";
		}
		return s;
	}
	public static function dumpStats()
	{
		var listenedObjectCount = 0; 
		var listenedEvents = 0;
		var listeners = 0;
		for ( o in listenerMap )
		{
			listenedObjectCount++;
			for ( e in o )
			{
				listenedEvents ++;
				listeners += e.length;
			}
		}
		return 'listenedObject:$listenedObjectCount \t listenedEvents:$listenedEvents \t listeners:$listeners';
	}
	
	public static function isListening( p_target:InteractiveObject, p_event:String ):Bool
	{
		var objectEvents = listenerMap.get(p_target);
		if ( objectEvents == null ) return false;
		var objectEventListeners = objectEvents.get(p_event);
		if ( objectEventListeners == null ) return false;
		return true;
	}
	
	public static function listen( p_target:InteractiveObject, p_event:String, p_callback:Event->Void )
	{
		//il semble que ce cas tordu puisse arriver..
		if ( listenerMap == null ) 
		{
			mt.Console.log("EventTools unlisten can't unlisten, listenerMap is NULL");
			listenerMap = new Map();
		}
		
		if ( p_target == null ) 
		{
			mt.Console.log("Impossible to register listener, target is NULL");
			return p_target;
		}
		if ( p_callback == null ) 
		{
			mt.Console.log("Impossible to register listener, callback is NULL");
			return p_target;
		}
		if ( stage() == null ) 
		{
			mt.Console.log("Impossible to register listener, stage is NULL");
			return p_target;
		}
		
		var objectEvents = listenerMap.get(p_target);
		if ( null == objectEvents )
		{
			objectEvents = new Map();
			listenerMap.set(p_target, objectEvents);
		}
		
		var objectEventListeners = objectEvents.get(p_event);
		if (objectEventListeners == null)
		{
			objectEventListeners = [];
			objectEvents.set(p_event, objectEventListeners);
		}
		
		if ( !Lambda.has( objectEventListeners, p_callback ) ) 
		{
			objectEventListeners.push( p_callback );
			p_target.addEventListener(p_event, p_callback );
		}
		else
		{
			mt.Console.dbg("listener already set for that event on that target");
		}
		
		return p_target;
	}

	public static function unlistenAll( p_target:InteractiveObject )
	{
		//il semble que ce cas tordu puisse arriver..
		if ( listenerMap == null || p_target == null ) 
		{
			return p_target;
		}
		
		var objectEvents = listenerMap.get(p_target);
		if( objectEvents == null )
		{
			return p_target;
		}
		
		for( evt in objectEvents.keys() )
			unlisten( p_target, evt );
		
		listenerMap.remove(p_target);
		return p_target;
	}
	
	public static function unlisten( p_target:InteractiveObject, p_event:String, ?p_callback:flash.events.Event->Void )
	{
		//il semble que ce cas tordu puisse arriver..
		if ( listenerMap == null || p_target == null ) 
		{
			mt.Console.log("EventTools unlisten can't unlisten, target is NULL or listenerMap is NULL");
			return p_target;
		}
		
		var objectEvents = listenerMap.get(p_target);
		if( objectEvents == null )
		{
			mt.Console.dbg("EventTools unlisten can't unlisten, objectEvents is NULL");
			return p_target;
		}

		var objectEventListeners = objectEvents.get(p_event);
		if( objectEventListeners == null )
		{
			mt.Console.dbg("EventTools unlisten can't unlisten, objectEventListeners is NULL");
			return p_target;
		}

		if( p_callback != null )
		{
			objectEventListeners.remove( p_callback );
			p_target.removeEventListener(p_event, p_callback );
		}
		else
		{
			objectEvents.remove( p_event );
			for( cb in objectEventListeners )
				p_target.removeEventListener(p_event, cb );
		}
		return p_target;
	}
}
