package en;

import mt.MLib;
import b.Room;
import b.*;
import com.*;
import com.Protocol;

import mt.deepnight.slb.*;

enum GroomActivity {
	G_None;
	G_Clean;
	G_Restock;
}

class Groom extends Entity {
	public static var ALL : Array<Groom> = [];

	public var tx			: Float;
	var vacuum				: h2d.SpriteBatch.BatchElement;
	var crate				: h2d.SpriteBatch.BatchElement;
	public var activity		: GroomActivity;

	public function new(r:b.Room) {
		super(r);

		activity = G_None;
		tx = 0;
		ALL.push(this);
		dir = Std.random(2)*2-1;
		baseSpeed*=2;
		wid = 90;
		hei = 160;
		gravity = 1;

		spr.setCenterRatio(0.5, 1);
		scale = 1.12+rnd(0,0.1,true);

		spr.a.registerStateAnim("groomCatCleaningB", 3, function() return cd.has("cleaningB"));
		spr.a.registerStateAnim("groomCatCleaning", 2, function() return cd.has("cleaningA"));
		spr.a.registerStateAnim("groomCatWalk", 1, function() return MLib.fabs(dx)>2);
		spr.a.registerStateAnim("groomCatIdle", 0);
		spr.a.applyStateAnims();

		vacuum = Assets.monsters2.addBatchElement(game.monstersSb2, "groomCatHoover",0, 0.5,1);
		vacuum.x = centerX;
		vacuum.y = yy;
		vacuum.visible = false;

		crate = Assets.tiles.addBatchElement(game.tilesFrontSb, Assets.getStockIconId(r.type),0, 0.5,1);
		crate.x = centerX;
		crate.y = yy;
		crate.visible = false;
		crate.scale(0.8);

		setPos(room.globalLeft+rnd(30, 100), room.globalBottom);
		cd.set("noWait", Const.seconds(3));
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb2, Assets.monsters2, "groomCatIdle");
	}

	override function setPos(x,y) {
		super.setPos(x,y);

		if( vacuum!=null ) {
			vacuum.x = centerX;
			vacuum.y = yy;
		}
	}

	public static function getAllAt(x,y) {
		return ALL.filter( function(e) return e.room.rx==x && e.room.ry==y );
	}

	function toString() return 'Groom($room)';


	override function set_room(r) {
		super.set_room(r);
		if( room!=null )
			setPos(room.globalLeft+room.wid*rnd(0.3, 0.7), room.globalBottom);
		return room;
	}

	override function unregister() {
		super.unregister();

		crate.remove();
		crate = null;

		vacuum.remove();
		vacuum = null;

		ALL.remove(this);
	}

	public function isWalking() {
		return MLib.fabs(dx)>=walkSpeed*2;
	}



	public function iaWander() {
		if( cd.has("wait") )
			return;

		function resetTarget() {
			var count = MLib.max(1, room.countGrooms());
			var p = 80;
			var w = ( room.wid-p*2 ) / count;
			var idx = 0;
			for(g in room.getGroomsInside())
				if( g!=this )
					idx++;
				else
					break;
			do {
				if( count<=1 )
					tx = room.globalLeft + p + rnd(0,w);
				else
					tx = room.globalLeft + p + w*idx + rnd(0,w);
			} while( MLib.fabs(tx-xx)<30 );

			if( !cd.has("noWait") )
				cd.set("wait", Const.seconds(rnd(0.5, activity==G_Clean?4:2)) );
		}

		if( tx==0 || tx<room.globalLeft+80 || tx>room.globalRight-200 )
			resetTarget();

		if( MLib.fabs(tx-xx)<=10 )
			resetTarget();

		if( tx>xx+5 ) dx+=walkSpeed;
		if( tx<xx+5 ) dx-=walkSpeed;

		if( stable && !cd.has("jump") )
			dy = -rnd(5,6);
	}

	public function iaGoto(tx:Float, ?run=false) {
		tx = room.globalLeft + tx;
		var s = run || MLib.fabs(tx-xx)>=100 ? runSpeed : walkSpeed;
		if( MLib.fabs(tx-xx)<=30 )
			s*=0.35;

		if( tx>xx+20 ) {
			dx+=s;
			dir = 1;
		}
		else if( tx<xx-20 ) {
			dx-=s;
			dir = -1;
		}
	}


	override function postUpdate() {
		super.postUpdate();

		spr.scaleX += Math.sin(time*0.09)*0.02;
		spr.scaleY += Math.cos(time*0.07)*0.02;

		if( Assets.SCALE != 1 )
			spr.scale( Assets.SCALE );

		if( isWalking() )
			spr.rotation = Math.cos(time*0.2)*0.1;
		else
			spr.rotation = Math.cos(time*0.07)*0.07;

		if( room.is(R_Lobby) )
			spr.y -= 55;

		if( vacuum!=null ) {
			vacuum.visible = activity==G_Clean;
			vacuum.x += (centerX-dir*50 - vacuum.x)*0.2;
			vacuum.y += (yy - vacuum.y)*0.1;
			vacuum.rotation = Math.cos(time*0.15)*0.12;
			vacuum.scaleX = -dir;
		}

		if( crate!=null ) {
			crate.visible = activity==G_Restock;
			crate.x = centerX + dir*30 + (isWalking() ? Math.cos(time*0.1)*3 : 0);
			crate.y = yy-5 + Math.sin(time*0.3)*(isWalking()?5:2);
			crate.rotation = dir*0.12;
		}
	}


	override function update() {
		super.update();

		if( stable && activity==G_Clean && !isWalking() && !cd.has("cleanWait") ) {
			var d = Const.seconds(rnd(0.8, 1.5));
			cd.set("cleanWait", d+Const.seconds(rnd(1,2)));
			if( Std.random(2)==0 )
				cd.set("cleaningA", d);
			else
				cd.set("cleaningB", d);
			cd.set("wait", d);
		}

		if( time%3==0 && cd.has("cleaningA") )
			game.fx.cleaningSmoke(centerX+dir*80, centerY-10);

		if( time%3==0 && cd.has("cleaningB") )
			game.fx.cleaningSmoke(centerX+dir*80, yy-10);
	}
}

