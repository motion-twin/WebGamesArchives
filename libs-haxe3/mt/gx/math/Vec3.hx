/*
Copyright (c) 2003-2006 Gino van den Bergen / Erwin Coumans  http://continuousphysics.com/Bullet/

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, 
including commercial applications, and to alter it and redistribute it freely, 
subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

ported from bullet physics http://bullet.googlecode.com/svn/tags/bullet-2.81 to haxe 
*/

package mt.gx.math;

class Vec3 extends QuadFloat
{
	public inline function new(x=.0,y=.0,z=.0)
		super(x, y, z);
	
	//one liner newing op here
	public inline function absolute()			return new Vec3(Math.abs(x), Math.abs(y), Math.abs(z) );
	
	//ip stands for inplace, meaning no new vec is emitted
	public inline  function incr(v:Vec3)
	{
		x += v.x;  y += v.y; z += v.z;
		return this;
	}
	
	public inline  function decr(v:Vec3)
	{
		x -= v.x;  y -= v.y; z -= v.z;
		return this;
	}
	
	public inline function scaleF(v:Float)
	{
		x *= v; y *= v; z *= v;
		return this;
	}
	
	public inline function scaleComps(v:Vec3)
	{
		x *= v.x; y *= v.y; z *= v.z;
		return this;
	}
	
	public inline function divF(v:Float)
	{
		var f = 1.0 / v;
		return scaleF(f);
	}
	
	public inline function incr4(x,y=0,z=0,w=0) {
		this.x += x;
		this.y += y;
		this.z += z;
		this.w += w;
		return this;
	}
	
	public inline function mul(v:Vec3)			return new Vec3(v.x * x, v.y * y, v.z * z);
	public inline function div(v:Vec3)			return new Vec3(v.x / x, v.y / y, v.z / z);
	
	public inline function add(v:Vec3)			return new Vec3(v.x + x, v.y + y, v.z + z);
	public inline function sub(v:Vec3)			return new Vec3(x - v.x, y - v.y, z - v.z);
	
	
	inline function minus(v:Vec3)				return sub(v);
	
	public inline function mulScalar(f:Float)	return new Vec3(x * f, y * f, z * f);
	public inline function divScalar(f:Float)	return mulScalar(1.0 / f);
	
	//math commoners
	public inline function dot(v:Vec3)			return x * v.x + y * v.y + z * v.z;
	public inline function dot3(v0, v1, v2)		return new Vec3( dot(v0), dot(v1), dot(v2));
	
	public inline function length2()			return dot(this);
	public inline function length()				return Math.sqrt(dot(this));
	public inline function fuzzyZero()			return length2() < 1e-6;
	
	public inline function normalize()			return this.scaleF(1.0/length());
	public inline function normalized()			return this.divScalar(length());

	public inline function safeNormalize()
	{
		var abs = absolute();
		var maxIndex = abs.maxAxis();
		if ( abs.el[maxIndex] > 0)
		{
			divF( abs.el[maxIndex] );
			return divF( length() );
		}
		set(1, 0, 0);
		return this;
	}
	
	public inline function angle(v:Vec3)
	{
		var s = Math.sqrt( length2() * v.length2() );
		mt.Assert.notZero(s);
		return Math.acos( dot(v) / s );
	}
	
	public inline function maxAxis()
		return (x < y) ? (y < z?2:1) : (x < z?2:0);
		
	public inline function minAxis()
		return (x < y) ? (x < z?0:2) : (y < z?1:2);
		
	public inline function closesAxis()			return absolute().minAxis();
	public inline function furthestAxis()		return absolute().maxAxis();
	
	//axis must be a unit lenght vector
	public inline function rotate( axis:Vec3, angle:Float){
		var o = axis.mulScalar( axis.dot(this));
		var x = this.minus( o );
		var y = axis.cross( this);
		
		o.incr( x.mulScalar( Math.cos( angle ) ) );
		o.incr( y.mulScalar( Math.sin( angle ) ) );
		
		return o;
	}
	
	public inline function cross(v:Vec3){
		return new Vec3(
			y * v.z - z * v.y,
			z * v.x - x * v.z,
			x * v.y - y * v.x );
	}
	
	public inline function triple(v1:Vec3, v2:Vec3){
		return 	x * (v1.y * v2.z - v1.z * v2.y)
			+	y * (v1.z * v2.x - v1.x * v2.z)
			+ 	z * (v1.x * v2.y - v1.y * v2.x);
	}
			
	public inline function isEq(v:Vec3) return x == v.x && y == v.y && z == v.z && w == v.w;
	public inline function isNear(v:Vec3, t : Float = 0.01) return dist2(v) <= t * t;
	
	public inline function iNEq(v)
		return !isEq(v);
		
	public inline function setMax(v){
		x = Math.max(x, v.x);
		y = Math.max(y, v.y);
		z = Math.max(z, v.z);
		w = Math.max(w, v.w);
	}
	
	public inline function setMin(v){
		x = Math.min(x, v.x);
		y = Math.min(y, v.y);
		z = Math.min(z, v.z);
		w = Math.min(w, v.w);
	}
	
	public inline function getSkewSymmetricMatrix(v0:Vec3,v1:Vec3,v2:Vec3)
	{
		v0.set(0.0, -z, y);
		v1.set(z, 0.0, -x);
		v2.set(-y, x, 0.0);
	}
	
	public inline function clone()
		return new Vec3(x, y, z);
		
	public inline function copy(v:Vec3)
	{
		x = v.x;
		y = v.y;
		z = v.z;
	}
	
	public inline function splat(v) {
		x = y = z = v;
		return this;
	}
	
	public inline function setZero()				x = y = z = w  = 0;
	public inline function isZero()					return x == 0 && y == 0 && z == 0;
		
	public function minDot( arr:Array<Vec3>, out : { dot:Float } ) : Int
	{
		var minDot = Math.POSITIVE_INFINITY;
		var ptIndex = -1;
		
		for( i in 0...arr.length)
		{
			var dot = arr[i].dot(this);
			if (dot < minDot)
			{
				minDot = dot;
				ptIndex = i;
			}
		}
		
		out.dot = minDot;
		return ptIndex;
	}
	
	public function maxDot( arr:Array<Vec3>, out : { dot:Float } ) : Int
	{
		var maxDot = Math.NEGATIVE_INFINITY;
		var ptIndex = -1;
		for( i in 0...arr.length)
		{
			var dot = arr[i].dot(this);
			if (dot > maxDot)
			{
				maxDot = dot;
				ptIndex = i;
			}
		}
		
		out.dot = maxDot;
		return ptIndex;
	}
	
	public inline function one() {
		w = z= x = y = 1.0;
	}
	
	public inline function zero() {
		w = z= x = y = 0.0;
	}
	
	public inline function dist2( v : Vec3) {
		var dx = v.x - x;
		var dy = v.y - y;
		var dz = v.z - z;
		return dx * dx + dy * dy + dz * dz;
	}
	
	public inline function dist( v : Vec3) {
		return Math.sqrt(dist2(v));
	}
	
	public inline function toString() {
		return 'Vec3{ x:$x y:$y z:$z }';
	}
	public static var ZERO = new Vec3(0, 0, 0);
	
}