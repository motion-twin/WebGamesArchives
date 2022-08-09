package inter.mod;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;

enum SlotType {
	HAVE;
	SEARCH;
	UNKNOWN;
}
typedef SlotTec = {
	>flash.MovieClip,
	type:SlotType,
	id:Int,
	tid:Int,
	tw:Tween,
	dm:mt.DepthManager,
	pro:flash.MovieClip,
	vig:flash.MovieClip,
	time:flash.MovieClip,
	counter:Counter,
	cross:flash.MovieClip,
};



class Tec extends inter.Module{//}

	public static var DP_PANEL = 0;
	public static var DP_SLOTS = 1;

	public static var MODEL_MAX = 12;

	public static var MX = 85.0;
	public static var MY = 70;

	public static var EC = 76;

	public static var CMAX = 8;
	public static var MA = 8;

	var animCoef:Float;
	var oid:Int;

	var flFirstLoad:Bool;
	var slots:Array<SlotTec>;
	var first:SlotTec;
	var turner:flash.MovieClip;
	var mcPanel:flash.MovieClip;


	public function new(){
		super();
		flFirstLoad = true;
		MX = ( Cs.mcw - ((CMAX*EC)+(CMAX-1)*MA) )*0.5 + EC*0.5;

		initInter();
		initSlots();
		maj();

		//line( 60, 0, 55, 600 );
		//line( 66, 0, 66, 600 );
		//line( 0, 22,  Cs.mcw, 20);
		//line( 0, 438,  Cs.mcw, 438);



		//Filt.glow(root,2,4,0xFFAA00);
		//Filt.glow(root,6,1,0xFFAA00);
	}

	override function update(){
		super.update();
		if(animCoef!=null)updateSlots();

		if(dboxTarget!=null){
			var id = getNearId(root._xmouse, root._ymouse);
			var p = getPos(id);
			dboxTarget._x = p.x;
			dboxTarget._y = p.y;
		}

		if (Game.me.world.data._mode != MODE_PLAY)
			return;

		var o = Game.me.getCounterInfo(first.counter);
		Cs.genTime(first.time, o.run,true, false  );

		var fr = Std.int(Std.int(o.c*160)+1);
		first.pro.gotoAndStop(fr);

		if( Inter.me.isReady() && o.c==1 && Api.isReady() ){
			Api.getStatus(maj);
		}

		// ENTER = validation
		if( flash.Key.isDown(flash.Key.ENTER) && panel.flWaitConfirm )panel.action.onPress();


	}


	// SLOTS
	function initSlots(){


		// SLOTS
		slots = [];

		var econ = Type.getEnumConstructs(_Tec);

		for( id in 0...econ.length ){

			var tec:_Tec = Type.createEnum(_Tec, econ[id] );
			if(tec == null )break;
			//trace((Type.getEnumConstructs(_Tec)[id])+">> "+GamePlay.getTechnoRaceId(tec)+"==="+Game.me.raceId);

			if( GamePlay.getTechnoRaceId(tec) == Game.me.raceId  ){

				var slot:SlotTec = cast dm.empty(DP_SLOTS);
				slot.dm = new mt.DepthManager(slot);
				slot.tid = id;
				slot._x = 50;
				slot._y = 50;
				slot._visible = false;
				slot.type = UNKNOWN;
				slot.dm = new mt.DepthManager(slot);

				Filt.glow(slot,2,4,Cs.COLOR_TEXT);

				var mc = slot.dm.attach("mcResearchVig",1);
				mc.gotoAndStop(id+1);
				mc._x = -EC*0.5;
				mc._y = -EC*0.5;
				//Filt.glow(mc,2,1,0xFFCC88,true);
				Filt.glow(mc,2,1,Cs.COLOR_TEXT,true);

				slot.vig = mc;

				slots.push(slot);

			}


		}

		// TEC CADRES
		//var mc = dm.attach("mcTecCadre",DP_SLOTS);
		//mc._x =  MX;
		//mc._y =  MY;


	}
	override function maj(){

		var me = this;

		// HAVE
		//var pl = Game.me.getPlayer(Game.me.playerId);
		var id = 0;
		for( tec in Game.me.tec ){
			//var tid = Type.enumIndex(tec);
			var slot = getSlot(Type.enumIndex(tec));
			slot._visible = true;
			if(slot.type!=HAVE){
				slot.time.removeMovieClip();
				slot.dm.clear(0);
				slot.tw = null;
				slot.pro.removeMovieClip();
				slot.vig.setMask(null);
				slot.onPress = null;
				slot.onRelease = null;
				slot.onReleaseOutside = null;
				slot.useHandCursor = false;
				fxBlink(slot);
			}
			var rid = Game.me.tec.length-(1+id);
			//trace("HAVE ! "+rid);
			if (GamePlay.canBeDisabled(tec)){
				if (slot.cross == null){
					haxe.Firebug.trace("cross");
					slot.cross = slot.attachMovie("mcActivationTechno", "cross", slot.getNextHighestDepth());
					slot.cross._x = -26;
					slot.cross._y = -26;
					slot.stop();
					slot.useHandCursor = true;
				}
				if (Game.me.isTecEnabled(tec)){
					slot.cross.gotoAndStop("2");
					slot.onRelease = function() Api.enableTec(tec, false, function() me.maj());
				}
				else {
					slot.cross.gotoAndStop("1");
					slot.onRelease = function() Api.enableTec(tec, true, function() me.maj());
				}
			}
			slot.type = HAVE;
			slot.id = rid;
			var p = getPos(rid);
			slot._x = p.x;
			slot._y = p.y;
			id++;
			setSlotHelp(slot);

		}
		oid = id;


		/*
		// HAVE PANEL
		mcPanel.removeMovieClip();
		var xmax = Math.min(Game.me.tec.length,CMAX);
		var ymax = Std.int((Game.me.tec.length-1)/CMAX)+1;
		if( xmax > 0 ){
			mcPanel = dm.attach("mcTecPanel",DP_PANEL);
			var side = 6;
			mcPanel._xscale = xmax*EC + (xmax-1)*MA + side*2;
			mcPanel._yscale = ymax*EC + (ymax-1)*MA + side*2;
			mcPanel._x = MX-(EC*0.5+side);
			mcPanel._y = MY+(5-ymax)*(EC+MA)-(EC*0.5+side);
			mcPanel.blendMode = "overlay";
			Col.setColor(mcPanel,0,-50);
		}
		*/



		// SEARCH
		first = null;
		for( o in Game.me.research ){
			//trace(Type.enumIndex(o._type));
			var slot = getSlot(Type.enumIndex(o._type));
			if( slot!= null ){
				if(first==null){
					first = slot;
					slot.counter = o._counter;
				}
				slot.id = id;
				slot._visible = true;
				if(slot.type==HAVE)trace("ERROOOOOOOOOOOOOOOR");
				slot.type = SEARCH;

				if(slot.pro == null ){

					var mask = slot.dm.attach("mcCadran",1);
					slot.vig.setMask(mask);

					var mc  = slot.dm.empty(0);
					var mdm = new mt.DepthManager(mc);
					var mc1  =  mdm.attach("mcTecBg",0);
					Col.setPercentColor(mc1,100,Cs.COLOR_SKY);
					var mc2  = mdm.attach("mcResearchVig",0);

					mc2.gotoAndStop(slot.tid+1);
					mc._x = -EC*0.5;
					mc._y = -EC*0.5;

					Filt.grey(mc2);
					mc2.blendMode = "overlay";
					//Filt.blur(mc2,2,2);

					slot.pro = mask;

					// TIME
					slot.time = slot.dm.empty(3);
					slot.time._x = -EC*0.5;
					slot.time._y = 22;
					Filt.glow(slot.time,2,4,0);
					//


				}
				// ACTION
				slot.onPress = callback(dragSlot,slot);
				slot.onRelease = callback(releaseSlot,slot);
				slot.onReleaseOutside = callback(releaseSlot,slot);

				// TIME
				slot.time._visible = slot == first;

				var time = GamePlay.getTechnoSearchTime( o._type )*Game.me.searchRate*(1-o._progress);
				// if( slot.time._visible )time = null;

				setSlotHelp(slot,time);

				var fr = Std.int(Std.int(o._progress*160)+1);
				slot.pro.gotoAndStop(fr);

				var p = getPos(id);
				slot.tw = new Tween(slot._x,slot._y,p.x,p.y);

				id++;
			}

		}




		// LINE
		root.clear();
		root.lineStyle(2,Cs.COLOR_TEXT,75,true,"normal","square","miter");
		var max = id;
		for( id in 0...max ){
			var ral = EC*0.5+10;
			if(MX>90)ral+=Math.min(MX-90,10);
			if(id==0||id==max-1)ral = 0;
			var p = getPos(id,ral);
			if(id==0)root.moveTo(p.x,p.y);
			else root.lineTo(p.x,p.y);
		}






		animCoef = flFirstLoad?1:0;
		flFirstLoad = false;
	}
	function updateSlots(){
		animCoef = Math.min(animCoef+0.1,1);

		for( mc in slots ){
			if(mc.type==SEARCH){
				var p = mc.tw.getPos(animCoef);
				mc._x = p.x;
				mc._y = p.y;
			}
		}
		if(animCoef==1)animCoef=null;

	}

	function setSlotHelp(slot:SlotTec,?time){
		var txt = "";
		txt += "<font size='14'><b>"+Lang.RESEARCH[slot.tid]+"</b></font><br>";
		txt += "<b>"+Lang.IGH_RESEARCH[slot.tid]+"</b>";
		if(time!=null){
			txt += "<br><i>"+Cs.getTime(time,true,false)+"</i>";
		}
		txt+="<br>"+Lang.FLAVOUR_RESEARCH[slot.tid]+"";

		Inter.me.makeHint(slot,txt,250);
	}

	// DRAG
	var dbox:{>flash.MovieClip,bmp:flash.display.BitmapData,sy:Float,sid:Int,cid:Int};
	var dboxTarget:flash.MovieClip;

	function dragSlot(mc:SlotTec){
		Inter.me.flDrag = true;
		removePanel();
		//
		dbox = cast dm.empty(10);
		dbox.bmp = new flash.display.BitmapData(EC,EC,true,0);
		var ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,0);
		var m = new flash.geom.Matrix();
		m.translate(EC*0.5,EC*0.5);
		dbox.bmp.draw(mc,m,ct,"layer");
		dbox.startDrag(true);

		var mdm = new mt.DepthManager(dbox);
		var mmc = mdm.empty(0);

		mmc.attachBitmap(dbox.bmp,0);
		mmc._x = -EC*0.5-mc._xmouse;
		mmc._y = -EC*0.5-mc._ymouse;
		dbox.sy = root._ymouse;
		dbox.sid = mc.id;
		dbox.cid = mc.id;
		dbox._y = -1000;

		var arrows = mdm.attach("mcTecCadre",1);
		arrows._x = -mc._xmouse;
		arrows._y = -mc._ymouse;
		 fxBurn(arrows);

		dbox.onRollOver = function(){};
		//dbox.blendMode = "overlay";
		mmc._alpha =60;

		//
		dboxTarget = cast dm.attach("mcTecDragTarget",9);
		dboxTarget._x = -1000;
		fxBurn(dboxTarget);



	}
	function releaseSlot(mc:SlotTec){
		Inter.me.flDrag = false;
		var fid = mc.id-oid;
		var id  = getNearId(root._xmouse, root._ymouse);
		var tid = id-oid;
		if( tid<0 ) tid = 0;


		if( tid != fid ){
			// YOTA: MAYBE A PROBLEM THERE
			Api.swapResearch(fid, tid, maj);
			dm.over(mc);
		}

		// DESTROY
		dbox.bmp.dispose();
		dbox.stopDrag();
		dbox.removeMovieClip();
		dbox = null;
		dboxTarget.removeMovieClip();
		dboxTarget = null;

	}

	// SAVE / LOAD
	var icons:Array<flash.MovieClip>;
	function initInter(){
		while(icons.length>0)icons.pop().removeMovieClip();
		icons = [];


		var max = Param.tecModels.length;
		var id = 0;


		//trace( max+"<"+MODEL_MAX );
		for( i in 0...2 ){

			var mc = dm.attach(Cs.gil("mcTecIco"),5);
			mc._x = Cs.mcw - 45;
			mc._y = Cs.mch - (90+id*30);
			mc.gotoAndStop(i+1);
			if( (i==0 && max<MODEL_MAX) || (i==1 && max>0) ){
				//Trick.butAction( mc,callback(selectOption,mc,i), callback(roverOption,mc) ,callback(routOption,mc));
				mc.onRelease = callback(selectOption,mc,i);
				routOption(mc);
				Inter.me.makeHint(mc,i==1?Lang.LOAD_TECHNO:Lang.SAVE_TECHNO);
			}else{
				mc._alpha = 10;
				if(i==0)Inter.me.makeHint(mc,Lang.TOO_MANY_SAVE_TECHNO);
			}
			icons.push(mc);
			id++;
		}

	}
	function selectOption(mc,id){
		removePanel();
		if( id == 0 )loadNewModelPanel();
		if( id == 1 )loadBuildPanel();

	}
	function roverOption(mc:flash.MovieClip){
		mc.filters = [];
		//Filt.glow(mc,2,4,0xFFDD88);
		Filt.glow(mc,6,0.5,Cs.COLOR_TEXT);
	}
	function routOption(mc:flash.MovieClip){
		mc.filters = [];
		var filt = new flash.filters.GlowFilter();
		filt.color = Cs.COLOR_TEXT;
		filt.knockout = true;
		filt.blurX = 2;
		filt.blurY = 2;
		filt.strength = 4;
		mc.filters  = [filt];

		Filt.glow(mc,6,0.5,Cs.COLOR_TEXT);
	}

	// MODELS - BUILD PANEL
	var panel:{>flash.MovieClip,cross:flash.MovieClip, action:flash.MovieClip, flWaitConfirm:Bool };

	function loadBuildPanel(?flFull:Bool){
		var a = [];
		for( mod in Param.tecModels )if(mod._raceId == Game.me.raceId )a.push(mod);

		var top = 20;

		panel = cast dm.attach(Cs.gil("mcTecBuildPanel"),11);
		panel.cross.onPress = removePanel;
		panel._x = Cs.mcw*0.5 - 100;
		panel._y = (Cs.mch-Inter.BH)*0.5 + 8;


		var hh= a.length*25 + 5 + top;
		if(flFull)hh += 20;
		panel.smc._yscale = hh;
		panel._y -= hh*0.5;
		var pdm = new mt.DepthManager(panel);

		var id = 0;
		for( mod in a ){
			var mc:{>flash.MovieClip,field:flash.TextField,cross:flash.MovieClip} = cast pdm.attach(Cs.gil("slotTecSave"),0);
			mc._x = 5;
			mc._y = top+5+id*25;
			mc.field.text = mod._name;
			mc.cross.onPress = callback(destroyModel,id);
			Trick.butAction(mc.smc,callback(loadModel,id),callback(roverModel,mc),callback(routModel,mc));
			id++;
		}




	}
	function removePanel(){
		panel.removeMovieClip();
		panel = null;
	}
	function destroyModel(id){
		Param.removeTecModel(id);
		removePanel();
		loadBuildPanel();
		initInter();
	}

	function loadModel(id){
		if( Inter.me.isReady() ){
			removePanel();
			Api.loadTechnoOrder(Param.tecModels[id]._list, maj);
		}
	}

	function roverModel(mc:flash.MovieClip){
		mc.blendMode = "overlay";
		//mc._alpha = 50;

	}
	function routModel(mc:flash.MovieClip){
		mc.blendMode = "normal";
		//mc._alpha = 100;
	}

	// MODELS - NEW PANEL
	function loadNewModelPanel(){

		panel = cast dm.attach(Cs.gil("mcTecNewModel"),11);

		panel.flWaitConfirm = true;
		panel.cross.onPress = removePanel;
		panel._x = Cs.mcw*0.5 - 100;
		panel._y = (Cs.mch-Inter.BH)*0.5 + 8 - 15;
		var field:flash.TextField = (cast panel).field;
		panel.action.onPress = callback(saveModel,field);
		//panel.smc.onRelease = callback(saveModel,field);
		flash.Selection.setFocus(field);

	}
	function saveModel(field:flash.TextField){
		if( !Inter.me.isReady() || field.text.length == 0 )return;

		var list = [];
		for(t in Game.me.tec )list.unshift(t);
		for(o in Game.me.research )list.push(o._type);
		Param.addTecModel(field.text,list,Game.me.raceId);

		removePanel();
		initInter();
	}


	// FX
	function fxBlink(slot:SlotTec){

	}
	function fxBurn(mc:flash.MovieClip){
		Filt.glow(mc,2,4,0xFFFFFF);
		Filt.glow(mc,6,2,Cs.COLOR_TEXT);
		mc.blendMode = "overlay";
	}
	override function display(){

		// CLEAN
		while(slots.length>0)slots.pop().removeMovieClip();


		//
		slots = [];
		var a = Type.getEnumConstructs(_Tec);

		var id = 0;

		var size = 80;

		//

		for( str in a ){
			var txt = "";

			var slot:SlotTec = cast dm.empty(1);
			var sdm = new mt.DepthManager(slot);
			slot.id = id;
			slot._x = 76+(id%CMAX)*size;
			slot._y = 32+(Std.int(id/CMAX))*size;

			var tec = Type.createEnum(_Tec,str) ;
			var tid = Type.enumIndex(tec);
			txt += "<font size='14'><b>"+Lang.RESEARCH[tid]+"</b></font><br>";
			txt += Lang.IGH_RESEARCH[tid];

			var mc = sdm.attach("mcResearchVig",1);
			mc.gotoAndStop(tid+1);

			if( Game.me.haveTechno( tec  ) ){

			}else{

				var flDispo = false;
				var flTurn = false;
				for( dr in Game.me.research ){
					if( Type.enumEq(dr._type,tec) ){
						var icon = sdm.attach("mcEngrenage",2);
						icon._x = 14;
						icon._y = 14;

						var fl = new flash.filters.DropShadowFilter();
						fl.strength = 4;
						fl.distance = 1;
						fl.color = 0x6F5F3C;
						fl.angle = 90;
						icon.filters = [fl];
						Filt.glow(icon,2,4,0);
						if(dr._counter!=null)turner = icon;
						flDispo = true;

						break;
					}
				}

				if(!flDispo){

					Filt.grey(mc);
					mc.blendMode = "overlay";
					Col.setColor(mc,0,20);
					Filt.blur(mc,2,2);


					//var b = getRequirement(tec);
					//txt += "<br><font color='#BB0000'>- Necessite "+Lang.BUILDING[Type.enumIndex(b)]+"</font>";

				}else{
					mc._alpha = 50;

				}

			}



			//
			Inter.me.makeHint(slot,txt);

			//
			slots.push(slot);
			id++;

		}
	}



	// GET
	function getSlot(tid){
		for(sl in slots)if(sl.tid == tid)return sl;
		return null;
	}
	/*
	function getRequirement(tec){
		for( b in BuildingLogic.ALL ){
			for(t in b.technos){
				if(Type.enumEq(t,tec))return b.kind;
			}
		}
		return null;
	}
	*/

	// FONCTION ZIGZAG

	function getPos(id,ral=0.0):{x:Float,y:Float}{
		var cmax = CMAX;

		var dx = 	id%cmax;
		var dy = 	Std.int(id/cmax);
		var n = 	dy%2;
		var sens =	n*2-1;

		var o = {
			x : MX+(n*(cmax-1)-dx*sens)*(EC+MA)*1.0,
			y : MY+dy*(EC+MA)*1.0,

		}


		if(dx%CMAX==0) 		o.x += ral*sens;
		if(dx%CMAX==CMAX-1) 	o.x -= ral*sens;


		return o;
	}
	function getNearId(x:Float,y:Float){
		var dist = 9999.9;
		var id = 0;
		for( i in 0...36 ){
			var p = getPos(i);
			var dx = x-p.x;
			var dy = y-p.y;
			var d = Math.sqrt(dx*dx+dy*dy);
			if( d < dist ){
				dist = d;
				id = i;
			}
		}
		if(id<oid)id = oid;
		var lim = oid + Game.me.research.length -1;
		if(id>lim)id = lim;

		return id;
	}

	//*/


//{
}