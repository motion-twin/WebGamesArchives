package mt.signal;

typedef Signal = {
	public var info : Dynamic; // info data. On flash 9, it is the Event instance object
	dynamic function destroy():Void;
	dynamic function disposeAfterDispatch():Void;
	
	// DO NOT MODIFY
	private var call : Dynamic;
	private var listener : Dynamic;
	private var autoDispose: Bool;
}