import mt.bumdum.Sprite;
import mt.bumdum.Lib;
class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var SCORE_ACCEL = 	KKApi.const(5);
	public static var SCORE_OVERTAKE =	KKApi.aconst([1000,3000,8000]);
	public static var SCORE_PERFECT =	KKApi.const(3000);
	public static var SCORE_FAST 	=	KKApi.const(5000);
	public static var SCORE_FURIOUS =	KKApi.const(8000);

	public static var TURN_MAX = 6;
	public static var LIFE_MAX = 100;
	public static var LAP_MALUS = 0.95;



	//public static var RACE = [ [50.0,50.0], [250,50], [250,250], [50,250] ];
	public static var RACE = [[150.0,255.0],[254,230],[270,223],[275,213],[277,199],[271,51],[266,36],[256,25],[240,24],[230,31],[223,45],[208,143],[205,154],[193,159],[179,156],[112,122],[105,115],[104,106],[110,97],[164,59],[168,50],[165,42],[157,39],[147,39],[73,41],[54,51],[39,69],[31,91],[33,111],[42,129],[55,140],[121,176],[130,184],[131,194],[123,202],[111,207],[40,219],[25,232],[19,249],[22,264],[34,274],[49,277],[66,274]];

	public static function init(){
		Game.me.checkpoints = [];
		//trace(Game.me.checkpoints);

		var pa = 0.0;
		for( i in 0...RACE.length ){

			var pos = RACE[i];
			var next = RACE[(i+1)%RACE.length];
			var na = getAng(pos,next);

			var da = Num.hMod(na-pa,3.14);
			var ba = pa+da*0.5 ;

			Game.me.checkpoints.push( {x:pos[0],y:pos[1],a:ba+1.57} );
			pa = na;

		}
	}

	static public function getAng(p1:Array<Float>,p2:Array<Float>){
		var dx = p2[0]-p1[0];
		var dy = p2[1]-p1[1];
		return Math.atan2(dy,dx);
	}

//{
}













