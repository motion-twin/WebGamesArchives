class entity.supa.SupaItem extends entity.Supa
{

	var supaId : int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		radius = 50;
	}


	/*------------------------------------------------------------------------
	INIT
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		scale(200);
		moveDown(5);
		this.gotoAndStop(string(supaId+1));
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode, id:int) {
		var linkage = "hammer_supa_item";
		var mc : entity.supa.SupaItem = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.supaId = id;
		mc.initSupa(g, Data.GAME_WIDTH/2,-50 );
		return mc;
	}


	/*------------------------------------------------------------------------
	RAMASSAGE
	------------------------------------------------------------------------*/
	function pick(pl) {
		game.fxMan.inGameParticles(Data.PARTICLE_ICE,x,y,15);
		game.fxMan.attachExplodeZone(x,y,50);
		var score = Data.getCrystalValue(supaId)*5;
		game.manager.logAction("$SU"+supaId);
		pl.getScore(this,score);
		game.soundMan.playSound("sound_item_supa", Data.CHAN_ITEM);

		// Fait pleurer l'autre joueur ^^
		var l = game.getPlayerList();
		for (var i=0;i<l.length;i++) {
			if ( l[i].uniqId!=pl.uniqId ) {
				l[i].setBaseAnims(Data.ANIM_PLAYER_WALK, Data.ANIM_PLAYER_STOP_L);
			}
		}

		destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: SORTIE PAR LE BAS (LOUPÉ !)
	------------------------------------------------------------------------*/
	function onDeathLine() {
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			pl[i].setBaseAnims(Data.ANIM_PLAYER_WALK, Data.ANIM_PLAYER_STOP_L);
		}
		destroy();
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();

		var l = game.getClose( Data.PLAYER, x,y+Data.CASE_HEIGHT*1.5, radius, false );
		var fl_break = false;
		for (var i=0;i<l.length && !fl_break;i++) {
			var e : entity.Player = downcast(l[i]);
			if ( !e.fl_kill ) {
				pick(e);
				fl_break=true;
			}
		}

		if ( y>=Data.GAME_HEIGHT+50 ) {
			onDeathLine();
		}
	}


}
