/**
 * original author shanem (Shane McCartney) http://www.lostinactionscript.com/blog/index.php/2008/10/06/as3-swf-profiler/
 * ported to haXe by theRemix : http://remixtechnology.com
 * demo and source : http://remixtechnology.com/view/SWFProfiler_haXe
 *
 * Usage: SWFProfiler.init( ?inspector_object_starting_point:Dynamic );
 * Right-Click / Command-Click on the stage after SWFProfiler has been initialized.
 * Choose "Show Profiler" to open the SWFProfiler
 * Choose "Garbage Collector" to force gc().
 * if SWFProfiler is visible, choose "Hide Profiler" to remove it from stage.
 *
 * Initialize without optional parameter: SWFProfiler.init();
 * Will disable the Inspector function.
 *
 * To Enable the Inspector function, pass an object as the starting point to trace from.
 * SWFProfiler.init(this);
 *
 * in the inspector textinput, use standard dot notation starting from the object passed
 *  "field" or "object.field" or "object.object.field"
 *
 * the value of the field will display in the inspector value box (right half) if it exists
 * the text in the inspector textinput will turn red if the field/object does not exist
 *
 */

package com.remixtechnology;
import flash.Lib;
import flash.display.Stage;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.ContextMenuEvent;
import flash.events.EventDispatcher;
import flash.net.LocalConnection;
import flash.system.System;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import haxe.Timer;

class SWFProfiler {
	private static var itvTime : Int;
	private static var initTime : Int;
	private static var currentTime : Int;
	private static var frameCount : Int;
	private static var totalCount : Int;

	public static var minFps : Int;
	public static var maxFps : Int;
	public static var minMem : Float;
	public static var maxMem : Float;
	public static var history : Int = 60;
	public static var fpsList : Array<Int> = new Array<Int>();
	public static var memList : Array<Float> = new Array<Float>();

	private static var displayed : Bool = false;
	private static var started : Bool = false;
	private static var inited : Bool = false;
	private static var frame : Sprite;
	private static var stage : Stage;
	private static var content : ProfilerContent;
	private static var ci : ContextMenuItem;
	private static var gc_ci: ContextMenuItem;

	public static inline function init(?main = null) : Void {
		if (!inited){
			inited = true;
			stage = Lib.current.stage;
			content = new ProfilerContent(main);
			frame = new Sprite();
			minFps = maxFps = 0;
			maxMem = 0;
			minMem = currentMem;
			var cm : ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			ci = new ContextMenuItem("Show Profiler", true);
			ci.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, select_ci, false, 0, true);
			gc_ci = new ContextMenuItem("Garbage Collector");
			gc_ci.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, select_gc_ci, false, 0, true);
			cm.customItems = [ci,gc_ci];
			flash.Lib.current.contextMenu = cm;
			start();
		}
	}

	public static inline function start() : Void {
		if(!started){
		started = true;
		initTime = itvTime = Std.int(Timer.stamp());

		totalCount = frameCount = 0;

		frame.addEventListener(Event.ENTER_FRAME, frameLoop, false, 0, true);
		}
	}

	public static inline function stop() : Void {
		if(!started) return;

		started = false;

		frame.removeEventListener(Event.ENTER_FRAME, frameLoop);
	}

	public static var currentFps:Int;

	public static var currentMem(get_currentMem, never):Float;
	public static inline function get_currentMem() : Float {
		return (System.totalMemory / 1024) / 1000;
	}

	public static var averageFps(get_averageFps, never):Float;
	public static inline function get_averageFps() : Float {
		return totalCount / runningTime;
	}

	public static var runningTime(get_runningTime, never):Float;
	private static inline function get_runningTime() : Float {
		return (currentTime - initTime) ;
	}

	public static var intervalTime(get_intervalTime, never):Float;
	private static inline function get_intervalTime() : Float {
		return (currentTime - itvTime);
	}


	private static inline function select_ci(_) : Void {
		if(!displayed) {
			show();
		} else {
			hide();
		}
	}

	private static inline function select_gc_ci(_) : Void {
		System.gc();
		System.gc(); // i always see people do it twice
	}

	private static inline function show() : Void {
		ci.caption = "Hide Profiler";
		displayed = true;
		stage.addEventListener(Event.RESIZE, resize, false, 0, true);
		stage.addChild(content);
		updateDisplay();
	}

	private static inline function hide() : Void {
		ci.caption = "Show Profiler";
		displayed = false;
		stage.removeEventListener(Event.RESIZE, resize);
		stage.removeChild(content);
	}

	private static inline function resize(e:Event) : Void {
		content.update(runningTime, minFps, maxFps, minMem, maxMem, currentFps, currentMem, averageFps, fpsList, memList, history);
	}

	private static inline function frameLoop(_) : Void {
		currentTime = Std.int(Timer.stamp());
		frameCount++;
		totalCount++;

		if(intervalTime >= 1) {
			currentFps = frameCount;

			if(displayed) {
				updateDisplay();
			} else {
				updateMinMax();
			}
			fpsList.push(currentFps);
			memList.push(currentMem);

			if(fpsList.length > history) fpsList.shift();
			if(memList.length > history) memList.shift();

			itvTime = currentTime;
			frameCount = 0;
		}
	}

	private static inline function updateDisplay() : Void {
		updateMinMax();
		content.update(runningTime, minFps, maxFps, minMem, maxMem, currentFps, currentMem, averageFps, fpsList, memList, history);
	}

	private static inline function updateMinMax() : Void {
		maxFps = Std.int(Math.max(currentFps, maxFps));
		minMem = Math.min(currentMem, minMem);
		maxMem = Math.max(currentMem, maxMem);
	}
}


class ProfilerContent extends Sprite {

	private static inline var FPS_LINE_COLOR_HIGH = 0x33FF00;
	private static inline var FPS_LINE_COLOR_NORMAL = 0xFFEE33;//0x0099CC;
	private static inline var FPS_LINE_COLOR_LOW = 0xFF3333;
	private static inline var MEM_LINE_COLOR_LOW = 0x00CCFF;
	private static inline var MEM_LINE_COLOR_NORMAL = 0xFFEE33;//0x336699;
	private static inline var MEM_LINE_COLOR_HIGH = 0xFF3366;

	private var fpsLabel: TextField;
	private var minFpsTxtBx : TextField;
	private var maxFpsTxtBx : TextField;
	private var minMemTxtBx : TextField;
	private var maxMemTxtBx : TextField;
	private var memLabel: TextField;
	private var infoTxtBx : TextField;
	private var inspectLabel : TextField;
	private var inspectInputTxt : TextField;
	private static inline var exists_tf : TextFormat = new TextFormat("_sans", 9, 0x99CCFF);
	private static inline var undefined_tf : TextFormat = new TextFormat("_sans", 9, 0xFF88AA);
	private var box : Shape;
	private var fps : Shape;
	private var mb : Shape;
	private var main: Dynamic;
	private var boxHeight: Int;

	public function new(?_main:Dynamic = null) : Void {
		super();
		fps = new Shape();
		mb = new Shape();
		box = new Shape();
		main = _main;

		//this.mouseChildren = (main==null)?false:true; // not necessary
		this.mouseEnabled = false;

		fps.x = 65;
		fps.y = 45;
		mb.x = 65;
		mb.y = 90;
		boxHeight = (main==null)?100:120;

		var tf : TextFormat = new TextFormat("_sans", 9, 0xCCCCCC);

		minFpsTxtBx = new TextField();
		minFpsTxtBx.autoSize = TextFieldAutoSize.RIGHT;
		minFpsTxtBx.defaultTextFormat = tf;
		minFpsTxtBx.x = 60;
		minFpsTxtBx.y = 37;
		minFpsTxtBx.mouseEnabled = false;

		maxFpsTxtBx = new TextField();
		maxFpsTxtBx.autoSize = TextFieldAutoSize.RIGHT;
		maxFpsTxtBx.defaultTextFormat = tf;
		maxFpsTxtBx.x = 60;
		maxFpsTxtBx.y = 5;
		maxFpsTxtBx.mouseEnabled = false;

		fpsLabel = new TextField();
		fpsLabel.autoSize = TextFieldAutoSize.RIGHT;
		fpsLabel.defaultTextFormat = tf;
		fpsLabel.x = 50;
		fpsLabel.y = 16;
		fpsLabel.mouseEnabled = false;

		minMemTxtBx = new TextField();
		minMemTxtBx.autoSize = TextFieldAutoSize.RIGHT;
		minMemTxtBx.defaultTextFormat = tf;
		minMemTxtBx.x = 60;
		minMemTxtBx.y = 83;
		minMemTxtBx.mouseEnabled = false;

		maxMemTxtBx = new TextField();
		maxMemTxtBx.autoSize = TextFieldAutoSize.RIGHT;
		maxMemTxtBx.defaultTextFormat = tf;
		maxMemTxtBx.x = 60;
		maxMemTxtBx.y = 50;
		maxMemTxtBx.mouseEnabled = false;

		memLabel = new TextField();
		memLabel.autoSize = TextFieldAutoSize.RIGHT;
		memLabel.defaultTextFormat = tf;
		memLabel.x = 55;
		memLabel.y = 66;
		memLabel.mouseEnabled = false;

		addChild(box);
		addChild(fpsLabel);
		addChild(minFpsTxtBx);
		addChild(maxFpsTxtBx);
		addChild(memLabel);
		addChild(minMemTxtBx);
		addChild(maxMemTxtBx);
		addChild(fps);
		addChild(mb);

		if(main != null){
			infoTxtBx = new TextField();
			infoTxtBx.autoSize = TextFieldAutoSize.LEFT;
			infoTxtBx.defaultTextFormat = new TextFormat("_sans", 11, 0xCCCCCC);
			infoTxtBx.y = 98;
			infoTxtBx.x = 290;
			infoTxtBx.border = true;
			infoTxtBx.mouseEnabled = false;

			inspectLabel = new TextField();
			inspectLabel.autoSize = TextFieldAutoSize.LEFT;
			inspectLabel.defaultTextFormat = tf;
			inspectLabel.text = "Inspect Object :";
			inspectLabel.x = 7;
			inspectLabel.y = 98;
			inspectLabel.mouseEnabled = false;

			inspectInputTxt = new TextField();
			inspectInputTxt.type = flash.text.TextFieldType.INPUT;
			inspectInputTxt.defaultTextFormat = exists_tf;
			inspectInputTxt.text = "stage.frameRate";
			inspectInputTxt.x = 80;
			inspectInputTxt.y = 98;
			inspectInputTxt.width = 200;
			inspectInputTxt.height = 18;
			inspectInputTxt.mouseEnabled = true;

			addChild(infoTxtBx);
			addChild(inspectLabel);
			addChild(inspectInputTxt);
		}

		this.addEventListener(Event.ADDED_TO_STAGE, added, false, 0, true);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removed, false, 0, true);
	}

	public inline function update(runningTime : Float, minFps : Int, maxFps : Int, minMem : Float, maxMem : Float, currentFps : Int, currentMem : Float, averageFps : Float, fpsList : Array<Int>, memList : Array<Float>, history : Int) : Void {
		if(runningTime >= 1 && maxMem > 0) {
			minFpsTxtBx.text = Std.string(minFps);
			maxFpsTxtBx.text = Std.string(maxFps);
			minMemTxtBx.text = Std.string(minMem);
			maxMemTxtBx.text = Std.string(maxMem);
		}

		fpsLabel.text = Std.int(currentFps) + " FPS\n" + Std.int(averageFps) + " Avg";
		memLabel.text = currentMem + " Mb";

		if(main != null) updateInspector();

		var vec : Graphics = fps.graphics;
		vec.clear();

		var i : Int = 0;
		var len : Int = fpsList.length;
		var height : Int = 35;
		var width : Int = stage.stageWidth - 80;
		var inc : Float = width / (history - 1);
		var rateRange : Float = maxFps - minFps;
		var value : Float;

		for(i in 0...len) {
			value = (fpsList[i] - minFps) / rateRange;
			vec.lineStyle(1,
				if(value<=.7){
					FPS_LINE_COLOR_LOW;
				}else if(value>=.9){
					FPS_LINE_COLOR_HIGH;
				}else{
					FPS_LINE_COLOR_NORMAL;
				}, 0.7);
			if(i == 0) {
				vec.moveTo(width- (len-1-i) * inc, -value * height);
			} else {
				vec.lineTo(width- (len-1-i) * inc, -value * height);
			}
		}

		vec = mb.graphics;
		vec.clear();

		i = 0;
		len = memList.length;
		rateRange = maxMem - minMem;
		for(i in 0...len) {
			value = (memList[i] - minMem) / rateRange;
			vec.lineStyle(1,
				if(value<=.6){
					MEM_LINE_COLOR_LOW;
				}else if(value>=.95){
					MEM_LINE_COLOR_HIGH;
				}else{
					MEM_LINE_COLOR_NORMAL;
				}, 0.7);
			if(i == 0) {
				vec.moveTo(width- (len-1-i) * inc, -value * height);
			} else {
				vec.lineTo(width- (len-1-i) * inc, -value * height);
			}
		}
	}

	private inline function updateInspector(  ):Void
	{
		var obj:Dynamic = main;
		var obj_ar:Array<String> = inspectInputTxt.text.split(".");

		if(inspectInputTxt.text.lastIndexOf(".") > 0){
			for(i in 0...obj_ar.length){
				if(Reflect.hasField(obj, obj_ar[i])){
					if(i < obj_ar.length-1){
						inspectInputTxt.defaultTextFormat = exists_tf;
						obj = Reflect.field(obj, obj_ar[i]);
					}else{
						if(Reflect.hasField(obj, obj_ar[i])){
							inspectInputTxt.defaultTextFormat = exists_tf;
							infoTxtBx.text = Reflect.field(obj, obj_ar[i]);
						}
					}
					inspectInputTxt.text = inspectInputTxt.text;
				}else{
					inspectInputTxt.defaultTextFormat = undefined_tf;
					infoTxtBx.text = "";
					inspectInputTxt.text = inspectInputTxt.text;
					break;
				}
			}
		}else{
			if(Reflect.hasField(main,inspectInputTxt.text)){
				infoTxtBx.text = Reflect.field(main, inspectInputTxt.text);
				inspectInputTxt.defaultTextFormat = exists_tf;
			}else{
				inspectInputTxt.defaultTextFormat = undefined_tf;
				infoTxtBx.text = "";
			}
			inspectInputTxt.text = inspectInputTxt.text;
		}


	}

	private inline function added(e : Event) : Void {
		resize();
		stage.addEventListener(Event.RESIZE, resize, false, 0, true);
	}

	private inline function removed(e : Event) : Void {
		stage.removeEventListener(Event.RESIZE, resize);
	}

	private inline function resize(e : Event = null) : Void {
		var vec : Graphics = box.graphics;
		vec.clear();

		vec.beginFill(0x000000, 0.5);
		vec.drawRect(0, 0, stage.stageWidth, boxHeight);
		vec.lineStyle(1, 0xFFFFFF, 0.2);

		vec.moveTo(65, 45);
		vec.lineTo(65, 10);
		vec.moveTo(65, 45);
		vec.lineTo(stage.stageWidth - 15, 45);

		vec.moveTo(65, 90);
		vec.lineTo(65, 55);
		vec.moveTo(65, 90);
		vec.lineTo(stage.stageWidth - 15, 90);

		vec.endFill();
	}
}