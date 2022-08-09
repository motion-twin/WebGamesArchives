package men;

import mt.deepnight.slb.*;
import mt.deepnight.Lib;
import mt.MLib;
import com.Protocol;
import h2d.SpriteBatch;

class Gift extends MinorEntity {
	var bouncing		: Bool;
	var offset			: Float;
	public var item		: Item;

	public var tx		: Null<Float>;

	var beGroup			: Array<{ e:BatchElement, dx:Float, dy:Float }>;

	public function new(r, x,y, i:Item) {
		beGroup = [];
		super(r,x,y);
		item = i;
		bouncing = true;
		offset = Lib.rnd(0,1);


		switch( item ) {
			case I_Money(n) :
				bouncing = false;
				var rseed = new mt.Rand(1000 + r.rx + r.ry);

				// Center stack
				spr.set("goldStack");
				spr.setScale( 0.4 + 0.6*MLib.fclamp(n/500, 0, 1.5) );

				// Right
				if( n>=300 ) {
					var e = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, "goldStack", 0, 0.5, 1);
					e.setScale( MLib.fclamp(0.4 + 0.6*(n-300)/300, 0, 1) );
					beGroup.push({ e:e, dx:90, dy:0 });
				}

				// Left
				if( n>=600 ) {
					var e = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, "goldStack", 0, 0.5, 1);
					e.setScale( MLib.fclamp(0.4 + 0.6*(n-600)/300, 0, 0.5) );
					beGroup.push({ e:e, dx:-70, dy:0 });
				}

			case I_EventGift(_) :
				bouncing = false;
				spr.set(Assets.getItemIcon(item));
				spr.setScale( 96/spr.tile.height );

			default :
				spr.set(Assets.getItemIcon(item));
				spr.setScale( 96/spr.tile.height );

				if( item==I_LunchBoxAll || item==I_LunchBoxCusto )
					spr.changePriority(-1);
		}
	}

	override function unregister() {
		for(e in beGroup)
			e.e.remove();
		beGroup = null;
		super.unregister();
	}

	override function postUpdate() {
		super.postUpdate();

		if( bouncing )
			spr.y -= MLib.fabs( Math.sin(Game.ME.ftime*0.1 + offset*3.14) * (15+offset*5) );

		for(e in beGroup) {
			e.e.x = spr.x+e.dx;
			e.e.y = spr.y+e.dy;
		}
	}

	override function update() {
		super.update();

		// Move
		if( tx!=null ) {
			xx+=(tx-xx)*0.05;
			//updateCoords();
			if( MLib.fabs(tx-xx)<=3 )
				tx = null;
		}

		switch( item ) {
			case I_Money(n) :
				if( Game.ME.itime%3==0 ) {
					var scale = 0.2 + 0.8*MLib.fclamp(n/200, 0, 1);
					Game.ME.fx.gold(this, scale);
				}

			case I_Gem :
				if( Game.ME.itime%30==0 )
					spr.setScale(2.2);

				if( spr.scaleX>2 ) {
					spr.scaleX+= (2-spr.scaleX)*0.1;
					spr.scaleY+= (2-spr.scaleY)*0.1;
				}

				Game.ME.fx.gem(this);

			case I_EventGift(_) :
				Game.ME.fx.eventGift(this);
				var s = 96/spr.tile.height;
				spr.scaleX = s + Math.cos(Game.ME.ftime*0.1)*0.05;
				spr.scaleY = s + Math.sin(Game.ME.ftime*0.08)*0.05;

			default :
		}
	}
}

