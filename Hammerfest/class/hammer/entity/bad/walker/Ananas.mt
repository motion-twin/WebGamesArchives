class entity.bad.walker.Ananas extends entity.bad.Jumper {

	static var CHANCE_DASH	= 6;

	var fl_attack	: bool ;

	var dashRadius	: float ;
	var dashPower	: float ;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpH(100) ;
		speed			*= 0.8 ;
		dashRadius 		= 100 ;
		dashPower		= 30 ;
		fl_attack		= false ;
		slideFriction	= 0.9;
		shockResistance	= 2.0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		if ( game.fl_bombExpert ) {
			dashRadius*=2;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_ANANAS];
		var mc : entity.bad.walker.Ananas = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	GELÉ
	------------------------------------------------------------------------*/
	function freeze(d) {
		super.freeze(d);
		fallFactor *= 1.5;
		fl_attack = false;
		unstick();
	}

	/*------------------------------------------------------------------------
	ASSOMÉ
	------------------------------------------------------------------------*/
	function knock(d) {
		super.knock(d);
		fallFactor *= 1.5;
		fl_attack = false;
		unstick();
	}


	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		super.killHit(dx);
		fl_attack = false;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE BAD EST PRÊT POUR UNE ACTION
	------------------------------------------------------------------------*/
	function isReady() {
		return !fl_attack && super.isReady() ;
	}


	/*------------------------------------------------------------------------
	REPOUSSE UN TYPE D'ENTITÉ
	------------------------------------------------------------------------*/
	function repel(type, powerFactor) {
		var l = game.getClose(type,x,y,dashRadius,false) ;
		for (var i=0;i<l.length;i++) {
			var e : entity.Physics = downcast(l[i]) ;
			shockWave( e, dashRadius, dashPower*powerFactor) ;
			e.dy -= 8 ;
			if ( e.isType(Data.PLAYER) ) {
				downcast(e).knock(Data.SECOND*1.5);
			}
		}
	}


	/*------------------------------------------------------------------------
	REPOUSSE UN TYPE D'ENTITÉ
	------------------------------------------------------------------------*/
	function vaporize(type) {
		var l = game.getClose(type,x,y,dashRadius,false) ;
		for (var i=0;i<l.length;i++) {
			var e = l[i];
			game.fxMan.attachFx( e.x, e.y-Data.CASE_HEIGHT, "hammer_fx_pop" );
			e.destroy();
		}
	}


	/*------------------------------------------------------------------------
	LANCE L'ATTAQUE
	------------------------------------------------------------------------*/
	function startAttack() {
		var fl_allOut = true;
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			if ( !pl[i].fl_knock ) {
				fl_allOut = false;
			}
		}
		if ( fl_allOut ) {
			return;
		}
		halt();
		playAnim(Data.ANIM_BAD_THINK);
		forceLoop(true);
		setNext(0,-10,Data.SECOND*0.9,Data.ACTION_MOVE);
		fl_attack = true;
		var mc = game.depthMan.attach("curse", Data.DP_FX) ;
		mc.gotoAndStop(""+Data.CURSE_TAUNT) ;
		stick(mc,0,-Data.CASE_HEIGHT*2.5);
	}


	/*------------------------------------------------------------------------
	EFFETS DE L'ATTAQUE
	------------------------------------------------------------------------*/
	function attack() {
		var fx = game.fxMan.attachExplodeZone(x,y,dashRadius) ;
		fx.mc._alpha = 20;
		game.shake(Data.SECOND*0.5, 5) ;

		var l = game.getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			if ( p.fl_stable ) {
				if ( p.fl_shield ) {
					p.dy = -8;
				}
				else {
					p.knock( Data.PLAYER_KNOCK_DURATION );
				}
			}
		}

		repel(Data.BOMB, 1) ;
		repel(Data.PLAYER, 2) ;
		vaporize(Data.PLAYER_SHOOT) ;

		fl_attack = false ;
		unstick();
	}


	/*------------------------------------------------------------------------
	EVENT: ATTERRISSAGE
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h) ;

		if ( fl_attack && isHealthy() ) {
			attack();
			playAnim(Data.ANIM_BAD_SHOOT_END);
			halt();
		}
		else {
			game.shake(Data.SECOND*0.2, 2) ;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( !isHealthy() ) {
			game.shake(5,3) ;
		}
		super.onHitWall() ;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM D'ATTAQUE
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);
		if ( id==Data.ANIM_BAD_SHOOT_END.id ) {
			walk();
		}
	}


	/*------------------------------------------------------------------------
	PRÉFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function prefix() {
		if ( isReady()  ) {
			if ( fl_playerClose && Std.random(1000)<=CHANCE_DASH*2 ) {
				startAttack();
			}
			if ( !fl_playerClose && Std.random(1000)<=CHANCE_DASH ) {
				startAttack();
			}
		}
		super.prefix() ;
	}

}

