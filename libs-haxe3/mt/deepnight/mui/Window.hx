package mt.deepnight.mui;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

class Window extends VGroup {
	public static var CLICKTRAP_COLOR = 0x0;
	public static var CLICKTRAP_ALPHA = 0.8;

	var clickTrap	: Null<Sprite>;
	var onClickTrap	: Null<Window->Void>;

	var autoCenterX	: Bool;
	var autoCenterY	: Bool;

	public function new(container:DisplayObjectContainer, ?hasClipTrap=true, ?onClickTrap:Window->Void) {
		if( hasClipTrap ) {
			clickTrap = new Sprite();
			container.addChild(clickTrap);
			setClickTrap(CLICKTRAP_COLOR, CLICKTRAP_ALPHA);
			clickTrap.addEventListener( flash.events.MouseEvent.CLICK, function(_) onClickClickTrap() );
			if( onClickTrap!=null )
				this.onClickTrap = onClickTrap;
		}

		super(container);

		autoCenterX = autoCenterY = true;
		wrapper.visible = false;
	}

	function onClickClickTrap() {
		if( onClickTrap!=null )
			onClickTrap(this);
	}

	public function setOnClickTrap(cb:Void->Void) {
		if( clickTrap!=null )
			onClickTrap = function(_) cb();
	}

	public function setAutoCenter(horizontal:Bool, vertical:Bool) {
		autoCenterX = horizontal;
		autoCenterY = vertical;
		askRender(false);
	}

	public function setClickTrap(col:Int, ?alpha=0.9) {
		if( clickTrap!=null ) {
			clickTrap.graphics.clear();
			clickTrap.graphics.beginFill(col, alpha);
			clickTrap.graphics.drawRect(0,0,100,100);
		}
	}

	override function set_x(v) {
		autoCenterX = false;
		return super.set_x(v);
	}

	override function set_y(v) {
		autoCenterY = false;
		return super.set_y(v);
	}

	override function prepareRender() {
		super.prepareRender();

		if( wrapper.stage!=null ) {
			var w = getWidth();
			var h = getHeight();
			var sw = wrapper.stage.stageWidth;
			var sh = wrapper.stage.stageHeight;

			if( clickTrap!=null ) {
				clickTrap.width = sw;
				clickTrap.height = sh;
			}

			// Alignment
			if( autoCenterX ) {
				x = sw*0.5-w*scale*0.5;
				autoCenterX = true;
			}
			if( autoCenterY ) {
				y = sh*0.5-h*scale*0.5;
				autoCenterY = true;
			}
		}
		else
			askRender(true);
	}

	override function show() {
		super.show();
		if( clickTrap!=null )
			clickTrap.visible = true;
	}

	override function hide() {
		super.hide();
		if( clickTrap!=null )
			clickTrap.visible = false;
	}

	override function destroy() {
		super.destroy();

		if( clickTrap!=null ) {
			clickTrap.parent.removeChild(clickTrap);
			clickTrap = null;
		}
	}
}