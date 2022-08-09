package mt.deepnight.mui;

import flash.display.Sprite;
import mt.MLib;

class Joystick extends Component {
	var base		: Sprite;
	var stick		: Sprite;
	var dx			: Float;
	var dy			: Float;
	var radius		: Int;
	var drag		: Null<{x:Float, y:Float}>;
	var onScroll	: Float->Float->Void; // dx,dy
	
	var stage		: flash.display.Stage;
	
	
	private function new(p, onScroll:Float->Float->Void) {
		super(p);
		
		radius = 8;
		minWidth = minHeight = radius*2;
		dx = dy = 0;
		this.onScroll = onScroll;
		
		hasBackground = false;
		
		base = new Sprite();
		wrapper.addChild(base);
		base.mouseChildren = base.mouseEnabled = false;
		
		stick = new Sprite();
		wrapper.addChild(stick);
		
		color = 0x3F849A;
		if( parent!=null )
			color = mt.deepnight.Color.brightnessInt(parent.color, 0.3);
		
		base.graphics.clear();
		base.graphics.beginFill(0x0, 0.5);
		base.graphics.drawCircle(0,0,radius);
		base.graphics.beginFill(mt.deepnight.Color.brightnessInt(color, -0.3), 1);
		base.graphics.drawCircle(0,0,radius*0.7);
		
		stick.graphics.clear();
		stick.graphics.beginFill(color, 1);
		stick.graphics.drawCircle(0,0,radius*1.1);
		
		stick.buttonMode = stick.useHandCursor = true;
		stick.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown );
		
		stage = stick.stage;
		stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		stage.addEventListener( flash.events.MouseEvent.MOUSE_MOVE, onMouseMove );
	}
	
	
	override function destroy() {
		stage.removeEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		stage.removeEventListener( flash.events.MouseEvent.MOUSE_MOVE, onMouseMove );
		super.destroy();
	}

	
	function getMouse() {
		return {
			x	: wrapper.stage.mouseX,
			y	: wrapper.stage.mouseY,
		}
	}
	
	
	function onGrab() {
		drag = getMouse();
		addState("drag");
		stick.addEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
	}
	
	
	function onRelease() {
		removeState("drag");
		stick.removeEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
	}
	
	
	function onMouseDown(e:flash.events.MouseEvent) {
		e.stopPropagation();
		onGrab();
	}
	
	
	function onMouseUp(e:flash.events.MouseEvent) {
		if( hasState("drag") )
			onRelease();
	}
	
	
	function onMouseMove(_) {
		if( !hasState("drag") )
			return;
			
		var m = getMouse();
		
		dx += 0.5 * (m.x-drag.x);
		dy += 0.5 * (m.y-drag.y);
		
		var off = getOffset();
		dx = off.dx*radius;
		dy = off.dy*radius;
		
		drag = getMouse();
		askRender(false);
	}
	
	function onEnterFrame(_) {
		var off = getOffset();
		onScroll(off.dx, off.dy);
	}
	
	function getOffset() {
		return {
			dx	: MLib.fmax(-1, MLib.fmin(1, dx/radius)),
			dy	: MLib.fmax(-1, MLib.fmin(1, dy/radius)),
		}
	}
	
	override function prepareRender() {
		super.prepareRender();
	}
	
	override function renderContent(w,h) {
		super.renderContent(w,h);
		
		var r = MLib.fmin(w,h);
		
		stick.x = radius + dx*0.7;
		stick.y = radius + dy*0.7 - 3;
		
		base.x = radius;
		base.y = radius;
		
		if( !hasState("drag") ) {
			dx*=0.7;
			dy*=0.7;
		}
		
		if( MLib.fabs(dx)<=0.3 )
			dx = 0;
			
		if( MLib.fabs(dy)<=0.3 )
			dy = 0;
		
		if( dx!=0 || dy!=0 )
			askRender(false);
	}
	
	
}
