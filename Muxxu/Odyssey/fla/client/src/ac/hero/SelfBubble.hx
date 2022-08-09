package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class SelfBubble extends Action {//}
	
	var hero:Hero;

	
	public function new(hero) {
		super();
		this.hero = hero;
	
	}
	override function init() {
		super.init();
	
		var h = Game.me.getFirst();
		var a = h.board.getUnbubbled();
		
		if ( a.length == 0 ) {
			kill();
			return;
		}
		
		var ball = a[Std.random(a.length)];
		ball.board.dm.over(ball);
		
		var bub = new SP();
		bub.scaleX = bub.scaleY = 0.4;
		var bubSkin = new fx.Bubble();
		bub.addChild(bubSkin);
		
		ball.bubble = true;
		ball.addChild(bub);
		bub.x = bub.y = 0;
		
		new mt.fx.Blob(bubSkin, 0.02);
		
	}
	
	
	// UPDATE
	override function update() {
		super.update();
		if ( timer == 20 ) kill();
	
	}
	
	//
	


	
	
//{
}