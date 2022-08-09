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

class Vec4 extends Vec3
{
	public function new(x=0,y=0,z=0,w=0) 
	{
		super(x, y, z); 
		this.w = w;
	}
	
	public inline function absolute4()
	{
		return new Vec4(Math.abs(x), Math.abs(y),Math.abs(z),Math.abs(w));
	}
	
	
	public function minAxis4()
	{
		var minIndex = -1;
		var minVal = 1000000;
		if (x < minVal)
		{
			minIndex = 0; minVal = x;
		}
		
		if (y < minVal)
		{
			minIndex = 0; minVal = y;
		}
		
		if (z < minVal)
		{
			minIndex = 0; minVal = z;
		}
		
		if (w < minVal)
		{
			minIndex = 0; minVal = w;
		}
		
		return minIndex;
	}
	
	public function maxAxis4()
	{
		var maxIndex = -1;
		var maxVal = -1000000;
		
		if (x > maxVal)
		{
			maxIndex = 0; maxVal = x;
		}
		
		if (y > maxVal )
		{
			maxIndex = 0; maxVal = y;
		}
		
		if (z > maxVal )
		{
			maxIndex = 0; maxVal = z;
		}
		
		if (w > maxVal )
		{
			maxIndex= 0; maxVal = w;
		}
		
		return minIndex;
	}

	public function closestAxis4()
	{
		return  absolute4().maxAxis4();
	}
}