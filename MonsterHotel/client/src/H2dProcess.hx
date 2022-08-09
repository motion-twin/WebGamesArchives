import mt.Process;

class H2dProcess extends Process {
	public var onNextUpdate			: Void->Void;
	var clientActive				: Bool;

	public function new(?p:Process, ?ctx:h2d.Sprite) {
		super(p);

		if( ctx==null )
			ctx = Main.ME.scene;

		onNextUpdate = null;
		name = "H2dProcess";
		clientActive = true;

		createRoot(ctx);
		root.name = name;
	}



	override public function update() {
		super.update();
		if( onNextUpdate!=null ) {
			var cb = onNextUpdate;
			onNextUpdate = null;
			cb();
		}

	}

	override public function onDispose() {
		super.onDispose();

		onNextUpdate = null;
	}
}
