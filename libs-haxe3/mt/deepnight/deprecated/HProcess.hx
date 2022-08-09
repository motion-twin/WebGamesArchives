package mt.deepnight.deprecated;

#if !h3d
#error "h3d lib is required."
#end

import h3d.Engine;
import h2d.Scene;
import h2d.Layers;
import h2d.Sprite;
import hxd.Event;

class HProcess extends Process {
	public static var GLOBAL_SCENE : Scene = null;

	public var root			: Layers;
	public var engine		: Engine;

	public function new(?proc:Process, ?parent:Sprite) {
		if( GLOBAL_SCENE==null && parent==null )
			throw "HProcess.SCENE is null.";

		super(proc);

		engine = Engine.getCurrent();
		root = new Layers( parent!=null ? parent : GLOBAL_SCENE );

		name = "HProcess";
		GLOBAL_SCENE.addEventListener(_onEventsInternal);
	}

	override function set_name(s:String) {
		if( root!=null )
			root.name = s;
		return super.set_name(s);
	}

	function _onEventsInternal(e:hxd.Event) {
		if( !destroyAsked )
			onEvents(e);
	}
	function onEvents(e:hxd.Event) {}

	inline function getScaleFor(px:Float, ?cm=1.0) {
		return mt.Metrics.cm2px(cm) / px;
	}

	override function unregister() {
		super.unregister();

		GLOBAL_SCENE.removeEventListener(_onEventsInternal);

		root.dispose();
		root = null;

		engine = null;
	}
}
