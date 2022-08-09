package mt.tipyx;

import h2d.col.Point;

/**
 * ...
 * @author Tipyx
 */
class Lib
{
	public static function GET_BEZIER(arPoint:Array<Point>, t:Float):Point {
		var arP = arPoint.copy();
		var nextArPoint = [];
		
		while (arP.length != 1) {
			for (i in 0...arP.length - 1) {
				nextArPoint.push(new Point(arP[i].x + ((arP[i + 1].x - arP[i].x) * t), arP[i].y + ((arP[i + 1].y - arP[i].y) * t)));
			}
			
			arP = nextArPoint.copy();
			nextArPoint = [];
		}
		
		return arP[0];
	}
}