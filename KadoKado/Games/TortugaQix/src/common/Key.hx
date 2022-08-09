import flash.ui.Keyboard;
import flash.events.KeyboardEvent;

/*
 * Handles flash9/10 key events.
 */
class Key {
	// number of frames before accepting a key up (this fixes the key repeat bug which sometimes happens on linux)
	static var FRAMES_DELAY = 2;
	static var keys = new List<Key>();
	public static var UP = new Key(Keyboard.UP, "Z".charCodeAt(0), "W".charCodeAt(0));
	public static var DOWN = new Key(Keyboard.DOWN, "S".charCodeAt(0), "S".charCodeAt(0));
	public static var LEFT = new Key(Keyboard.LEFT, "Q".charCodeAt(0), "A".charCodeAt(0));
	public static var RIGHT = new Key(Keyboard.RIGHT, "D".charCodeAt(0), "D".charCodeAt(0));
	public static var ADD = new Key(Keyboard.NUMPAD_ADD);
	public static var MINUS = new Key(Keyboard.NUMPAD_SUBTRACT);
	public static var SPACE = new Key(Keyboard.SPACE);
	public static var ENTER = new Key(Keyboard.ENTER);
	public static var DELETE = new Key(Keyboard.DELETE);
	public static var HOME = new Key(Keyboard.HOME);
	public static var P = new Key("P".charCodeAt(0));
	public static var W = new Key("W".charCodeAt(0));
	public static var X = new Key("X".charCodeAt(0));
	public static var C = new Key("C".charCodeAt(0));

	public var isDown : Bool;
	var code : Int;
	var code1 : Int;
	var code2 : Int;
	var down : Bool;
	var frames : Int;

	function new( c, ?alt1:Null<Int>=null, ?alt2:Null<Int>=null ){
		code = c;
		code1 = if (alt1 == null) code else alt1;
		code2 = if (alt2 == null) code else alt2;
		down = false;
		frames = 0;
		keys.push(this);
	}

	inline function setDown( d:Bool ){
		if (d){
			isDown = true;
			down = true;
			frames = 0;
		}
		else {
			down = false;
			frames = 1;
		}
	}

	public static function init(){
		var stage = flash.Lib.current.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, callback(onKey,true));
		stage.addEventListener(KeyboardEvent.KEY_UP, callback(onKey,false));
	}

	static function onKey(down:Bool, evt:flash.events.KeyboardEvent){
		switch (evt.keyCode){
			case UP.code,UP.code1,UP.code2: UP.setDown(down);
			case DOWN.code,DOWN.code1,DOWN.code2: DOWN.setDown(down);
			case LEFT.code,LEFT.code1,LEFT.code2: LEFT.setDown(down);
			case RIGHT.code,RIGHT.code1,RIGHT.code2: RIGHT.setDown(down);
			case SPACE.code,SPACE.code1,SPACE.code2: SPACE.setDown(down);
			case ENTER.code,ENTER.code1,ENTER.code2: ENTER.setDown(down);
			case DELETE.code,DELETE.code1,DELETE.code2: DELETE.setDown(down);
			case ADD.code,ADD.code1,ADD.code2: ADD.setDown(down);
			case MINUS.code,MINUS.code1,MINUS.code2: MINUS.setDown(down);
			case HOME.code,HOME.code1,HOME.code2: HOME.setDown(down);
			case P.code,P.code1,P.code2: P.setDown(down);
			case W.code,W.code1,W.code2: W.setDown(down);
			case X.code,X.code1,X.code2: X.setDown(down);
			case C.code,C.code1,C.code2: C.setDown(down);
		}
	}

	public static function update(){
		for (k in keys){
			if (k.isDown && !k.down){
				k.frames++;
				if (k.frames >= FRAMES_DELAY)
					k.isDown = false;
			}
		}
	}
}