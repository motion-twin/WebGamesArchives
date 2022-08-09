

class Blank extends Game {//}

	
	
	public function new(id) {
		super();
		
		var seed = new mt.Rand(id);
		seed.rand(); // pb de seed, vori avec warp
		graphics.beginFill(seed.random(0xFFFFFF));

		graphics.drawRect(0,0,Game.WIDTH, Game.HEIGHT);
		
	}
	
	override function update() {
		super.update();

		if( click ) setWin(true);
		
	}
	
//{
}