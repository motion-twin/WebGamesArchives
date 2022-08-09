package en;

class Item extends Entity {
	var duration		: mt.flash.Volatile<Int>;
	var pickDist		: mt.flash.Volatile<Int>;
	var active			: Bool;
	
	public function new(x,y) {
		super();
	
		active = true;
		duration = -1;
		pickDist = 35;
		initLife(999);
		cx = x;
		cy = y;
		xr = rnd(0.2, 0.8);
		yr = rnd(0.2, 0.8);
		weight = 0;
		collides = false;
	}
	
	function onPickUp() {
		fx.pickUp(xx,yy);
	}
	
	function deactivate() {
		active = false;
		sprite.visible = false;
	}
	
	function activate() {
		active = true;
		sprite.visible = true;
		fx.halo(xx,yy, 30, 0x00FFFF);
	}
	
	public override function update() {
		super.update();
		
		if( active ) {
			
			if( onScreen && !killed && !hero.dead ) {
				var d = distance(hero);
				if( d<=25 || d<=pickDist && sightCheck(hero) ) {
					onPickUp();
					destroy();
					return;
				}
			}
			
			if( duration>0 ) {
				duration--;
				if( onScreen ) {
					if( duration<=30*2 )
						sprite.alpha = game.time%3==0 ? 1 : 0.5;
					else if( duration<=30*5 )
						sprite.alpha = game.time%6==0 ? 0.7 : 1;
				}
				if( duration<=0 )
					destroy();
			}
		}
		else
			sprite.visible = false;
	}
}
