import flash.display.Sprite;

@:bind
class Texture1 extends flash.display.Bitmap { public function new(){super();} }
@:bind
class Texture2 extends flash.display.Bitmap { public function new(){super();} }
@:bind
class BgCenter extends flash.display.Sprite {}

typedef Pt = { x:Float, y:Float };
typedef GroundCircle = {
	id:Int,
	min:Float,
	max:Float,
	texture:flash.display.BitmapData,
	color:UInt,
	line:UInt,
	matrix:flash.geom.Matrix
};
typedef BgPart = { cx:Int, cy:Int, sprite:Sprite };

class PartArray {
	public var parts : Array<BgPart>;
	public var cx : Int;
	public var cy : Int;

	public function new(){
		parts = new Array();
		cx = 0;
		cy = 0;
	}

	public function up(){
		cy--;
		var discarded = new List();
		for (i in 0...3)
			discarded.push(parts[8-i]);
		for (i in 0...9)
			parts[8-i] = parts[(8-i)-3];
		return discarded;
	}

	public function down(){
		cy++;
		var discarded = new List();
		for (i in 0...3)
			discarded.push(parts[i]);
		for (i in 0...9)
			parts[i] = parts[i+3];
		return discarded;
	}

	public function right(){
		cx++;
		var discarded = new List();
		for (i in 0...3){
			discarded.push(parts[i*3]);
			parts[i*3] = parts[i*3+1];
			parts[i*3+1] = parts[i*3+2];
			parts[i*3+2] = null;
		}
		return discarded;
	}

	public function left(){
		cx--;
		var discarded = new List();
		for (i in 0...3){
			discarded.push(parts[i*3+2]);
			parts[i*3+2] = parts[i*3+1];
			parts[i*3+1] = parts[i*3];
			parts[i*3] = null;
		}
		return discarded;
	}

	public function reset(){
		parts = new Array();
	}

	public function update(){
		for (y in 0...3){
			for (x in 0...3){
				var idx = y*3 + x;
				if (parts[idx] == null)
					parts[idx] = { cx:cx+(x-1), cy:cy+(y-1), sprite:null };
			}
		}
	}
}

class GroundScroll extends Sprite {
	var circles : Array<GroundCircle>;
	var currentCircle : Int;
	var maxCircle : Int;
	var ox : Float;
	var oy : Float;
	var parts : Array<Array<BgPart>>;
	var table : PartArray;
	var opx : Null<Float>;
	var opy : Null<Float>;

	static var color1 : UInt;
	static var texture1 : Texture1;
	static var texture1Visited : Texture1;
	static var color2 : UInt;
	static var texture2 : Texture2;
	static var texture2Visited : Texture2;

	public function new(){
		super();
		color1 = Game.color.random();
		texture1 = new Texture1();
		texture1Visited = new Texture1();
		ColorSet.setColorBitmap(texture1Visited.bitmapData, color1);
		do { color2 = Game.color.random(); } while (color2 == color1);
		texture2 = new Texture2();
		texture2Visited = new Texture2();
		ColorSet.setColorBitmap(texture2Visited.bitmapData, color2);
		parts = new Array();
		table = new PartArray();
		circles = new Array();
		for (i in 0...50){
			var matrix = new flash.geom.Matrix();
			matrix.rotate(Math.random()*Math.PI*2);
			circles.unshift({
				id: i,
				min: 1.0*Math.pow(i+1,3),
				max: 1.0*Math.pow(i+2,3),
				color: if (i%2==1) Config.CIRCLE_LIGHT else Config.CIRCLE_DARK,
				texture: if (i%2==1) texture1.bitmapData else texture2.bitmapData,
			    matrix: matrix,
				line: if (i%2==1) Config.CIRCLE_LIGHT else Config.CIRCLE_DARK,
			});
		}
		x = 0;
		y = 0;
		ox = x;
		oy = y;
		currentCircle = 0;
		maxCircle = 1;
	}

	public function getCurrentCircle() : Int {
		return currentCircle;
	}

	function redraw(){
		var px = -Math.floor(x/Config.SQ);
		var py = -Math.floor(y/Config.SQ);
		var dx = px - opx;
		var dy = py - opy;
		opx = px;
		opy = py;
		var me = this;
		Lambda.map(
			if (dx < 0) table.left() else if (dx > 0) table.right() else new List(),
			function(i) if (i != null) me.removeChild(i.sprite)
		);
		Lambda.map(
			if (dy < 0) table.up() else if (dy > 0) table.down() else new List(),
			function(i) if (i != null) me.removeChild(i.sprite)
		);
		table.update();
		for (i in table.parts){
			if (i.sprite == null){
				i.sprite = createPart(i.cx*Config.SQ, i.cy*Config.SQ, Config.SQ, Config.SQ);
				addChild(i.sprite);
			}
		}
	}

	function visitedColor( c:UInt ){
		if (c == Config.CIRCLE_LIGHT)
			return color1;
		if (c == Config.CIRCLE_DARK)
			return color2;
		return c;
	}

	function visitedTexture( t:flash.display.BitmapData ){
		if (t == texture1.bitmapData)
			return texture1Visited.bitmapData;
		if (t == texture2.bitmapData)
			return texture2Visited.bitmapData;
		return t;
	}

	public function update(nx:Float, ny:Float){
		x -= (nx-ox);
		y -= (ny-oy);
		redraw();
		ox = nx;
		oy = ny;
		var dist = Math.sqrt(nx*nx + ny*ny);
		var i = circles.length - currentCircle - 1;
		while (i < circles.length &&  dist < circles[i].min)
			i++;
		while (i < circles.length && i > 0 && dist > circles[i].max)
			i--;
		currentCircle = circles.length - i;
		if (currentCircle > maxCircle){
			var i = circles.length - maxCircle;
			if (i > 0 && i < circles.length){
				circles[i].color = visitedColor(circles[i].color);
				circles[i].line = visitedColor(circles[i].line);
				circles[i].texture = visitedTexture(circles[i].texture);
				table.reset();
				redraw();
			}
			maxCircle = currentCircle;
		}
	}

	static function findIntersection( ray:Float, p0:Pt, p1:Pt ) : Pt {
		var result = { x:0.0, y:0.0 };
		if (p0.x == p1.x){
			result.x = p0.x;
			result.y = Math.sqrt(ray*ray - result.x*result.x);
			if (result.y < p0.y || result.y > p1.y)
				result.y *= -1;
		}
		else if (p0.y == p1.y){
			result.y = p0.y;
			result.x = Math.sqrt(ray*ray - result.y*result.y);
			if (result.x < p0.x || result.x > p1.x)
				result.x *= -1;
		}
		return result;
	}

	static function findIntersections( ray:Float, line:{p0:Dynamic, p1:Dynamic, pc:Dynamic, min:Float, max:Float} ) : Array<Pt> {
		var i = findIntersection(ray, cast line.p0, cast line.p1);
		var result = if (line.pc.x == 0 && line.p0.y == line.p1.y)
			[i, { x:i.x *-1, y:i.y }];
		else if (line.pc.y == 0 && line.p0.x == line.p1.x)
			[i, { x:i.x, y:i.y * -1 }];
		else
			[i];
		result.sort(function(a,b){ var cmp = Reflect.compare(a.x, b.x); return if (cmp != 0) cmp else Reflect.compare(a.y, b.y); });
		return result;
	}

	public function createPart( cx:Int, cy:Int, w:Float, h:Float ){
		var setDist = function(pt:{x:Float,y:Float,d:Float}){
			pt.d = Math.sqrt(pt.x*pt.x + pt.y*pt.y);
		}

		// compute part's box corners, borders and its bounding lines
		var NW = { x:cx-w/2, y:cy-h/2, d:0.0 }; setDist(NW);
		var NE = { x:cx+w/2, y:cy-h/2, d:0.0 }; setDist(NE);
		var SW = { x:cx-w/2, y:cy+h/2, d:0.0 }; setDist(SW);
		var SE = { x:cx+w/2, y:cy+h/2, d:0.0 }; setDist(SE);
		var O  = { x:cx*1.0, y:cy*1.0, d:0.0 }; setDist(O);
		var N  = { x:cx*1.0, y:cy-w/2, d:0.0 }; setDist(N);
		var S  = { x:cx*1.0, y:cy+w/2, d:0.0 }; setDist(S);
		var W  = { x:cx-w/2, y:cy*1.0, d:0.0 }; setDist(W);
		var E  = { x:cx+w/2, y:cy*1.0, d:0.0 }; setDist(E);
		var lines = [
			{ p0:NW, p1:SW, pc:W, min:0.0, max:0.0 },
			{ p0:SW, p1:SE, pc:S, min:0.0, max:0.0 },
			{ p0:SE, p1:NE, pc:E, min:0.0, max:0.0 },
			{ p0:NE, p1:NW, pc:N, min:0.0, max:0.0 },
		];
		for (l in lines){
			if (l.p0.d > l.p1.d){
				var tmp = l.p1;
				l.p1 = l.p0;
				l.p0 = tmp;
			}
			l.min = Math.min(l.pc.d, l.p0.d);
			l.max = Math.max(l.pc.d, l.p1.d);
		}

		// find circles colliding this box
		var crossedCircles = new List();
		var dists = [ NW, NE, SW, SE, O, N, S, E, W ];
		dists.sort(function(a,b) return Reflect.compare(a.d, b.d));
		var min = dists[0].d;
		var max = dists[8].d;
		for (c in circles)
			if (
				(c.min >= min && c.max <= max) || // fully inside the box
				(min <= c.max && max >= c.min) ||
				(max >= c.min && max <= c.max)
			)
				crossedCircles.add(c);

		var result = new Sprite();
		for (c in crossedCircles){
			result.graphics.lineStyle(0, 0x000000, 0);
			var colidingLinesMin = Lambda.filter(lines, function(l) return l.min <= c.min && l.max >= c.min );
			var colidingLinesMax = Lambda.filter(lines, function(l) return l.min <= c.max && l.max >= c.max );
			if (colidingLinesMax.length == 0 && colidingLinesMin.length == 0){
				if (Game.instance.slowLevel >= 4)
					result.graphics.beginFill(c.color);
				else
					result.graphics.beginBitmapFill(c.texture, c.matrix);
				// around us
				if (c.max*2 > w)
					result.graphics.drawRect(cx-w/2, cy-h/2, w, h);
				// inside us
				else {
					result.graphics.lineStyle(Config.LINES_W, c.line, Config.LINES_ALPHA);
					result.graphics.drawCircle(0, 0, c.max);
				}
				result.graphics.endFill();
			}
			else if (colidingLinesMax.length > 0){
				var points = new Array();
				for (l in colidingLinesMax)
					for (intersect in findIntersections(c.max, l))
						points.push(intersect);
				var rad = c.max;
				if (points.length == 2){
					var a = points[0];
					var b = points[1];
					var mid = Geom.middle(a, b);
					if (mid.y == 0 && a.x < 0){
						a = {x:Math.abs(a.x), y:a.y};
						b = {x:Math.abs(b.x), y:b.y};
					}
					var dist = Geom.distance(mid, {x:0.0, y:0.0});
					var vect = { x:mid.x/dist, y:mid.y/dist };

					var angleB = Geom.angleRad({x:0.0, y:0.0}, b);
					var angleA = Geom.angleRad({x:0.0, y:0.0}, a);
					var angle = Math.abs(angleB - angleA);
					if (angle > Math.PI)
						angle -= Math.PI;
					var dist = rad / Math.cos(angle / 2);
					var control = { x:dist*vect.x, y:dist*vect.y };
					if (Game.instance.slowLevel >= 4)
						result.graphics.beginFill(c.color);
					else
						result.graphics.beginBitmapFill(c.texture, c.matrix);
					result.graphics.moveTo(points[0].x, points[0].y);
					result.graphics.curveTo(control.x, control.y, points[1].x, points[1].y);
					var from = points[1];
					var corners = [NW, NE, SE, SW];
					while (corners.length > 0){
						for (p in corners.copy()){
							if (p.d <= c.max && (p != cast from) && (p.x == from.x || p.y == from.y)){
								result.graphics.lineTo(p.x, p.y);
								from = cast p;
								corners.remove(p);
								break;
							}
							else if (p.d > c.max){
								corners.remove(p);
							}
						}
					}
					result.graphics.lineTo(points[0].x, points[0].y);
					result.graphics.endFill();
					result.graphics.lineStyle(Config.LINES_W, c.line, Config.LINES_ALPHA);
					result.graphics.moveTo(points[0].x, points[0].y);
					result.graphics.curveTo(control.x, control.y, points[1].x, points[1].y);
				}
			}
			else {
				if (Game.instance.slowLevel >= 4)
					result.graphics.beginFill(c.color);
				else
					result.graphics.beginBitmapFill(c.texture, c.matrix);
				result.graphics.drawRect(cx-w/2, cy-h/2, w, h);
				result.graphics.endFill();
			}
		}
		// DEBUG: draw bounding box
		if (Config.DRAW_BOUNDING_BOX){
			var mid = w / 2;
			result.graphics.endFill();
			result.graphics.lineStyle(0, Config.GROUND_BOX);
			result.graphics.moveTo(cx-mid, cy-mid);
			result.graphics.lineTo(cx+mid, cy-mid);
			result.graphics.lineTo(cx+mid, cy+mid);
			result.graphics.lineTo(cx-mid, cy+mid);
			result.graphics.lineTo(cx-mid, cy-mid);
		}

		if (cx == 0 && cy == 0){
			var gfx = new BgCenter();
			result.addChild(gfx);
		}

		return result;
	}
}