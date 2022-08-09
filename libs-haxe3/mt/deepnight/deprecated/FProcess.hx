package mt.deepnight.deprecated;

#if (!flash && !openfl)
#error "Flash or OpenFL is required."
#end

import flash.display.Sprite;

class FProcess extends Process {
	public static var DEFAULT_PARENT : Sprite = flash.Lib.current;

	public var root			: Sprite;
	var pt0					: flash.geom.Point;

	public function new( ?proc:Process, ?parent:Sprite ) {
		super(proc);

		name = "FProcess";

		pt0 = new flash.geom.Point();

		root = new Sprite();
		if( parent!=null )
			parent.addChild(root);
		else
			DEFAULT_PARENT.addChild(root);
	}

	override function unregister() {
		super.unregister();

		pt0 = null;

		if( root.parent!=null )
			root.parent.removeChild(root);
		root = null;
	}
}
