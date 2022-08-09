class Fx
{//}

	public var sn:Snake;
	public var stg:Stage;
	
	public var onFinish:Void->Void;
	
	public function new() {
		sn = Game.me.snake;
		stg = Stage.me;
		Game.me.effects.push(this);
	}
	public function update() {
	
		
	}
	public function kill(){
		Game.me.effects.remove(this);
		if ( onFinish != null ) onFinish();
	}
	
//{
}








