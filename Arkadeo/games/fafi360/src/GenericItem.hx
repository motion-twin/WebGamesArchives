import mt.flash.Volatile;

class GenericItem extends Entity {
	public var locked	: Volatile<Bool>;
	var color			: Int;
	
	public var fl_repop	: Bool; // disparaît au repop ?
	var fl_active		: Bool;
	var shine			: Float;
	//var grabDist		: Volatile<Int>;
	
	public function new() {
		super();
		
		color = 0xFFFF17;
		fl_active = true;
		locked = false;
		frict = 0.88;
		fl_collide = false;
		fl_repop = false;

		game.items.push(this);
			
		var m = 4; // en nb de cases!
		var pt = {cx:0., cy:0.}
		do {
			pt.cx = rnd(Game.FPADDING+m, Game.FPADDING+Game.FWID-m);
			pt.cy = rnd(Game.FPADDING+m, Game.FPADDING+Game.FHEI-m);
		} while( pt.cx<=Game.FPADDING+8 && pt.cy>=Game.FPADDING+Game.FHEI*0.3 && pt.cy<= Game.FPADDING+Game.FHEI*0.7 );
		xx = Game.GRID * pt.cx;
		yy = Game.GRID * pt.cy;
		updateFromScreenCoords();
		
		cd.set("shine", Game.FPS * (Math.random()*3));
	}
	
	public override function unregister() {
		super.unregister();
		game.items.remove(this);
	}
	
	public function removeItem() {
		if( locked )
			pickUp();
		else {
			fx.smokePop(xx, yy);
			destroy();
		}
	}
	
	public function activate() {
		fx.popHalo(xx,yy, color);
		fl_active = true;
		spr.visible = true;
	}
	
	public function pickUp() {
		destroy();
	}
	
	public override function update() {
		super.update();
			
		var b = game.ball;
		
		if( fl_active ) {
			var d = mt.deepnight.Lib.distanceSqr(xx,yy, b.xx,b.yy);
			if( !locked ) {
				var grabDist = game.playerTeam.hasPerk(_PBonusGrab) ? 100 : 50;
				var minZ = 999;
				if( game.isPlaying() && b.z<=minZ && !locked ) {
					if( d<=grabDist*grabDist )
						if( Math.sqrt(d)<=grabDist ) {
							spr.blendMode = flash.display.BlendMode.ADD;
							locked = true;
							removeShadow();
						}
				}
			}
			
			if( locked ) {
				var a = Math.atan2(b.yy-yy, b.xx-xx);
				dx += Math.cos(a)*0.09;
				dy += Math.sin(a)*0.09;
				if( Math.sqrt(d)<=10 )
					pickUp();
			}
			
			if( ! game.lowq ) {
				if( !locked && !cd.has("shine") ) {
					cd.set("shine", Game.FPS * 1.5);
					shine = 1;
				}
				
				if( shine>0 ) {
					shine-=0.1;
					if( shine>0 ) {
						var ct = mt.deepnight.Color.getColorizeCT(0xFFFF80, shine*1);
						spr.transform.colorTransform = ct;
						spr.filters = [ new flash.filters.GlowFilter(0xFFFF80, shine*0.7, 8,8,1) ];
					}
					else {
						spr.filters = [];
						spr.transform.colorTransform = new flash.geom.ColorTransform();
					}
				}
				
				if( !cd.has("spark") ) {
					cd.set("spark", mt.deepnight.Lib.rnd(10,20));
					fx.itemSpark(xx,yy);
				}
			}
		}
	}
}
