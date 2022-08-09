class GrimSmall {
	
	var dm 			: mt.DepthManager ;
	var title 		: GrimSmall;
	var mc			: flash.MovieClip;

	
	static function main(){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		var title:GrimSmall = new GrimSmall();
		
		
	}
	
	function new(){
		flash.Lib._root.onEnterFrame = mainLoop;
		
		dm = new mt.DepthManager(flash.Lib.current) ;
		mc = dm.attach("title_small",1);
		mc._y = -2;
		
		var rootxt:String = Reflect.field(flash.Lib._root, "txt");
		var txt:String = if (rootxt != null) rootxt else "..." ;

		var rootSchool:String = Reflect.field(flash.Lib._root, "school");
		var sc:Int = if (rootSchool != null) (Std.parseInt(rootSchool)+1) else 1 ;


		
		mc.gotoAndStop(sc);



		//if (txt != null) 
		mc.field.text = txt;
		mc._alpha = 100 ;
	
		}
		
	function mainLoop(){
		
		
		if (mc._alpha < 100) {
			mc._alpha += 50;
		}
		else{
			flash.Lib._root.stop();
			
		}

	}
		
}
