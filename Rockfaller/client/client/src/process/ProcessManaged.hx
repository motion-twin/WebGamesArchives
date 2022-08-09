package process;

interface ProcessManaged {
	var isReady : Bool;
	var root	: h2d.Layers;
	
	function onReady():Void;
}

