package mt.gx.as;

class ColTransEx
{
	public static inline function ofs(cl:flash.geom.ColorTransform,r=0,g=0,b=0,a=0)
	{
		cl.redOffset 		= r;
		cl.greenOffset		= g;
		cl.blueOffset		= b;
		cl.alphaOffset		= a;
		return cl;
	}
	
	public static inline function mul(cl:flash.geom.ColorTransform,r=1.0,g=1.0,b=1.0,a=1.0)
	{
		cl.redMultiplier			= r;
		cl.greenMultiplier 			= g;
		cl.blueMultiplier			= b;
		cl.alphaMultiplier			= a;
		return cl;
	}
	
	public static inline function rst(cl:flash.geom.ColorTransform)
	{
		ofs(cl);
		mul(cl);
		return cl;
	}
}