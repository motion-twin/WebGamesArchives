class Cs {

	public static var  mcw = 	500;
	public static var  mch = 	300;
	public static var  MARGIN = 	44;


	public static var CZ = 0.5 ; //inclinaison du plan
	//public static var HOR = 227 ;
	public static var HOR = 200 ;
	public static var HEIGHT = 170 ;


	public static var DEFAULT_WALK_SPEED = 1 ;

	public static function getTeamMid(team){
		var xMin = 999.9;
		var xMax = -999.9;
		var yMin = 999.9;
		var yMax = -999.9;
		for( f in Game.me.fighters ){
			if( f.team == team ){
				xMin = Math.min(f.x,xMin);
				yMin = Math.min(f.y,yMin);
				xMax = Math.max(f.x,xMax);
				yMax = Math.max(f.y,yMax);
			}
		}
		return {x:(xMax+xMin)*0.5,y:(yMax+yMin)*0.5};
	}



}