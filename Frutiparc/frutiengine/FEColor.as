/*
$Id: FEColor.as,v 1.1 2003/09/22 13:38:14  Exp $

Class: FEColor
*/
class FEColor{
	static function toRGBObj(nb){
		var r = (nb >> 16) & 255;
		var g = (nb >> 8 ) & 255;
		var b = nb & 255;
		return {r: r,g: g,b: b};
	}
	
	static function toRGBInt(obj){
		return obj.r * 256 * 256 + obj.g * 256 + obj.b;
	}
	
}
