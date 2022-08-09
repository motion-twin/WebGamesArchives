package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.VGroup;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.MLib;
import mt.Metrics;
import TeamInfos;

class Tutorial extends mt.deepnight.FProcess {
	var game			: Game;
	var wrapper			: Sprite;
	var curMsg			: Null<Bitmap>;
	var curPhase		: Int;
	var focus			: Bitmap;
	var clickToResume(default,set)	: Bool;
	var triggerChain	: Array<{p:Perk, phase:Int}>;
	var eventChain		: Array<Void->Void>;

	public function new(g:Game) {
		super();
		game = g;
		curPhase = -1;
		triggerChain = [];
		eventChain = [];

		wrapper = new Sprite();
		root.addChild(wrapper);
		wrapper.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onClick );

		clickToResume = false;

		focus = new Bitmap();
		wrapper.addChild(focus);
		focus.visible = false;

		onResize();
	}

	function set_clickToResume(v) {
		root.mouseChildren = root.mouseEnabled = v;
		return clickToResume = v;
	}

	override function unregister() {
		hideMessage();

		super.unregister();
		wrapper.removeEventListener( flash.events.MouseEvent.CLICK, onClick );

		if( curMsg!=null ) {
			curMsg.parent.removeChild(curMsg);
			curMsg.bitmapData.dispose(); curMsg.bitmapData = null;
		}
		focus.bitmapData.dispose(); focus.bitmapData = null;
	}

	public inline function getWidth() return MLib.ceil( Const.WID/Const.UPSCALE );
	public inline function getHeight() return MLib.ceil( Const.HEI/Const.UPSCALE );


	function onClick(_) {
		if( cd.has("click") )
			return;

		hideFocus();
		if( clickToResume ) {
			clickToResume = false;
			game.resume();
			if( triggerChain.length>0 ) {
				var t = triggerChain.shift();
				trigger(t.p, t.phase);
			}
			else if( eventChain.length>0 )
				eventChain.shift()();

		}
	}

	public function triggerById(id:String, e:Entity) {
		if( Global.ME.playerCookie.hasTutoFlag(id) )
			return;

		Global.ME.playerCookie.setTutoFlag(id);
		switch( id ) {
			case "yellowCard" :
				setMessage( Lang.TutoFaultYellow_0 );
				focusEntity(e);
				eventChain = [
					function() {
						setMessage( Lang.TutoFaultYellow_1 );
						focusEntity(e);
					},
					function() {
						hideMessage();
					}
				];

			case "redCard" :
				setMessage( Lang.TutoFaultRed_0 );
				focusEntity(game.ball);
				eventChain = [
					function() {
						hideMessage();
					}
				];

			case "star" :
				setMessage( Lang.TutoFaultStarPlayer_0 );
				focusEntity(e);
				eventChain = [
					function() {
						hideMessage();
					}
				];

			default : trace("Unknown tutorial flag "+id);
		}
	}



	public function trigger(tutoPerk:Perk, phase:Int) {
		if( game.oppTeam.hasPerk(tutoPerk) && curPhase==phase-1 ) {
			curPhase = phase;

			switch( tutoPerk ) {
				case _PTuto1 :
					switch( curPhase ) {
						case 0 :
							setMessage( Lang.Tuto1_0 );
							focusFree(game.hud.button0.x+game.hud.button0.width*0.5, game.hud.button0.y+game.hud.button0.height*0.5, 70, false);

						case 1 :
							setMessage( Lang.Tuto1_1 );
							delayer.add( function() {
								focusEntity( game.ball );
							}, 100);

						case 2 :
							setMessage( Lang.Tuto1_2 );
					}

				case _PTuto2 :
					switch( curPhase ) {
						case 0 :
							setMessage( Lang.Tuto2_0 );
							focusCase(Const.FWID*0.3, Const.FHEI*0.5, 80);

						case 1 :
							setMessage( Lang.Tuto2_1 );
							focusFree(game.hud.button0.x+game.hud.button0.width*0.5, game.hud.button0.y+game.hud.button0.height*0.5, 70, false);

						case 2 :
							setMessage( Lang.Tuto2_2 );
							hideFocus();
					}


				case _PTuto3 :
					switch( curPhase ) {
						case 0 :
							setMessage( Lang.Tuto3_0 );
							focusEntity(game.ball.owner);

						case 1 :
							setMessage( Lang.Tuto3_1 );
							focusEntity(game.ball.owner);

						case 2 :
							setMessage( Lang.Tuto3_2 );
							focusEntity(en.Player.getActive(0));

						case 3 :
							setMessage( Lang.Tuto3_3 );

						case 4 :
							setMessage( Lang.Tuto3_4 );
					}

				case _PTutoMatch :
					switch( curPhase ) {
						case 0 :
							setMessage( Lang.TutoMatch_0, 50 );
							focusFree(80, 30, 100);

						case 1 :
							setMessage( Lang.TutoMatch_1, 50 );
							focusFree(80, 30, 100);

						case 2 :
							setMessage( Lang.TutoMatch_2, 50 );
							focusFree(getWidth()-80, 30, 100);

						case 3 :
							hideMessage();
					}


				case _PTutoElectric :
					switch( curPhase ) {
						case 0 :
							setMessage( Lang.TutoElec_0 );
							focusEntity(game.ball);

						case 1 :
							setMessage( Lang.TutoElec_1 );
							focusEntity(game.ball);

						case 2 :
							setMessage( Lang.TutoElec_2 );
							focusEntity(game.ball);

						case 3 :
							hideMessage();
					}


				default :
			}
		}
	}

	public function chain(p:Perk, i:Int) {
		if( game.oppTeam.hasPerk(p) )
			if( i==curPhase+1 || triggerChain.length>0 && i==triggerChain[triggerChain.length-1].phase+1 )
				triggerChain.push({ p:p, phase:i });
	}

	public function complete() {
		if( curPhase>=0 )
			hideMessage();
	}

	public function getEntityPosition(e:Entity) {
		return {
			x	: e.xx+game.scroller.x,
			y	: e.yy+game.scroller.y,
		}
	}

	override function onResize() {
		super.onResize();

		if( wrapper==null )
			return;

		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;

		if( focus.bitmapData!=null )
			focus.bitmapData.dispose();
		focus.bitmapData = new BitmapData(getWidth(), getHeight(), true, 0x0);
	}

	inline function focusEntity(e:Entity, ?r) {
		var pt = getEntityPosition(e);
		focusFree(pt.x, pt.y, r);
	}


	inline function focusCase(cx:Float, cy:Float, ?r) {
		focusFree((Const.FPADDING+cx)*Const.GRID + game.scroller.x, (Const.FPADDING+cy)*Const.GRID + game.scroller.y, r);
	}



	function focusFree(x:Float,y:Float, ?r=50., ?pauseGame=true) {
		clickToResume = pauseGame;
		if( pauseGame )
			game.pause();

		tw.terminateWithoutCallbacks(focus.alpha);
		focus.visible = true;
		focus.alpha = 0;
		tw.create(focus.alpha, 1, 200);

		var bd = focus.bitmapData;
		if( pauseGame ) {
			bd.fillRect(bd.rect, Color.addAlphaF(Const.BG_COLOR, 0.7));
			focus.blendMode = NORMAL;

			var hole = new Sprite();
			hole.graphics.beginFill(0x00FF00,1);
			hole.graphics.drawCircle(0,0, r);
			hole.x = x;
			hole.y = y;

			bd.draw(hole, hole.transform.matrix, flash.display.BlendMode.ERASE);
			bd.applyFilter( bd, bd.rect, pt0, new flash.filters.BlurFilter(8,8) );
		}
		else {
			bd.fillRect(bd.rect, 0x0);
			focus.blendMode = ADD;

			var s = new Sprite();
			s.graphics.lineStyle(6, 0xFFFF80, 1);
			s.graphics.drawCircle(x,y, r);

			bd.draw(s);
			bd.applyFilter( bd, bd.rect, pt0, new flash.filters.GlowFilter(0xFFC600,1, 16,16,2, 2) );
			bd.applyFilter( bd, bd.rect, pt0, new flash.filters.GlowFilter(0xFF8000,1, 64,64,3, 2) );
		}
	}

	function hideFocus() {
		tw.terminateWithoutCallbacks(focus.alpha);
		tw.create(focus.alpha, 0, 400).onEnd = function() {
			focus.visible = false;
		}
	}

	public inline function hasMessage() {
		return curMsg!=null;
	}

	function hideMessage() {
		if( curMsg!=null ) {
			var bmp = curMsg;
			curMsg = null;
			tw.create(bmp.y, -bmp.height, 400).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose(); bmp.bitmapData = null;
			}
		}
	}

	public inline function getMessageHeight() {
		return curMsg!=null ? curMsg.y + curMsg.height : 0;
	}

	public function setMessage(msg:String, ?topMargin=5) {
		hideMessage();
		cd.set("click", 5);

		var w = getWidth()/2;
		var s = new Sprite();
		var tf = Global.ME.createField(msg,FBig);
		s.addChild(tf);
		if( !Global.ME.getFont().cyrillic ) {
			var f = tf.getTextFormat();
			f.leading = -6;
			tf.setTextFormat(f);
			tf.defaultTextFormat = f;
		}
		tf.multiline = true;
		tf.width = w-5;
		tf.height = MLib.fmax(tf.textHeight+5, 23);
		tf.x = Std.int(w*0.5 - tf.textWidth*0.5);

		s.graphics.beginFill(0x312D68, 1);
		s.graphics.drawRect(0,0, w, tf.height);
		s.filters = [
			new flash.filters.GlowFilter(0x464095,1, 2,2,10),
		];

		curMsg = Lib.flatten(s, 1);
		curMsg.bitmapData = Lib.scaleBitmap(curMsg.bitmapData, 2, true);
		wrapper.addChild(curMsg);
		curMsg.x = -2;
		curMsg.y = getHeight();

		tw.create(curMsg.y, topMargin, 500);
	}

	override function update() {
		super.update();
		if( focus.visible && !clickToResume /*&& !tw.exists(focus,"alpha")*/ ) { // TODO
			focus.alpha = 0.6 + Math.cos(time*0.4)*0.4;
		}
	}
}