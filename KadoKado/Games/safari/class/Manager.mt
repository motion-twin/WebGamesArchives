class Manager {

	var root : MovieClip;
	var game : Game ;

	static var current : Manager;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
	function new(mc) {
		root = mc ;
		game = new Game(this);
	}

/*------------------------------------------------------------------------
    LOOP
 ------------------------------------------------------------------------*/
	function mainLoop() {
		Timer.update();
		if ( Timer.fps()<=20 )
			game.fl_fast = true ;
		if ( Timer.fps()<=15 )
			downcast(root)._quality = "low" ;
		game.update() ;
	}


	static function init(mc : MovieClip) {

		Std.registerClass("drone", entity.target.Drone);
		Std.registerClass("warper", entity.target.Warper);
		Std.registerClass("bigUFO", entity.target.Big);
		Std.registerClass("option", entity.target.Option);

		Std.registerClass("gib", entity.fx.Gib);
		Std.registerClass("shoot", entity.fx.Shoot);
		Std.registerClass("instantFx", entity.fx.Instant);
		Std.registerClass("cartridge", entity.fx.Cartridge);

        if ( KKApi.available() )
		  current = new Manager(mc);
	}

	static function main() {
	    if ( KKApi.available() )
		  current.mainLoop();
	}


}


