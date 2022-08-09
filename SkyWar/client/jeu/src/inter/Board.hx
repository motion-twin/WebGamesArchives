package inter;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


class Board {//}

	public static var DP_PANEL = 2;
	public static var DP_TABS = 1;

	public static var WIDTH = 240;
	public static var TAB_LINE = 121;

	public var root:{
		>flash.MovieClip,
		butMode:flash.MovieClip,
		fieldTitle: flash.TextField,
		fieldFood: flash.TextField,
		fieldPeople: flash.TextField,
		fieldMode: flash.TextField,
		fieldAtt: flash.TextField,
		fieldDef: flash.TextField,
		fieldTime:flash.TextField,
		barBreed:flash.MovieClip,
		butA:flash.MovieClip,
		butB:flash.MovieClip,
		butC:flash.MovieClip,
		prev:flash.MovieClip,
		next:flash.MovieClip,
	};


	public var mask:flash.MovieClip;
	public var barCounter:Counter;
	public var animSens:Int;
	public var animCoef:Float;

	public var tabs:Array<flash.MovieClip>;
	public var tid:Int;
	public var dm:mt.DepthManager;
	public var pan:Panel;

	public var nullBut:flash.MovieClip;

	public function new(fr){
		Inter.me.board = this;

		nullBut = Inter.me.dm.attach("mcNullBut",Inter.DP_BOARD);
		nullBut.onPress = function(){};
		nullBut.useHandCursor = false;
		nullBut._x = Cs.mcw;
		nullBut._alpha = 0;

		root = cast Inter.me.dm.attach(Cs.gil("mcPanel"),Inter.DP_BOARD);
		root.gotoAndStop(fr+1);
		root._x = Cs.mcw-(WIDTH+3)+800;
		root._y = 2;
		Inter.me.updateArea();
		dm = new mt.DepthManager(root);
		Inter.me.updateArea();

		mask = Inter.me.dm.attach("mcPanelMask",Inter.DP_BOARD);
		mask._x = Cs.mcw;
		mask.gotoAndStop(Game.me.raceId+1);
		root.setMask(mask);

		//animCoef = 1;
		if( Param.is(_ParamFlag.PAR_MENU_ANIM) ){
			animCoef = 0;
			animSens = 1;
		}else{
			root._x = Cs.mcw-(WIDTH+3);
			Inter.me.updateArea();
		}
	}

	public function update(){
		mask.removeMovieClip();

		if(animSens!=null){
			animCoef = Num.mm(0,animCoef+0.15*animSens,1);
			var c = Math.pow(animCoef,0.5);
			var tx = Cs.mcw-(WIDTH+3);
			var bx = tx+250;
			root._x = tx*c + bx*(1-c);
			Inter.me.updateArea();

			/*
			root.filters = [];
			mask.removeMovieClip();
			if(animCoef<0.66){
				var bl = (1-animCoef*0.75)*128;
				Filt.blur(root,bl,0);
				trace(bl);
			}
			*/



			if(animCoef==1)animSens = null;
			if(animCoef==0)remove();

		}


		pan.update();
		root.barBreed._xscale = Game.me.getCounterInfo(barCounter).c*100;
	}
	public function display(){
		pan.display();


	}

	public function setPanel(panel){
		pan.remove();
		pan = panel;
	}


	public function setSkin(id,?tid){

		this.tid = tid;
		while(tabs.length>0)tabs.pop().removeMovieClip();
		root.gotoAndStop(id+1);

		switch(id){
			case 0 :
				tabs = [];
				for( i in 0...3 ){

					var mc = dm.attach(Cs.gil("mcSignet"),DP_TABS);
					mc._x = 36 + 57*i;
					mc._y = 98;
					mc.gotoAndStop(i==tid?1:2);
					mc.smc.gotoAndStop(i+1);
					mc.onPress = callback(selectTab,i);
					tabs.push(mc);

					Inter.me.makeHint(mc,Lang.getTitleDesc(Lang.TABS[i],Lang.IGH_TABS[i]));

				}
				barCounter = Inter.me.isle.pl.breed;
			case 4 :
				root.butA.stop();
				root.butB.stop();
				root.butC.stop();

		}


		updateFields();


	}

	public function updateFields(){

		var pl = Inter.me.isle.pl;

		root.fieldTitle.text = Lang.tuc(Game.me.getPlanetName(pl.id));
		root.fieldFood.text = Std.string(pl.food);
		root.fieldPeople.text = Std.string(pl.pop);
		root.fieldAtt.text = Std.string(pl.att);
		root.fieldDef.text = Std.string(pl.def);

		barCounter = Inter.me.isle.pl.breed;

		// HINTS
		var a = [root.fieldFood,root.fieldPeople,root.fieldAtt,root.fieldDef];
		for( i in 0...4 ){
			var mmc = Reflect.field(root,"_igh_"+i);
			var str = getIsleFieldHint(i);
			if( i==0 )	Inter.me.makeHint(mmc,str,null,true,getPopHint);
			else 		Inter.me.makeHint(mmc,str);
		}
	}
	public function getIsleFieldHint(i){
		var str = "<b>"+Lang.ISLAND_CARACS[i]+"</b><br/>";
		str += "<i>"+Lang.IGH_ISLAND_CARACS[i]+"</i>";
		return str;
	}
	public function getPopHint(){
		var str = "";
		if(Param.is(_ParamFlag.PAR_IN_GAME_HELP)) str+=getIsleFieldHint(0)+"<br/>";
		str += "<p align='center'><b>"+Lang.NEXT_POP+"</b><br/>"+Cs.getTime(Game.me.getCounterInfo(barCounter).run)+"</p>";
		return str;
	}



	public function loadImage(url){
		var mcl = new flash.MovieClipLoader();
		mcl.loadClip(url,root.smc);
	}
	function selectTab(n){
		var pl = Inter.me.isle.pl;
		inter.Panel.sliderPosSave = null;
		switch(n){
			case 0:	new inter.pan.War(pl);
			case 1:	new inter.pan.ConstructShip(pl);
			case 2:	new inter.pan.Yard(pl);
			//case 2:	new inter.pan.Research();

		}
	}


	public function vanish(){


		if( Param.is(_ParamFlag.PAR_MENU_ANIM) ){
			animCoef = 1;
			animSens = -1;
		}else{
			remove();
		}

		//trace("vanish!");
		//animSens = -1;
		//animCoef = 1;
		//if( !Param.is(_ParamFlag.PAR_MENU_ANIM) ) animCoef = 0;

		Inter.me.hideHint();
		Inter.me.mcBackBut.onPress = null;
		root.onPress = function(){};
		root.useHandCursor = false;
	}

	public function remove(){
		nullBut.removeMovieClip();
		Inter.me.mcBackBut.removeMovieClip();

		root.removeMovieClip();
		mask.removeMovieClip();

		Inter.me.board = null;
		Inter.me.updateArea();
		Inter.me.hideHint();
	}


//{
}















