import flash.display.Sprite;
import flash.display.MovieClip;

import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.deepnight.SuperText;

import HomeCustomizerData;

private class ColorPicker extends Sprite {
	var man				: Manager;
	
	var target			: String;
	var hc				: HomeCustomizer;
	
	public function new(hc:HomeCustomizer, id:String) {
		super();
		
		target = id;
		this.hc = hc;
		Manager.ME.dm.add(this, Const.DP_INTERF);
		
		var cw = 12;
		var ch = 10;
		filters = [
			new flash.filters.DropShadowFilter(2,-90, 0x0,0.3, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,1, 2,2,6)
		];

		var colors = HomeCustomizerData.getColors();
		colors.push(0);
				
		var x = 0;
		var y = 0;
		for(c in colors) {
			var s = new Sprite();
			addChild(s);
			s.graphics.beginFill(c>0 ? c : 0xC9C9C9, 1);
			s.graphics.drawRect(0,0,cw,ch);
			s.x = x*cw;
			s.y = y*ch;
			s.buttonMode = s.useHandCursor = true;
			s.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) s.filters = [ new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10, 1,true) ] );
			s.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) s.filters = [ new flash.filters.DropShadowFilter(1, -90, 0xFFFFFF,0.15, 0,0,1, 1,true) ] );
			s.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
				Manager.ME.cancelClick = true;
				if( c<=0 ) {
					Manager.SBANK.cancel().play();
					hc.sendColor(target, 0);
				}
				else {
					Manager.SBANK.actionSelect().play();
					hc.sendColor(target, c);
				}
			});
			s.filters = [ new flash.filters.DropShadowFilter(1, -90, 0xFFFFFF,0.15, 0,0,1, 1,true) ];
			x++;
			if( x>=HomeCustomizerData.HUES ) {
				x = 0;
				y++;
			}
		}
		
		this.x = Std.int( Const.WID*0.4 - width*0.5 );
		this.y = -height;
		Manager.TW.create(this, "y", 10, 200);
	}
}


class HomeCustomizer {
	public var wrapper		: Sprite;
	var man					: Manager;

	var level				: Int;
	var buttons				: Array<{isActive:Void->Bool, spr:Sprite}>;
	var skinnables			: Array<{id:String, name:String, mc:MovieClip, allowColors:Bool, allowedFrames:Array<Int>, curFrameIndex:Int, curColor:Int}>;
	var wid					: Int;
	var hei					: Int;
	var cp					: Null<ColorPicker>;
	var replications		: Array<{id:String, mc:MovieClip}>;
	
	public function new(l) {
		man = Manager.ME;
		level = l;
		
		debug("homeLevel "+level);
		
		wrapper = new Sprite();
		man.dm.add(wrapper, Const.DP_INTERF);
		buttons = new Array();
		skinnables = new Array();
		replications = new Array();
		
		wid = 160;
		hei = 16;

		wrapper.x = Const.WID-wid-10;
		wrapper.y = 10;
	}
	
	public function isEmpty() {
		return buttons.length<=1;
	}
	
	public function setVisibility(b) {
		wrapper.visible = b;
	}
	
	
	public function attachButtons() {
		var open = false;
		createButton(Tx.CustomizeHome, true, function() {
			if( isEmpty() ) {
				Manager.SBANK.error01().play();
				man.message(Tx.NothingToCustomize);
			}
			else {
				open = !open;
				if( open )
					man.tweenScroll(4,2, 800);
				else
					man.centerScroll(800);
					
				if( man.globalTimer!=null )
					man.globalTimer.wrapper.visible = !open;
				if( open )
					Manager.SBANK.actionSelect().play();
				else
					Manager.SBANK.cancel().play(0.5);
					
				if( !open )
					removeColorPicker();
				
				for(i in 1...buttons.length) {
					var bt = buttons[i];
					var a = bt.isActive() ? 1 : 0.3;
					man.tw.create(bt.spr, "alpha", open ? a : 0, 300);
					bt.spr.mouseChildren = bt.spr.mouseEnabled = open;
				}
			}
		});
		
		
		for(inf in skinnables) {
			// Frame button
			if( inf.allowedFrames.length>1 ) {
				var bt = createButton(inf.name, function() {
					removeColorPicker();
					Manager.SBANK.actionSelect().play(0.5);
					nextFrame(inf.id);
					for(b2 in buttons)
						b2.spr.alpha = b2.isActive() ? 1 : 0.3;
				});
				bt.spr.mouseChildren = bt.spr.mouseEnabled = false;
				bt.spr.alpha = 0;
			}
			// Color button
			if( inf.allowColors ) {
				var bt = createButton("  > "+Tx.Color, 8, function() {
					removeColorPicker();
					if( !skinnableCanBeColored(inf.id) ) {
						Manager.SBANK.error01().play();
						man.message(Tx.CannotColorizeThis);
					}
					else {
						Manager.SBANK.actionSend().play(0.5);
						cp = new ColorPicker(this, inf.id);
					}
				});
				bt.isActive = function() return skinnableCanBeColored(inf.id);
				bt.spr.mouseChildren = bt.spr.mouseEnabled = false;
				bt.spr.alpha = 0;
			}
		}
	}
	
	inline function debug(str:String) {
		if( !man.prod ) trace(str);
	}
	
	public function applyClientInit(cinit:Common.ClientInit) {
		for(inf in cinit._home._t) {
			debug("apply "+inf._k+" frame="+inf._f+" col="+inf._c);
				
			var sk = getSkinnable(inf._k);
			if( sk==null )
				throw "no skinnable object found for "+inf._k;
			

			// Frame
			if( inf._f>0 ) {
				var fidx = -1;
				for(i in 0...sk.allowedFrames.length)
					if( sk.allowedFrames[i]==inf._f ) {
						fidx = i;
						break;
					}
				if( fidx<0 )
					throw "invalid frame "+inf._f+" for "+inf._k;
				sk.curFrameIndex = fidx;
				applyFrame(inf._k, inf._f);
			}

			// Color
			if( inf._c!=null ) {
				sk.curColor = inf._c;
				applyColor(inf._k, inf._c);
			}

		}
	}
	
	
	function onServerReply(b:Bool) {
		debug("onServerReply: "+b);
	}
	
	function onServerError(e:Dynamic) {
		man.message(Tx.HomeCustomFailed+"\n\n(errcode: "+e+")");
		Manager.SBANK.error01().play();
	}
	
	
	public function nextFrame(id:String) {
		var sk = getSkinnable(id);
		if( sk==null )
			throw "skinnable object not found for "+id;
			
		var mc = sk.mc;
		sk.curFrameIndex++;
		if( sk.curFrameIndex >= sk.allowedFrames.length )
			sk.curFrameIndex = 0;
			
		var frame = sk.allowedFrames[sk.curFrameIndex];
		applyFrame(id, frame);
		applyColor(id, sk.curColor);
		var data : Common.HomeRequest = {
			_id	: id,
			_f : frame,
			_col : null,
		}
		tools.Codec.load("http://" + man.cinit._extra._urlHome, data, onServerReply, onServerError, 5) ;
	}
	
	
	public function sendColor(id:String, col:Int) {
		if( applyColor(id,col) ) {
			getSkinnable(id).curColor = col;
			var data : Common.HomeRequest = {
				_id	: id,
				_f : null,
				_col : col,
			}
			tools.Codec.load("http://" + man.cinit._extra._urlHome, data, onServerReply, onServerError, 5) ;
		}
	}
	
	
	function getSkinnable(id:String) {
		for(s in skinnables)
			if( s.id==id )
				return s;
		return null;
	}
	
	function skinnableCanBeColored(id:String) {
		var sk = getSkinnable(id);
		if( sk==null )
			return false;
		return Reflect.field(sk.mc, "_colorize") != null;
	}
	
	
	public function applyColor(id:String, c:Int) : Bool {
		var sk = getSkinnable(id);
		if( sk==null ) {
			return false;
		}
			
		var mc = sk.mc;
		if( !skinnableCanBeColored(id) ) {
			mc.filters = [];
			for(rmc in getReplications(id))
				rmc.filters = [];
			return false;
		}

		mc.filters = c<=0 ? [] : cast [ Color.getColorizeMatrixFilter(c, 0.8, 0.2) ];
		for(rmc in getReplications(id))
			rmc.filters = c<=0 ? [] : cast [ Color.getColorizeMatrixFilter(c, 0.8, 0.2) ];
			
		return true;
	}
	
	public function applyFrame(id:String, f:Int) : Bool {
		var sk = getSkinnable(id);
		if( sk==null )
			return false;
			
		var mc = sk.mc;
		mc.gotoAndStop(f);
		var smc : MovieClip = Reflect.field(mc, "_colorize");
		if( smc!=null )
			smc.visible = false;
			
		for(rmc in getReplications(id)) {
			rmc.gotoAndStop(f);
			var smc : MovieClip = Reflect.field(rmc, "_colorize");
			if( smc!=null )
				smc.visible = false;
		}
			
		return true;
	}
	
	
	function getReplications(id:String) {
		var a = [];
		for(o in replications)
			if( o.id==id )
				a.push(o.mc);
		return a;
	}
	
	
	function removeColorPicker() {
		if( cp!=null ) {
			cp.parent.removeChild(cp);
			cp = null;
		}
	}

	
	public inline function associateData(mc:MovieClip, id:String) {
		var data = HomeCustomizerData.getAvailableValues(id, level);
		skinnables.push({
			id				: id,
			name			: HomeCustomizerData.getName(id),
			mc				: mc,
			allowColors		: data.colors,
			allowedFrames	: data.frames,
			curFrameIndex	: 0,
			curColor		: 0,
		});
		applyFrame(id, 1);
	}
	
	public inline function addReplication(mc:MovieClip, id:String) {
		replications.push({
			mc	: mc,
			id	: id,
		});
		applyFrame(id, 1);
	}
	
	
	function createButton(label:String, ?margin=false, ?indent=0, cb:Void->Void) {
		var bt = new Sprite();
		wrapper.addChild(bt);
		var button = {isActive:function() return true, spr:bt};
		buttons.push(button);
		
		bt.useHandCursor = bt.buttonMode = true;
		bt.filters = [ new flash.filters.GlowFilter(0x0,0.3, 8,8,1) ];
		bt.x = indent;
		bt.y = (buttons.length-1)*(hei+1);
		
		var bg = new Sprite();
		bt.addChild(bg);
		bg.graphics.beginFill(0x0, 0.8);
		bg.graphics.drawRect(0,0, wid-indent,hei);
		if( margin ) {
			bg.graphics.beginFill(0x0080FF,1);
			bg.graphics.drawRect(-4,0,4,hei);
		}
		
		var stf = new SuperText();
		stf.setFont(0xFFFFFF, "small", 8);
		stf.x = 2;
		stf.setText(label);
		stf.autoResize();
		bt.addChild(stf.wrapper);
		
		bt.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
			man.cancelClick = true;
			cb();
		});
		bt.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) bg.transform.colorTransform = Color.getColorizeCT(0xBC311D, 1) );
		bt.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) bg.transform.colorTransform = new flash.geom.ColorTransform() );
		return button;
	}
	
	
	public function lock() {
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
		wrapper.alpha = 0.2;
	}
	public function unlock() {
		wrapper.mouseChildren = wrapper.mouseEnabled = true;
		wrapper.alpha = 1;
	}
}
