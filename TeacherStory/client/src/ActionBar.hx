import Common;

import flash.display.Sprite;
import mt.deepnight.SpriteLib;

class Action {
	public var value		: Dynamic;
	public var label		: String;
	public var count		: Int;
	public var spr			: Sprite;
	public var cd			: Int;
	public var cdField		: Null<flash.text.TextField>;
	public var icon			: Null<flash.display.MovieClip>;
	public var cost			: Int;
	
	public var onClick		: Void->Void;
	public var onOver		: Void->Void;
	public var onOut		: Void->Void;
	public var isAvailable	: Void->Bool;
	public var isVisible	: Void->Bool;
	public var isPending	: Void->Bool;
	public var allowShuffleAnim	: Void->Bool;
	
	public var priority		: Int;
	public var highlight	: Bool;
	
	public function new(v:Dynamic, l:String, ?n=-1) {
		value = v;
		label = l;
		count = n;
		cost = 0;
		spr = new Sprite();
		cd = 0;
		priority = 0;
		highlight = false;
		
		onClick = function() {}
		onOver = function() {}
		onOut = function() {}
		isAvailable = function() return true;
		isVisible = function() return true;
		isPending = function() return false;
		allowShuffleAnim = function() return true;
	}
	
	public function setHighlight(b:Bool) {
		highlight = b;
		if( b )
			spr.filters = [
				mt.deepnight.Color.getContrastFilter(0.3),
				new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,4, 1,true),
				new flash.filters.GlowFilter(0x2FC6FF,1, 4,4,4),
				new flash.filters.GlowFilter(0x41C0F1,0.9, 16,16,2, 2),
			];
	}
}


class ActionBar extends flash.display.Sprite {
	public static var ALL : Array<ActionBar> = new Array();
	
	var man					: Manager;
	public var barName		: String;
	public var actions		: Array<Action>;
	var wrapper				: Sprite;
	public var barLocked(default,null)	: Bool;
	
	public var bwid			: Int;
	public var bhei			: Int;
	public var offColor		: Int;
	
	public var sizeLimit	: Int;
	
	var shuffleAnims		: Array<{a:Action, mc:lib.Jackpot, loopSound:mt.deepnight.Sfx}>;
	
	public var canUnlock	: Void->Bool;
	public var showLabel	: Bool;
	
	public function new(bname:String) {
		super();
		barName = bname.toUpperCase();
		man = Manager.ME;
		actions = new Array();
		bwid = bhei = 40;
		barLocked = false;
		sizeLimit = 10;
		//scroll = 0;
		offColor = 0x4B4E58;
		showLabel = true;
		shuffleAnims = new Array();
		wrapper = new Sprite();
		addChild(wrapper);
		
		canUnlock = function() return true;
		
		ALL.push(this);
	}
	
	public override function toString() {
		return barName + " : " + Lambda.map(actions, function(a) return a.label).join(",");
	}
	
	public function empty() {
		for(a in actions) {
			a.spr.parent.removeChild(a.spr);
		}
		actions = new Array();
	}
	
	public function sortActions( sortFunc:Action->Action->Int ) {
		actions.sort(function(a,b) {
			return sortFunc(a, b);
		});
	}
	
	public function addAction(a:Action) {
		actions.push(a);
		addChild(a.spr);
	}
	
	public function getButton(value:Dynamic) : Sprite {
		var a = getAction(value);
		return a==null ? null : a.spr;
	}
	
	public function getAction(value:Dynamic) : Action {
		for(a in actions) {
			if(a.value==value)
				return a;
		}
		return null;
	}
	
	public function getActionCoordinate(value:Dynamic) : {x:Int, y:Int} {
		var mc = getButton(value);
		if( mc==null )
			return null;
		
		var pt = mc.localToGlobal( new flash.geom.Point(0,0) );
		return {
			x	: Std.int(pt.x + bwid*0.5),
			y	: Std.int(pt.y + bwid*0.5)
		}
	}
	
	public function attachActions() {
		for(a in actions)
			a.spr.parent.removeChild(a.spr);
		
		for(a in actions) {
			a.spr = new Sprite();
			wrapper.addChild(a.spr);
			
			var hit = new Sprite();
			a.spr.addChild(hit);
			hit.graphics.beginFill(0x0, 0);
			hit.graphics.drawRect(-1,-1,bwid+2,bhei+2);
			
			var s = new Sprite();
			a.spr.addChild(s);
			
			if( a.icon!=null ) {
				s.addChild(a.icon);
				//a.icon.x = Std.int( bwid*0.5-a.icon.width*0.5 );
				//a.icon.y = showLabel ? 0 : Std.int( bhei*0.5-a.icon.height*0.5 );
			}
			
			if( a.label!=null && (showLabel || a.icon==null)) {
				var tf = man.createField(a.label);
				s.addChild(tf);
				tf.width = bwid;
				tf.height = bhei;
				//if( !showBg )
					//tf.textColor = color;
				tf.multiline = tf.wordWrap = true;
				tf.height = tf.textHeight+4;
				if( a.icon==null )
					tf.y = Std.int( bhei*0.5-tf.textHeight*0.5 - 2 );
				else {
					tf.x = Std.int( bwid*0.5-tf.textWidth*0.5 - 2 );
					tf.y = Std.int(a.icon.height);
				}
				tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.6, 2,2) ];
			}
			
			// Quantité en stock
			if( a.count>0 ) {
				var c = new Sprite();
				var w = 13;
				a.spr.addChild(c);
				
				var tf = man.createField("99", true);
				c.addChild(tf);
				tf.text = Std.string(a.count);
				tf.x = Std.int(w*0.5-tf.textWidth*0.5-1);
				
				//var off = !a.isAvailable() || barLocked;
				var col = a.count==0 ? 0x743D6B : 0x313780;
				c.graphics.beginFill(col, 1);
				c.graphics.drawRoundRect(0,0,w, tf.textHeight+2, 8,8);
				//if( off )
					//c.alpha = 0.5;
				c.filters = [
					new flash.filters.GlowFilter(0xffffff,0.4, 2,2,10, 1,true),
					//new flash.filters.GlowFilter(col,0.7, 2,2,10),
				];
				c.x = Std.int( bwid*0.8 - w*0.5 );
				c.y = Std.int( bhei - 12 );
			}
			
			// Prix
			if( a.count==0 && a.cost>0 ) {
				var c = new Sprite();
				var w = 30;
				a.spr.addChild(c);
				
				var tf = man.createField(Tx.BuyLabel, true);
				c.addChild(tf);
				tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2,2,4) ];
				c.x = Std.int( bwid*0.5 - tf.textWidth*0.5+2 );
				c.y = bhei - 12;
			}
		
			// Compteur CD
			var tf = man.createField("999", FBig, true);
			a.spr.addChild(tf);
			tf.y = Std.int( bhei*0.5 - tf.textHeight*0.5*tf.scaleY );
			tf.filters = [
				new flash.filters.GlowFilter(0x0,0.9, 4,4,5)
			];
			//tf.blendMode = flash.display.BlendMode.OVERLAY;
			a.cdField = tf;

			a.spr.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) {
				if( !barLocked )
					a.onOver();
				if( !barLocked && !a.isPending() && a.isAvailable() )
					a.spr.filters = [ new flash.filters.GlowFilter(0xFFC600,1, 4,4,2) ];
			});
			a.spr.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) {
				a.onOut();
				a.highlight = false;
				if( !a.isPending() )
					a.spr.filters = [];
			});
			a.spr.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
				onActionClicked(a);
			});
			//man.actions.push(a);
			//if( !isActionVisible(a.a.id) )
				//a.spr.visible = false;
			//else
		}
		//unlockAll();
		unlock();
		updateActions();
	}
	
	public function onActionClicked(a:Action) {
		if( barLocked || !a.isAvailable() )
			return;
		a.onClick();
		man.cancelClick = true;
	}
	
	//function getDefaultFilters(a:Action<T>) : Array<flash.filters.BitmapFilter> {
		//return
			//if( isPending(a.value) )
			//else
				//[];
	//}
	
	function countVisibles() {
		var n = 0;
		for(a in actions)
			if( a.isVisible() )
				n++;
		return n;
	}
	
	public function getVisibles() {
		var arr = [];
		for(a in actions)
			if( a.isVisible() )
				arr.push(a);
		return arr;
	}
	
	public function getWidth() {
		return countVisibles()*(bwid+1);
	}
	
	
	public function shuffleAnim(?val:Dynamic) {
		if( man.cm.turbo )
			return;
		var x = 0;
		for(a in actions) {
			if( a.isVisible() && a.allowShuffleAnim() ) {
				if( val==null || a.value==val ) {
					if( val==TAction.MoreSlots )
						continue;
					var mc = new lib.Jackpot();
					addChild(mc);
					mc.x = (bwid+1)*x;
					var sfx = Manager.SBANK.shuffleLoop();
					shuffleAnims.push({a:a, mc:mc, loopSound:sfx});
					sfx.play(0.1);
				}
				x++;
			}
		}
		man.delayer.add( stopshuffleAnim, 500 );
	}
	
	function stopshuffleAnim() {
		var i = 0;
		for(c in shuffleAnims) {
			man.delayer.add( function() {
				man.tw.terminate(c.a.spr);
				c.a.spr.y = 3;
				man.tw.create(c.a.spr, "y",0, TElasticEnd, 100);
				c.mc.parent.removeChild(c.mc);
				c.loopSound.stop();
				Manager.SBANK.shuffleEnd().play(0.4);
			}, i*300);
			i++;
		}
		shuffleAnims = [];
	}
	
	
	public function updateActions() {
		var x = 0;
		var idx = 0;
		for(a in actions) {
			//if( idx>=scroll && idx<scroll+sizeLimit ) {
				a.spr.x = x * (bwid+1);
				a.spr.y = a.isPending() ? -3 : 0;
				a.spr.visible = a.isVisible();
				a.spr.buttonMode = a.spr.useHandCursor = a.isAvailable() && !barLocked;
				a.cdField.visible = man.at(Class) && a.cd!=0 && a.cd<99;
				if( a.isPending() ) {
					a.spr.filters = [
						new flash.filters.GlowFilter(0xFFFFFF,1, 4,4, 10),
						new flash.filters.GlowFilter(0xFFCF0F,1, 8,8, 1),
						new flash.filters.GlowFilter(0xFF6F0F,1, 32,16, 1),
					];

					a.spr.parent.setChildIndex(a.spr, a.spr.parent.numChildren-1);
				}
				else
					if( a.highlight )
						a.setHighlight(true);
					else
						a.spr.filters = [];
					
				if( a.cd!=0 ) {
					a.cdField.text = Std.string(a.cd);
					a.cdField.x = Std.int( bwid*0.5 - a.cdField.textWidth*0.5*a.cdField.scaleX - 2 );
				}
				
				if( a.icon!=null ) {
					if( !a.isAvailable() || barLocked )
						a.icon.filters = [
							mt.deepnight.Color.getSaturationFilter(-1),
							mt.deepnight.Color.getContrastFilter(-0.5),
							mt.deepnight.Color.getColorizeMatrixFilter(offColor, 1, 0),
						];
					//else if( a.count==0 )
						//a.icon.filters = [
							//mt.deepnight.Color.getContrastFilter(-0.3),
							//mt.deepnight.Color.getColorizeMatrixFilter(offColor, 0.7, 0.3),
						//];
					else
						a.icon.filters = [];
				}
				if( a.spr.visible )
					x++;
			//}
			//else
				//a.spr.visible = false;

			idx++;
		}
		
		// Flèches de scrolling
		//var vis = countVisibles();
		//if( vis>sizeLimit ) {
			//scrollLeft.setFrame(scroll>0 ? 0 : 1);
			//scrollRight.setFrame(scroll<vis-sizeLimit ? 0 : 1);
			//scrollRight.x = (bwid+1)*sizeLimit;
		//}
		//else {
			//scrollLeft.visible = scrollRight.visible = false;
		//}
	}
	
	public function length() {
		return actions.length;
	}
	
	public function lock() {
		barLocked = true;
		updateActions();
	}
	
	public function unlock() {
		barLocked = false;
		updateActions();
	}
	
	public static function lockAll() {
		for(b in ALL)
			b.lock();
	}
	public static function unlockAll() {
		for(b in ALL)
			if( b.canUnlock() )
				b.unlock();
	}
	public static function updateAll() {
		for(b in ALL)
			b.updateActions();
	}
}

