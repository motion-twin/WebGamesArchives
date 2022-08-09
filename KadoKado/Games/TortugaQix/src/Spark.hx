import geom.Pt;
import geom.PVector;
import flash.display.Shape;

@:bind
class Ecureuil extends flash.display.MovieClip {
	public var sub : flash.display.MovieClip;
	public function new(){ super(); }
}

class EcureuilCollision extends flash.display.BitmapData {
	public function new(){
		super(30, 30, true, 0x00000000);
		var s = new flash.display.Shape();
		var g = s.graphics;
		g.beginFill(0x333333);
		g.drawEllipse(0, 0, 30, 30);
		g.endFill();
		draw(s);
	}
}

class Spark {
	public static var sparks : Array<Spark> = [];
	public static var lastSpawn = 0.0;
	static function spawn(){
		var cursor = Game.getCursorPos();
		sparks = [
			new Spark(true),
			new Spark(false)
		];
		/*
		sparks[0].pos.set({ x:Game.W/2, y:(Game.PADH*1.0) });
		sparks[0].direction.set(Direction.WEST);
		sparks[0].side.set(Direction.SOUTH);
		sparks[1].pos.set({ x:Game.W/2, y:Game.PADH*1.0 });
		sparks[1].direction.set(Direction.EAST);
		sparks[1].side.set(Direction.SOUTH);
		*/
		sparks[0].pos.set({ x:Game.field.x, y:Game.H/2 });
		sparks[0].direction.set(Direction.SOUTH);
		sparks[0].side.set(Direction.EAST);
		sparks[1].pos.set({ x:Game.field.x+Game.field.width, y:Game.H/2 });
		sparks[1].direction.set(Direction.SOUTH);
		sparks[1].side.set(Direction.WEST);
	}

	public static function reset(){
		sparks = [];
		lastSpawn = 0.0;
	}

	public static function updateSparks(){
		if (sparks.length == 0){
			spawn();
		}
		for (s in sparks.copy()){
			s.oldPos.set(s.pos);
			for (t in 0...Math.round(Game.level.sparksSpeed*mt.Timer.tmod)){
				s.update();
			}

		}
	}

	public static function pauseSparksAnim(){
		for (s in sparks)
			s.pauseAnim();
	}

	public var movie : Ecureuil;
	public var pos : PVector;
	public var oldPos : PVector;
	public var direction : PVector;
	public var side : PVector;
	public var destroyed : Bool;
	public var left : Bool;
	public var panicked : Bool;
	public var collision : EcureuilCollision;

	public function new(l:Bool){
		movie = new Ecureuil();
		movie.gotoAndStop(1);
		collision = new EcureuilCollision();
		left = l;
		pos = new PVector();
		oldPos = new PVector();
		direction = new PVector();
		side = new PVector();
		destroyed = false;
		panicked = false;
	}

	function canUse( side:Pt, dir:Pt ){
		if (left)
			return Direction.rightOf(side).equals(dir);
		else
			return Direction.leftOf(side).equals(dir);
	}

	public function update(){
		var pixels = Game.getPixels(Math.round(pos.x), Math.round(pos.y));
		var nextPixel = pixels[Direction.d2i(direction)];
		var sidePixel = pixels[Direction.d2i(side)];
		var otherSide = side.clone().negate();
		var otherSidePixel = pixels[Direction.d2i(otherSide)];
		// we are on path, emptyness on our side, just go ahead
		if (Colors.isConqueredPath(nextPixel) && sidePixel == Colors.TO_CONQUER){
			destroyed = false;
		}
		else if (otherSidePixel == Colors.TO_CONQUER && canUse(otherSide, direction.clone().negate())){
			direction.negate();
			side.set(otherSide);
			destroyed = false;
		}
		else {
			var candidates = [];
			var dirs = [ side.clone(), otherSide ];
			for (v in dirs)
				if (Colors.isConqueredPath(pixels[Direction.d2i(v)]))
					candidates.push(v);
			destroyed = true;
			for (c in candidates){
				var pixels = Game.getPixels(Math.round(pos.x+c.x), Math.round(pos.y+c.y));
				for (d in [Direction.NORTH, Direction.WEST, Direction.SOUTH, Direction.EAST]){
					var p = pixels[Direction.d2i(d)];
					if (p == Colors.TO_CONQUER){
						// Good boy, we are not destroyed finally
						if (canUse(d, c)){
							side.set(d);
							direction.set(c);
							destroyed = false;
							panicked = false;
							break;
						}
					}
				}
			}
			if (destroyed){ // Ok, panic now and find a way out
				var pforward = pos.clone().add(direction);
				var pleft = pos.clone().add(Direction.leftOf(direction));
				var pright = pos.clone().add(Direction.rightOf(direction));
				var candidates = [ pforward, pleft, pright ];
				var best = null;
				var bestDistToQix = 99999999.0;
				var qixPos = Game.qix.getPos();
				for (c in candidates)
					if (Colors.isConqueredPath(Game.getPixel(Math.round(c.x), Math.round(c.y)))){
						var dist = c.distanceSquared(qixPos);
						if (dist < bestDistToQix){
							best = c;
							bestDistToQix = dist;
						}
					}
				if (best != null){
					best.sub(pos);
					direction.set(best);
					side.set(if (left) Direction.leftOf(direction) else Direction.rightOf(direction));
				}
			}
		}
		pos.add(direction);
		if (direction.equals(Direction.NORTH)){
			if (movie.currentFrame != 3) movie.gotoAndStop(3);
		}
		else if (direction.equals(Direction.SOUTH)){
			if (movie.currentFrame != 2) movie.gotoAndStop(2);
		}
		else if (direction.equals(Direction.WEST)){
			if (movie.currentFrame != 4) movie.gotoAndStop(4);
		}
		else if (direction.equals(Direction.EAST)){
			if (movie.currentFrame != 1) movie.gotoAndStop(1);
		}
		if (movie.sub != null)
			movie.sub.play();
		movie.x = pos.x;
		movie.y = pos.y;
	}

	public function pauseAnim(){
		if (movie.sub != null)
			movie.sub.stop();
	}
}