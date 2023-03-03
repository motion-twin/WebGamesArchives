package handler;
import Common;

class CommunityActions extends Handler<Void>{
	static var ACTIONS = [
		"Tenir la porte",
		"Hurler",
		"Se cacher sous le lit",
		"Serrer les fesses",
		"Attendre sous les draps",
		"Appeler à l'aide",
		"Se cramponner à un bout de bois",
		"Prier pour sa vie",
		"S'égosiller tout seul chez soi",
		"Brailler « au secours »",
		"Pleurer en position foetale",
		"Se cramponner à son sac à dos",
		"Claquer des dents",
		"Paniquer et hurler",
		"Se planquer derrière des détritus",
		"Ramper sous un carton",
		"Attendre calmement...",
		"Pleurer nerveusement",
		"Vociférer comme un dément",
	];

	var h : IntHash<Void->Void>;

	public function new() {
		super();

		h = new IntHash();
		h.set( 1, doRevolution );
		h.set( 2, doChaos );

		community( "default", doDefault );
		free( "ES_horde", "horde.mtt", doHorde );
	}

	function doDefault() {
		if( App.user.eventState == null ) {
			App.reboot();
			return;
		}
		if( !h.exists( App.user.eventState ) ) {
			App.reboot();
			return;
		}
		h.get( App.user.eventState )();
	}

	function doRevolution() {
		App.context.event = "revolution";
		doEvent( App.user.eventState );
	}

	function doChaos() {
		App.context.event = "chaos";
		doEvent( App.user.eventState );
	}

	function doEvent(event : Int ) {
		prepareTemplate("event.mtt");
		App.context.eventStat = App.user.eventState;
	}

	function doHorde() {
		var actions = tools.Utils.getListFrom(Text.getUnformated.RandomMidnightAction);
		var a1 = null;
		var a2 = null;
		while( a1 == a2) {
			a1 = actions[Std.random(actions.length)];
			a2 = actions[Std.random(actions.length)];
		}
		App.context.action1 = a1;
		App.context.action2 = a2;
		App.context.hideBar = true;
	}
}
