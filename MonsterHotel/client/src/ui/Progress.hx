package ui;

import mt.deepnight.Tweenie;
import mt.MLib;
import Game;
import com.Protocol;
import h2d.SpriteBatch;

class Progress extends mt.Process {
	public var ratio(default,null)	: Float;
	public var width(default,null)	: Float;
	public var height(default,null)	: Float;
	var bg					: BatchElement;
	var bar					: BatchElement;
	public var x(get,set)	: Float;
	public var y(get,set)	: Float;
	public var fxId			: Null<String>;

	public function new() {
		super(Game.ME);

		name = "progressBar";
		width = 200;
		height = 15;
		fxId = "yellowDot";

		ratio = 0;

		bg = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, "uiLoadingBarBg", 0);

		bar = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, "uiLoadingBar", 0);
		bar.scaleX = 0.1;

		if( Game.ME.isVisitMode() )
			hide();
	}

	public inline function hide() bg.visible = bar.visible = false;
	public inline function show() bg.visible = bar.visible = !Game.ME.isVisitMode();

	function set_x(v) {
		var v = Std.int(v);
		bg.x = v;
		bar.x = v+21;
		return v;
	}
	function set_y(v) {
		var v = Std.int(v);
		bg.y = v;
		bar.y = v+6;
		return v;
	}
	inline function get_x() return bg.x;
	inline function get_y() return bg.y;

	public function set(r:Float) {
		r = MLib.fclamp(r,0,1);
		if( r!=ratio ) {
			var d = MLib.fabs(ratio-r)<=0.1 ? 400 : 100;
			ratio = r;
			tw.create(bar.scaleX, ratio, d);
		}
	}

	public function setDuration(start:Float, end:Float) {
		//if( time%30==0 )
			//trace(Game.ME.realTime+" "+Date.fromTime(start)+" "+Date.fromTime(end));
		set( (Game.ME.serverTime-start)/(end-start) );
	}

	override function onDispose() {
		super.onDispose();

		bar.remove();
		bar = null;

		bg.remove();
		bg = null;
	}

	override function update() {
		super.update();

		if( fxId!=null && itime%3==0 && bar.visible )
			Game.ME.fx.bar(fxId, bar.x + ratio*width, y + height*0.5);
	}
}