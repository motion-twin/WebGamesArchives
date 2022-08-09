package ui;

import mt.MLib;
import Game;
import com.Protocol;
import mt.deepnight.Lib;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

#if !dprot
//#error "Should not be compiled without -D dprot"
#end

class NetworkDebug extends H2dProcess {
	public static var CURRENT : NetworkDebug;

	var bwid				: Int;
	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;

	public function new() {
		CURRENT = this;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		name = "NetworkDebug";
		bwid = 64;

		var e = addToggle("Sending", function(v) {
			Game.ME.blockSend = !v;
		});

		var e = addToggle("Receiving", function(v) {
			Game.ME.blockReceive = !v;
		});
		e.y = 40;


		// Pending button
		var i = new h2d.Interactive(250,32, root);
		i.backgroundColor = alpha(0x5C5FA3);
		i.y = 80;
		var tf = Assets.createText(24, 0xFFFFFF, "???", i);
		tf.x = 5;
		createTinyProcess(function(_) {
			if( time%5==0 )
				tf.text = "Send pendings ("+Game.ME.pendingCmds.length+")";
		});
		i.onClick = function(_) {
			if( Game.ME.pendingCmds.length>0 )
				Game.ME.flushNetworkBuffer();
		}

		onResize();
	}



	function addToggle(label:String, onToggle:Bool->Void) {
		var v = true;
		var i = new h2d.Interactive(200,32, root);
		var s = new h2d.Graphics(i);
		var tf = Assets.createText(24, "???", i);
		tf.x = 40;

		function _redraw() {
			s.clear();
			s.beginFill(v?0x00FF40:0xFF0000);
			s.drawRect(0,0, 32,32);
			tf.text = label+": "+(v?"ON":"off");
			tf.textColor = v?0x00FF00:0xFF0000;
		}
		_redraw();

		i.onClick = function(_) {
			v = !v;
			onToggle(v);
			_redraw();
		}
		return i;
	}


	override function unregister() {
		super.unregister();

		if( CURRENT==this )
			CURRENT = null;
	}


	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(bwid, 0.7) );
		root.x = 10;
		root.y = 100;
	}

	override function update() {
		super.update();
	}
}

