package mt.heaps;

class GraphicsExtender {
	static public function drawRing( g : h2d.Graphics, cx : Float, cy : Float, innerRay : Float, outerRay : Float, nsegments = 0 ) {
		g.flush();
		if( nsegments == 0 )
			nsegments = Math.ceil(outerRay * 3.14 * 2 / 4);
		if( nsegments < 3 ) nsegments = 3;
		var angle = Math.PI * 2 / (nsegments - 1);
		for( i in 0...nsegments ) {
			var a = i * angle;
			g.addPoint(cx + Math.cos(a) * outerRay, cy + Math.sin(a) * outerRay);
		}
		for( i in 0...nsegments ) {
			var a = (nsegments - i - 1) * angle;
			g.addPoint(cx + Math.cos(a) * innerRay, cy + Math.sin(a) * innerRay);
		}
		g.flush();
	}

	static public function drawRingPie( g : h2d.Graphics, cx : Float, cy : Float, innerRay : Float, outerRay : Float, angleStart:Float, angleLength:Float, nsegments = 0 ) {
		g.flush();
		if( nsegments == 0 )
			nsegments = Math.ceil(outerRay * angleLength / 4);
		if( nsegments < 3 ) nsegments = 3;
		var angle = angleLength / (nsegments - 1);
		for( i in 0...nsegments ) {
			var a = i * angle + angleStart;
			g.addPoint(cx + Math.cos(a) * outerRay, cy + Math.sin(a) * outerRay);
		}
		for( i in 0...nsegments ) {
			var a = (nsegments - i - 1) * angle + angleStart;
			g.addPoint(cx + Math.cos(a) * innerRay, cy + Math.sin(a) * innerRay);
		}
		g.flush();
	}
}