package inter;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;

typedef McText = {>flash.MovieClip,field:flash.TextField};

typedef Slot = { >flash.MovieClip, pic:flash.MovieClip, fieldTitle:flash.TextField, dm:mt.DepthManager };


class Panel {//}

	var cy:Float;
	//public var width:Float;
	public var height:Float;
	public var root:{ >flash.MovieClip, bg:flash.MovieClip, brd:flash.MovieClip };


	public var slots:Array<Slot>;
	var slotSkins:Array<flash.MovieClip>;

	var content:flash.MovieClip;
	var mdm:mt.DepthManager;
	var dm:mt.DepthManager;
	var mcTitle:McText;
	var board:inter.Board;

	var ml:Dynamic;

	public function new(){
		Inter.me.panel = this;
		if( Inter.me.board==null ){
			var b = new inter.Board(2);
		}

		board = Inter.me.board;
		board.setPanel(this);
		root = cast Inter.me.board.dm.empty(Board.DP_PANEL);
		root.stop();

		mdm = new mt.DepthManager(root);
		height = 466;

		root.bg.onPress = function(){}
		root.useHandCursor = true;

		ml = {};
		Reflect.setField(ml,"onMouseWheel", scrollWheel);
		flash.Mouse.addListener(cast ml);
	}

	public function display(){
		content.removeMovieClip();
		content = mdm.empty(0);
		dm = new mt.DepthManager(content);
		cy = 0;
		slotSkins = [];
		//Inter.me.displayIcons();
	}

	public function update(){
		updateSlider();
	}

	// TITLE
	function genTitle(str:String){
		cy+=17;
		mcTitle = cast dm.attach("mcPanelTitle",0);
		mcTitle._y = cy+8;
		mcTitle.smc._xscale = inter.Board.WIDTH;
		mcTitle.field._width = inter.Board.WIDTH;
		mcTitle.field.text = Lang.tuc( str );
		cy+=43;
	}

	// TEXT
	function genText(str,flDark=false){
		var m = 20;
		var mc:McText = cast dm.attach("mcPanelText",0);
		mc._x = m;
		mc._y = cy;
		mc.field._width = inter.Board.WIDTH-2*m;
		mc.field.htmlText = str;
		mc.field._height = mc.field.textHeight+8;
		mc.field.textColor = flDark?Cs.COLOR_PANEL_TEXT_DARK:Cs.COLOR_PANEL_TEXT;
		cy += mc.field._height;
		return mc.field;

	}
	function genSeparator(){
		var mc = dm.attach("mcSeparator",0);
		mc._y = cy+2;
		mc._xscale = inter.Board.WIDTH;
		cy += 6;
	}

	// BUTTON

	function genButton(str,f){
		var hh = 24;
		var mc:McText = cast dm.attach(Cs.gil("mcYellowButton"),0);
		mc._x = inter.Board.WIDTH*0.5;
		mc._y = cy+hh*0.5;

		var field:flash.TextField = cast(mc).field;
		field.text = str;
		Trick.makeButton(mc,f);

		return mc;

	}



	// SLOT
	function displaySlots(max){


		var mod = 2;
		var ww  = 105;
		var hh  = 92;
		var mx = 11;//(width - ww*mod)/(mod+1);

		slots = [];
		for( id in 0...max ){
			var mc:Slot = cast slider.dm.attach(Cs.gil("slotBld"),1);
			slots.push(mc);
			mc._x = mx+(id%mod)*ww;
			if(id%mod>0)slider.dm.under(mc);
			mc._y = Std.int(id/mod)*hh;
			mc.dm = new mt.DepthManager(mc);
			slotSkins.push(mc);
			initSlot(mc,id);

		}
		updateSliderMin();

	}
	function initSlot(mc,id){

	}
	function displaySlotCost(slot:Slot,rawcost){
		var cost = {
			_material:rawcost.material,
			_cloth:rawcost.cloth,
			_ether:rawcost.ether,
			_population:rawcost.population,
		}
		var a = [cost._material,cost._cloth,cost._ether,cost._population];
		var cid = 0;
		var y = 17;
		for( n in a ){
			if(n!=null && n>0 ){
				//var mmc = sdm.attach("mcResSticker",0);
				var mmc = slot.dm.attach("mcCapsule",0);
				mmc._x = 83;
				mmc._y = y ;
				//mmc.gotoAndStop([4,3,2,5][cid]);
				mmc.gotoAndStop([2,3,4,1][cid]);
				Reflect.setField(mmc,"_val",n);
				y+=18;
				Filt.glow(mmc,2,1,0x025286);
			}
			cid++;
		}

		// POP
		/*
		var max = cost._population;
		var ec = Math.min(37/(max-1),7);
		for( i in 0...max ){
			var mc = sdm.attach("mcIcoPop",0);
			mc._x = 87+i*ec;
			mc._y = y+6;//75;
			Filt.glow(mc,2,4,0x025286);
			mc.blendMode = "layer";
			mc._alpha = 75;

		}
		*/




	}

	function rOverSlot(mc:Slot){
		Filt.glow(mc.pic,4,0.5,0xFFFFFF,true);
		Filt.glow(mc.pic,2,4,0xFFFFFF);
		Filt.glow(mc.pic,10,0.5,0xFFFFFF);
		Col.setColor(mc,0,10);
	}
	function rOutSlot(mc:Slot){
		mc.pic.filters = [];
		Col.setColor(mc,0,0);
	}

	// SLIDER
	var slider:{
		>flash.MovieClip,
		ymin:Float,
		ymax:Float,
		dm:mt.DepthManager,
		mask:flash.MovieClip,
		scroll:flash.MovieClip,
		bar:{
			>flash.MovieClip,
			by:Float,
			space:Float,
			flScroll:Bool
		}
	};
	static public var sliderPosSave:Float;

	function genSlider(h){
		//h = bot-cy;
		slider = cast dm.empty(0);
		slider.ymax = cy;
		slider._y = slider.ymax;
		slider.dm = new mt.DepthManager(slider);
		// MASK
		slider.mask = dm.attach("mcMask",0);
		slider.mask._y = cy;
		slider.mask._xscale = inter.Board.WIDTH;
		slider.mask._yscale = h;
		slider.setMask(slider.mask);
		//
		cy += h;
		//
		if(sliderPosSave!=null){
			slider._y = sliderPosSave;
		}
	}
	
	function updateSliderMin(){
		slider.ymin = slider.ymax+slider.mask._yscale-slider._height;
		slider._y = Num.mm(slider.ymin,slider._y,slider.ymax);
		if( slider.scroll == null)	initScrollBar();
	}
	
	function updateSlider(){
		if(slider.bar.flScroll)
			moveBar();
		return;
		//if(root._xmouse<0 || root._ymouse<slider.mask._y || root._ymouse>slider.mask._y+slider.mask._yscale  )return;
		if(root._xmouse<0)
			return;
		var c = (root._ymouse-slider.ymax)/(slider.mask._yscale-slider.ymax);
		var inc = -(c*2-1)*Math.min(root._xmouse/10,10);
		slider._y = Num.mm(slider.ymin,slider._y+inc,slider.ymax);
		slider._y = Math.round(slider._y);
		sliderPosSave = slider._y;
	}

	function initScrollBar(){
		slider.scroll = dm.attach("mcScrollBg",1);
		slider.scroll.gotoAndStop(Game.me.raceId+1);
		if(  slider.ymin < slider.ymax ){
			slider.bar = cast dm.attach("mcScrollBar",1);
			slider.bar.gotoAndStop(Game.me.raceId+1);
		}

		var m = 2;
		var sbw = 10;
		var ww = inter.Board.WIDTH;


		var bx = ww-(sbw+m+4);
		//var bx = ww-(sbw+m+7);
		var by = slider.ymax+m;
		var ratio = slider.mask._yscale/slider._height;


		slider.scroll._x = 	bx-m;
		slider.bar._x = 	bx;

		slider.scroll._y = 	by-m;
		slider.bar._y = 	by;

		var space = slider.mask._yscale-2*m;


		slider.bar.onPress = callback(pressScrollBar,bx, by, bx, by+space*(1-ratio)); //callback(slider.bar.startDrag, false, bx, by, bx, by+space*(1-ratio) );
		slider.bar.onRelease = releaseScrollBar;
		slider.bar.onReleaseOutside = releaseScrollBar;

		slider.scroll._yscale = slider.mask._yscale;
		slider.bar._yscale = slider.mask._yscale * ratio -m;

		slider.bar.by = by;
		slider.bar.space= space;




		//
		var ry = 1- (slider._y-slider.ymin)/(slider.ymax-slider.ymin);
		slider.bar._y = by + ry * (slider.bar.space-slider.bar._yscale) ;



	}

	function removeScrollBar(){
		slider.scroll.removeMovieClip();
		slider.bar.removeMovieClip();
		slider.scroll = null;
	}

	function moveBar(){
		var ratio = slider.mask._yscale/slider._height;
		var ry = (slider.bar._y-slider.bar.by) / (slider.bar.space-slider.bar._yscale);
		slider._y = slider.ymin+(slider.ymax-slider.ymin)*(1-ry);
		sliderPosSave = slider._y;


	}

	function pressScrollBar(left,top,right,bot){
		Inter.me.flDrag = true;
		slider.bar.flScroll = true;
		slider.bar.startDrag( false, left,top,right,bot);

	}
	function releaseScrollBar(){
		Inter.me.flDrag = false;
		slider.bar.flScroll = false;
		slider.bar.stopDrag();
	}
	function scrollWheel(inc){
		if(slider.scroll==null)return;
		var ratio = slider.mask._yscale/slider._height;
		var speed = 5*ratio;
		var m = 2;
		var ymin = slider.ymax+m;
		var ymax = ymin + (slider.mask._yscale-2*m)*(1-ratio);
		slider.bar._y = Num.mm( ymin, slider.bar._y-inc*speed, ymax );
		moveBar();
	}




	//
	var flCancel:Bool;
	public function cancel(){
		flCancel = true;
		sliderPosSave = null;
		Inter.me.isle.initDalleBuildActions();
		remove();
	}
	public function remove(){
		flash.Mouse.removeListener(cast ml);
		Inter.me.board.pan = null;
		root.removeMovieClip();
		Inter.me.hideHint();
	}




//{
}


/*
> Balance
> Anti Music Song
> The best ever death metal band out of Denton
> No, I can't
> Broom People
> Pure Gold
> West country dream
> The Last Day Of Jimi Hendrix's Life
> Dilaudid
> Magpie

*/












