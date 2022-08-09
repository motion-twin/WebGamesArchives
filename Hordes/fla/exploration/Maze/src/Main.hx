package ;

import flash.Lib;
import MazeGenerator;

class Main {
	static function main() {
		var cont = new flash.display.MovieClip();
		Lib.current.addChild(cont);
		cont.x = 150;
		new Main(cont);
	}
		
	var maze : HordesExploMaze;
	var root : flash.display.MovieClip;
	var texts : Array<Array<flash.text.TextField>>;
	
	function new(pRoot) {
		root = pRoot;
		texts = [];
		var width = 17;
		var height = 17;
		for ( i in 0...height ) {
			texts[i] = [];
			for ( j in 0...width ) {
				var t = new flash.text.TextField();
				t.width = SIZE;
				t.height = SIZE;
				var tf = t.getTextFormat();
				tf.align = flash.text.TextFormatAlign.CENTER;
				t.defaultTextFormat = tf;
				t.border = true;
				root.addChild(t);
				texts[i][j] = t;
			}
		}
		maze = new HordesExploMaze( width, height );
		root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onKeyPress );
		onKeyPress();
	}
	
	function onKeyPress(?e:flash.events.KeyboardEvent) {
		maze.generate(8, 0);
		render();
	}
	
	
	inline static var SIZE = 30;
	function render() {
		var g = root.graphics;
		g.clear();
		var data = maze.getData();
		for ( i in 0...maze.height ) 
		for ( j in 0...maze.width) {
			var n = data[i][j];
			g.beginFill( n.type == MazeNodeType.Wall ? 0x0 :  (n.special == MazeNodeSpecialType.Room) ? 0xFF0000 : 0xCCCCCC );
			g.drawRect( n.x * SIZE, n.y * SIZE, SIZE, SIZE );
			g.endFill();
			var t = texts[i][j];
			t.text = Std.string(n.distance);
			t.x = n.x * SIZE;
			t.y = n.y * SIZE;
		}
	}
}