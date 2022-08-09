class Manager {//}

	public static var DP_BG = 	0;
	public static var DP_MAP = 	1;
	public static var DP_MODULE = 	2;
	public static var DP_MENU = 	3;
	public static var DP_FRONT = 	4;

	static var _main :{update:Void->Void};
	public static var dm:mt.DepthManager;
	public static var mcLog:{>flash.MovieClip,field:flash.TextField,str:String};
	public static var mcWaitScreen:{>flash.MovieClip,field:flash.TextField};

	public static var planetLoaded:Int;
	public static var mcPlanet:flash.MovieClip;


	public static var swfUrl:String;

	public static function main(){
		haxe.Log.setColor(0xFFFFFF);
		mt.flash.Key.enableForWmode();
		Cs.init();


		// URL
		swfUrl = Reflect.field( flash.Lib._root, "swfUrl" );
		if( swfUrl == null )swfUrl = "../../web/www/swf/";

		// INIT
		dm = new mt.DepthManager(flash.Lib._root);
		var bg = dm.attach("mcManagerBg",DP_BG);

		// LANG
		Text.setLang(Reflect.field(flash.Lib._root, "lang"));

		// PLANET
		loadPlanet();
	}

	public static function initLeReste(){
		// CHECK DEMO
		if( Reflect.field( flash.Lib._root, "demo" ) == null ){
			_main = cast new navi.Map(dm.empty(DP_MAP));
			navi.Map.me.initConnexion();
			Api.askInfos();
		}else{
			_main = cast new Demo(dm.empty(DP_MAP));
		}

		// UPDATE
		flash.Lib._root.onEnterFrame = function(){ _main.update(); }
	}



	// PLANET
	public static function loadPlanet(){
		mcPlanet = dm.empty(0);
		mcPlanet._visible = false;

		planetLoaded = 0;

		var mcl = new flash.MovieClipLoader();
		mcl.onLoadComplete = onPlanetLoaded;
		mcl.onLoadInit = onPlanetLoaded;
		mcl.loadClip( swfUrl+"planet.swf", mcPlanet );
	}
	public static function onPlanetLoaded(mc:flash.MovieClip){
		planetLoaded++;
		if(planetLoaded<2)return;
		mcPlanet._visible = false;
		initLeReste();
	}

	// WAIT SCREEN
	public static function initWaitScreen(){
		mcWaitScreen = cast dm.attach( "mcWaitScreen", DP_FRONT );
		mcWaitScreen.field.text = Text.get.CONNECTION_SERVER;
	}
	public static function removeWaitScreen(){
		mcWaitScreen.removeMovieClip();
	}

	// LOG
	public static function log(str){
		if(mcLog==null){
			mcLog = cast dm.attach( "mcLogWindow", 2 );
			mcLog.str = "";
			mcLog._x = 4;
			mcLog._y = 4;
			mcLog._visible = false;
		}
		mcLog.str+=str+"\n";
		if(mcLog.str.length>5000)mcLog.str = mcLog.str.substr(-1,500);

		mcLog.field.text = mcLog.str;
		mcLog.field.scroll = mcLog.field.maxscroll+1;
	}


	//{
}









/*

DRONES :
 - ANTI-MINE
 - ANTI-SPEEDER

MOTEUR :
 - HYPERDRIVE 2
 - HYPERDRIVE 3
 - HYPERDRIVE 4
 - HYPERDRIVE 5
 - HYPERDRIVE 6
 - HYPERDRIVE 7
 - HYPERDRIVE 8

MUNITION
 - VIE SUP
 - VIE SUP


*/
