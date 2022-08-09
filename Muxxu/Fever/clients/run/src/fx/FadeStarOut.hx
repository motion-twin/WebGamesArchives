package fx;
import Protocole;
import mt.bumdum9.Lib;

class FadeStarOut extends mt.fx.Fx{//}

	var shade:flash.display.Sprite;
	var queue:Array<flash.display.Sprite>;
	var stars:Array<McStar>;
	var player:Player;
	var step:Int;
	
	public function new(player:Player) {
		this.player = player;
		super();
		queue = [];
		step  = 0;
		coef  = 0;
		
		// QUEUE
		shade = new flash.display.Sprite();
		shade.blendMode = flash.display.BlendMode.ADD;
		
		// STARS
		var p = World.me.mainSquare.ent.localToGlobal(new flash.geom.Point(0, 0));
		stars  = [];
		for( i in 0...2 ) {
			var star = new McStar();
			stars.push(star);
			star.x = p.x;
			star.y = p.y;
			star.scaleX = star.scaleY = 3;
			star.gotoAndStop(i+1);
		}
		
		Main.root.addChild(shade);
		Main.root.addChild(stars[1]);
		Main.root.addChild(player);
		Main.root.addChild(stars[0]);
		

		// MASK
		player.mask = stars[0];
		
		
	}
	

	override function update() {
		super.update();
		
		var a = queue.copy();
		for( q in a ) {
			q.alpha -= 0.1;
			if( q.alpha <= 0 ) {
				queue.remove(q);
				shade.removeChild(q);
			}
		
		}
		
		
		switch( step ) {
			case 0 :
				for( star in stars ){
					star.scaleX *= 0.95;
					star.scaleX -= 0.05;
					star.scaleY = star.scaleX;
					star.rotation -= 5;
				}
				
				coef = (coef + 0.03) % 1;
				var s = stars[0];
				var sh = new McStar();
				shade.addChild(sh);
				sh.x = s.x;
				sh.y = s.y;
				sh.rotation = s.rotation;
				sh.scaleX = s.scaleX;
				sh.scaleY = s.scaleY;
				Col.setPercentColor(sh, 1, Col.getRainbow2(coef));
				queue.push(sh);
			
				var gl = stars[1];
				var ec = 12;
				gl.width = s.width + ec;
				gl.height = s.height + ec;

				if( stars[0].scaleX < 0.1 ) step++;
				
			case 1 :
				if( queue.length == 0 ) kill();
				
		}
	}

	override function kill() {
		player.mask = null;
		for( star in stars )Main.root.removeChild(star);
		Main.root.removeChild(shade);
		super.kill();
		World.me.backIn();
	}
	
	
	
//{
}








