class mode.SoccerSelector extends Mode {
	var world		: levels.SetManager;
	var views		: Array<levels.View>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);

		world = new levels.SetManager(manager, "xml_soccer");
		var bg = depthMan.attach("hammer_special_bg", Data.DP_BACK_LAYER);
		bg.gotoAndStop( ""+(Data.BG_SOCCER+1) );
		bg._width	= Data.DOC_WIDTH;
		bg._height	= Data.DOC_HEIGHT;


		views = new Array();
		for (var i=0;i<4;i++) {
			world.goto(i);
			var v = new levels.View(world,depthMan);
			v.fl_fast = false;
			v.fl_hideBorders = true;
			v.display(i);
			v.scale(0.35);
			v.moveTo( 15+250*(i%2),  20 + 300* ((i>1)?1:0) );
			v._back.onRelease = callback(this, onSelect, i);
			v._back.onRollOver = callback(this, onOver, i);
			v._back.onRollOut = callback(this, onOut, i);
			views.push(v);
		}
	}


	/*------------------------------------------------------------------------
	EVENT: SELECTION
	------------------------------------------------------------------------*/
	function onSelect(n:int) {
		manager.startGameMode( new mode.Soccer(manager, n) );
	}


	/*------------------------------------------------------------------------
	EVENT: ROLLOVER
	------------------------------------------------------------------------*/
	function onOver(n:int) {
		FxManager.addGlow( views[n]._back, 0xffffff, 4 );
	}

	/*------------------------------------------------------------------------
	EVENT: ROLLOUT
	------------------------------------------------------------------------*/
	function onOut(n:int) {
		views[n]._back.filters = [];
	}


	/*------------------------------------------------------------------------
	BOUCLE
	------------------------------------------------------------------------*/
	function main() {
		super.main();
	}


}

