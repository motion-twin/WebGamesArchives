package ;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import mt.deepnight.Tip;
using As3Tools;
/**
 * ...
 * @author de
 */


class Gui
{
	public var		roomName 		: TextField;
	
	public var 		labels : Array<TextField>;
	public var		minimap : ui.Minimap;
	
	public var baseLine : Int;
	
	public var tip : mt.deepnight.Tip;
	
	
	static var fontSz = 10;
	
	public inline function H() return flash.Lib.current.stage.stageHeight;
	public inline function W() return flash.Lib.current.stage.stageWidth;
	
	public function new()
	{
		labels = [];
		labels.push( roomName = dfltTf() );
		
		var outline = function(f) FilterEx.outline( f, 0 );
		
		roomName.y = 4;
		
		var txtFmt:TextFormat = roomName.getTextFormat();
		txtFmt.font = "square";
		txtFmt.size = fontSz;
		roomName.setTextFormat( txtFmt );
		roomName.defaultTextFormat = txtFmt;
		
		roomName.visible = true;
		outline( roomName );
		
		baseLine = H();
		
		
		tip = new mt.deepnight.Tip();
		
		var bg = tip.spr.bg;
		var g :flash.display.Graphics = bg.graphics;
		
		//trace("truc");
		tip.bgFilters = [];
		g.clear();
		g.lineStyle(2, 0x3965fb, 1, true, flash.display.LineScaleMode.NONE,
		flash.display.CapsStyle.ROUND);
		g.beginFill(0x232564, Main.isHiFi() ? 0.9 : 1);
		g.drawRect(0, 0, 100, 100);
		
		var f = new flash.filters.GlowFilter();
		f.color = 0x0081e2;
		f.blurX = 16;
		f.blurY = 16;
		f.inner = true;
		f.alpha = 0.56;
		
		tip.bgFilters = [f];
	}
	
	public function showTip(msg:String, hand = true)
	{
		tip.show( msg);
		Main.guiStage().buttonMode = true;
		Main.guiStage().useHandCursor = hand;
	}
	
	public function hideTip()
	{
		tip.hide();
		Main.guiStage().buttonMode = false;
		Main.guiStage().useHandCursor = false;
	}
	
	public function setMinimap( onOff : Bool )
	{
		if( onOff )
		{
			if( minimap == null)
			{
				minimap = new ui.Minimap();
				Main.guiStage().addChild( minimap.preMc );
				Main.guiStage().addChild( minimap.mc );
				
				minimap.preMc.toFront();
				minimap.mc.toFront();
			}
		}
		else
		{
			if( minimap != null)
			{
				minimap.preMc.detach();
				minimap.mc.detach();
				minimap = null;
			}
		}
		Main.loadingScreen.toFront();
	}
	
	public function update()
	{
		var base = 40;
		
		roomName.x = 10;
		
		if( minimap != null)
			minimap.update();
			
		tip.update();
	}
	
	public function dfltTf()
	{
		var tf = new TextField();
		
		tf.textColor = 0xFFFFFF;
		tf.autoSize = TextFieldAutoSize.LEFT;
		
		tf.embedFonts = true;
		tf.text = "NOT_INITIALIZED";
		tf.x = 0;
		tf.y = -128;
		tf.visible = true;
		
		tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		tf.gridFitType = flash.text.GridFitType.SUBPIXEL;
		
		var txtFmt:TextFormat = tf.getTextFormat();
		txtFmt.font = "square";
		txtFmt.size = fontSz;
		tf.setTextFormat( txtFmt );
		tf.defaultTextFormat = txtFmt;

		tf.mouseEnabled = false;
		return tf;
	}
	

	public function init()
	{
		for( t in labels )
			Main.guiStage().addChild( t );
		Main.guiStage().addChild( tip.spr );
	}
}