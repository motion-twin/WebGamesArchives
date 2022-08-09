package wave;
import Protocol;
import mt.bumdum9.Lib;


class Noise extends fx.Wave {//}

	override function spawn(type) {
		var pos = getRandomPoint(16);
		new fx.Spawn(type,pos.x,pos.y);
	}
	

	
	
//{
}












