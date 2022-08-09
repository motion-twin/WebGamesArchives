package ui;

import mt.MLib;
import b.Room;
import h2d.SpriteBatch;
import h2d.TextBatchElement;
import mt.deepnight.Tweenie;

class Menu extends H2dProcess {
	public static var CURRENT : Menu;
	static var UNIQ = 0;

	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;

	var bwid			: Int;
	var bhei			: Int;
	var elements		: Array<{ g:BatchGroup, active:Bool }>;
	var attachX			: Float;
	var attachY			: Float;
	public var sideMode	: Bool;
	var locked			: Bool;
	var uniq			: Int;


	public function new(?r:b.Room, ?ax:Float, ?ay:Float, ?fast=false) {
		close(fast);
		CURRENT = this;
		uniq = UNIQ++;

		super(Game.ME);

		name = 'Menu'+uniq;
		root.name = name;
		sideMode = hcm()<=8;
		//#if debug sideMode = true; #end

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;
		tsb.name = name+".tsb";

		locked = false;
		bwid = 100;
		bhei = 90;
		root.detach();
		if( sideMode ) {
			Main.ME.uiWrapper.add(root, Const.DP_BARS);
			attachX = attachY = -1;
		}
		else {
			Main.ME.uiWrapper.add(root, Const.DP_CTX_UI);
			attachX = r!=null ? r.globalCenterX : ax;
			attachY = r!=null ? r.globalBottom : ay;
		}

		elements = [];

		onResize();
		root.visible = false;
		onNextUpdate = finalize.bind(fast);
	}

	public function finalize(fast:Bool) {
		if( destroyed )
			return;

		if( sideMode ) {
			var x = 0.;
			for(e in elements) {
				e.g.x = x;
				x+=bwid;
			}
		}
		else {
			var x = 0.;
			for(i in 0...elements.length) {
				var e = elements[i];
				e.g.x = x;
				e.g.y = 5;

				//if( !sideMode && i<elements.length-1 && e.active ) {
					//var s = Assets.tiles.getH2dBitmap("btnSeparator", root);
					//s.x = e.g.x + bwid;
					//s.y = e.g.y+5;
					//s.scaleX = 2;
					//s.alpha = 0.85;
					//s.height = bhei;
				//}

				x+=bwid;
			}
		}

		root.visible = true;
		onResize();
		if( !fast ) {
			var y = root.y;
			tw.create(root.y, h()>y, TEaseOut, 200);
		}
	}

	public static function close(?fast=false) {
		if( CURRENT!=null ) {
			var e = CURRENT;
			CURRENT = null;
			if( e.sideMode && !fast ) {
				e.onNextUpdate = null;
				e.tw.terminateWithoutCallbacks(e.root.y);
				e.tw.create(e.root.y, e.h(), 150).end( e.destroy );
			}
			else
				e.destroy();
		}
	}

	public static function isOpen(?inSideMode:Bool) {
		return CURRENT!=null && (!inSideMode || inSideMode==CURRENT.sideMode);
	}

	public function getButtonUiCoord(id:Int) {
		var e = elements[id];
		if( e==null )
			return { x:0., y:0. }
		else
			return {
				x	: root.x + ( e.g.x + bwid*0.5 )*root.scaleX,
				y	: root.y + ( e.g.y + bhei*0.5 )*root.scaleY,
			}
	}

	public function addButton(label:String, ?iconId="iconTodoYellow", ?active=true, ?cb:Void->Void) {
		var g = new BatchGroup(sb,tsb);

		var w = bwid;
		var h = bhei;
		var padding = 10;
		var i = new h2d.Interactive(w, h, root);
		i.onRelease = function(e:hxd.Event) {
			if( locked || destroyed )
				return;

			if( !Game.ME.isDragging() ) {
				if( active ) {
					locked = true;
					// Blink current
					var blink = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0xFFA600), w,h), i );
					blink.tile.setCenterRatio(0.5, 0.5);
					blink.x = w*0.5;
					blink.y = h*0.5+5;
					blink.blendMode = Add;
					var a = tw.create(blink.alpha, 0, 100);
					a.onUpdateT = function(t) {
						blink.alpha = 1-t;
					}
					a.onEnd = function() {
						//close();
						locked = false;
						if( cb!=null )
							cb();
					};
				}
				Game.ME.cancelClick();
			}
			else
				Game.ME.onMouseUp(e);
		}
		i.onPush = function(e) {
			Game.ME.onMouseDown(e);
			if( Game.ME.drag!=null )
				Game.ME.drag.startedOverUi = true;
		}
		i.onWheel = Game.ME.onWheel;
		g.add(i);

		var bg = Assets.tiles.addBatchElement(sb, true||sideMode ? (active?"btnBlankBig":"btnBlankBig") : (active?"btnAction":"btnActionOff"),0, 0.5,0.5);
		bg.setSize(w,h);
		bg.setPos(w*0.5, h*0.5);
		g.add(bg);

		var icon = Assets.tiles.addBatchElement(sb, iconId,0, 0.5, 0.5);
		icon.setScale(55/icon.height);
		if( !active )
			icon.alpha = 0.5;
			//icon.color = h3d.Vector.fromColor(alpha(0x626B91), 1);
		icon.x = w*0.5;
		icon.y = 30;
		g.add(icon);

		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 21, label);
		tf.textColor = 0x1D2B49;
		tf.x = Std.int( w*0.5 - tf.textWidth*0.5*tf.scaleX );
		tf.y = Std.int( h-tf.textHeight*tf.scaleY-8 );
		tf.alpha = active ? 1 : 0.4;
		g.add(tf);

		elements.push({ g:g, active:active });
	}


	override function onResize() {
		super.onResize();
		updateCoords();
	}


	function updateCoords() {
		if( sideMode ) {
			root.setScale(  Main.getScale(bwid, sideMode ? 1.1 : 0.9) );
			root.x = Std.int( w()*0.5 - root.width*0.5 );
			root.y = Std.int( h() - root.height );
		}
		else {
			#if responsive
			root.setScale( Main.getScale(bwid, 1) );
			#else
			root.setScale( MLib.fmax( 0.5, Game.ME.totalScale*1.3 ) );
			#end
			var pt = Game.ME.sceneToUi(attachX, attachY);
			root.x = Std.int(pt.x - bwid*elements.length*root.scaleX*0.5);
			root.y = Std.int(pt.y);
		}
	}


	override function onDispose() {
		super.onDispose();

		for(e in elements)
			e.g.dispose();
		elements = null;

		sb.dispose();
		sb = null;
		tsb.dispose();
		tsb = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	override function update() {
		super.update();
		if( !sideMode )
			updateCoords();
	}
}