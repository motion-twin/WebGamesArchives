package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;


class People extends navi.Menu{//}

	var skin:{>flash.MovieClip, field:flash.TextField  };
	var mcButs:{>flash.MovieClip,dm:mt.DepthManager,list:Array<flash.MovieClip>};

	var endTimer:Float;
	var txt:String;
	var cursor:Int;

	override function init(){
		super.init();
		skin = cast dm.attach("mcPeople",1);
		navi.menu.Shop.initAlien(skin,bs);
		skin._x = navi.Menu.MARGIN;
		skin._y = navi.Menu.MARGIN*(Cs.mch/Cs.mcw);
	}

	function setText(str){
		txt = str;
		cursor = 0;
		skin.field.text = str;
		skin.field._y = Math.max(143, 216 - skin.field.textHeight*0.5);
		skin.field.text = "";
	}

	function addBut(id,f){
		if(mcButs==null){
			mcButs = cast dm.empty(2);
			mcButs.list = [];
			mcButs.dm = new mt.DepthManager(mcButs);
			mcButs._y = 317;
		}

		var mc = mcButs.dm.attach("mcButPeople",0);
		var field:flash.TextField = (cast mc).field;
		field.text = Text.get.BUTTON_PEOPLE[id];
		field._width = field.textWidth+10;
		mc.smc._xscale = field._width;

		mc.onPress = f;
		mc.onRollOver = function(){ mc.blendMode = "add"; };
		mc.onRollOut = function(){ mc.blendMode = "normal"; };

		mcButs.list.push(mc);
		updateButPos();
	}
	function updateButPos(){
		var x = 0.0;
		for( mc in mcButs.list ){
			mc._x = x;
			x += mc._width+10;
		}

		mcButs._x = Cs.mcw*0.5 - mcButs._width*0.5;

	}
	function removeAllButs(){
		mcButs.removeMovieClip();
	}


	override public function update(){
		super.update();

		if(cursor!=null){
			cursor++;
			var str = txt.substr(0,cursor);
			if( cursor%3 > 0 ) str+="_";
			skin.field.text = str;

			skin.field.scroll = skin.field.maxscroll;


		}

		if( endTimer!=null ){
			endTimer -= mt.Timer.tmod;
			if(endTimer<=0){
				endTimer = null;
				quit();
			}
		}

	}


//{
}








