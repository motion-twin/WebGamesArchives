package mt.gx.h2d;


class BoundsEx {
	public static function randomXF(b:h2d.col.Bounds
	#if neko
		,?rd:neko.Random
	#end
		,?mr:mt.Rand
	) {
		return mt.gx.Dice.rollF( #if neko rd,#end mr,b.xMin, b.xMax );
	}
	
	public static function randomYF(b:h2d.col.Bounds
	#if neko
		,?rd:neko.Random
	#end
		,?mr:mt.Rand
	) {
		return mt.gx.Dice.rollF( #if neko rd,#end mr,b.yMin, b.yMax );
	}
}

class Ex
{
	
}