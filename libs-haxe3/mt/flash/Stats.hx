package mt.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib;

class Stats extends Sprite
{
	public static var DEFAULT_COLOR = 0x333;
	public static var ALERT_COLOR = 0xE81700;
	public static var ALERT_FPS = 15;

	public static var WID	= 60;
	public static var HEI	= 50;
	public var updateFreq : Int;
	private var graph : BitmapData;

	private var fpsText : TextField;
	private var msText : TextField;
	private var memText : TextField;
	private var format : TextFormat;
	public var custom : TextField;

	private var fps : Int;
	private var timer : Int;
	private var ms : Int;
	private var msPrev : Int;
	private var mem : Float;
	var inAlert : Bool = false;

	public function new (?x=0, ?y=0, ?a=1.0, ?mouseEnabled=false) {
		super ();
		msPrev = 0; mem = 0;

		graph = new BitmapData( WID, HEI, false, 0x333 );
		var gBitmap:Bitmap = new Bitmap( graph );
		gBitmap.y = 45;
		addChild(gBitmap);

		format = new TextFormat( "_sans", 9 );
		drawBackground(DEFAULT_COLOR);
		fpsText = new TextField();
		msText = new TextField();
		memText = new TextField();
		custom = new TextField();

		fpsText.defaultTextFormat = custom.defaultTextFormat = msText.defaultTextFormat = memText.defaultTextFormat = format;
		fpsText.width = msText.width = memText.width = WID;
		fpsText.selectable = msText.selectable = memText.selectable = false;

		fpsText.textColor = 0xFFFF00;
		fpsText.text = "FPS: ";
		addChild(fpsText);

		msText.y = 10;
		msText.textColor = 0x00FF00;
		msText.text = "MS: ";
		addChild(msText);

		memText.y = 20;
		memText.textColor = 0x00FFFF;
		memText.text = "MEM: ";
		addChild(memText);

		custom.y = 30;
		custom.textColor = 0xffffff;
		custom.text = "N/A";
		addChild(custom);

		this.x = x;
		this.y = y;
		this.alpha = a;
		if(mouseEnabled)
			addEventListener(MouseEvent.CLICK, mouseHandler);
		else {
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		addEventListener(Event.ENTER_FRAME, update);
		updateFreq = 1000;
	}


	public function destroy() {
		if( parent!=null )
			parent.removeChild(this);

		removeEventListener(MouseEvent.CLICK, mouseHandler);
		removeEventListener(Event.ENTER_FRAME, update);

		graph.dispose();
		graph = null;
	}

	function drawBackground( color : Int )
	{
		graphics.clear();
		graphics.beginFill(color );
		graphics.drawRect(0, 0, WID, HEI /*50*/);
		graphics.endFill();
	}

	private function mouseHandler( e:MouseEvent ):Void
	{
		if (this.mouseY > this.height * .35)
			stage.frameRate --;
		else
			stage.frameRate ++;

		fpsText.text = "FPS: " + fps + " / " + stage.frameRate;
	}

	private function update( e:Event ):Void
	{
		timer = Lib.getTimer();
		fps++;

		if( timer - updateFreq > msPrev )
		{
			msPrev = timer;
			mem = Std.int ( ( System.totalMemory / 1048576 ) * 1000 ) / 1000;

			var fpsGraph : Int = Std.int (Math.min( HEI, HEI / (Lib.current.stage.frameRate*updateFreq/1000) * fps ));
			var memGraph : Int = Std.int (Math.min( HEI, Math.sqrt( Math.sqrt(mem * 5000 ) ) )) - 2;

			graph.scroll( 1, 0 );
			graph.fillRect( new Rectangle( 0, 0, 1, graph.height ), 0x333 );
			graph.setPixel( 0, graph.height - fpsGraph, 0xFFFF00);
			graph.setPixel( 0, graph.height - ( ( timer - ms ) >> 1 ), 0x00FF00 );
			graph.setPixel( 0, graph.height - memGraph, 0x00FFFF);

			var realFPS = fps * 1000 / updateFreq;
			if( !inAlert && realFPS <= ALERT_FPS )
			{
				inAlert = true;
				drawBackground( ALERT_COLOR );
			}
			else if( inAlert && realFPS > ALERT_FPS )
			{
				drawBackground( DEFAULT_COLOR );
			}

			fpsText.text = "FPS: " + (realFPS) + " / " + Lib.current.stage.frameRate;
			memText.text = "MEM: " + mem;

			fps = 0;
		}

		msText.text = "MS: " + (timer - ms);
		ms = timer;
	}
}
