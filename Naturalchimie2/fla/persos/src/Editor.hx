import mt.bumdum.Lib;


class Editor {
	
	var dm 				: mt.DepthManager ;
	var paramList	: Array<flash.MovieClip>;
	var colorList	: Array<flash.MovieClip>;	
	var gui				: flash.MovieClip;
	var so				: flash.SharedObject;
	var palette		: Array<Array<Int>>;
	var initPerso	: Bool;
	var persoMC		: flash.MovieClip;
	var thumbMC		: flash.MovieClip;
	var perso 		: Display;
	var thumb 		: Display;

	static var DP_EDITOR_GUI	 = 1;
	static var DP_EDITOR_PERSO	 = 2;
	static var DP_EDITOR_THUMB	 = 3;
	
	static function main(){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		var editor:Editor = new Editor();
	}
	
	function new(){
		init();
		flash.Lib._root.onEnterFrame = mainLoop;
		}
		
	function mainLoop(){
		perso.update();
		thumb.update();
		
		if ((perso.isUpdated) && (initPerso) ) {
			persoActiveParam(perso.getParam());
			palette = perso.getPalette();
			drawpalette();
			initPerso = false;
		}
	}

	function init(){
		dm = new mt.DepthManager(flash.Lib.current) ;
		
		gui = dm.attach("panel",DP_EDITOR_GUI);
		
		persoMC = dm.empty(DP_EDITOR_PERSO);
		thumbMC = dm.empty(DP_EDITOR_THUMB);
		
		perso = new Display(persoMC);
		thumb = new Display(thumbMC);
		
		palette =  new Array();

		so = flash.SharedObject.getLocal("NC_paramList");
		initButton();
		if (so.data.paramList != null) restoreButton();

		perso.initPerso(gui.cadre._x,gui.cadre._y,parsePersoParam());
		thumb.initThumb(gui.thumb._x,gui.thumb._y,parsePersoParam());
		initPerso = true;
		
		}
	
	function initRandom(){
		var me = this;
		gui.lvl1Random.onPress = function(){
				me.randomize(1);
			}	
		gui.lvl2Random.onPress = function(){
				me.randomize(2);
			}
		gui.lvl3Random.onPress = function(){
				me.randomize(3);
			}	
		gui.lvl4Random.onPress = function(){
				me.randomize(4);
			}	
		gui.raz.onPress = function(){
				me.randomize(5);
			}	
		gui.okButton.onPress = function(){
				me.restoreFromInput();
			}	
		
		}
	
	function randomize(lvl:Int){
			switch(lvl){
				case 1:
						for (i in 2 ... Cs.PMAX){
						paramList[i].value = Std.random(100);
						paramList[i].field.text = paramList[i].value;
						}
						for (i in 0 ... Cs.CMAX){
						colorList[i].value = Std.random(100);
						colorList[i].field.text = colorList[i].value;
						};
				case 2:
						for (i in 3 ... Cs.PMAX){
						paramList[i].value = Std.random(100);
						paramList[i].field.text = paramList[i].value;
						};
				case 3:
						for (i in 0 ... Cs.CMAX){
						colorList[i].value = Std.random(100);
						colorList[i].field.text = colorList[i].value;
						};
				case 4:
						for (i in 0 ... Cs.PMAX){
						paramList[i].value = Std.random(100);
						paramList[i].field.text = paramList[i].value;
						}
						for (i in 0 ... Cs.CMAX){
						colorList[i].value = Std.random(100);
						colorList[i].field.text = colorList[i].value;
						};
				case 5:
						for (i in 0 ... Cs.PMAX){
						paramList[i].value = 0;
						paramList[i].field.text = paramList[i].value;
						}
						for (i in 0 ... Cs.CMAX){
						colorList[i].value = 0;
						colorList[i].field.text = colorList[i].value;
						};
			}
			apply();
		}
	
	function restoreButton(){
			var cl:Array<String>  = new Array();
 			cl = so.data.paramList.split(";");
		 	for (i in 0 ...Cs.PMAX){
				paramList[i].field.text = ""+cl[i];
				paramList[i].value = Std.parseInt(cl[i]);
				}
			for (i in 0 ...Cs.CMAX){
				colorList[i].field.text = ""+cl[(i+Cs.PMAX)];
				colorList[i].value = Std.parseInt(cl[(i+Cs.PMAX)]);
			}
	}
	
	function restoreFromInput(){
			var cl:Array<String>  = new Array();
 			cl = this.gui.field.field.text.split(";");
		 	for (i in 0 ...Cs.PMAX){
				paramList[i].field.text = ""+cl[i];
				paramList[i].value = Std.parseInt(cl[i]);
				}
			for (i in 0 ...Cs.CMAX){
				colorList[i].field.text = ""+cl[(i+Cs.PMAX)];
				colorList[i].value = Std.parseInt(cl[(i+Cs.PMAX)]);
			}
			apply();
	}
		
	function initButton(){
		initRandom();
		paramList = new Array();
		colorList = new Array();
		for( i in 0...Cs.PMAX) {
			var b = "p"+i+"button";
			var mc:flash.MovieClip = Reflect.field(gui,b);
			mc.field.text = "0"; 
			mc.value = 0;
			initButVal(mc);
			paramList.push(mc);
		}
		
		for( i in 0...Cs.CMAX) {
			var b = "col"+i+"button";
			var mc:flash.MovieClip = Reflect.field(gui,b);
			mc.field.text = "0";
			mc.value = 0;
			initButVal(mc);
			colorList.push(mc);
		}
	}

	function initButVal(mc:flash.MovieClip){
		var me = this;
		mc.f0.onPress = function(){	me.incMe(mc,-1);}
		mc.f1.onPress = function(){	me.incMe(mc,1);	}
	}
		
	function incMe(mc:flash.MovieClip,val:Int){
			if (( 0 <= (mc.value + val) ) && ( (mc.value + val) <= 100 )) {
				mc.value = mc.value + val;
				mc.field.text = ""+mc.value;
				apply();
			}else{
				if ( 0 >= (mc.value + val) )  {mc.value = 99;}
				else {mc.value = 0; }
				mc.field.text = ""+mc.value;
				apply();
			}	
		}
	
	function parsePersoParam() : String{
		var str:String= "";
		for( i in 0...Cs.PMAX) {
			str += paramList[i].field.text +";";
		}
		for( i in 0...Cs.CMAX) {
			str += colorList[i].field.text;
			if (i != Cs.CMAX-1) str += ";";
		}
		return str;
	}
		
		
		
	function apply(){
		var str = parsePersoParam();
		this.gui.field.field.text = str;
		this.so.data.paramList = this.gui.field.field.text;
		perso.updatePerso(str);
		thumb.updatePerso(str);
		initPerso = true;

	}
	
	
	
	function persoActiveParam(param:Array<Int>){
		for (i in 0 ...Cs.PMAX){
			if (Lambda.has(param,i)){
				paramList[i]._alpha =100;
			}else{
				paramList[i]._alpha =20;
			}
		}
	}
	
	function drawpalette(){
		var pad:Int = 8;
		for (i in 0 ...Cs.CMAX){
			var pal = palette[i];
			var thisCol:Int = untyped pal[colorList[i].value%pal.length];
			drawRect(colorList[i].colbg ,29 ,24 ,thisCol,100);
			var colpos = 0; 
			for (j in 0...pal.length){if (pal[j] == thisCol)  colpos = j;}
			var temptab = new Array();
			temptab = pal.splice(0,colpos);
			pal = pal.concat(temptab);
			
			if (pal.length <10){
				for (j in 0...pal.length){
					if (pal[j] == thisCol) {
						var mc : flash.MovieClip = colorList[i].colbg.createEmptyMovieClip("col"+i+j,30); 
						Filt.glow(mc,2,30,0xffffff,true);
						mc._x = (j*pad) +70;
						mc._y =8;
						drawRect( mc,pad ,pad+4 ,pal[j],100);
					}else{
						var mc : flash.MovieClip = colorList[i].colbg.createEmptyMovieClip("col"+i+j,10+j); 
						mc._x = (j*pad)+70;
						mc._y = 10;
						drawRect( mc,pad ,pad ,pal[j],100);
					}
				}
				Filt.glow(colorList[i].colbg,2,30,0x666666,true);
			}else{
				for (j in 0...pal.length){
					var mc : flash.MovieClip;
					if (j != 0){ 
						mc  = colorList[i].colbg.createEmptyMovieClip("col"+i+j,10+j); 
						drawRect( mc,pad ,pad ,pal[j],100);
					}else{ 
						mc = colorList[i].colbg.createEmptyMovieClip("col"+i+j,50+j);
						drawRect( mc,pad+4 ,pad+4 ,pal[j],100);
						Filt.glow(mc,3,30,0xffffff,true);
					}
					mc._x = (Math.sin(((j*Cs.RAD)/pal.length)% Cs.RAD)*(pal.length*1.3))+100;
					mc._y = (Math.cos(((j*Cs.RAD)/pal.length)% Cs.RAD)*8) +8;	
				}	
			}
		}
	}
		
	function drawRect(target_mc:flash.MovieClip, width:Int, height:Int, fillColor:Int, fillAlpha:Int){
		target_mc.beginFill(fillColor, fillAlpha);
		target_mc.moveTo(0, 0);
		target_mc.lineTo(width, 0);
		target_mc.lineTo(width, height);
		target_mc.lineTo(0, height);
		target_mc.lineTo(0, 0);
		target_mc.endFill();
	}
	
	
	
}
