package ac ;

import mt.bumdum.Lib;


class Object extends State {//}


	var f : Fighter ;
	var name : String ;
	var oid : String ;

	var loaded:Int;

	var icon:mt.bumdum.Phys;

	/*
	var mc : flash.MovieClip ;
	var artWork : flash.MovieClip ;
	var mcText : flash.TextField ;
	*/


	public function new(f : Fighter, name : String, oid:String) {
		super();
		this.f = f ;
		this.name = name;
		this.oid = oid;

		f.playAnim("stand");

		addActor(f);


	}


	override function init() {

		icon = new mt.bumdum.Phys( Scene.me.dm.empty( Scene.DP_PARTS ) );

		var mcl = new flash.MovieClipLoader();
		mcl.onLoadComplete = 	iconLoaded;
		mcl.onLoadInit = 	iconLoaded;
		mcl.loadClip( Main.DATA._equip.split("::id::").join(oid), icon.root );
		loaded = 0;

		icon.x = f.x - 20 ;
		icon.y = Scene.getY(f.y)-50;
		icon.vy = -2;
		icon.timer = 40;
		icon.frict = 0.9;
		icon.fadeLimit = 5;


		releaseCasting();
		var ac = new ac.Announce(f,name);
		ac.endCall = end;

		//





	}

	function initPourDeBon(){



	}

	function iconLoaded(mc){
		loaded++;
		if(loaded==2)initPourDeBon();
	}





	public override function update() {
		super.update();
	}

//{
}