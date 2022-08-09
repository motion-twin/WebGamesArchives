package fx;
import Protocole;
import mt.bumdum9.Lib;

class FadeStarIn extends mt.fx.Fx{//}

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
		for( i in 0...3 ) {
			var star = new McStar();
			stars.push(star);
			star.x = p.x;
			star.y = p.y;
			star.scaleX = star.scaleY = 0;
			star.gotoAndStop([1, 1, 2][i]);
		}
		
		
		Main.root.addChild(stars[2]);
		Main.root.addChild(player);
		Main.root.addChild(stars[0]);
		Main.root.addChild(shade);
		Main.root.addChild(stars[1]);
		
		// MASK
		shade.mask = stars[0];
		player.mask = stars[1];
		
		
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
		
			/*
			if( q.tabIndex-- <= 0 ) {
				shade.removeChild(q);
				queue.remove(q);
			}
			*/
			
		}
		
		
		switch( step ) {
			case 0 :
				for( star in stars ){
					star.scaleX += 0.03;
					star.scaleX *= 1.07;
					star.scaleY = star.scaleX;
					star.rotation += 4;
				}
				
				coef = (coef + 0.03) % 1;
				var s = stars[0];
				var sh = new McCounterStar();
				shade.addChild(sh);
				sh.x = s.x;
				sh.y = s.y;
				sh.rotation = s.rotation;
				sh.scaleX = s.scaleX;
				sh.scaleY = s.scaleY;
				sh.tabIndex = 10;
				var col = Col.getRainbow2(coef);
				Col.setPercentColor(sh, 1, col);
				queue.push(sh);
			
				var gl = stars[2];
				var ec = 12;
				gl.width = s.width + ec;
				gl.height = s.height + ec;

				if( stars[0].scaleX > 5 ) step++;
				
			case 1 :
				if( queue.length == 0 ) kill();
				
		}
	}
	
	override function kill() {
		player.mask = null;
		for( star in stars )Main.root.removeChild(star);
		Main.root.removeChild(shade);
		super.kill();
	}
	
	
	
//{
}








