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
import haxe.ds.Vector.Vector;

class QuadFloat
{
	public var el : Vector<Float>;
	
	public inline function new(x=.0,y=.0,z=.0,w=.0)
	{
		el = new Vector(4);
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function fromArray(a:Array<Float>)
	{
		Assert.isTrue(a.length >= 4);
		for ( i in 0...4) el[i] = a[i];
	}
	
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var w(get, set):Float;
	
	public inline function get_x() return el[0];
	public inline function get_y() return el[1];
	public inline function get_z() return el[2];
	public inline function get_w() return el[3];
	
	public inline function set_x(v) return el[0]=v;
	public inline function set_y(v) return el[1]=v;
	public inline function set_z(v) return el[2]=v;
	public inline function set_w(v) return el[3]=v;
	
	/**
	 * previously called setValue
	 */
	public inline function set(x=0.0,y=0.0,z=0.0,w=0.0)
	{
		this.x = x; this.y = y; this.z = z; this.w=w;
	}
}