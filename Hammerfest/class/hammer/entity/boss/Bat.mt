class entity.boss.Bat extends entity.Mover {

	static var GLOW_BASE	= 8;
	static var GLOW_RANGE	= 4;
	static var RADIUS		= Data.CASE_WIDTH*1.5;
	static var SPEED		= 6.5;
	static var SHOOT_SPEED	= 8;
	static var LIVES		= 3;
	static var WAIT_TIME	= Data.SECOND*3.5;
	static var FLOAT_X		= 5;
	static var FLOAT_Y		= 10;
	static var MAX_FALL_ROTATION	= 80;

	var dir			: int;
	var lives		: int;

	var fl_trap		: bool; // entity.Bad compatibility (spikes)

	var fl_shield	: bool;
	var fl_immune	: bool;
	var immuneTimer	: float;
	var fl_move		: bool;
	var fl_wait		: bool;
	var fl_death	: bool;
	var fl_deathUp	: bool;

	var fl_anger	: bool;

	var floatOffset	: float;
	var tx			: float;
	var ty			: float;

	var fbList		: Array<entity.shoot.BossFireBall>;

//	var shieldMC	: MovieClip;
	var glow		: flash.filters.GlowFilter;
	var glowCpt		: float;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;

		fl_hitGround	= false;
		fl_hitCeil 		= false;
		fl_hitWall		= false;
		fl_hitBorder	= true;
		fl_gravity		= false;
		fl_friction		= false;
		fl_moveable		= false;
		fl_alphaBlink	= false;
		fl_trap			= false;

		fl_move			= false;
		fl_wait			= false;
		fl_shield		= false;
		fl_immune		= false;
		immuneTimer		= 0;
		fl_anger		= false;
		floatOffset		= 0;

		fl_death		= false;
		fl_deathUp		= false;

		dir			= 1;
		lives		= LIVES;
		fbList		= new Array();

		glow		= new flash.filters.GlowFilter();
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_boss_bat";
		var mc : entity.boss.Bat = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBoss(g) ;
		return mc ;
	}



	/*------------------------------------------------------------------------
	INITIALISATION GÉNÉRIQUE
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.BAD);
		register(Data.BOSS);
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU BOSS
	------------------------------------------------------------------------*/
	function initBoss(g) {
		init(g);
		moveTo(Data.GAME_WIDTH*0.5,30) ;

		playAnim(Data.ANIM_BAT_INTRO);
		_xscale = -scaleFactor*100;
		endUpdate();
	}


	function destroy() {
//		shieldMC.removeMovieClip();
		super.destroy();
		game.fl_clear = true;
		game.fxMan.attachExit();
	}


	/*------------------------------------------------------------------------
	GÉNÈRE UN NOUVEAU POINT DE DESTINATION
	------------------------------------------------------------------------*/
	function moveRandom() {
		if ( fl_death ) {
			return;
		}
		var limit = 0.8;
		do {
			tx = Data.GAME_WIDTH*(1-limit)*0.5 + Std.random( Math.round(Data.GAME_WIDTH*limit) );
			ty = Data.GAME_HEIGHT*(1-limit)*0.5 + Std.random( Math.round(Data.GAME_HEIGHT*limit) );
		} while (  distance(tx,ty)<Data.BOSS_BAT_MIN_DIST  ||  Math.abs(x-tx)<Data.BOSS_BAT_MIN_X_DIST  );

		var sign = Math.round(  (tx-x)/Math.abs(tx-x)  );
		if ( sign!=dir ) {
			flip();
		}
		else {
			playAnim(Data.ANIM_BAT_MOVE);
			fl_move = true;
		}
	}


	/*------------------------------------------------------------------------
	CHANGE DE SENS GAUCHE-DROITE
	------------------------------------------------------------------------*/
	function flip() {
		halt();
		playAnim(Data.ANIM_BAT_SWITCH);
		dir = -dir;
		_xscale = dir*scaleFactor*100;
	}


	/*------------------------------------------------------------------------
	STOP / CONTINUE LE MOUVEMENT VERTICAL
	------------------------------------------------------------------------*/
	function halt() {
		fl_stopStepping = true;
		fl_move = false;
		dx = 0;
		dy = 0;
	}


	/*------------------------------------------------------------------------
	GESTION IMMUNITÉ
	------------------------------------------------------------------------*/
	function immune() {
		fl_immune	= true;
		immuneTimer	= Data.SECOND*3;
	}

	function removeImmunity() {
		fl_immune	= false;
		stopBlink();
		shield();
	}


	function wait() {
		fl_wait = true;
	}

	function stopWait() {
		fl_wait = false;
		x = _x;
		y = _y;
	}


	/*------------------------------------------------------------------------
	GESTION BOUCLIER
	------------------------------------------------------------------------*/
	function shield() {
		if ( fl_shield || fl_death ) {
			return;
		}
//		shieldMC = game.depthMan.attach("hammer_player_shield", Data.DP_BADS) ;
//		shieldMC._xscale *= 1.5;
//		shieldMC._yscale = shieldMC._xscale;
		fl_shield	= true;
		filters		= null;

		glowCpt			= 0;
	}

	function removeShield() {
//		shieldMC.removeMovieClip();
		fl_shield	= false;

		glow.quality	= 1;
		glow.color		= 0xffd78c;
		glow.strength	= 180;
		glow.blurX		= GLOW_BASE;
		glow.blurY		= GLOW_BASE;
		glow.alpha		= 1.0;
		filters			= [upcast(glow)];
	}


	/*------------------------------------------------------------------------
	TOUCHÉ PAR UNE BOMBE
	------------------------------------------------------------------------*/
	function freeze(d) {
		if ( fl_immune || fl_death ) {
			return;
		}

		if ( fl_shield ) {
			removeShield();
			bossAnger();
		}
		else {
			stopWait();
			immune();
			shield();
			bossCalmDown();
			loseLife();
		}
	}


	/*------------------------------------------------------------------------
	BEHAVIOURS DÉSACTIVÉS
	------------------------------------------------------------------------*/
	function knock(d) {	}
	function killHit(dx) { }


	/*------------------------------------------------------------------------
	APPELÉ SUR LA MORT DU JOUEUR
	------------------------------------------------------------------------*/
	function onPlayerDeath() {
		bossCalmDown();
		shield();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIMATION
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);


		// arrivée
		if ( id==Data.ANIM_BAT_INTRO.id ) {
			_xscale = scaleFactor*100;
			shield();
			moveRandom();
		}

		// switch
		if ( id==Data.ANIM_BAT_SWITCH.id ) {
			playAnim(Data.ANIM_BAT_MOVE);
			fl_move = true;
		}
	}


	/*------------------------------------------------------------------------
	PRÉFIXE DU STEPPING
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();
		if ( !fl_immune && !fl_death ) {
			var l = game.getClose(Data.PLAYER,x,y+Data.CASE_HEIGHT*0.5, RADIUS, false);
			for (var i=0;i<l.length;i++) {
				var e : entity.Player = downcast(l[i]) ;
				e.killHit(dx) ;
			}
		}
	}


	/*------------------------------------------------------------------------
	INFIX DE STEPPING
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();

	}


	/*------------------------------------------------------------------------
	EVENT: ACTION SUIVANTE
	------------------------------------------------------------------------*/
	function onNext() {
		if ( next.action==Data.ACTION_MOVE ) {
			if ( fl_anger ) {
				bossCalmDown();
				shield();
				return;
			}
			moveRandom();
			stopWait();
		}
		next = null;
	}


	/*------------------------------------------------------------------------
	PERD UNE VIE
	------------------------------------------------------------------------*/
	function loseLife() {
		if ( fl_death ) {
			return;
		}
		blinkColor		= 0xff0000;
		blinkColorAlpha	= 100;
		blink(Data.BLINK_DURATION);
		playAnim(Data.ANIM_BAT_KNOCK);
		game.fxMan.attachExplosion(x,y,100);

		lives--;
		if ( lives<=0 ) {
			kill();
		}
		else {
			game.shake(Data.SECOND, 2);
		}
	}


	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function kill() {
		removeShield();
		game.shake(Data.SECOND*5, 3);
		playAnim(Data.ANIM_BAT_MOVE);
		blinkColorAlpha	= 50;
		halt();

		filters		= null;
		fl_wait		= false;
		fl_death 	= true;
		fl_deathUp	= true;
		rotation	= -30*dir;
		dy			= -1.5;
		if ( y>=Data.GAME_HEIGHT*0.5 ) {
			dy*=2;
		}
		floatOffset	= 0;
		setNext(null,null,Data.SECOND*9999,Data.ACTION_MOVE);

	}


	/*------------------------------------------------------------------------
	ATTACHE UNE FIREBALL FLOTTANTE
	------------------------------------------------------------------------*/
	function attachFireBall(ang, distFactor) {
		var s = entity.shoot.BossFireBall.attach(game,x,y);
		s.initBossShoot( this, ang);
		fbList.push(s);
		s.maxDist	*= distFactor;
		s.distSpeed	*= distFactor;
		return s;
	}


	/*------------------------------------------------------------------------
	ÉNERVEMENT: LANCE SON ATTAQUE
	------------------------------------------------------------------------*/
	function bossAnger() {
		stopWait();
		halt();
		playAnim( Data.ANIM_BAT_ANGER ) ;
		game.fxMan.attachExplosion(x,y,60);
		fl_anger	= true;

		var s;
		attachFireBall(0,	1.0);
		attachFireBall(180,	1.0);
		attachFireBall(0,	0.5);
		attachFireBall(180,	0.5);

		attachFireBall(90,	1.0);
		attachFireBall(270,	1.0);

		setNext(null,null, Data.SECOND*15, Data.ACTION_MOVE);

//		fl_alphaBlink	= false;
//		blinkColor		= 0xff6e2e;
//		blinkColorAlpha	= 65;
//		blink(Data.BLINK_DURATION);
	}


	/*------------------------------------------------------------------------
	FIN D'ÉNERVEMENT
	------------------------------------------------------------------------*/
	function bossCalmDown() {
		for (var i=0;i<fbList.length;i++) {
			fbList[i].destroy();
		}
		if ( fl_anger ) {
			game.fxMan.attachExplosion(x,y,50);
			playAnim(Data.ANIM_BAT_WAIT);
		}
		fbList = new Array();
		setNext(null,null, Data.SECOND, Data.ACTION_MOVE);
		fl_anger = false;
	}


	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();

		// flottement sur place
		if ( fl_wait ) {
			floatOffset -= 0.1*dir;
			_x = x+Math.sin(floatOffset)*FLOAT_X;
			_y = y+Math.cos(floatOffset)*FLOAT_Y;
		}

		// Mort
		if ( fl_death ) {
			if ( !fl_deathUp ) {
				_rotation = MAX_FALL_ROTATION + Math.sin(floatOffset)*7;
				floatOffset -= 0.5*dir;
				_x = x+Math.sin(floatOffset)*FLOAT_X*1.7;
			}
			else {
				floatOffset -= 0.2*dir;
				_x = x+Math.sin(floatOffset)*FLOAT_X*3;
			}
		}

		// Bouclier
//		if ( shieldMC._name != null ) {
//			shieldMC._x = _x;//-dir*20;
//			shieldMC._y = _y-5;
//		}

	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Hurry up désactivé
		if ( !fl_death ) {
			game.huTimer = 0;
		}
		else {
			game.huTimer += Timer.tmod*3;
		}

		super.update();

		// Timer immunité
		if ( fl_immune ) {
			immuneTimer-=Timer.tmod;
			if ( immuneTimer<=0 ) {
				removeImmunity();
			}
		}

		if ( game.manager.isDev() && Key.isDown(75) && !fl_death ) {
			kill();
		}

		// Déplacement
		if ( fl_move ) {
			moveToPoint(tx,ty,SPEED);
			glow.alpha	= 0.5;
			if ( distance(tx,ty) <=10 ) {
				glow.alpha = 1.0;
				halt();
				wait();
				floatOffset	= 0;
				playAnim(Data.ANIM_BAT_WAIT);
				setNext(null,null, WAIT_TIME, Data.ACTION_MOVE)
			}
		}


		if ( !fl_shield && !fl_death ) {
			glowCpt += 0.3*Timer.tmod;
			glow.blurX	= GLOW_BASE + GLOW_RANGE*Math.sin(glowCpt);
			glow.blurY	= glow.blurX;
			filters		= [upcast(glow)];
		}

		// Mort
		if ( fl_death ) {
			// Ascension
			if ( fl_deathUp && Std.random(6)==0 ) {
				game.fxMan.inGameParticles( Data.PARTICLE_STONE, Std.random(Data.GAME_WIDTH),0, Std.random(3)+1 );
				game.shake(Data.SECOND,1);
				game.fxMan.attachExplodeZone(
					x+Std.random(20)*(Std.random(2)*2-1),
					y+Std.random(20)*(Std.random(2)*2-1),
					Std.random(40)+10
				);
			}

			// Chute
			if ( !fl_deathUp && Std.random(2)==0 ) {
				var fx = game.fxMan.attachFx(
					x+Std.random(20)*(Std.random(2)*2-1),
					y-Std.random(40),
					"hammer_fx_pop"
				);
				fx.mc._rotation = Std.random(360);
				fx.mc._xscale = Std.random(50)+50;
				fx.mc._yscale = fx.mc._xscale;
//				game.fxMan.attachExplodeZone(
//					x+Std.random(20)*(Std.random(2)*2-1),
//					y+Std.random(20)*(Std.random(2)*2-1),
//					Std.random(20)+5
//				);
			}


			if ( y<=-50 && fl_deathUp ) {
				_xscale = scaleFactor*100;
				playAnim(Data.ANIM_BAT_FINAL_DIVE);
				dy = 5;
				fl_deathUp = false;
			}

			if ( !fl_deathUp ) {
				rotation = Math.min(MAX_FALL_ROTATION, rotation+2.5*Timer.tmod);
				dy += 0.1*Timer.tmod;
				if ( Std.random(2)==0 ) {
					game.fxMan.inGameParticles( Data.PARTICLE_SPARK, x,y, Std.random(2)+1 );
				}
				if ( y>=Data.DEATH_LINE+Data.GAME_HEIGHT*1.5 ) {
//					game.fxMan.inGameParticles( Data.PARTICLE_SPARK, x,Data.GAME_HEIGHT, Data.MAX_FX);
//					game.fxMan.attachFx(x,Data.GAME_HEIGHT*0.5, "hammer_fx_death");
//					game.fxMan.attachExplodeZone(x,y,100);
					game.shake(Data.SECOND*1.5, 5);
					this.destroy();
				}
			}
		}
	}
}

