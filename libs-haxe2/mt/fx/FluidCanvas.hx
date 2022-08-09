package mt.fx;
import mt.bumdum9.Lib;


private typedef Cell = {
	x:Int, y:Int,
	u:Float, v:Float,
	r:Float, g:Float, b:Float,
	ou:Float, ov:Float,
	or:Float, og:Float, ob:Float
};


class FluidCanvas extends Fx{//}

	static var DIR  = [[1, 0], [1, 1], [0, 1], [ -1, 1], [ -1, 0], [ -1, -1], [0, -1], [1, -1]];
	static var AT = 0.25;
	
	public var warp_x:Bool;
	public var warp_y:Bool;
	public var colors:Bool;
	
	var width:Float;
	var height:Float;
	var res:Float;
	
	public var visc:Float;
	public var iter:Int;
	
	public var xmax:Int;
	public var ymax:Int;
	var xmax2:Int;
	var ymax2:Int;
	var cmax:Int;
	var icmax:Float;
	
	//
	var u:Array<Float>;
	var v:Array<Float>;
	
	var r:Array<Float>;
	var g:Array<Float>;
	var b:Array<Float>;
	
	var uOld:Array<Float>;
	var vOld:Array<Float>;
	
	var rOld:Array<Float>;
	var gOld:Array<Float>;
	var bOld:Array<Float>;
	
	var curlAbs:Array<Float>;
	var curlOrig:Array<Float>;

	var dt:Float;
	//
	var avgDensity:Float;
	var avgSpeed:Float;
	var uniformity:Float;
	
	// COLOR
	public var fadeSpeed:Float;
	public var colorDiffusion:Float;
	
	var grid:Array<Array<Cell>>;
	var cells:Array<Cell>;
	

	public function new(ww, hh, resolution = 10.0 ) {
		width = ww;
		height = hh;
		res = resolution;
		super();
	
		fadeSpeed = 0.3;
		visc = 0.0001;
		
		
		dt = 1;
		iter = 10;
		warp_x = false;
		warp_y = false;
		
		xmax = Math.ceil(ww / resolution);
		ymax = Math.ceil(hh / resolution);
		xmax2 = xmax + 2;
		ymax2 = ymax + 2;
		
		u = [];
		v = [];
		uOld = [];
		vOld = [];
		
		curlAbs = [];
		curlOrig = [];
		
		cmax = xmax2 * ymax2;
		icmax = 1 / cmax;
		
		// GRID
		for( i in 0...cmax ) {
			u[i] = v[i] = uOld[i] = vOld[i] = 0.0;
			curlAbs[i] = curlOrig[i] = 0;
		}
		
	}
	
	public function initColors(colorDiffusion=0.0) {
		colors = true;
		this.colorDiffusion = colorDiffusion;
		
		r = [];
		g = [];
		b = [];

		rOld = [];
		gOld = [];
		bOld = [];
		
		// GRID
		for( i in 0...cmax ) r[i] = g[i] = b[i] = rOld[i] = gOld[i] = bOld[i] = 0;

	}
	
	override function update() {
		
		addSourceUV();

		// VORTICITY HERE
		calcVorticity(uOld, vOld);
		
		swapUV();
		diffuseUV(visc);
		project(u, v, uOld, vOld);

		swapUV();
        advect(1, u, uOld, uOld, vOld);
        advect(2, v, vOld, uOld, vOld);
		project(u, v, uOld, vOld);
		
		// !IS RGB
		if( colors ) {
			
			addSourceRGB();
			swapRGB();
			
			
			if( colorDiffusion != 0 && dt != 0 ) {
				diffuseRGB(colorDiffusion);
				swapRGB();
			}
			
			advectRGB(u, v);

			fadeRGB();
			
		
		}
		
	}
	
	function addSource(x:Array<Float>, x0:Array<Float>) {
		for( i in 0...cmax ) x[i] += dt * x0[i];

	}
	
	function addSourceUV() {
		for(i in 0...cmax) {
			u[i] += uOld[i]*dt;
			v[i] += vOld[i]*dt;
		}
	}

	function swapUV() {
		
		
		var tmp = u;
		u = uOld;
		uOld = tmp;
		
		var tmp = v;
		v = vOld;
		vOld = tmp;
		
	
	}

	function diffuseUV(diff:Float) {
		var a = dt * diff * xmax * ymax;
		linearSolverUV(a, 1.0 + 4 * a);
	}

	function linearSolverUV(a:Float, c:Float) {
		
			var index = 0;
			c = 1 / c;
			
			//*
			for (k in  0...iter ) {
				index = getIndex(1, 1);
				for (j in 0...ymax ) {
					for( i in 0...xmax) {
						u[index] = ( ( u[index-1] + u[index+1] + u[index - xmax2] + u[index + xmax2] ) * a  +  uOld[index] ) * c;
						v[index] = ( ( v[index - 1] + v[index + 1] + v[index - xmax2] + v[index + xmax2] ) * a  +  vOld[index] ) * c;
						index++;
					}
					index += 2;
				}
				setBoundary( 1, u );
				setBoundary( 2, v );
			}

			
	}
	
	function setBoundary(bound:Int, x:Array<Float> ) {
			
		var step = getIndex(0, 1) - getIndex(0, 0);
		
		
		// --- X ---
		var dst1 = getIndex(0, 1);
		var src1 = getIndex(1, 1);
		var dst2 = getIndex(xmax+1, 1 );
		var src2 = getIndex(xmax, 1);

		if( warp_x ) {
			src1 ^= src2;
			src2 ^= src1;
			src1 ^= src2;

		}
		if( bound == 1 && !warp_x ) {
			for (i in 0...ymax ) {
				x[dst1] = -x[src1];     dst1 += step;   src1 += step;
				x[dst2] = -x[src2];     dst2 += step;   src2 += step;
			}
		}else{
			for (i in 0...ymax ){
				x[dst1] = x[src1];      dst1 += step;   src1 += step;
				x[dst2] = x[src2];      dst2 += step;   src2 += step;

			}
		}

		// --- Y ---
		dst1 = getIndex(1, 0);
		src1 = getIndex(1, 1);
		dst2 = getIndex(1, ymax+1);
		src2 = getIndex(1, ymax);
		
		if( warp_y ) {
			src1 ^= src2;
			src2 ^= src1;
			src1 ^= src2;
		}
		if( bound == 2 && !warp_y ) {
			for (i in 0...xmax ){
				x[dst1++] = -x[src1++];
				x[dst2++] = -x[src2++];
			}
		} else {
			for (i in 0...xmax ){
				x[dst1++] = x[src1++];
				x[dst2++] = x[src2++];
			}
		}

		x[getIndex(0,0)] = 				0.5 * (x[getIndex(1, 0  )] + x[getIndex(  0, 1)]);
		x[getIndex(0,ymax+1)] = 		0.5 * (x[getIndex(1, ymax+1)] + x[getIndex(  0, ymax)]);
		x[getIndex(xmax+1, 0)] = 		0.5 * (x[getIndex(xmax, 0  )] + x[getIndex(xmax+1, 1)]);
		x[getIndex(xmax+1, ymax+1)] = 	0.5 * (x[getIndex(xmax, ymax+1)] + x[getIndex(xmax+1, ymax)]);

	}
		
	function project(x:Array<Float>, y:Array<Float>, p:Array<Float>, div:Array<Float>) {
		

		var index = 0;
		var h = -0.5 / xmax;

		index = getIndex(1, 1);
		for ( j in 0...ymax ){
			for ( i in 0...xmax ) {
				div[index] = h * ( x[index+1] - x[index-1] + y[index+xmax2] - y[index-xmax2] );
				p[index] = 0;
				index++;
			}
			index+=2;
		}

		setBoundary(0, div);
		setBoundary(0, p);

		linearSolver(0, p, div, 1, 4);

		var fx = 0.5 * xmax;
		var fy = 0.5 * ymax;
		index = getIndex(1, 1);
		for (j in 0...ymax)	{
			for (i in 0...xmax) {
				x[index] -= fx * (p[index+1] - p[index-1]);
				y[index] -= fy * (p[index + xmax2] - p[index - xmax2]);
				index++;
			}
			index += 2;
		}

		setBoundary(1, x);
		setBoundary(2, y);
	}

	function linearSolver(b:Int, x:Array<Float>, x0:Array<Float>, a:Float, c:Float){
		var index = 0;

		if( a == 1 && c == 4 ) {
			for ( k in 0...iter) {
				index = getIndex(1,1);
				for ( j in 0...ymax){
					for (i in 0...xmax ) {
						x[index] = ( x[index - 1] + x[index + 1] + x[index - xmax2] + x[index + xmax2] + x0[index] ) * .25;
						index++;
					}
					index += 2;
				}
				setBoundary( b, x );
			}
		}
		else
		{
			c = 1 / c;
			for ( k in 0...iter) {
				index = getIndex(1, 1);
				for ( j in 0...ymax){
					for (i in 0...xmax ) {
						x[index] = ( ( x[index - 1] + x[index + 1] + x[index - xmax2] + x[index + xmax2] ) * a + x0[index] ) * c;
						index ++;
					}
					index += 2;
				}
				setBoundary( b, x );
			}
		}
	}
	
	function advect( b:Int, _d:Array<Float>, d0:Array<Float>, du:Array<Float>, dv:Array<Float>) {
		
		var i0 = 0;
		var j0 = 0;
		var i1 = 0;
		var j1 = 0;
		var index = 0;
		
		var x = 0.0;
		var y = 0.0;
		var s0 = 0.0;
		var t0 = 0.0;
		var s1 = 0.0;
		var t1 = 0.0;
		
		var dt0x = dt * xmax;
		var dt0y = dt * ymax;

		index = getIndex(1, 1);
		for ( j in 0...ymax ) {
			for ( i in 0...xmax) {
				
				x = (i+1) - dt0x * du[index];
				y = (j+1) - dt0y * dv[index];

				if (x > xmax + 0.5) x = xmax + 0.5;
				if (x < 0.5) x = 0.5;

				i0 = Std.int(x);
				i1 = i0 + 1;

				if (y > ymax + 0.5) y = ymax + 0.5;
				if (y < 0.5) y = 0.5;

				j0 = Std.int(y);
				j1 = j0 + 1;

				s1 = x - i0;
				s0 = 1 - s1;
				t1 = y - j0;
				t0 = 1 - t1;

				_d[index] = s0 * (t0 * d0[getIndex(i0, j0)] + t1 * d0[getIndex(i0, j1)]) + s1 * (t0 * d0[getIndex(i1, j0)] + t1 * d0[getIndex(i1, j1)]);
				index++;
			}
			index += 2;
		}
		setBoundary(b, _d);
	}

	function calcVorticity(_x:Array<Float>,_y:Array<Float>) {
		
		var dw_dx = 0.0;
		var dw_dy = 0.0;
		var length = 0.0;
		var index = 0;
		var vv = 0.0;

		// Calculate magnitude of (u,v) for each cell. (|w|)
		index = getIndex(1, 1);
		for (j in 0...ymax ){
			for (i in 0...xmax) {
				dw_dy = u[Std.int(index + xmax2)] - u[Std.int(index - xmax2)];
				dw_dx = v[Std.int(index + 1)] - v[Std.int(index - 1)];
				vv = (dw_dy - dw_dx) * .5;
				curlOrig[ index ] = vv;
				curlAbs[ index ] = vv < 0 ? -vv : vv;
				index++;
			}
			index+=2;
		}

		for (j in 0...ymax-2 ){
			for (i in 0...xmax - 2) {
				index = getIndex(i + 2, j + 2);
				
				dw_dx = curlAbs[Std.int(index + 1)] - curlAbs[Std.int(index - 1)];
				dw_dy = curlAbs[Std.int(index + xmax2)] - curlAbs[Std.int(index - xmax2)];

				length = Math.sqrt(dw_dx * dw_dx + dw_dy * dw_dy) + 0.000001;

				length = 2 / length;
				dw_dx *= length;
				dw_dy *= length;

				vv = curlOrig[ index ];

				_x[ index ] = dw_dy * -vv;
				_y[ index ] = dw_dx * vv;


			}
		}
	}
	
	// RGB
	function addSourceRGB() {
		for( i in 0...cmax ) {
			r[i] += dt * rOld[i];
			g[i] += dt * gOld[i];
			b[i] += dt * bOld[i];
		}
	}
	
	function swapRGB() {
		var tmp = r;
		r = rOld;
		rOld = tmp;
		
		var tmp = g;
		g = gOld;
		gOld = tmp;
		
		var tmp = b;
		b = bOld;
		bOld = tmp;
	}
	
	function diffuseRGB(diff:Float) {
		var a = dt * diff * xmax * ymax;
		linearSolverRGB(a, 1.0 + 4 * a);
	}
	
	function linearSolverRGB(a:Float, c:Float) {
		
			var index = 0;
			c = 1 / c;
			

			for (k in  0...iter ) {
				for (j in 0...ymax ) {
					for( i in 0...xmax) {
						index = getIndex(i+1, j+1);
						r[index] = ( ( r[index-1] + r[index+1] + r[index - xmax2] + r[index + xmax2] ) * a  +  rOld[index] ) * c;
						g[index] = ( ( g[index-1] + g[index+1] + g[index - xmax2] + g[index + xmax2] ) * a  +  gOld[index] ) * c;
						b[index] = ( ( b[index-1] + b[index+1] + b[index - xmax2] + b[index + xmax2] ) * a  +  bOld[index] ) * c;
					}
				}
				setBoundary( 1, u );
				setBoundary( 2, v );
			}
			
		
	}
	
	function advectRGB(du:Array<Float>, dv:Array<Float>) {
		
		var i0:Null<Int> = 0;
		var j0 = 0;
		var i1 = 0;
		var j1 = 0;
		var index = 0;
		
		var x = 0.0;
		var y = 0.0;
		var s0 = 0.0;
		var t0 = 0.0;
		var s1 = 0.0;
		var t1 = 0.0;

		var dt0x = dt * xmax;
		var dt0y = dt * ymax;

		for ( j in 0...ymax ) {
			for ( i in 0...xmax) {
				index = getIndex(i + 1, j + 1);
				
				x = (i+1) - dt0x * du[index];
				y = (j+1) - dt0y * dv[index];

				if (x > xmax + 0.5) x = xmax + 0.5;
				if (x < 0.5)     x = 0.5;

				i0 = Std.int(x);

				if (y > ymax + 0.5) y = ymax + 0.5;
				if (y < 0.5)     y = 0.5;

				j0 = Std.int(y);

				s1 = x - i0;
				s0 = 1 - s1;
				t1 = y - j0;
				t0 = 1 - t1;


				i0 = getIndex(i0, j0);
				j0 = i0 + xmax2;
				//checkIndex(i0);
				//checkIndex(j0);
				
				r[index] = s0 * ( t0 * rOld[i0] + t1 * rOld[j0] ) + s1 * ( t0 * rOld[Std.int(i0+1)] + t1 * rOld[Std.int(j0+1)] );
				g[index] = s0 * ( t0 * gOld[i0] + t1 * gOld[j0] ) + s1 * ( t0 * gOld[Std.int(i0+1)] + t1 * gOld[Std.int(j0+1)] );
				b[index] = s0 * ( t0 * bOld[i0] + t1 * bOld[j0] ) + s1 * ( t0 * bOld[Std.int(i0+1)] + t1 * bOld[Std.int(j0+1)] );
			}
		}
		setBoundaryRGB();
	}
	
	function setBoundaryRGB() {
			
		if( !warp_x && !warp_y ) return;
		
		var dst1 = 0;
		var dst2 = 0;
		var src1 = 0;
		var src2 = 0;
		var step = getIndex(0, 1) - getIndex(0, 0);
	
		if ( warp_x ) {
			dst1 = getIndex(0, 1);
			src1 = getIndex(1, 1);
			dst2 = getIndex(xmax+1, 1 );
			src2 = getIndex(xmax, 1);
		
			src1 ^= src2;
			src2 ^= src1;
			src1 ^= src2;
		
			for (i in 0...ymax)	{
				r[dst1] = r[src1]; g[dst1] = g[src1]; b[dst1] = b[src1]; dst1 += step;   src1 += step;
				r[dst2] = r[src2]; g[dst2] = g[src2]; b[dst2] = b[src2]; dst2 += step;   src2 += step;
			}
		}
	
		if ( warp_y ) {
			dst1 = getIndex(1, 0);
			src1 = getIndex(1, 1);
			dst2 = getIndex(1, ymax+1);
			src2 = getIndex(1, ymax);
		
			src1 ^= src2;
			src2 ^= src1;
			src1 ^= src2;
		
			for (i in 0...xmax ){
				r[dst1] = r[src1]; g[dst1] = g[src1]; b[dst1] = b[src1];  ++dst1; ++src1;
				r[dst2] = r[src2]; g[dst2] = g[src2]; b[dst2] = b[src2];  ++dst2; ++src2;
			}
		}
	}
	
    function fadeRGB(){
		var holdAmount = 1 - fadeSpeed;

		avgDensity = 0;
		avgSpeed = 0;

		var totalDeviations = 0.0;
		var currentDeviation:Float;
		var density:Float;

		var tmp_r:Float;
		var tmp_g:Float;
		var tmp_b:Float;

		var i = cmax;
		while ( --i > -1 ) {
				// clear old values
				uOld[i] = vOld[i] = 0;
				rOld[i] = 0;
				gOld[i] = bOld[i] = 0;

				// calc avg speed
				avgSpeed += u[i] * u[i] + v[i] * v[i];

				// calc avg density
				tmp_r = Math.min(1.0, r[i]);
				tmp_g = Math.min(1.0, g[i]);
				tmp_b = Math.min(1.0, b[i]);

				density = Math.max(tmp_r, Math.max(tmp_g, tmp_b));
				avgDensity += density; // add it up

				// calc deviation (for uniformity)
				currentDeviation = density - avgDensity;
				totalDeviations += currentDeviation * currentDeviation;

				// fade out old
				r[i] = tmp_r * holdAmount;
				g[i] = tmp_g * holdAmount;
				b[i] = tmp_b * holdAmount;

		}

		avgDensity *= icmax;
		avgSpeed *= icmax;
		uniformity = 1.0 / (1 + totalDeviations * icmax);               // 0: very wide distribution, 1: very uniform
	}
	
	// OUT
	function fadeR() {
		var holdAmount = 1 - fadeSpeed;

		avgDensity = 0;
		avgSpeed = 0;

		var totalDeviations:Float = 0;
		var currentDeviation:Float;
		var tmp_r:Float;

		var i = cmax;
		while ( --i > -1 ) {
			
				// clear old values
				uOld[i] = vOld[i] = 0;
				rOld[i] = 0;

				// calc avg speed
				avgSpeed += u[i] * u[i] + v[i] * v[i];

				// calc avg density
				tmp_r = Math.min(1.0, r[i]);
				avgDensity += tmp_r;   // add it up

				// calc deviation (for uniformity)
				currentDeviation = tmp_r - avgDensity;
				totalDeviations += currentDeviation * currentDeviation;

				// fade out old
				r[i] = tmp_r * holdAmount;
		}
		
		avgDensity *= icmax;
		uniformity = 1.0 / (1 + totalDeviations * icmax);               // 0: very wide distribution, 1: very uniform
	}
	
	// TOOLS
	inline function getIndex(x, y) {
		return x + y * xmax2;
	}
		
	// DEBUG
	function checkIndex(i) {
		if( i < 0 || i >= cmax ) trace("error index:" + i);
	}
	
	// ADD
	public function addForce(x:Float, y:Float, vx:Float, vy:Float) {
		var index = getIndex( Std.int(x/res)+1, Std.int(y/res)+1 );
		if( index < 0 || index >= cmax ) return;
        uOld[index] += vx;
        vOld[index] += vy;
	}
	
	public function addColor(x:Float, y:Float, color:Int) {
		var index = getIndex( Std.int(x/res)+1, Std.int(y/res)+1 );
		if( index < 0 || index >= cmax ) return;

		var o = Col.colToObj( color );
		var colorMult = 1 / 0xFF;
		rOld[index]  += o.r * colorMult;
		gOld[index]  += o.g * colorMult;
		bOld[index]  += o.b * colorMult;
	}
	
	
	
	// GET
	public function getForce(x:Float, y:Float) {
		var index = getIndex( Std.int(x / res)+1, Std.int(y / res)+1 );
		if( index < 0 || index >= cmax ) return null;
		return {
			x : u[index],
			y : v[index],
		}
	}
	
	public function drawBmp(bmp:flash.display.BitmapData) {
	
		var d = 0xFF;
		
		bmp.lock();
		for( x in 0...xmax) {
			for( y in 0...ymax) {
				var index = getIndex(x + 1, y + 1);

				var col = (Std.int(r[index] * d) << 16) | (Std.int(g[index] * d) << 8) | Std.int(b[index] * d);
				bmp.setPixel(x, y, col);
				//bmp.setVector();
				
				
				
				
				//if( x == 0 && y == 0) trace(r[index]);
			}
		}
		bmp.unlock();
		
		bmp.applyFilter(bmp, bmp.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(2,2,2) );
		
	}
	
	
//{
}










