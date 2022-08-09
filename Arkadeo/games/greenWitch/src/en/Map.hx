package en;

import Const;

class Map extends Entity {
	var active			: Bool;
	
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		collides = false;
		weight = 0;
		zpriority = -20;
		selectable = true;
		
		var s = game.char.get("map");
		s.setCenter(0.5,1);
		s.y = -Const.GRID*0.5 + 5;
		sprite.addChild(s);
		
		game.currentLevel.setUsedZone(cx,cy, 1,1);
	}
	
	override public function isOver(x:Float, y:Float) {
		return x>=xx-20 && x<xx+20 && y>=yy-55 && y<=yy;
	}
	
	override public function update() {
		super.update();
		
		if( game.time%6==0 ) {
			var near = mt.deepnight.Lib.distance(xx,yy+10, game.hero.xx, game.hero.yy) <= 20;
			if( !active && near ) {
				active = true;
				game.miniMap.show();
			}
			if( active && !near ) {
				active = false;
				game.miniMap.hide();
			}
		}
	}
	
}