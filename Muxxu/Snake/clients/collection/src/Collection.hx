import Protocole;
import mt.bumdum9.Lib;

//using mt.deepnight.SuperMovie;

class Collection  extends flash.display.Sprite{//}
	
	static public var WIDTH = 400;
	static public var HEIGHT = 208;
	static public var MOTION_SPEED = 0.05;


	public var dm:mt.DepthManager;
	public var buts:Array<ButSec>;
	public var motion:Bool;
	
	var fxm:mt.fx.Manager;
	var action:Void->Void;
	var module:Module;
	var step:Int;
	
	public static var me:Collection;
	
	public function new() {
		super();
		me = this;
		dm = new mt.DepthManager(this);
		
		//
		motion = false;
		
		// BG
		graphics.beginFill(Gfx.col("green_0"));
		graphics.drawRect(0, 0, WIDTH, HEIGHT);

		buts = [];
		for( id in 0...4 ) {
			var but = new ButSec(id);
			but.y = id * ButSec.SIDE;
			dm.add(but, 1);
			but.action = callback(openSection, id);
			buts.push(but);
		}
		
		fxm = new mt.fx.Manager();
		addEventListener(flash.events.Event.ENTER_FRAME,update);
		
		//
		buts[0].select(null);
	}
	
	public function openSection(id) {
		var sens = 1;
		
		if( module != null ) {
			sens = (module.mid < id)?-1:1;
			var fx = new mt.fx.Tween(module, module.x, HEIGHT * sens, MOTION_SPEED);
			fx.onFinish = module.kill;
			fx.curveInOut();
		}
		
		
		switch(id) {
			case 0 :	module = new mod.CardDisplay(Main.data._cards);
			case 1 :	module = new mod.Market();
			case 2 : 	module = new mod.Lottery();
			case 3 : 	module = new mod.Bazar();
		}
		
		module.mid = id;
		module.y = -HEIGHT*sens;
		var fx = new mt.fx.Tween(module, module.x, 0, MOTION_SPEED);
		fx.curveInOut();
		fx.onFinish = function() { Collection.me.motion = false; me.module.init(); };
		
		motion = true;
	}

	
	function closeModule() {
		if( module == null ) return;
		removeChild(module);
		module = null;
	}
	
	//
	function update(e) {
		
		fxm.update();
		var a = pix.Sprite.all.copy();
		for( sp in a ) sp.update();
		
		
		module.update();
	}

	

	
//{
}



	class ButSec extends flash.display.MovieClip {
		public static var SIDE = 52;
		
		var id:Int;
		var bg:pix.Element;
		public var icon:pix.Element;
		var title:flash.text.TextField;
		public var action:Void->Void;
		
		public function new(id) {
			
			this.id = id;
			super();
			blendMode = flash.display.BlendMode.LAYER;
			
			// GFX
			bg = new pix.Element();
			bg.drawFrame(Gfx.collection.get("section_bg_small"),0,0);
			icon = new pix.Element();
			icon.drawFrame(Gfx.collection.get(id, "section_icons"));
			icon.x = SIDE * 0.5;
			icon.y = SIDE * 0.5 + 3;
			
			// FIELD
			title = Main.getField(0xFFFFFF, 8, -1, "nokia");
			title.text = Lang.COLLECTION_SECTIONS[id];
			title.width = title.textWidth + 3;
			title.x = Std.int((SIDE - title.width) * 0.5);
			title.y = -1;
			title.filters = [ new flash.filters.GlowFilter(Gfx.col("green_2"), 1, 4, 4, 40) ];
			
			// ADD
			addChild(bg);
			addChild(icon);
			addChild(title);
			
			// EVENTS
			addEventListener( flash.events.MouseEvent.CLICK, select );
			
		}
		
		public function select(e) {
			if( !mouseEnabled || Collection.me.motion ) return;
			light();
			action();
		}
		
		function light() {
			for( b in Collection.me.buts ) if( b != this ) b.unlight();
			title.textColor = 0xFFFFFF;
			Filt.glow(icon, 4, 400, 0xFFFFFF);
			new mt.fx.Flash(icon,0.07);
			new mt.fx.Flash(bg,0.15);
			mouseEnabled = false;
		}
		public function unlight() {

			title.textColor = Gfx.col("green_0");
			icon.filters = [];
			mouseEnabled = true;
		}
		
		
	}








