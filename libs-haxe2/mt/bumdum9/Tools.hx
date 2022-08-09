﻿package mt.bumdum9;
import mt.bumdum9.Lib;

class Tools implements haxe.Public{//}


	
	static function slice(mc:flash.display.DisplayObject, max):Array < mt.fx.Part < flash.display.Sprite >> {
		
		
		var b = mc.getBounds(mc.parent);
		b.x -= mc.x;
		b.y -= mc.y;
		
		//var b = mc.getBounds(mc);
		
		var base = new Polygon( [ b.left, b.top, b.right, b.top, b.right, b.bottom, b.left, b.bottom ] );
		var pols = [base];
		
		var order = function (a:Polygon, b:Polygon) {
			if( a.getCirc() > b.getCirc() ) return -1;
			return 1;
		}
		
		for( i in 0...max) {
			pols.sort(order);
			var p = pols[0];
			pols.push( p.equiSlice() );
		}
		
		
		var bmp = new BMD( Math.ceil(b.width), Math.ceil(b.height), true, 0);
		var m = mc.transform.matrix;
		m.translate( -mc.x, -mc.y );
		m.translate( -b.x, -b.y );

		
		bmp.draw(mc, m,mc.transform.colorTransform);
		
		var a = [];
		for( pol in pols ) {
			
			var ce = pol.getCenter();
			var p = new mt.fx.Part(new SP());
			p.setPos(mc.x + ce.x, mc.y + ce.y);
			m.identity();
			m.translate(b.x,b.y);
			m.translate(-ce.x,-ce.y);
			p.root.graphics.beginBitmapFill(bmp, m, false, true);
			pol.draw(p.root, -ce.x, -ce.y);
			p.root.graphics.endFill();
			a.push(p);

		}
		
		return a;
		
	}
	
	/*
	
	static function slice2(mc:flash.display.DisplayObject, max) {
		
		
		var b = mc.getBounds(mc.parent);
		b.x -= mc.x;
		b.y -= mc.y;
		
		//var b = mc.getBounds(mc);
		
		var base = new Polygon( [ b.left, b.top, b.right, b.top, b.right, b.bottom, b.left, b.bottom ] );
		var pols = [base];
		
		var order = function (a:Polygon, b:Polygon) {
			if( a.getCirc() > b.getCirc() ) return -1;
			return 1;
		}
		
		for( i in 0...max) {
			pols.sort(order);
			var p = pols[0];
			pols.push( p.equiSlice() );
		}
		
		
		var bmp = new BMP( Math.ceil(b.width), Math.ceil(b.height), true, 0);
		var m = mc.transform.matrix;
		m.translate( -mc.x, -mc.y );
		m.translate( -b.x, -b.y );

		
		bmp.draw(mc, m,mc.transform.colorTransform);
		
		
		
		var a = [];
		for( pol in pols ) {
			
			var ce = pol.getCenter();
			var p = new mt.fx.Part(new SP());
			p.setPos(mc.x + ce.x, mc.y + ce.y);
			m.identity();
			m.translate(b.x,b.y);
			m.translate(-ce.x,-ce.y);
			p.root.graphics.beginBitmapFill(bmp, m);
			pol.draw(p.root, -ce.x, -ce.y);
			p.root.graphics.endFill();
			a.push(p);

		}
		
		return a;
		
	}
	
	*/
	
	static function getMcPos(mc:SP,tryMax=10) {
		var b = mc.getBounds(mc.parent);
		for ( i in 0...tryMax ) {
			var x = Std.random(Math.ceil(b.width));
			var y = Std.random(Math.ceil(b.height));
			if ( mc.hitTestPoint(x, y, true) )
				return { x:x, y:y };
		}
		return null;
		
	}
	
	
	static function getScreenshot(mc:SP) {
		var b = mc.getBounds(mc);
		
		var ss = new flash.display.Bitmap();
		ss.bitmapData = new BMD(Math.ceil(b.width), Math.ceil(b.height), true, 0x00FF0000);
		var m = new MX();
		m.rotate( mc.rotation * 0.0174);
		m.scale(mc.scaleX, mc.scaleY);
		m.translate( -b.x, -b.y);
		ss.bitmapData.draw(mc, m, mc.transform.colorTransform, mc.blendMode);
		
		ss.x = mc.x + b.x;
		ss.y = mc.y + b.y;
		return ss;
	}
	
	
	
//{
}


private typedef PolPoint = { x:Float, y:Float, d:Float, next:PolPoint };
class Polygon {
		
	public var first:PolPoint;

	public function new( ?a:Array<Float> ) {
		
		if( a == null ) a = [];
		while( a.length > 0 ) pushPoint(a.shift(), a.shift());
		
		/*
		var p = first;
		while(true){
			p = p.next;
			if( p == first ) break;
		}
		*/
	}
	public function pushPoint(x:Float, y:Float) {
		if( first == null ) {
			first = { x:x, y:y, d:0.0 , next:null };
			first.next = first;
			return;
		}
		var last = getLast();
		var point = { x:x, y:y, d:0.0 , next:first };
		majPoint(point);
		last.next = point;
		majPoint(last);
	}
	public function majPoint(p:PolPoint) {
		var dx = p.x - p.next.x;
		var dy = p.y - p.next.y;
		p.d =  Math.sqrt(dx * dx + dy * dy);
	}
	
	public function getLast() {
		var p = first;
		while(true) {
			p = p.next;
			if( p.next == first ) return p;
		}
		return null;
		
	}
	public function getCirc() {
		var circ = 0.0;
		var p = first;
		while(true) {
			circ += p.d;
			p = p.next;
			if( p == first ) return circ;
		}
		return -1;
	}
	
	public function insertPointOnCirc(c:Float) {
		var circ = getCirc();
		var pos = c * circ;
		var cur = 0.0;

		var p = first;
		while(true) {
			
			if( cur + p.d > pos ) {
				return insertPointAt(p, (pos - cur) / p.d);
			}
			cur += p.d;
			p = p.next;
			if( p == first ) break;
		}
		return null;
	}
	public function insertPointAt(p:PolPoint, co:Float) {
		
		var dx = p.next.x - p.x;
		var dy = p.next.y - p.y;
		var a = Math.atan2(dy, dx);
		var dist = Math.sqrt(dx * dx + dy * dy)*co;
		
		var point = {
			x:p.x + Math.cos(a) * dist,
			y:p.y + Math.sin(a) * dist,
			d:dist,
			next:p.next,
		}
		p.next = point;
		majPoint(p);
		majPoint(point);
		return point;
	}
	
	// SLICE
	public function equiSlice2(?a:Float) {
		if( a == null ) a = Math.random();
		var b = (a + 0.5) % 1;
		return slice(a, b);
	}
	
	public function equiSlice(?rnd=0.25) {
		
		//return equiSlice();
		var segments = getSortedPoints();
		var a = [];
		for ( i in 0...2 ) {
			var p = segments[i];
			var np = insertPointAt(p, 0.5 + (Math.random() * 2 - 1) * rnd);
			a.push(np);
		}
		return spliceInTwo(a[0], a[1]);
		
	}
	function getSortedPoints() {
		var a = [];
		var p = first;
		while ( true ) {
			a.push(p);
			p = p.next;
			if ( p == first ) break;
		}
		a.sort(sortPoints);
		return a;
	}
	function sortPoints(a:PolPoint,b:PolPoint) {
		if ( a.d > b.d ) return -1;
		return 1;
	}
	
	
	
	
	public function slice(a:Float, b:Float) {
		var start = insertPointOnCirc(a);
		var end = 	insertPointOnCirc(b);
		return spliceInTwo( start, end );
	}
	
	public function spliceInTwo(start:PolPoint,end:PolPoint) {
		var pol = new Polygon();
		var p = start;
		
		while(true) {
			pol.pushPoint(p.x, p.y);
			if( p == end ) break;
			p = p.next;
		}
		
		start.next = end;
		majPoint(start);
		first = start;
		
		
		return pol;
	}
	
	public function draw(mc:flash.display.Sprite, dx=0.0, dy=0.0) {
		var p = first;
		mc.graphics.moveTo( p.x+dx, p.y+dy );
		while(true){
			p = p.next;
			mc.graphics.lineTo(p.x+dx, p.y+dy);
			if( p == first ) break;
		}
	}
	

	public function getCenter() {
		var box = getBox();
		return {
			x: box.x + box.width * 0.5,
			y: box.y + box.height * 0.5,
		}
		
	}
	
	public function getBox() {
		var rect = new flash.geom.Rectangle();
		rect.left = 9999;
		rect.top = 9999;
		rect.right = -9999;
		rect.bottom = -9999;
		
		var p = first;
		while( true ) {
			rect.left = Math.min( p.x, rect.left );
			rect.top = Math.min( p.y, rect.top );
			rect.right = Math.max( p.x, rect.right );
			rect.bottom = Math.max( p.y, rect.bottom );
			p = p.next;
			if( p == first ) break;
		}
		return rect;
		
	}
	

	
	
	public function traceIn( mc:flash.display.Sprite, ?color, pray=2, pcol=0x0000FF ) {
		if( first == null ) return;
		if( color == null ) color = Std.random(0xFFFFFF);// Col.shuffle(0xFF0000, 150);
		var gfx = mc.graphics;
		
		// SHAPE
		gfx.beginFill(color);
		draw(mc);
		gfx.endFill();
		
		// POINTS
		var p = first;
		while( true ) {
			gfx.beginFill(pcol);
			gfx.drawCircle(p.x, p.y, pray);
			gfx.endFill();
			p = p.next;
			if( p == first ) break;
		}
		
	}
	
}