package fx;
import Protocole;
import mt.bumdum9.Lib;

class GameOver extends WorldFx{//}

	static var SIDE = 20;
	
	var player:Player;
	var step:Int;
	var squares:Array<Part>;
	
	public function new(player:Player) {
		this.player = player;
		super();
	
		slice();
		World.me.backIn();
		World.me.setControl(false);
			
		step  = 0;
		coef = 0;
		
		h.sprite.setAnim(Gfx.hero.getAnim("hero_hurt"), false);
		new mt.fx.Shake(h.sprite, 4,0);
	}
	
	

	override function update() {
		super.update();
	
		switch(step) {
			case 0 :
				if( coef++ > 20 ) {
					coef = 0;
					step++;
					h.sprite.setAnim(Gfx.hero.getAnim("hero_explode"), false);
				}
			case 1 :
				if( coef++ > 120 ) {
					
					h.setSquare( isl.respawn );
					h.face();
					//isl.sortElements();
					World.me.setControl(true);
					new mt.fx.Blink(h.sprite, 100, 8, 4);
					step ++;
					
				}
			case 2 :
				if( squares.length == 0 ) kill();
		
		}
		
		
		var a = squares.copy();
		for( sq in a ) {
			sq.update();
			if( sq.y > Cs.mcrh + SIDE ) {
				sq.kill();
				squares.remove(sq);
			}
		}
		
	}

	function slice() {
		var bitmapData = new flash.display.BitmapData(Cs.mcw, Cs.mcrh, false, 0xFF00FF);
		//bitmapData.draw(player.game);
		bitmapData.draw(player);
		var xmax = Math.ceil(Cs.mcw / SIDE);
		var ymax = Math.ceil(Cs.mcrh / SIDE);
		var ray = SIDE * 0.5;
		squares  = [];
		for( x in 0...xmax ) {
			for( y in 0...ymax ) {
		
				var p = new Part();
				p.x = (x + 0.5) * SIDE;
				p.y = (y + 0.5) * SIDE;
				p.updatePos();
				p.frict = 0.98;
				
				Main.root.addChild(p.root);
				
				var dx = p.x - Cs.mcw * 0.5;
				var dy = p.y - Cs.mcrh * 0.5;
				var a = Math.atan2(dy, dx);
				var dist = Math.sqrt(dx * dx + dy * dy);
				var cc = Math.abs(dist / 250);
				var speed = 0.75+ (1-cc) * 4;
				p.vx = Math.cos(a) * speed;
				p.vy = Math.sin(a) * speed - 1;
				p.vr = (Math.random() * 2 - 1) * 5;
				p.fvr = 0.97;
				
				p.weight = 0.05 + Math.random() * 0.15;
				p.timer = 40 + Std.random(20);
				
			
				var m = new flash.geom.Matrix();
				m.translate(-p.x,-p.y);
				p.root.graphics.beginBitmapFill(bitmapData, m);
				var r = SIDE * 0.5;
				p.root.graphics.drawRect( -r, -r, 2 * r, 2 * r);
				
				Col.setPercentColor(p.root, cc * 0.25, 0);
				
				
				squares.push(p);
				
			}
		}
		
		
	}
	

	
	
//{
}


	class Part {
		
		public var root:flash.display.Sprite;
		public var x:Float;
		public var y:Float;
		public var vx:Float;
		public var vy:Float;
		public var vr:Float;
		public var scale:Float;
		public var frict:Float;
		public var fvr:Float;
		public var weight:Float;
		public var timer:Int;
		public var fadeLimit:Int;
		public var fadeType:Int;
		public var sleep:Null<Int>;
		
		public function new(?mc) {
			if( mc == null ) mc = new flash.display.Sprite();
			root = mc;
			x = 0;
			y = 0;
			vx = 0;
			vy = 0;
			vr = 0;
			scale = 1;
			frict = 1.0;
			fvr = 1.0;

			fadeLimit = 10;
			fadeType = 0;
			
			timer = 10 + Std.random(10);
			
		}
		
		public function setPos(nx, ny) {
			x = nx;
			y = ny;
			updatePos();
		}
		public function setScale(sc) {
			scale = sc;
			root.scaleX = root.scaleY = scale;
		}
		
		
		public function update() {
			
			vy += weight;
			vx *= frict;
			vy *= frict;
			
			x += vx;
			y += vy;
			
			vr *= fvr;
			root.rotation += vr;
			
			timer--;
			
			if( timer < fadeLimit ) {
				var c = timer / fadeLimit;
				switch(fadeType) {
					case 0 :		root.scaleX = root.scaleY = c*scale;
					case 1 :
						
				}
			}
			if( timer == 0 ) kill();
			
			
				updatePos();
		}
		
		public function updatePos() {
			root.x = x;
			root.y = y;
		}

		public function kill() {
			if( root.parent != null ) root.parent.removeChild(root);
		}
		
	}
	





