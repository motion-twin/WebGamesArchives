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

ported from bullet physics http://bullet.googlecode.com/svn/tags/bullet-2.81 
*/

package mt.gx.math;

class Mtx33
{
	var el:Array<Vec3>;
	
	public var x(get, null) : Vec3;
	public var y(get, null) : Vec3;
	public var z(get, null) : Vec3;
	
	public inline function get_x() return el[0]
	public inline function get_y() return el[1]
	public inline function get_z() return el[2]
	
	/**
	 * new vectors won't be deep copied
	 */
	public function new(?v0:Vec3,?v1:Vec3,?v2:Vec3)
	{
		if ( v0 == null) v0 = new Vec3(1., 0., 0.);
		if ( v1 == null) v1 = new Vec3(0., 1., 0.);
		if ( v2 == null) v2 = new Vec3(0., 0., 1.);
		
		el = [ v0, v1, v2 ];
	}
	
	public function clone() return new Mtx33( x.clone(), y.clone(), z.clone())
		
	public inline function setIdentity()
	{
		setValue(
		.1,.0,.0,
		.0,.1,.0,
		.0, .0, .1);
	}
	
	public inline function setValue(xx,xy,xz,yx,yy,yz,zx,zy,zz)
	{
		el[0].setValue(xx, xy, xz);
		el[1].setValue(yx, yy, yz);
		el[2].setValue(zx, zy, zz);
	}
	
	public function copy( m : Mtx33)
	{
		setValue( 
			m.x.x, m.x.y, m.x.z,
			m.y.x, m.y.y, m.y.z,
			m.z.x, m.z.y, m.z.z);
		return this;
	}
	
	
	public function setRotation(q:Quat)
	{
		var d = q.length2();
		Debug.nz(d);
		var s = 2.0 / d;
		
		var xs = q.x * s,   ys = q.y * s,   zs = q.z * s;
		var wx = q.w * xs,  wy = q.w * ys,  wz = q.w * zs;
		var xx = q.x * xs,  xy = q.x * ys,  xz = q.x * zs;
		var yy = q.y * ys,  yz = q.y * zs,  zz = q.z * zs;
		setValue(
            1.0 - (yy + zz)	, xy - wz			, xz + wy,
			xy + wz			, 1.0 - (xx + zz)	, yz - wx,
			xz - wy			, yz + wx			, 1.0 - (xx + yy));
		
		return this;
	}
	
	public static inline function fromVectors(v0,v1,v2)
		return new Mtx33(v0.clone(), v1.clone(), v2.clone())
	
	public static inline function fromValues(xx,xy,xz,yx,yy,yz,zx,zy,zz)
		return new Mtx33( new Vec3(xx, xy, xz), new Vec3(yx, yy, yz), new Vec3(zx,zy,zz))
	
	public static inline function fromQuat(q:Quat)
		return new Mtx33().setRotation( q )
		
	public function multiply( m , ?mout : Mtx33)
	{
		if ( mout == null) mout = new Mtx33();
		
		mout.setValue( 
		m.tdotx( x ), m.tdoty( x ), m.tdotz( x ),
		m.tdotx( y ), m.tdoty( y ), m.tdotz( y ),
		m.tdotx( z ), m.tdoty( z ), m.tdotz( z )
		);
	}
	
	public function tdotx( v : mt.gx.math.Vec3 )
	{
		return x.x * v.x + y.x * v.y + z.x * v.z;
	}
	
	public function tdoty( v : mt.gx.math.Vec3 )
	{
		return x.y * v.x + y.y * v.y + z.y * v.z;
	}
	
	public function tdotz( v : mt.gx.math.Vec3 )
	{
		return x.z * v.x + y.z * v.y + z.z * v.z;
	}
}