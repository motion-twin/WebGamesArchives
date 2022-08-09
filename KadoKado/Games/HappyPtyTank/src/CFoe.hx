import ShotManager;
import MoveManager;

class CFoe extends Enemy {	
	public function new(){
		super();
		shot = new ShotManager(this,  [ Pause(1000), Shot ], 2);
		life = maxLife = 25;
		value = KKApi.const(100);
		speed = 4 * (60/mt.Timer.wantedFPS);
		#if devNoFoo
		graphics.beginFill(0xFF0000);
		graphics.drawCircle(0,0,15);
		graphics.endFill();
		#else
		addChild(new DummyFoe());
		#end
	}
}