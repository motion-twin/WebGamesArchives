package mt.m3d;
import mt.m3d.T;

class App {
	
	var stage : flash.display.Stage3D;
	var ctx : Context;
	var camera : Camera;
	var frameCount : Int;
	var keysPressed : Array<Null<Int>>;
	
	public function new() {
		var root = flash.Lib.current;
		keysPressed = [];
		camera = new Camera();
		stage = root.stage.stage3Ds[0];
		stage.addEventListener( flash.events.Event.CONTEXT3D_CREATE, function(_) {
			ctx = stage.context3D;
			ctx.enableErrorChecking = true;
			ctx.configureBackBuffer( root.stage.stageWidth, root.stage.stageHeight, 0, true );
			init();
		});
		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) {
			keysPressed[e.keyCode] = frameCount;
		});
		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, function(e:flash.events.KeyboardEvent) {
			keysPressed[e.keyCode] = null;
		});
		root.addEventListener(flash.events.Event.ENTER_FRAME, function(_) {
			if( ctx != null ) render();
			frameCount++;
		});
		stage.requestContext3D();
	}
	
	inline function isDown(k) {
		return keysPressed[k] != null;
	}
	
	inline function isToggled(k) {
		return keysPressed[k] == frameCount;
	}
	
	function init() {
	}
	
	function render() {
		ctx.clear();
		ctx.setDepthTest( true, flash.display3D.Context3DCompareMode.LESS_EQUAL );
		ctx.setCulling(flash.display3D.Context3DTriangleFace.BACK);
		draw();
		ctx.present();
	}
	
	function draw() {
	}
	
}