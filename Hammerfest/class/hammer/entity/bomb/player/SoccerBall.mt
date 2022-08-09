class entity.bomb.player.SoccerBall extends entity.bomb.PlayerBomb
{

	static var TOP_SPEED	= 4;

	var speed				: float;
	var burnTimer			: float;
	var lastPlayer			: entity.Player;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		lastPlayer		= null;
		duration		= 999999;
		burnTimer		= 0;
		bounceFactor	= 0.8;
		fl_bounce		= true;
		slideFriction	= Data.FRICTION_SLIDE * 0.9;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_soccer";
		var mc : entity.bomb.player.SoccerBall = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb(g, x,y );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.SOCCERBALL);
		FxManager.addGlow(this, 0x808080, 2);
		game.fxMan.attachShine( x, y-Data.CASE_HEIGHT*0.5 );
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return null;
	}

	/*------------------------------------------------------------------------
	AUGMENTE LA PUISSANCE DE LA BOMBE
	------------------------------------------------------------------------*/
	function upgradeBomb(p) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: KICK
	------------------------------------------------------------------------*/
	function onKick(p) {
		super.onKick(p);
		lastPlayer = p;
		if ( Math.abs(dx)<10 ) {
			dx *= 3;
			dy *= 1.1;
		}
	}


	/*------------------------------------------------------------------------
	MET LE FEU AU BALLON
	------------------------------------------------------------------------*/
	function burn() {
		burnTimer = Data.SECOND;
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		// never explodes
	}


	/*------------------------------------------------------------------------
	INFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();
		var id = world.getCase( {x:cx,y:cy} ) ;
		if ( id==Data.FIELD_GOAL_1 ) {
			downcast(game).goal(1);
			destroy();
		}
		if ( id==Data.FIELD_GOAL_2 ) {
			downcast(game).goal(0);
			destroy();
		}
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();
		sub._rotation += dx*5;
		if ( dx>0 ) {
			sub._xscale = -Math.abs(sub._xscale);
		}
		if ( dx<0 ) {
			sub._xscale = Math.abs(sub._xscale);
		}

	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		var ocx = Entity.x_rtc(oldX);
		var ocy = Entity.y_rtc(oldY);
		if ( world.getCase( {x:ocx,y:ocy} ) != Data.GROUND ) {
			dx = -dx;
			if ( Math.abs(dx)>7 ) {
				game.fxMan.inGameParticlesDir( Data.PARTICLE_DUST, x,y, Std.random(5)+1, dx);
			}
		}

	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		speed = Math.sqrt( Math.pow(dx,2) + Math.pow(dy,2) );
		animFactor = 0.5 * speed/TOP_SPEED ;
		fl_airKick = true;

		if ( burnTimer>0 ) {
			game.fxMan.inGameParticles(Data.PARTICLE_SPARK, x,y,Std.random(3));
			var fx = game.fxMan.attachFx(
				x + Std.random(5)*(Std.random(2)*2-1),
				y - Std.random(20),
				"hammer_fx_ballBurn"
			);
			var ratio = Math.min(1,speed/TOP_SPEED);
			fx.mc._xscale = 100 * ratio;
			fx.mc._yscale = fx.mc._xscale;
			burnTimer-=Timer.tmod;
		}
		super.update();
	}
}

