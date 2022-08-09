import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;

typedef McCounter = {>flash.MovieClip, butMin:flash.MovieClip, butMaj:flash.MovieClip, field:flash.TextField };

class Game {//}

	static var mcw = 100;
	static var mch = 100;


	var skin:String;
	var url:String;

	var loaded:Int;
	var bouille:Bouille;
	var dm:mt.DepthManager;
	var root:flash.MovieClip;
	var avatar:flash.MovieClip;
	public static var me:Game;

	public function new( mc:flash.MovieClip ){
	
		me = this;
		root = mc;
		dm = new mt.DepthManager(mc);
		var bg = dm.attach("mcBg",0);

		dm.attach("mcCadre",2);

		url = 	Reflect.field(flash.Lib._root,"url");
		skin =	Reflect.field(flash.Lib._root,"skin");

		if (skin != null){
			skin = Skin.decodeSkin(skin);
		}

		if( url==null )	url = "../../../web/www/swf/avatar.swf";
		if( skin==null ) skin = "0,1,2,3,4,5,6,7,8";


		loadBouille();
	}

	// BOUILLE
	function loadBouille(){

		avatar = dm.empty(1);

		var me = this;
		var f = function (mc){
			me.loaded++;
			if(me.loaded==2)me.applyBouille();
		}
		loaded = 0;

		var mcl = new flash.MovieClipLoader();
		mcl.loadClip(url,avatar);
		mcl.onLoadInit = f;
		mcl.onLoadComplete = f;

	}
	function applyBouille(){

		bouille = new Bouille(skin);
		bouille.firstDecal = 0;
		bouille.apply(avatar);
	}






//{
}













