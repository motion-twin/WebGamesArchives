package ui;

import mt.deepnight.Tweenie;
import mt.MLib;
import mt.data.GetText;
import Data;
import b.Room;
import h2d.SpriteBatch;
import com.*;

class Tip extends H2dProcess {
	public static var CURRENT : Tip;

	var sb				: h2d.SpriteBatch;
	var tsb				: h2d.SpriteBatch;
	var title			: h2d.TextBatchElement;
	var bg				: BatchElement;
	var bottom			: BatchElement;
	var active			: Bool;
	var hp = 100;
	var vp = 10;
	var maxWid = 600;
	static var UNIQ = 0;
	var uid : Int;

	public function new(?col:Null<Int>, titleStr:LocaleString, ?line:LocaleString, ?lines:Array<{col:Int, str:LocaleString}>) {
		uid = UNIQ++;
		//trace("new "+uid);
		clear();

		super(Game.ME);

		Main.ME.uiWrapper.add(root, Const.DP_NOTIFICATION);

		active = true;
		CURRENT = this;
		if( col==null )
			col = Const.TEXT_GOLD;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;

		bg = Assets.tiles.addBatchElement(sb, "popUpBg", 0);
		bg.color = h3d.Vector.fromColor( alpha(mt.deepnight.Color.clampBrightnessInt(col, 0, 0.2)) );
		var top = Assets.tiles.addBatchElement(sb, "popUpTop", 0);

		title = Assets.createBatchText(tsb, Assets.fontTiny, 24, mt.Utf8.uppercase( titleStr ));
		title.textColor = col;
		title.x = hp;
		title.y = vp;
		title.maxWidth = maxWid/title.scaleX;
		title.dropShadow = { color:0x0, alpha:0.8, dx:0, dy:3 }

		//var w = tf.textWidth*tf.scaleX;
		//var h = 0.;
		if( lines==null )
			lines = [{ col:0xFFFFFF, str:line }];
		var y = title.y + title.textHeight*title.scaleY;
		for(l in lines) {
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 18, l.col, l.str);
			tf.x = hp;
			tf.y = y;
			tf.maxWidth = maxWid/tf.scaleX;
			tf.dropShadow = { color:0x0, alpha:0.8, dx:0, dy:3 }
			y += tf.textHeight*tf.scaleY + 10;
			//w = MLib.fmax(w, tf.textWidth*tf.scaleX);
			//h += tf.textHeight*tf.scaleY + 10;
		}

		//bg.width = tsb.width + hp*2;
		bg.width = maxWid + hp*2;
		bg.height = tsb.height + vp*2;
		bottom = Assets.tiles.addBatchElement(sb, "popUpBottom", 0);
		bottom.y = bg.height;
		top.width = bottom.width = bg.width;

		onResize();
	}

	dynamic function shouldBeOnTop() return true;

	public static function fromClient(c:en.Client, ?animate=true) {
		var inf = Lang.getClient(c.type, c.shotel);
		var col = null;
		if( !c.isWaiting() ) {
			var col = DataTools.getWallColorCode(c.room.sroom.custom.color);
			mt.deepnight.Color.clampBrightnessInt(col, 0.8, 1);
		}
		var lines = [{ col:0xFFFFFF, str:inf.desc }];
		for( p in Data.ClientPerk.all )
			if( c.sclient.hasPerk(p.id) )
				lines.push({ col:Const.TEXT_PERK, str:Lang.getPerk(p.id) });

		var old = CURRENT;
		var e = new ui.Tip( col, cast inf.name+" (\""+c.getName()+"\")", lines );
		if( !c.isWaiting() ) {
			e.appendClientInfos(c.sclient);
			//e.shouldBeOnTop = function() {
				//var r = c.getRealRoom();
				//return r==null ? true : Game.ME.sceneToUiY(r.globalBottom) < e.h()*0.5;
			//}
		}
		e.onResize();

		if( !c.isWaiting() )
			e.addTimer( c.room );
		//var timer = Assets.createBatchText(e.tsb, Assets.fontTiny, 19, Const.TEXT_GRAY, "???");

		if( !animate ) {
			e.tw.completeAll();
			if( old!=null )
				old.destroy();
		}

		//if( !c.isWaiting() )
			//e.createTinyProcess( function(_) {
				//if( !e.cd.hasSet("timer", Const.seconds(1)) && c.room!=null ) {
					//var t = c.room.getTaskTimer();
					//if( t!=null ) {
						//var label = if( c.room.is(R_Bedroom) && c.room.countClients()==1 )
							//Lang.t._("Leave in %time%");
						//else
							//Lang.t._("Finish in %time%");
						//timer.text = Game.ME.prettyTime(label, t.end);
						//timer.x = e.hp + e.maxWid - timer.textWidth*timer.scaleX;
						//timer.y = e.title.y + e.title.textHeight*e.title.scaleY*0.5 - timer.textHeight*timer.scaleY*0.5;
					//}
					//timer.visible = t!=null;
				//}
			//}, true);


		return e;
	}

	public function addTimer(r:Room) {
		var timer = Assets.createBatchText(tsb, Assets.fontTiny, 19, Const.TEXT_GRAY, "???");
		timer.visible = false;
		createChildProcess( function(_) {
			if( !cd.hasSet("timer", Const.seconds(1)) && r!=null && !r.destroyed ) {
				var t = r.getTaskTimer();
				timer.visible = t!=null;
				if( t!=null ) {
					var label = if( r.is(R_Bedroom) && r.countClients()==1 )
						Lang.t._("Leave in %time%");
					else
						Lang.t._("Finish in %time%");
					timer.text = Game.ME.prettyTime(label, t.end);
					timer.x = hp + maxWid - timer.textWidth*timer.scaleX;
					timer.y = title.y + title.textHeight*title.scaleY*0.5 - timer.textHeight*timer.scaleY*0.5;
				}
			}
		}, true);
	}

	public function appendClientInfos(c:SClient) {
		var shotel = Game.ME.shotel;
		var isize = 35;
		var spacing = isize*0.9;
		var cols =
			(c.likes.length>0?1:0) +
			(c.dislikes.length>0?1:0) +
			(c.emit!=null?1:0) +
			(c.money>0?1:0);

		if( cols==0 )
			return;

		var y = bg.height;
		bg.height+=40;
		bottom.y = bg.height;

		var x : Float = hp;
		if( c.likes.length>0 ) {
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 16, Const.TEXT_PERK, Lang.t._("I need:"));
			tf.x = hp;
			tf.y = y + isize*0.5 - tf.textHeight*tf.scaleY*0.5;
			x += tf.textWidth*tf.scaleX;
			for(a in c.likes) {
				var e = Assets.tiles.hbe_get(sb, Assets.getAffectIcon(a));
				e.constraintSize(isize);
				e.setPos(x,y);
				x+=isize*0.7;
			}
			x+=spacing;
		}

		if( c.dislikes.length>0 ) {
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 16, Const.TEXT_BAD, Lang.t._("I hate:"));
			tf.x = x;
			tf.y = y + isize*0.5 - tf.textHeight*tf.scaleY*0.5;
			x += tf.textWidth*tf.scaleX;
			for(a in c.dislikes) {
				var e = Assets.tiles.hbe_get(sb, Assets.getAffectIcon(a));
				e.constraintSize(isize);
				e.setPos(x,y);
				x+=isize*0.7;
			}
			x+=spacing;
		}

		if( c.emit!=null ) {
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 16, Const.TEXT_GRAY, Lang.t._("I generate:"));
			tf.x = x;
			tf.y = y + isize*0.5 - tf.textHeight*tf.scaleY*0.5;
			x += tf.textWidth*tf.scaleX;
			var e = Assets.tiles.hbe_get(sb, Assets.getAffectIcon(c.emit));
			e.constraintSize(isize);
			e.setPos(x,y);
			x+=isize*0.7;
			x+=spacing;
		}

		if( c.money>0 && shotel.featureUnlocked("savings") ) {
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 16, Const.TEXT_SAVING, Lang.t._("Savings:"));
			tf.x = x;
			tf.y = y + isize*0.5 - tf.textHeight*tf.scaleY*0.5;
			x += tf.textWidth*tf.scaleX;
			for(i in 0...c.money) {
				var e = Assets.tiles.hbe_get(sb, "moneyBill");
				e.constraintSize(isize);
				e.setPos(x,y);
				x+=isize*0.35;
			}
			x+=spacing;
		}
	}

	public static function clear() {
		if( CURRENT!=null ) {
			var e = CURRENT;
			CURRENT = null;
			e.active = false;
			//trace("clear "+e.uid);
			//e.tw.create( e.root.y, e.h()*0.5, 150 ).onEnd = function() {
				//e.destroy();
				//trace("destroy "+e.uid);
			//}
			if( e.root.y<e.h()*0.5 )
				e.tw.create( e.root.y, -e.root.height, 150 ).onEnd = function() {
					e.destroy();
				}
			else
				e.tw.create( e.root.y, e.h(), 150 ).onEnd = function() {
					e.destroy();
				}
		}
	}

	override function onDispose() {
		super.onDispose();

		title = null;

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		bg = null;
		bottom = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();

		if( !active )
			return;

		root.setScale( MLib.fmin( w()*0.9/maxWid, Main.getScale(30, 0.35) ) );

		root.x = w()*0.5 - root.width*0.5;
		if( shouldBeOnTop() ) {
			root.y = -root.height;
			tw.create(root.y, hcm()<=9 ? 10 : ui.MainStatus.CURRENT.root.scaleY*65, 350);
		}
		else {
			root.y = h();
			tw.create(root.y, h()-root.height-10*root.scaleY, 350);
		}
	}

	override function update() {
		super.update();
		if( root.y<h()*0.5 && !shouldBeOnTop() )
			onResize();

		if( root.y>h()*0.5 && shouldBeOnTop() )
			onResize();
	}
}


