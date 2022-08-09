package inter.pan;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;

typedef SlotResearch = {
	>flash.MovieClip,
	field:flash.TextField,
	ico:flash.MovieClip,
	bar:flash.MovieClip,
	cost:flash.MovieClip,
	cross:flash.MovieClip,
	but0:flash.MovieClip,
	but1:flash.MovieClip,
	time:flash.MovieClip,
	counter:Counter
};

class Research extends inter.Panel {//}
	var first:SlotResearch;

	public function new(){

		super();
		Inter.me.board.setSkin(3);
		display();
		height -=7;

	}

	override function display(){
		super.display();

		genTitle(Lang.TITLE_RESEARCH);
		cy += 1;
		genSlider(height+5-cy);

		var y = 0;

		first = null;
		var id = 0;

		var mainPlayer = Game.me.getPlayer();

		for( r in Game.me.research ){

			var mc:SlotResearch = cast slider.dm.attach("slotResearch",0);
			var sdm = new mt.DepthManager(mc);
			var tid = Type.enumIndex(r._type);

			mc._x = 0;
			mc._y = y;
			mc.bar._xscale = 0;

			mc.field.text = Lang.RESEARCH[tid];


			mc.time = sdm.empty(10);
			mc.time._x = 190;
			mc.time._y = 64;
			Filt.glow(mc.time, 2, 4, 0x060606);

			y += 93;

			if(first==null && Game.me.world.data._mode == MODE_PLAY){
				first = mc;
				mc.counter = r._counter;
			}else{
				mc.bar._xscale = r._progress*100;
				var time = GamePlay.getTechnoSearchTime( r._type )*Game.me.searchRate*(1-r._progress);
				Cs.genTime(mc.time, time,true, false  );
				updateTimePos(mc);
			}

			// CROSS
			mc.but0.onPress = callback(incPriority,id,-1);
			mc.but1.onPress = callback(incPriority,id,1);

			// ICO
			mc.ico.gotoAndStop( tid+1 );
			var ico = new mt.DepthManager(mc.ico).attach("mcResearchVig",0);
			ico.gotoAndStop( tid+1 );

			// TEC
			Inter.me.makeHint(mc.ico,Lang.IGH_RESEARCH[tid]);

			//
			id++;
		}
		updateSliderMin();
	}

	override function update(){
		var o = Game.me.getCounterInfo(first.counter);

		Cs.genTime(first.time, o.run, true, false  );
		//
		updateTimePos(first);
		first.bar._xscale = o.c*100;

		if( Inter.me.isReady() &&  o.c == 1 && Api.isReady() ){
			Inter.me.initLoading();
			Api.getStatus(Inter.me.module.display);
		}

		updateSlider();
	}

	function updateTimePos(mc:SlotResearch){
		mc.time._x  = 158-mc.time._width*0.5;
	}

	public function incPriority(id,n){
		var nid = id+n;
		if( nid >= 0 && nid < Game.me.research.length ){
			Api.swapResearch(id,id+n, display);
		}
	}
//{
}















