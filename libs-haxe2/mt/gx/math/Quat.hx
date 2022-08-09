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

class Quat extends QuadFloat
{
	public static inline function fromAxisAngle(axis:Vec3,angle:Float)
	{
		var q = new Quat();
		q.setRotation(axis, angle);
		return q;
	}
	
	public inline function setRotation(axis:Vec3, angle:Float)
	{
		var d = axis.length();
		Debug.nz(d);
		var s = Math.sin( angle * 0.5 ) / d;
		setValue(axis.x * s, axis.y * s, axis.z * s, Math.cos(angle*0.5) );
	}
	
	/*
	* @param yaw Angle around Y
	* @param pitch Angle around X
	* @param roll Angle around Z 
	* */
	public inline function setEuler(yaw:Float,pitch:Float,roll:Float)
	{
		var halfYaw = yaw*0.5;
		var halfPitch = pitch*0.5;
		var halfRoll = roll*0.5;
		var cosYaw = Math.cos( halfYaw );
		var sinYaw = Math.sin( halfYaw );
		var cosRoll = Math.cos( halfRoll );
		var sinRoll = Math.sin( halfRoll );
		var cosPitch = Math.cos( halfPitch );
		var sinPitch = Math.sin( halfPitch );
		
		setValue( 
			cosRoll * sinPitch * cosYaw 	+	sinRoll * cosPitch * sinYaw, 
			cosRoll * cosPitch * sinYaw 	-	sinRoll * sinPitch * cosYaw,
			sinRoll * cosPitch * cosYaw 	-	cosRoll * sinPitch * sinYaw,
			cosRoll * cosPitch * cosYaw 	+	sinRoll * sinPitch * sinYaw );
	}
	
	/*
	* * @param yaw Angle around Z
	* @param pitch Angle around Y
	* @param roll Angle around X 
	*/
	public inline function setEulerZYX(yaw:Float,pitch:Float,roll:Float)
	{
		var halfYaw = yaw*0.5;
		var halfPitch = pitch*0.5;
		var halfRoll = roll*0.5;
		var cosYaw = Math.cos( halfYaw );
		var sinYaw = Math.sin( halfYaw );
		var cosRoll = Math.cos( halfRoll );
		var sinRoll = Math.sin( halfRoll );
		var cosPitch = Math.cos( halfPitch );
		var sinPitch = Math.sin( halfPitch );
		
		setValue( 
			sinRoll * cosPitch * cosYaw - cosRoll * sinPitch * sinYaw, 
			cosRoll * sinPitch * cosYaw + sinRoll * cosPitch * sinYaw,
			cosRoll * cosPitch * sinYaw - sinRoll * sinPitch * cosYaw,
			cosRoll * cosPitch * cosYaw + sinRoll * sinPitch * sinYaw	);
	}
	
	public inline function ipIncr(q:Quat)
	{
		x += q.x;
		y += q.y;
		z += q.z;
		w += q.w;
		return this;
	}
	
	public inline function ipDecr(q:Quat)
	{
		x -= q.x;
		y -= q.y;
		z -= q.z;
		w -= q.w;
		return this;
	}
	
	public inline function ipScale(s:Float)
	{
		x *= s;
		y *= s;
		z *= s;
		w *= s;
		return this;
	}
	
	public inline function ipDiv(s:Float)
		return this.ipScale(1.0/s)
	
	public inline function ipMul( q : Quat )
	{
		setValue(
			w * q.x + x * q.w + y * q.z - z * q.y,
			w * q.y + y * q.w + z * q.x - x * q.z,
			w * q.z + z * q.w + x * q.y - y * q.x,
			w * q.w - x * q.x - y * q.y - z * q.z
		);
	}
	
	public inline function dot( q : Quat )
		return x * q.x + y * q.y +z * q.z + w * q.w
		
	public inline function length2()
		return dot(this)
		
	public inline function length()
		return Math.sqrt(dot(this))
	
	public inline function mulScalar(f:Float) return new Quat(x * f, y * f, z * f, w * f)
	public inline function divScalar(f:Float) return mulScalar(1.0 / f)
	public inline function angle(q:Quat)
	{
		var s = length2() * q.length2();
		Debug.nz(s);
		return Math.acos( dot(q) / s );
	}
	
	public inline function getAngle()
		return 2.0 * Math.acos(w) 
	
	public inline function getAxis()
	{
		var sq = 1.0 - w * w;
		
		if ( sq < 10 * MathEx.EPSILON)
			return new Vec3(1);
			
		var s = 1.0 / Math.sqrt( sq );
		return new Vec3(x * s, y * s, z * s);
	}
	
	public inline function inverse()
		return new Quat( -x, -y, -z, w)
		
	public inline function add(q:Quat)
		return new Quat(x + q.x, y + q.y, z + q.z, w + q.w)
	
	public inline function sub(q:Quat)
		return new Quat(x - q.x, y - q.y, z - q.z, w - q.w)
	
	//not same as inverse
	public inline function neg()
		return new Quat( -x, -y, -z, -w)
		
	public function farthest(qd:Quat)
	{
		var diff = sub(qd);
		var sum = add(qd);
		return (diff.length2() > sum.length2())
		? qd
		: qd.neg();
	}
	
	public function nearest(qd:Quat)
	{
		var diff = sub(qd);
		var sum = add(qd);
		return (diff.length2() < sum.length2())
		? qd
		: qd.neg();
	}
	
	//i suspect slerp was never used
	public function slerp(q:Quat, t:Float)
	{
		var mag = Math.sqrt(length2() * q.length2());
		Debug.nz( mag );
		
		var product = dot(q) / mag;
		var ap = Math.abs(product) ;
		if ( ap > 1.0 - MathEx.EPSILON
		&&	ap < 1.0 + MathEx.EPSILON ) 
		{
			var sign = product < 0? -1:1;
			var theta = Math.acos( sign * product);
			var s1 = Math.sin(sign * t * theta);
			var d  = 1.0 / Math.sin(theta);
			var s0 = Math.sin((1.0 - t) * theta);
			return new Quat( 
				(x * s0 + q.x * s1) * d,
				(y * s0 + q.y * s1) * d,
				(z * s0 + q.z * s1) * d,
				(w * s0 + q.w * s1) * d
			);
		}
		else 
			return this;
	}
	
	public static inline function getIdentity()
		return new Quat(.0, .0, .0, 1.0)
}