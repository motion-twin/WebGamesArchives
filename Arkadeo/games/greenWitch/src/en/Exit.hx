package en;

class Exit extends Entity {
	public static var ALL : Array<Exit> = [];
	
	var activation		: Int;
	
	public function new(x,y) {
		super();
		
		selectable = true;
		ALL.push(this);
		initLife(999);
		cx = x;
		cy = y;
		weight = 0;
		collides = false;
		zpriority = -999;
		activation = 15;
		
		var s = game.char.get("stairDown");
		sprite.addChild(s);
		if( game.currentLevel.getCollision(cx-1,cy) ) {
			// descente vers la gauche
			s.setCenter(1,0);
			s.x = s.y = Std.int(-Const.GRID*0.5);
			s.scaleX = -1;
			//game.currentLevel.setCollision(cx,cy);
			//game.currentLevel.setCollision(cx,cy+1);
		}
		else {
			s.setCenter(0,0);
			s.x = s.y = Std.int(-Const.GRID*0.5);
		}
	}
	
	public override function detach() {
		super.detach();
		ALL.remove(this);
	}
	

	override public function isTouchedBy(e:Entity) {
		return e.cx>=cx && e.cx<=cx+1 && e.cy>=cy && e.cy<=cy+1;
	}
	
	override public function isOver(x:Float, y:Float) {
		return x>=xx-10 && x<xx+30 && y>=yy-10 && y<=yy+30;
	}
	
	override function onActivate() {
		super.onActivate();
		if( en.it.Civilian.ALL.length>0 )
			fx.pop(xx,yy, Lang.NeedCivilians({_n:en.it.Civilian.ALL.length}));
		else
			game.onExit();
	}
	
	
	//public override function update() {
		//super.update();
	//}
}
