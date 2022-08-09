import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;
import inter.Map;

enum InterStep{
	Planet;
	Map;
	Module;
	Zoom(sens:Int);
}

typedef DCounter = {>flash.MovieClip,a:Array<Digit>};
typedef Digit = {>flash.MovieClip,n:Int,trg:Int };
typedef McParamField = {>flash.MovieClip,field:flash.TextField,checkbox:flash.MovieClip};

class Inter {//}

	static public var BH = GamePlay.INTER_BH;
	static public var MAP_ZOOM = 0.15;

	static public var DP_TRACER = 		18;
	static public var DP_LOADING = 		16;
	static public var DP_HINT = 		14;

	static public var DP_BOARD = 		12;
	static public var DP_BORDER =		11;


	static public var DP_SCREEN =		8;

	static public var DP_BAR = 		3;

	static public var DP_MODULE = 		1;
	static public var DP_BG = 		0;

	public var flWaitPlayer:Bool;

	public var width:Float;
	public var height:Float;
	public var currentModule:Int;

	public var nbLoading:Int;
	public var flLoading:Bool;
	public var flDrag:Bool;
	public var flTransition:Bool;

	static public var me:Inter;
	public var dm:mt.DepthManager;
	public var step:InterStep;
	var moduleIcons:Array<flash.MovieClip>;
	var curIcon:Int;

	public var map:inter.Map;
	public var module:inter.Module;

	public var panel:inter.Panel;

	public var isle:inter.Isle;
	public var root:flash.MovieClip;
	public var mcLoading:flash.MovieClip;
	public var mcBackBut:flash.MovieClip;
	public var mcBar:{ >flash.MovieClip, res:flash.MovieClip, cur:flash.MovieClip, bar:flash.MovieClip, dm:mt.DepthManager, counter:Counter };
	public var mcHint:{>flash.MovieClip,bg:flash.MovieClip,field:flash.TextField, cx:Int, cy:Int, getText:Void->String};
	public var mcUnits:{>flash.MovieClip,bg:flash.MovieClip,field:flash.TextField};
	public var background:flash.MovieClip;
	public var foreground:flash.MovieClip;

	var mcSlider:flash.MovieClip;
	var counters:Array<DCounter>;

	public var board:inter.Board;
	public var bgBar:{>flash.MovieClip,mat:flash.MovieClip,eth:flash.MovieClip};

	var mcLog:{>flash.MovieClip,field:flash.TextField};
	var logText:String;

	public function new( mc:flash.MovieClip ){
		nbLoading = 0;
		flLoading = false;
		flDrag = false;
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		logText = "";

		attachBackground();
		initBorders();

		updateArea();
	}

	function initBorders(){

		var butPref:flash.MovieClip = null;

		var p = [[0,0],[71,0],[764,0],[71,445]];
		for( i in 0...4 ){
			var mc = dm.attach(Cs.gil("mcBorder"),DP_BORDER);
			mc._x = p[i][0];
			mc._y = p[i][1];
			mc.gotoAndStop(i+1);
			if(i==3)bgBar = cast  mc;
			if(i==1)butPref = cast(mc).butPref;

		}

		// COUNTERS
		counters = [];
		for( i in 0...2 ){
			var counter:DCounter = cast dm.empty(DP_BORDER);
			counters.push(counter);

			var ecd = 17;
			switch( Game.me.raceId ){
				case 0 :
					counter._x = 152 + 151*(i+1);
					counter._y = 473;
					ecd = 17;
				case 1:
					counter._x = 212 + 112*(i+1);
					counter._y = 470;
					ecd = 20;
			}



			var cdm = new mt.DepthManager(counter);
			counter.a = [];
			for( i in 0...4 ){
				var mc:Digit = cast cdm.attach("mcDigit",0);
				mc._x = ecd*i;
				//mc.n = Std.random(10);
				//mc.trg = Std.random(10);
				mc.n = 0;
				mc.trg = 0;
				counter.a.unshift(mc);

			}
		}

		// SLIDER
		mcSlider = dm.attach(Cs.gil("mcSlider"),DP_BORDER);
		mcSlider._x = 80;
		mcSlider._y = 456;
		makeHint(mcSlider,"",null,true,getSliderHint);


		// MODULE_ICONS
		moduleIcons = [];
		for( i in 0...4 ){
			var mc = dm.attach(Cs.gil("mcTab"),DP_BORDER);
			mc._x = 114 + i*36;
			mc._y = Cs.mch-23;
			mc.onPress = callback(launchModule,i,null);
			mc.gotoAndStop(i+1);
			moduleIcons.push(mc);
			mc._alpha= 0;
			makeHint(mc,Lang.getTitleDesc(Lang.MODULES[i],Lang.IGH_MODULES[i]));

		}

		// TIPS
		//makeSquareHint( dm, 255, 467, 140, 35, Lang.DESC_MATERIAL );
		//makeSquareHint( dm, 400, 467, 140, 35, Lang.DESC_ETHER );

		// PANEL UNITS
		mcUnits = cast dm.attach(Cs.gil("panelUnits"),DP_BORDER);
		mcUnits._x = 8;
		mcUnits._y = 8;
		mcUnits.field.text = "";

		// PREFERENCES
		Trick.makeButton(butPref,null,toggleParam);


	}



	// MAP
	public function initMap(){
		step = Map;
		if( map == null ) map = new inter.Map();
		else 		  map.active();

	}
	public function updateArea(){
		width = Cs.mcw;
		height = Cs.mch-Inter.BH;
		if(board!=null){
			//width-= inter.Board.WIDTH;
			width-= Cs.mcw-board.root._x;
			if(width>Cs.mcw)width = Cs.mcw;
		}

	}

	static var escapeDown = false;

	// UPDATE
	public function update(){
		board.update();

		switch(step){
			case Zoom(sens) : updateZoom(sens);
			case Map	: map.update();
			case Planet	: isle.update();
			case Module	: module.update();
		}

		updateScrollText();
		updateHint();
		//board.update();
		updateBar();

		// AUTO UPDATE
		if( Inter.me.isReady() && Game.me.world.isOld() && Game.me.world.data._mode != MODE_END){
			Api.getWorld(if (step == Map) map.maj else null);
		}

		// PARAMS
		if( escapeDown && !flash.Key.isDown(flash.Key.ESCAPE)){
			toggleParam();
		}
		escapeDown = flash.Key.isDown(flash.Key.ESCAPE) && !flash.Key.isDown(flash.Key.ALT);

		// DEBUG - NEXT ENGINE
		if( Game.flDebug && Inter.me.isReady() && flash.Key.isDown(flash.Key.ENTER) ){
			var confirm = if (Inter.me.isle != null) Inter.me.isle.maj else Inter.me.map.maj;
			if (module!=null)
				confirm = module.maj;
			Api.next(Inter.me.isle.pl.id, confirm);
		}
	}

	// COMMAND

	public function selectPlanet(pl:Planet,flZoom){
		isle = new inter.Isle(pl);
		if(flZoom)initZoom(1);
		else isle.active();
	}


	public function attachBackBut(){
		if(mcBackBut!=null){
			mcBackBut.removeMovieClip();
			mcBackBut = null;
		}
		mcBackBut = dm.attach("mcBackBut",DP_BOARD-1);
		mcBackBut._xscale = Cs.mcw;
		mcBackBut._yscale = Cs.mch;
		mcBackBut.onPress = board.pan.cancel;
		mcBackBut._alpha = 0;
	}

	// BAR
	public function loadBar( data:DataStatus ){


		var a = [data._res._material, data._res._ether ];
		for( i in 0...2 ){
			var counter = counters[i];
			var sum = a[i];
			for( k in 0...4 ){
				var n = Std.int(sum%10);
				sum = Std.int(sum/10);
				var dig = counter.a[k];
				dig.trg = n;
				if(dig.trg!=dig.n)dig.gotoAndPlay(2);
			}

		}

		if( mcBar == null ){
			mcBar = cast dm.empty(DP_BAR);
			mcBar._y = Cs.mch;
			mcBar.dm = new mt.DepthManager(mcBar);
		}
		mcBar.counter = data._maj;

		// UNITS
		mcUnits.field.text = data._units+"/"+data._unitMax;
		makeHint(mcUnits,"Nombre d'unité");

		//
		Trick.butKill(bgBar.mat);
		Trick.butKill(bgBar.eth);
		cast(bgBar.mat)._hint = false;
		cast(bgBar.eth)._hint = false;
		var desc = Lang.DESC_MATERIAL+"\n"+(if (Game.me.tickMaterial > 0) "+" else "")+Game.me.tickMaterial+"/cycle";
		var desc2 = Lang.DESC_ETHER+"\n"+(if (Game.me.tickEther > 0) "+" else "")+Game.me.tickEther+"/cycle";
		makeHint(bgBar.mat,desc,null,true);
		makeHint(bgBar.eth,desc2,null,true);

	}
	public function updateBar(){
		var o = Game.me.getCounterInfo(mcBar.counter);
		var rule = 1;
		var m = 5;
		var by = 267;
		var ly = 273;
		switch(Game.me.raceId){
			case 1:
				by = 332;
				ly = 179+5;
		}
		var tx = Std.int((by+m+ o.c*(ly-2*m))/rule)*rule;
		if(mcSlider._x<tx)	mcSlider._x = tx;
		else 			mcSlider._x += (tx-mcSlider._x)*0.2 ;
		if( o.c == 1 && Game.me.world.data._mode != MODE_END && Api.isReady() ){
			Api.getStatus(null);
		}
	}
	public function getSliderHint(){
		var o = Game.me.getCounterInfo(mcBar.counter);
		var str = "<p align='center'><b>"+Lang.CYCLE_REMAINING_TIME+"</b><br/>";
		str += Cs.getTime(o.run,false)+"</p>";
		return str;
	}



	// ANIM
	var zoomCoef:Float;
	var dcx:Float;
	var dcy:Float;
	var mcIsleScreenshot:{>flash.MovieClip,bmp:flash.display.BitmapData};

	public function initZoom(sens){
		flTransition = true;
		hideHint();
		step = Zoom(sens);
		zoomCoef = 0.5-0.5*sens;

		dcx = (Cs.mcw*0.5 - isle.pl.x) - map.root._x ;
		dcy = (Cs.mch*0.5 - isle.pl.y) - map.root._y ;


		isle.root._visible = false;
		isle.bg._visible = false;


		mcIsleScreenshot = cast map.mdm.empty(0);
		var mc = mcIsleScreenshot;
		mc.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0x000000FF);
		mc.bmp.draw(isle.root);
		mc.attachBitmap(mc.bmp,0);
		mc._xscale = mc._yscale =  MAP_ZOOM*100;
		mc._x = isle.pl.x-(Cs.mcw-inter.Board.WIDTH)*0.5*MAP_ZOOM;
		mc._y = isle.pl.y-Cs.mch*0.5*MAP_ZOOM;
		mcIsleScreenshot._alpha = 0;


		map.flat();
		if(sens==-1){
			var p = fitInMap(isle.pl.x,isle.pl.y);
			dcx = -(isle.pl.x - p.x);
			dcy = -(isle.pl.y - p.y);
			map.active();

		}

	}
	function fitInMap(x,y){
		return {
			x:Num.mm( Cs.mcw*0.5, x, map.width-Cs.mcw*0.5 ),
			y:Num.mm( Cs.mch*0.5, y, map.height-Cs.mch*0.5 )
		}


	}

	public function updateZoom(sens){
		var inc = 0.1;
		if(flash.Key.isDown(flash.Key.SPACE))inc = 0.01;
		zoomCoef = Num.mm(0,zoomCoef+sens*inc,1);

		var c = 1/(1-zoomCoef*(1-MAP_ZOOM)                       );
		var centerCoef = Math.pow(1-zoomCoef,1);

		//var dwx = inter.Board.WIDTH*0.5*zoomCoef;
		var dwx = inter.Board.WIDTH*0.5*Math.pow(zoomCoef,2);

		map.root._xscale = map.root._yscale = c*100;
		map.root._x = Cs.mcw*0.5 - (isle.pl.x*c + dcx*c *centerCoef + dwx) ;
		map.root._y = Cs.mch*0.5 - (isle.pl.y*c + dcy*c*centerCoef ) ;

		var bgc = Math.pow(zoomCoef,0.3);
		isle.bg._xscale = isle.bg._yscale =  bgc*100;
		isle.bg._visible = true;




		// ALPHA
		var al = Num.mm(0,zoomCoef*1.5-0.5,1);
		map.mcFlat._alpha = (1-al)*100;
		isle.bg._alpha = al*100;
		mcIsleScreenshot._alpha = al*100;
		foreground._alpha = (1-al)*20;


		if(zoomCoef==1){
			cleanIsleScreen();

			map.unFlat();
			map.unactive();
			isle.active();

			map.root._xscale = map.root._yscale = 100;
			flTransition = false;

			var x = isle.pl.x;
			var y = isle.pl.y;
			var p = fitInMap(x,y);

			map.root._x = Cs.mcw*0.5 - p.x;
			map.root._y = Cs.mch*0.5 - p.y;

		}
		if(zoomCoef==0){
			cleanIsleScreen();
			step = Map;
			map.unFlat();
			isle.bg.removeMovieClip();
			isle = null;
			flTransition = false;
			map.maj();
		}

	}

	public function cleanIsleScreen(){

		mcIsleScreenshot.bmp.dispose();
		mcIsleScreenshot.removeMovieClip();


	}

	// FOREGROUND



	// BACKGROUND
	public function attachBackground(){
		background = dm.attach(Cs.gil("mcBackground"),DP_BG);
	}

	// HINT / TIPS
	public function makeSquareHint(pdm:mt.DepthManager,x,y,w,h,str){
		var mc = pdm.attach("mcSquare",10);
		mc._x = x;
		mc._y = y;
		mc._xscale = w;
		mc._yscale = h;
		makeHint(mc,str);
	}
	
	public function makeHint(mc:flash.MovieClip, str, ?width, ?flForceHelp, ?getText){
		if (cast(mc)._hint)
			return;
		var f = mc.onRollOver;
		var f2 = mc.onRollOut;
		var me = this;
		mc.onRollOver = function(){
			me.displayHint(str, width, flForceHelp, getText);
			if (f != null)
				f();
		};
		mc.onRollOut =  function(){
			me.hideHint();
			if (f2 != null)
				f2();
		};
		mc.onDragOver = mc.onRollOver;
		mc.onDragOut = mc.onRollOut;
		cast(mc)._hint = true;
	}
	
	function displayHint(str, ?width, ?flForceHelp, ?getText){
		if( !Param.is(_ParamFlag.PAR_IN_GAME_HELP ) && flForceHelp!=true )
			return;

		//		haxe.Firebug.trace(flash.TextField.getFontList());
		
		if( mcHint == null ){
			mcHint = cast dm.attach(Cs.gil("mcHint"),DP_HINT);
			var fl = new flash.filters.DropShadowFilter();
			fl.blurX = 4;
			fl.blurY = 4;
			fl.distance = 4;
			fl.color = 0;
			fl.angle = 45;
			fl.strength = 0.25;
			mcHint.filters = [fl];
		}

		if( getText!=null ){
			str = getText();
			mcHint.getText = getText;
		}else{
			mcHint.getText = null;
		}

		//str = "test";
		if( width!=null )mcHint.field._width = width;

		// mcHint.field.embedFonts = true;
		mcHint.field.htmlText = str;
		Game.fixTextField(mcHint.field);

		mcHint.field._width = mcHint.field.textWidth+5;
		mcHint.field._height = mcHint.field.textHeight+5;
		// HACK SINGLE LINE
		if(mcHint.field._height<24) mcHint.field._height -= 4;

		mcHint.bg._xscale = mcHint.field._width+4;
		mcHint.bg._yscale = mcHint.field._height+2;

		mcHint.cx = (root._xmouse<Cs.mcw*0.5)?0:1;
		mcHint.cy = (root._ymouse<Cs.mch*0.5)?0:1;
		
		updateHint();
	}

	public function hideHint(){
		if (mcHint == null)
			return;
		mcHint.removeMovieClip();
		mcHint = null;
	}
	
	function updateHint(){
		if (mcHint == null)
			return;
		var ma =  10;
		var tx = ma+root._xmouse-(mcHint._width+2*ma)*mcHint.cx;
		var ty = ma+root._ymouse-(mcHint._height+2*ma)*mcHint.cy;
		mcHint._x = Math.min( tx, Cs.mcw-mcHint._width );
		mcHint._y = Math.min( ty, Cs.mch-mcHint._height );
		if( mcHint.getText!=null )
			mcHint.field.htmlText =mcHint.getText();
	}

	// MSG BOX
	var mcMsg:{>flash.MovieClip, fieldTitle:flash.TextField, fieldDesc:flash.TextField, backBut:flash.MovieClip };
	public function msgBox(title,desc,?a:Array<{f:Void->Void,name:String}>){

		if(mcMsg!=null)destroyMsgBox();
		//

		// BACK BUT
		var bb = dm.attach("mcMask",DP_LOADING);
		bb._xscale = Cs.mcw;
		bb._yscale = Cs.mch;
		bb.onPress = function(){};
		bb._alpha = 0 ;

		//
		var ww = 200;
		mcMsg = cast dm.attach("mcMsgBox",DP_LOADING);
		mcMsg.fieldTitle.text = title;
		mcMsg.fieldDesc.text = desc;
		mcMsg.fieldDesc._height = mcMsg.fieldDesc.textHeight+8;
		mcMsg.backBut = bb;
		var hh = mcMsg.fieldDesc._y + mcMsg.fieldDesc._height + 30;
		var mdm = new mt.DepthManager(mcMsg);


		// BUTS
		if( a == null )a = [{f:null,name:"ok"}];
		var id = 0;
		var me = this;
		for( o in a ){
			var mc = mdm.attach("mcMsgBut",0);
			var f = function(){ o.f(); me.destroyMsgBox();};
			//if(f==null)f = destroyMsgBox;
			Trick.makeButton(mc,f);
			var c = (id+1)/(a.length+1);
			mc._x = ww*c;
			mc._y = hh - 16;
			Reflect.setField(mc,"_name",o.name);
			id++;
		}

		// PLACE
		mcMsg.smc._yscale = hh;
		mcMsg._x = (Cs.mcw-ww)*0.5;
		mcMsg._y = (Cs.mch-(hh+Inter.BH))*0.5;




	}
	function destroyMsgBox(){
		mcMsg.backBut.removeMovieClip();
		mcMsg.removeMovieClip();
		mcMsg = null;
	}

	// PLAYER WAIT
	public function initPlayerWait(){
		flWaitPlayer = true;
		initScrollText(Lang.WAITING_PLAYERS);
		var now = Game.me.now();
	}

	// MODE
	public function launchMode(){
		removeScrollText();
		switch(Game.me.world.data._mode){
			case MODE_INSTALL :
			case MODE_WAIT :	Inter.me.initPlayerWait();
			case MODE_PLAY :
			case MODE_END :		initScrollText(Lang.GAME_END);
		}
	}

	// SCROLLTEXT
	var mcScrollText:{>flash.MovieClip, field:flash.TextField, w:Float };
	public function initScrollText(str:String){
		mcScrollText.removeMovieClip();
		mcScrollText = null;

		str = str.toLowerCase()+" - ";

		mcScrollText = cast dm.attach("mcScrollText",DP_SCREEN);
		mcScrollText.field.text = str;
		mcScrollText.w = mcScrollText.field.textWidth;
		while( mcScrollText.field.textWidth < Cs.mcw+mcScrollText.w ){
			mcScrollText.field.text = mcScrollText.field.text+str;
		}
		mcScrollText.field._width = mcScrollText.field.textWidth+10;

		Filt.glow(mcScrollText,10,1,0xFFFFFF);
		mcScrollText.blendMode = "overlay";


	}
	public function removeScrollText(){
		mcScrollText.removeMovieClip();
	}
	function updateScrollText(){
		mcScrollText._x -= 3;
		if( mcScrollText._x < -mcScrollText.w )mcScrollText._x += mcScrollText.w;

	}

	// MODULE
	public function launchModule(id:Int,?n:Int){


		if( flTransition || currentModule == id )return;

		for( mc in moduleIcons )mc._alpha = 0;
		moduleIcons[id]._alpha = 100;


		step = Module;
		module.remove();



		switch(id){
			case 0 :
				if(Inter.me.isle!=null)		Inter.me.isle.leave();
				else				initMap();

			case 1:

				var pl = Game.me.getDefaultPlanet();
				if( n != null )pl = Game.me.getPlanet(n);
				pl.secureLaunch( callback(selectPlanet,pl,currentModule==0) );

			case 2 :	new inter.mod.Tec();
			case 3 :	new inter.mod.Chat();
		}

		currentModule = id;

	}

	// CHAT WARNING
	var mcNewMsg:flash.MovieClip;
	public function checkChatWarning(){
		if( inter.mod.Chat.haveNewMessage() ){
			if( mcNewMsg == null ){
				mcNewMsg = dm.attach(Cs.gil("mcNewMsg"),DP_BORDER);
				//mcNewMsg = dm.attach("mcNewMsg",DP_BORDER);
				mcNewMsg._x = 223;
				mcNewMsg._y = 484;
				mcNewMsg.blendMode = "overlay";
			}
		}else{
			removeChatWarning();
		}
	}
	public function removeChatWarning(){
		if( mcNewMsg != null ){
			mcNewMsg.removeMovieClip();
			mcNewMsg = null;
		}
	}

	// LOADING
	public function initLoading(){
		nbLoading++;
		if(!flLoading){
			flLoading = true;
			mcLoading = dm.attach("mcLoading",DP_LOADING);
			mcLoading.smc = dm.attach("mcMask",DP_LOADING);
			mcLoading.smc._xscale = Cs.mcw;
			mcLoading.smc._yscale = Cs.mch;
			mcLoading.smc._alpha = 0;
			mcLoading.smc.useHandCursor = false;
			mcLoading.smc.onPress = function(){};
		}
	}
	public function removeLoading(){
		nbLoading--;
		if (nbLoading == 0){
			flLoading = false;
			mcLoading.smc.removeMovieClip();
			mcLoading.removeMovieClip();
		}
	}
	public function isReady(){
		return !flLoading && !flDrag && Inter.me.board.animSens == null && Api.isReady();
	}

	// PARAMETRES JOUEUR
	//static var PARAM_LIST = [ Param.FAST_LINK, Param.FAST_LINK_SELF, Param.TECHNO_FALSE, Param.WILL_BUILD, Param.DISPLAY_UNIT_LIFE ];
	var mcParams:{>flash.MovieClip,slots:Array<McParamField>,cross:flash.MovieClip};
	function toggleParam(){
		if (mcParams == null)
			displayParams();
		else
			removeParams();
	}
	public function displayParams(){
		if( mcParams!=null )removeParams();
		mcParams = cast dm.attach("mcParamPanel",DP_LOADING);
		mcParams._x = (Inter.me.width-mcParams._width)*0.5;
		mcParams._y = (Inter.me.height-mcParams._height)*0.5;
		mcParams.cross.onPress = removeParams;
		mcParams.smc.onPress = function(){};
		mcParams.smc.useHandCursor = false;

		var dm = new mt.DepthManager(mcParams);
		mcParams.slots = [];
		var sy = 28.0;
		var x = 5;
		var y = sy;
		var colMax = 8;
		var titles = [0,1,6,8,11];
		var titleId = 0;
		for( i in 0...Param.flags.length ){
			if( i == titles[titleId] ){
				var mc:McParamField = cast dm.attach("titleParam",0);
				mc._x = x;
				mc._y = y;
				cast(mc)._txt = Lang.PARAM_SECTION[titleId];
				y += 24;
				titleId++;
			}

			// PARAM
			var mc:McParamField = cast dm.attach("slotParam",0);
			mc._x = x ;
			mc._y = y ;
			mc.field.text = Lang.PARAMS[i];
			mc.field._height = mc.field.textHeight+4;
			mc.checkbox.stop();
			mc.checkbox.onPress = callback(toggleFlag,i);
			y += mc.field._height + 6;
			mcParams.slots.push(mc);
			if( y > 360){
				x += 224;
				y = sy;
			}
		}

		updateParams();
	}
	public function updateParams(){
		for( i in 0...Param.flags.length ){
			mcParams.slots[i].checkbox.gotoAndStop(Param.flags[i]?2:1);
		}
	}
	public function removeParams(){
		mcParams.removeMovieClip();
		mcParams = null;
	}
	public function toggleFlag(id){
		Param.toggleFlag(id);
		updateParams();
		applyParams();
	}
	public function applyParams(){
		for( pl in Game.me.planets )if(pl.owner == Game.me.playerId)pl.updateAvailables();
		switch(step){
			case Planet:
				Inter.me.isle.attachLinks();
				Inter.me.isle.maj();
			case Module:
				Inter.me.module.maj();
			case Map:
				Inter.me.map.maj();
			case Zoom(sens):
		}
		if( Inter.me.board !=null )Inter.me.board.display();
	}

	// DEBUG
	public function toggleTracer(?flForce){
		if(flForce && mcLog!=null )return;
		if(mcLog==null){
			mcLog = cast Inter.me.dm.attach("mcLog",DP_TRACER);
			mcLog.field.text = logText;
			mcLog.field.scroll = mcLog.field.maxscroll;
		}else{
			mcLog.removeMovieClip();
			mcLog = null;
		}
	}
	public function trace(str:Dynamic, ?n:haxe.PosInfos){
		logText += str+"\n";
		mcLog.field.text = logText;
		mcLog.field.scroll = mcLog.field.maxscroll;
	}



//{
}
















