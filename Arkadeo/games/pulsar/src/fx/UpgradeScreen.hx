package fx;
import Protocol;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
using mt.bumdum9.MBut;
import api.AKProtocol;
import api.AKApi;

class BmpSkills extends BMD {}

private typedef USlot =  { el:gfx.Tuiles, upg:UpgradeType };

private typedef DataUpgrade =  { id:UpgradeType, desc:String };


enum UpgradeMode {
	UM_Choice;
	UM_Auto;
}

class UpgradeScreen extends mt.fx.Sequence {

	public static var WIDTH = 540;
	public static var HEIGHT = 400;
	public static var BY = 300;
	public static var SLOT_WIDTH = 80;
	public static var SLOT_HEIGHT = 48;
	public static var DATA_UPG = ods.Data.parse("data.ods", "upgrades", DataUpgrade);

	var gfx:mt.pix.Store;
	var count:Int;
	var screen:SP;
	var inventory:Array<USlot>;
	var choices:Array<USlot>;
	var availables:Array<UpgradeType>;
	var desc:TF;
	var instructions:TF;
	
	var mode : UpgradeMode;
	
	public function new( mode : UpgradeMode ) {
		super();
		this.mode = mode;
		// SCREEN
		screen = new SP();
		Game.me.dm.add(screen, Game.DP_BG);
		screen.graphics.beginFill(0);
		screen.graphics.drawRect(0, 0, WIDTH, HEIGHT );
		screen.x = (Game.WIDTH - WIDTH) >> 1;
		screen.y = (Game.HEIGHT - HEIGHT) >> 1;
		new mt.fx.Spawn(screen, 0.1, true);
		//
		desc = TField.get(0xFFFFFF);
		desc.y = BY + 16 + SLOT_HEIGHT;
		desc.multiline = desc.wordWrap = true;
		screen.addChild(desc);
		// INIT RUN STATE
		if( AKApi.getLevel() == 3 )	Game.me.runState.upgrades.push(BONUS_TIME_FIRST);
		if( AKApi.getLevel() == 6 )	Game.me.runState.upgrades.push(BONUS_TIME_SECOND);
		//
		initAll();
	}
	
	
	function initAll() {
		// AVAILABLES
		availables = Type.allEnums(UpgradeType);
		availables.remove(BONUS_TIME_FIRST);
		availables.remove(BONUS_TIME_SECOND);
		// BUILD INVENTORY
		inventory = [];
		switch( mode ) {
			case UM_Choice:
				// FIELDS
				instructions = TField.get(0x888888);
				instructions.text = Texts.pickUpgrade;
				instructions.width = instructions.textWidth + 4;
				instructions.x = Std.int(WIDTH - instructions.textWidth) >> 1;
				instructions.y = BY - 16;
				screen.addChild(instructions);
				//
				count = Cs.MALUS_PER_PLAY;
				for( upg in Game.me.runState.upgrades ) {
					var pos = getNextInventoryPos();
					var sl = getSlot(upg);
					sl.el.x = pos.x;
					sl.el.y = pos.y;
					inventory.push(sl);
					availables.remove(upg);
				}
				initChoice();
			case UM_Auto :
				var validButton = new gfx.InventoryButton();
				validButton.gotoAndStop(1);
				validButton.x = Std.int(Game.WIDTH / 2 - validButton.width / 2);
				validButton.y = BY;
				validButton.makeSimpleButton(function() {
					screen.blendMode = flash.display.BlendMode.LAYER;
					var e = new mt.fx.Vanish(screen, 16, 10,true);
					e.onFinish = finish;
				});
				screen.addChild(validButton);
				//
				for( i in 0...api.AKApi.getLevel()-1 ) {
					var upg = availables[Game.me.seed.random(availables.length)];
					var pos = getNextInventoryPos();
					var sl = getSlot(upg);
					sl.el.x = pos.x;
					sl.el.y = pos.y;
					sl.el.makeBut(	function(){}, //NOTHING
									function() {
										Filt.glow(sl.el, 4, 2, 0xFFFFFF);
										setDesc( Texts.ALL.get(DATA_UPG[Type.enumIndex(upg)].desc) );
									},
									function() {
										setDesc("");
										sl.el.filters = [];
									}
								);
					inventory.push(sl);
					availables.remove(upg);
				}
		}
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				var id = AKApi.getEvent();
				if( id != null ) choose(id);
			case 1 : // WAIT
		}
	}
	
	inline static var PADDING = 5;
	function initChoice() {
		step = 0;
		instructions.text = Texts.pickUpgrade;
		instructions.width = instructions.textWidth + 4;
		instructions.x = Std.int(WIDTH - instructions.textWidth) >> 1;
		// CHOICES
		choices = [];
		var max = Game.me.have(CHOICE_MINUS_ONE) ? 2 : 3;
		var a = availables.copy();
		var mx = (WIDTH - max * SLOT_WIDTH) >> 1;
		for( i in 0...max ) {
			var index = Game.me.seed.random(a.length);
			var upg = a[index];
			a.splice(index, 1);
			var sl = getSlot(upg);
			sl.el.x = mx + i * (SLOT_WIDTH + PADDING);
			sl.el.y = BY;
			sl.el.makeBut(	function() {
								trace("test click");
								AKApi.emitEvent(i);
							},
							function() {
								Filt.glow(sl.el, 4, 2, 0xFFFFFF);
								setDesc( Texts.ALL.get(DATA_UPG[Type.enumIndex(upg)].desc) );
							},
							function() {
								setDesc("");
								sl.el.filters = [];
							}
						);
			choices.push(sl);
		}
	}
	
	function choose(id:Int) {
		count--;
		nextStep();
		var sl = choices[id];
		var pos = getNextInventoryPos();
		var e = new mt.fx.Tween(sl.el, pos.x, pos.y, 0.05);
		e.curveInOut();
		e.onFinish = callback(next, sl);
		
		Game.me.runState.upgrades.push(sl.upg);
		inventory.push(sl);
		choices.remove(sl);
		availables.remove(sl.upg);
		
		setDesc("");
		instructions.text = "";
		
		for( sl in choices ) new mt.fx.Vanish(sl.el, 10, 10, true);
	}
	
	function next(sl:USlot) {
		new mt.fx.Flash(sl.el);
		if( count > 0 ) {
			initChoice();
		} else {
			screen.blendMode = flash.display.BlendMode.LAYER;
			var e = new mt.fx.Vanish(screen, 16, 10,true);
			e.onFinish = finish;
		}
	}
	
	function finish() {
		kill();
		Game.me.initPlay();
	}
	
	function setDesc(str) {
		desc.text = str;
		desc.width = WIDTH - 40;
		if( instructions != null )
			desc.height = instructions.textHeight + 4;
		desc.x = Std.int(WIDTH - desc.textWidth) >> 1;
	}
	
	// TOOLS
	function getNextInventoryPos() {
		var col = 6;
		var mx = (WIDTH - (SLOT_WIDTH + PADDING) * col) >> 1;
		return {
			x: mx + (inventory.length % col) * (SLOT_WIDTH + PADDING),
			y: 12 + Std.int(inventory.length / col) * (SLOT_HEIGHT + PADDING),
		}
	}
	
	function getSlot(upg:UpgradeType) {
		var el = new gfx.Tuiles();
		el._Bg.gotoAndStop(1);
		el.gotoAndStop( Type.enumIndex(upg) + 1 );
		screen.addChild(el);
		return {el:el, upg:upg}
	}
}

