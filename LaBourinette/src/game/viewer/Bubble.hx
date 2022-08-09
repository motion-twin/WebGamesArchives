package game.viewer;

class Bubble extends flash.display.Sprite {
	var emitter : flash.display.Sprite;
	var frames : Int;
	var url : String;
	var loader : flash.display.Loader;
	var target : flash.display.Sprite;

	public function new(p:flash.display.Sprite, ?p2:flash.display.Sprite, url_:String){
		super();
		url = url_;
		emitter = p;
		frames = 0;
		draw();
	}

	public function update() : Bool {
		++frames;
		if (frames > 60){
			stop();
			return false;
		}
		if (x == emitter.x && y == emitter.y)
			return true;
		draw();
		return true;
	}

	function draw(){
		x = emitter.x;
		y = emitter.y;
		var dim = 10;
		var dpt = 1;
		var arr = 0.2;
		// NOTE: we work in a rotated world, x and y are inversed...
		var dy = dim * 0.25;
		var dx = dim * 0.5;
		var h = emitter.x > 0 ? 1 : -1;
		var v = emitter.y > 0 ? 1 : -1;
		var pt = { x:1*dpt*h, y:1*dpt*v };
		graphics.clear();
		graphics.lineStyle(2, 0xffffff, 1, false, flash.display.LineScaleMode.NONE, flash.display.CapsStyle.ROUND, flash.display.JointStyle.ROUND);
		graphics.beginFill(0xffffff);
		graphics.moveTo(pt.x, pt.y);
		graphics.lineTo(h*dx, v * (dim * arr + dy));
		graphics.lineTo(h*dx,  v * (dim + dy));
		graphics.lineTo(h*(dim + dx), v * (dim + dy));
		graphics.lineTo(h*(dim + dx), v * dy);
		graphics.lineTo(h*(dim * arr + dx), v * dy);
		graphics.lineTo(pt.x, pt.y);
		graphics.endFill();
		filters = [
			new flash.filters.DropShadowFilter(0.2, 0, 0x000000, 2, 2)
		];
		if (loader == null){
			target = new flash.display.Sprite();
			addChild(target);
			loader = new flash.display.Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, callback(onLoaded));
			// addChild(loader);
			loader.load(new flash.net.URLRequest(url));
		}
		var pad = 0.05;
		target.x = h*(dim + dx - pad * dim);
		if (v > 0)
			target.y = v*(dy + pad * dim);
		else
			target.y = v*(dy - pad * dim) - dim;
		target.scaleX = dim * (1 - pad*2) / 68;
		target.scaleY = dim * (1 - pad*2) / 68;
		// l.width = dim;
		// l.height = dim;
		target.rotation = 90;
	}

	public function stop() : Void {
		if (parent != null)
			parent.removeChild(this);
	}

	function onLoaded(_){
		var b = new flash.display.BitmapData(68,68);
		b.draw(loader);
		var b = new flash.display.Bitmap(b);
		b.smoothing = true;
		target.addChild(b);
	}
}