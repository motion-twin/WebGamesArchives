class entity.bomb.bad.Mine extends entity.bomb.BadBomb
{
	static var SUDDEN_DEATH	= Data.SECOND * 1.1;
	static var HIDE_SPEED	= 3;
	static var DETECT_RADIUS= Data.CASE_WIDTH*2.5;

	var fl_trigger	: bool;
	var fl_defuse	: bool;
	var fl_plant	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		fl_blink		= true;
		fl_alphaBlink	= false;
		duration		= Data.SECOND*15;
		power			= 50 ;
		radius			= Data.CASE_WIDTH*3;

		fl_trigger		= false;
		fl_defuse		= false;
		fl_plant		= false;
	}

	/*------------------------------------------------------------------------
	INITIALISATION BOMBE
	------------------------------------------------------------------------*/
	function initBomb(g,x,y) {
		super.initBomb(g,x,y);
		if ( game.fl_bombExpert ) {
			radius*=1.3; // higher factor than other badbombs !
		}
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_mine" ;
		var mc : entity.bomb.bad.Mine = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) ) ;
		mc.initBomb(g, x,y ) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return attach(game, x,y) ;
	}

	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		if ( !fl_trigger ) {
			playAnim(Data.ANIM_BOMB_LOOP);
		}
		if ( !fl_defuse ) {
			rotation = 0;
		}
	}

	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		if ( !fl_trigger || fl_defuse ) {
			game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_pop") ;
			destroy();
		}
		else {
			super.onExplode() ;
			game.fxMan.attachExplodeZone(x,y,radius) ;

			var l = game.getClose(Data.PLAYER,x,y,radius,false) ;

			for (var i=0;i<l.length;i++) {
				var e : entity.Player = downcast(l[i]) ;
				e.killHit(0) ;
				shockWave( e, radius, power ) ;
				if ( !e.fl_shield ) {
					e.dy = -10-Std.random(20) ;
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: KICK (CES BOMBES SONT FACILEMENT REPOUSSABLES)
	------------------------------------------------------------------------*/
	function onKick(p) {
		super.onKick(p);
		triggerMine();

		updateLifeTimer(Data.SECOND*0.7);
		dx *= 0.8 + Std.random(10)/10
//		fl_defuse = true;
	}


	/*------------------------------------------------------------------------
	ACTIVE LA MINE
	------------------------------------------------------------------------*/
	function triggerMine() {
		if ( fl_trigger ) {
			return;
		}
		fl_trigger = true;
		playAnim(Data.ANIM_BOMB_DROP);
		dy = -7;
		show();
		alpha = 100;

		setLifeTimer(SUDDEN_DEATH*3); // pour forcer le blink
		updateLifeTimer(SUDDEN_DEATH);
		blinkLife();
	}


	/*------------------------------------------------------------------------
	LANCE UNE ANIM
	------------------------------------------------------------------------*/
	function playAnim(a) {
		super.playAnim(a);
		if ( a.id==Data.ANIM_BOMB_DROP.id ) {
			fl_loop = true;
		}
		if ( a.id==Data.ANIM_BOMB_LOOP.id ) {
			fl_loop = false;
		}
	}


	/*------------------------------------------------------------------------
	GÈLE LA BOMBE
	------------------------------------------------------------------------*/
//	function getFrozen(uid) {
//		var b = entity.bomb.player.MineFrozen.attach(game, x, y);
//		b.uniqId = uid;
//		return b;
//	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		// Activation à l'atterrissage
		if ( fl_stable && !fl_plant ) {
			fl_plant = true;
		}

		// Disparition après la pose
		if ( fl_plant && !fl_trigger && alpha>0 ) {
			alpha-=Timer.tmod*HIDE_SPEED;
			if ( alpha<=0 ) {
				hide();
			}
		}

		// Déclenchement
		if ( fl_plant && !fl_trigger ) {
			var l = game.getClose(Data.PLAYER,x,y,DETECT_RADIUS,false);
			for (var i=0;i<l.length;i++) {
				if ( !l[i].fl_kill ) {
					triggerMine();
				}
			}
		}
	}

}

