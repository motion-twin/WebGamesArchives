class entity.boss.Tuberculoz extends entity.Mover {

	// Codes d'action
	static var auto_inc		= 1;
	static var WALK			= auto_inc++;
	static var JUMP			= auto_inc++;
	static var DASH			= auto_inc++;
	static var BOMB			= auto_inc++;
	static var HIT			= auto_inc++;
	static var BURN			= auto_inc++;
	static var TORNADO		= auto_inc++;
	static var TORNADO_END	= auto_inc++;
	static var DIE			= auto_inc++;

	// Séquences d'attaque
	static var seq_inc		= 0;
	static var SEQ_BURN		= seq_inc++;
	static var SEQ_TORNADO	= seq_inc++;
	static var SEQ_DASH		= seq_inc++;
	static var LAST_SEQ		= seq_inc-1;
	static var SEQ_DURATION	= Data.SECOND*9

	static var LIVES			= 100;
	static var GROUND_Y			= 446;
	static var CENTER_OFFSET	= -28;
	static var HEAD_OFFSET_X	= 10;
	static var HEAD_OFFSET_Y	= -54;
	static var RADIUS			= Data.CASE_WIDTH*1.7;
	static var HEAD_RADIUS		= Data.CASE_WIDTH*0.9;
	static var MAX_BADS			= 3; // compter +1 car les bads spawnent par 2

	static var INVERT_KICK_X	= 150; /* distance au bord à laquelle la bombe est
										renvoyée en arrière plutot qu'en avant */

	static var WALK_SPEED		= 3;
	static var DASH_SPEED		= 16;
	static var FIREBALL_SPEED	= 3;

	static var TORNADO_INTRO	= Data.SECOND*2;
	static var TORNADO_DURATION	= Data.SECOND*7;

	static var JUMP_Y			= 15;
	static var JUMP_EST_X		= 80;
	static var JUMP_EST_Y		= -145;

	static var A_STEP			= 5; // nb de bads tués avant spawn d'item A & B
	static var B_STEP			= 10;
	static var EXTRA_LIFE_STEP	= 30;

	// Chances sur 1000
	static var CHANCE_PLAYER_JUMP		= 22;
	static var CHANCE_BOMB_JUMP			= 15;
	static var CHANCE_DASH				= 1;
	static var CHANCE_SPAWN				= 25;
	static var CHANCE_BURN				= 5;
	static var CHANCE_FINAL_ANGER		= 35;


	var _firstUniq		: int;
	var lives			: int;
	var dir				: int;

	var fl_trap			: bool; // entity.Bad compatibility (spikes)

	var fl_shield		: bool;
	var fl_immune		: bool;
	var immuneTimer		: float;
	var fl_death		: bool;
	var fl_defeated		: bool;

	var recents			: Array<bool>;
	var badKills		: int;
	var totalKills		: int;

	var action			: int;
	var dashCount		: int;
	var seq				: int;
	var seqTimer		: float;
	var fl_twister		: bool;

	var fl_bodyRadius	: bool; // ! DEBUG ONLY !

	var lifeBar			: { > MovieClip, bar:MovieClip, barFade:MovieClip };
	var itemA			: entity.item.SpecialItem;
	var itemB			: entity.item.SpecialItem;

	var fbCoolDown		: float;

	var defeatTimeOut	: float;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		fl_hitGround	= false;
		fl_hitCeil 		= false;
		fl_hitWall		= false;
		fl_hitBorder	= true;
		fl_physics		= true;
		fl_gravity		= false;
		fl_friction		= false;
		fl_moveable		= false;
		fl_blink		= true;
		fl_alphaBlink	= false;
		fl_trap			= false;
		blinkColorAlpha	= 60;
		blinkColor		= 0xff6600;

		fl_shield		= false;
		fl_immune		= false;
		immuneTimer		= 0;
		recents			= new Array();
		fl_death		= false;
		fl_defeated		= false;

		fbCoolDown		= 0;
		defeatTimeOut	= 0;

		x			= Data.GAME_WIDTH * 0.5;
		y			= GROUND_Y;
		dir			= Std.random(2)*2-1;

		lives		= LIVES;
		badKills	= 0;
		totalKills	= 0;
		seq			= 0;
		seqTimer	= SEQ_DURATION;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_boss_human";
		var mc : entity.boss.Tuberculoz = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBoss(g) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
//		register(Data.BAD);
		register(Data.BOSS);
		_firstUniq = game.getUniqId();
	}


	/*------------------------------------------------------------------------
	INITIALISATION BOSS
	------------------------------------------------------------------------*/
	function initBoss(g) {
		init(g);
		playAnim(Data.ANIM_BOSS_BAT_FORM);
		endUpdate();

		lifeBar		= downcast( game.depthMan.attach("hammer_interf_boss_bar",Data.DP_INTERF) );
		lifeBar._rotation = -90;
		lifeBar._x = 0;
		lifeBar._y	= Data.GAME_HEIGHT*0.5;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		lifeBar.removeMovieClip();
		super.destroy();
	}


	/*------------------------------------------------------------------------
	RENVOIE UNE LISTE D'ENTITÉS AU CONTACT
	------------------------------------------------------------------------*/
	function getHitList(t:int) {
		var l;
		l = game.getClose( t, x, y+CENTER_OFFSET, RADIUS, false );
		if ( action==WALK ) {
			var lh = game.getClose( t, x+HEAD_OFFSET_X*dir, y+HEAD_OFFSET_Y, HEAD_RADIUS, false );
			for (var i=0;i<lh.length;i++) {
				l.push(lh[i]);
			}
		}
		return l;
	}


	/*------------------------------------------------------------------------
	CONTACTS AVEC D'AUTRES ENTITÉS
	------------------------------------------------------------------------*/
	function checkHits() {
		if ( fl_death ) {
			return;
		}

		var l;

		// Bombes
		l = getHitList(Data.PLAYER_BOMB);
		for (var i=0;i<l.length;i++) {
			var b : entity.bomb.PlayerBomb = downcast(l[i]);
			if ( !b.fl_explode && action==DASH && dx!=0 ) {
				b.onExplode();
			}
			if ( !b.fl_explode && !checkFlag(b.uniqId) ) {
				kickBomb(b);
				flag( b.uniqId );
			}
		}


		// Joueur
		if ( !fl_immune ) {
			l = getHitList(Data.PLAYER);
			for (var i=0;i<l.length;i++) {
				var p : entity.Player = downcast(l[i]);
				if ( !p.fl_kill ) {
					p.killHit(dx);
					if ( action==DASH && dx!=0 ) {
						game.fxMan.attachExplodeZone(p.x, p.y-Data.CASE_HEIGHT*0.5, Data.CASE_WIDTH*2);
					}
					game.shake(Data.SECOND,3);
				}
			}
		}


		// Bads
		l = getHitList(Data.BAD);
		for (var i=0;i<l.length;i++) {
			var b : entity.Bad = downcast(l[i]);
			if ( b.uniqId!=uniqId && !b.fl_kill && b.fl_trap ) {
				if ( !fl_immune && b.fl_freeze && b.evaluateSpeed()>=Data.ICE_HIT_MIN_SPEED ) {
					game.fxMan.inGameParticles(Data.PARTICLE_CLASSIC_BOMB, x,y,4);
					game.fxMan.attachExplodeZone( b.x, b.y-Data.CASE_HEIGHT*0.5, Data.CASE_WIDTH*2 );
					loseLife(10);
					onKillBad();
					b.destroy();
				}
				else {
					b.killHit(dx);
					if ( action==DASH && dx!=0 ) {
						game.fxMan.attachExplodeZone(b.x, b.y-Data.CASE_HEIGHT*0.5, Data.CASE_WIDTH*2);
					}
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	FLAG PAR UNIQID
	------------------------------------------------------------------------*/
	function flag(uid) {
		recents[uid-_firstUniq]=true;
	}

	function checkFlag(uid) {
		return ( recents[uid-_firstUniq]==true );
	}


	/*------------------------------------------------------------------------
	MISE À JOUR BARRE DE VIE
	------------------------------------------------------------------------*/
	function updateBar() {
		lifeBar.barFade._xscale = lifeBar.bar._xscale;
		lifeBar.barFade.gotoAndPlay("1");
		lifeBar.bar._xscale = lives/LIVES*100;
	}


	/*------------------------------------------------------------------------
	PERTE D'UNE VIE
	------------------------------------------------------------------------*/
	function loseLife(n) {
		if ( fl_immune ) {
			return;
		}

		lives-=n;
		updateBar();
		if ( lives<=0 ) {
			die();
		}
		else {
			game.killPointer();
			immune();

			// Gros dégâts
			if ( n>1 ) {
				fl_gravity		= true;
				fl_hitBorder	= true;
				dy		= -9;
				next	= null;
				action	= HIT;
				playAnim(Data.ANIM_BOSS_HIT);
				game.shake(Data.SECOND,4);
				// Petit moment de répit
				game.destroyList(Data.SHOOT);
				var lp = game.getPlayerList();
				for (var i=0;i<lp.length;i++) {
					lp[i].knock(Data.SECOND);
				}
				var l = game.getBadList();
				for (var i=0;i<l.length;i++) {
					var b = l[i];
					if ( fl_stable ) {
						b.dx = 0;
					}
					b.knock(Data.KNOCK_DURATION);
				}
			}
		}
	}

	/*------------------------------------------------------------------------
	IMMUNITÉ
	------------------------------------------------------------------------*/
	function immune() {
		fl_immune	= true;
		immuneTimer	= Data.SECOND*3;
		blink(Data.BLINK_DURATION_FAST);
	}


	/*------------------------------------------------------------------------
	FAIT APPARAITRE N BOMBES EN JEU
	------------------------------------------------------------------------*/
	function spawnBombs(n) {
		var bList = new Array();
		var fl_tooClose = false;

		for (var i=0;i<n;i++) {
			var b = entity.bomb.bad.BossBomb.attach(game,0,0);
			do {
				b.moveTo(
					Std.random(Math.round(Data.GAME_WIDTH*0.8)) + Data.GAME_WIDTH*0.1,
					Std.random(150)+100
				);
				fl_tooClose = false;
				for (var j=0;j<bList.length;j++) {
					if (  bList[j].distance(b.x,b.y)<=Data.CASE_WIDTH*6  ) {
						fl_tooClose = true;
					}
				}
			} while (fl_tooClose);
			game.fxMan.attachFx( b.x, b.y-Data.CASE_HEIGHT*0.5, "hammer_fx_pop" );
			bList.push(b);
		}
	}


	/*------------------------------------------------------------------------
	POUSSE UNE BOMBE
	------------------------------------------------------------------------*/
	function kickBomb(b) {
		if ( dx==0 ) {
			b.dx = dir*15;
		}
		else {
			b.dx = dx*5;
		}
		b.dy = -7;
		b.setLifeTimer(Data.SECOND*0.7);
		if (  (b.x<x && dir>0)  ||  (b.x>x && dir<0)  ) {
			b.dx*=-1;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI L'ENTITÉ EST AFFECTÉE PAR LE VENT
	------------------------------------------------------------------------*/
	function isWindCompatible(e) {
		if ( !fl_twister && (e.types&Data.FX)==0 ) {
			return false;
		}
		if ( e.fl_kill ) {
			return false;
		}
		if ( e.uniqId==uniqId ) {
			return false;
		}
		if ( (e.types&Data.SHOOT)>0 || (e.types&Data.ITEM)>0 ) {
			return false;
		}
		if ( (e.types&Data.BAD)>0 && downcast(e).fl_freeze ) {
			return false;
		}
		if ( e.y<30 ) {
			return false;
		}

		return true;
	}


	/*------------------------------------------------------------------------
	MAIN: DASH
	------------------------------------------------------------------------*/
	function updateDash() {
		// Particules d'entrée
		if ( (oldX<0 && x>=0) || (oldX>0 && x<=0) ) {
			game.fxMan.inGameParticles( Data.PARTICLE_STONE, 10, y-30, 6 );
		}
		if ( (oldX>Data.GAME_WIDTH && x<=Data.GAME_WIDTH) || (oldX<Data.GAME_WIDTH && x>=Data.GAME_WIDTH) ) {
			game.fxMan.inGameParticles( Data.PARTICLE_STONE, Data.GAME_WIDTH-10, y-30, 6 );
		}
		// Changement de direction
		if (  (dx<0 && x<=-Data.GAME_WIDTH) || (dx>0 && x>=Data.GAME_WIDTH*2)  ) {
			var p : entity.Player = downcast( game.getOne(Data.PLAYER) );
			dx = -dx;
			y = p.y;
			dir = -dir;
			_xscale = -_xscale;
			if ( x<0 ) {
				game.attachPointer( 0, p.cy-2, p.cx,p.cy-2 );
			}
			else {
				game.attachPointer( Data.LEVEL_WIDTH, p.cy-2, p.cx,p.cy-2 );
			}
			dashCount++;
			// Fin
			if ( dashCount>2 ) {
				if ( dir<0 ) {
					x = Data.GAME_WIDTH+80;
				}
				else {
					x = -80;
				}
				y = GROUND_Y;
				game.killPointer();
				fl_hitBorder = true;
				jump(JUMP_Y*0.6);
			}

		}
	}


	/*------------------------------------------------------------------------
	MAIN: TORNADE
	------------------------------------------------------------------------*/
	function updateTornado() {

		if ( Std.random(3)>0 ) {
			// Particules
			if ( fl_twister || Std.random(5)==0 ) {
				game.fxMan.inGameParticles( Data.PARTICLE_DUST, Std.random(Data.GAME_WIDTH), Std.random(Data.GAME_HEIGHT), Std.random(3));
			}

			// Vent
			var l = game.getList(Data.PHYSICS);
			for (var i=0;i<l.length;i++) {
				var e : entity.Physics = downcast(l[i]);
				if ( isWindCompatible(e) ) {
					var wind = Std.random(22)/10 + 0.5;
					if ( e.fl_stable ) {
						if ( wind>Data.GRAVITY ) {
							e.dy -= wind+3;
							e.dx += Std.random(2) * (Std.random(2)*2-1);
						}
					}
					else {
						e.dy-=wind;
						e.dx += Std.random(2) * (Std.random(2)*2-1);
					}
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	MAIN: MORT
	------------------------------------------------------------------------*/
	function updateDeath() {
		// Roches
		if (  (dx!=0 || dy!=0 || next.action==DIE)  &&  Std.random(3)==0  ) {
			if ( Std.random(2)==0 ) {
				game.fxMan.inGameParticles(Data.PARTICLE_STONE, Std.random(Data.GAME_WIDTH),0, Std.random(2));
			}
			else {
				game.fxMan.inGameParticles(Data.PARTICLE_STONE, Std.random(Data.GAME_WIDTH),Std.random(Math.round(Data.GAME_HEIGHT*0.6)), Std.random(2));
			}
			game.shake(Data.SECOND,1);
		}

		// Atterissage
		if ( dy>0 && y>=GROUND_Y-8 ) {
			game.shake(Data.SECOND,5);
			land();
			y = GROUND_Y-8;
		}


		// Strikes
		if ( next.action==DIE ) {
			dx *= game.xFriction;
			if ( Std.random(3)==0 ) {
				var s = game.depthMan.attach("hammer_fx_strike", Data.FX);
				playAnim(Data.ANIM_BOSS_HIT);
				replayAnim();
				s._y = y - Std.random(60);
				s._x = Data.GAME_WIDTH*0.5;
				var d = Std.random(2)*2-1;
				s._xscale = 100 * d;
				if ( dx< 0 ) {
					dx = (Std.random(4)+2);
				}
				else {
					dx = -(Std.random(4)+2);
				}
			}
		}

		// Envol
		if ( animId!=Data.ANIM_BOSS_DEATH.id ) {
			if ( Std.random(3)==0 ) {
				game.fxMan.attachExplodeZone(
					Std.random(20)*(Std.random(2)*2-1) + x,
					y - Std.random(70),
					Std.random(20)+8
				);
			}
		}
	}


	/*** ACTIONS ***/

	/*------------------------------------------------------------------------
	GESTION DE L'IA
	------------------------------------------------------------------------*/
	function ia() {
		if ( action==WALK ) {
			seqTimer-=Timer.tmod;

			// Retournement au bord
			if (  (x>=Data.GAME_WIDTH-RADIUS && dir>0) || (x<=RADIUS && dir<0) ) {
				dir = -dir;
				walk();
				return;
			}

			// Saute vers le joueur
			if ( Std.random(1000)<CHANCE_PLAYER_JUMP ) {
				if (  game.getClose( Data.PLAYER, x+JUMP_EST_X*dir, y+JUMP_EST_Y, RADIUS, false ).length > 0  ) {
					jump(JUMP_Y);
					return;
				}
			}

			// Saute vers une bombe de joueur
			if ( Std.random(1000)<CHANCE_BOMB_JUMP ) {
				if (  game.getClose( Data.PLAYER_BOMB, x+JUMP_EST_X*dir, y+JUMP_EST_Y, RADIUS, false ).length > 0  ) {
					jump(JUMP_Y);
					return;
				}
			}


			// Attaques spéciales
			if ( seqTimer<=0 && !fl_death ) {
				seqTimer = SEQ_DURATION;

				switch (seq) {
					case SEQ_BURN		: burn(); break;
					case SEQ_DASH		: dash(); break;
					case SEQ_TORNADO	: tornado(); break;
				}
				seq++;
				if ( seq>LAST_SEQ ) {
					seq=0;
				}
			}

			// Spawn d'ennemis
			if ( Std.random(1000)<CHANCE_SPAWN ) {
				if ( game.getBadList().length + game.getList(Data.BAD_BOMB).length < MAX_BADS ) {
					dropBombs();
					return;
				}
			}


		}
	}


	/*------------------------------------------------------------------------
	ARRÊT
	------------------------------------------------------------------------*/
	function halt() {
		dx = 0;
	}


	/*------------------------------------------------------------------------
	MARCHE
	------------------------------------------------------------------------*/
	function walk() {
		if ( fl_death ) {
			setNext(null,null,Data.SECOND*3,DIE);
			return;
		}

		if ( _xscale*dir<0 ) {
			playAnim(Data.ANIM_BOSS_SWITCH);
			halt();
		}
		else {
			playAnim(Data.ANIM_BOSS_WAIT);
			_xscale = dir*Math.abs(_xscale);
			dx = WALK_SPEED * dir;

			action = WALK;
		}
	}


	/*------------------------------------------------------------------------
	SAUT
	------------------------------------------------------------------------*/
	function jump(jumpY) {
		action		= JUMP;
		fl_gravity	= true;
		dx			= dir*WALK_SPEED*1.6;
		dy			= -jumpY;

		playAnim(Data.ANIM_BOSS_JUMP_UP);
	}


	/*------------------------------------------------------------------------
	ATTERRISSAGE
	------------------------------------------------------------------------*/
	function land() {
		action		= null;
		fl_gravity	= false;
		y			= GROUND_Y;
		dy			= 0;

		playAnim(Data.ANIM_BOSS_JUMP_LAND);
	}


	/*------------------------------------------------------------------------
	ATTAQUE DASH EN FIREBALL
	------------------------------------------------------------------------*/
	function dash() {
		action = DASH;
		halt();
		dashCount = 0;
		playAnim(Data.ANIM_BOSS_DASH_START);
	}


	/*------------------------------------------------------------------------
	LANCÉ DE BOMBES
	------------------------------------------------------------------------*/
	function dropBombs() {
		action = BOMB;
		halt();
		playAnim(Data.ANIM_BOSS_BOMB);
	}


	/*------------------------------------------------------------------------
	EMBRASEMENT
	------------------------------------------------------------------------*/
	function burn() {
		halt();
		playAnim(Data.ANIM_BOSS_BURN_START);
		setNext(null,null,Data.SECOND*3.5,BURN);
		action = BURN;
	}


	/*------------------------------------------------------------------------
	TORNADE (??)
	------------------------------------------------------------------------*/
	function tornado() {
		halt();
		playAnim(Data.ANIM_BOSS_TORNADO_START);
		setNext( null,null, TORNADO_INTRO, TORNADO );
		fl_twister = false;
		action = TORNADO;
	}


	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function die() {
		halt();
		action			= null;
		defeatTimeOut	= Data.SECOND*15;
		fl_death		= true;
		fl_gravity		= true;
		var dist		= Data.GAME_WIDTH*0.5-x;
		dx				= dist*0.025;
		dy				= -13;
		dir				= (dx>0)?-1:1;
		_xscale			= scaleFactor*100 * dir;
		lifeBar.removeMovieClip();

		game.bulletTime(Data.SECOND*2);
		game.shake(Data.SECOND,5);
		playAnim(Data.ANIM_BOSS_HIT);

		// bads
		var bl = game.getBadList();
		for (var i=0;i<bl.length;i++) {
			var b = bl[i];
			b.dropReward = null;
			b.killHit( Std.random(50)*(Std.random(2)*2-1) );
			b.dy-=Std.random(10);
			game.fxMan.inGameParticles( Data.PARTICLE_SPARK, b.x, b.y, Std.random(3)+1 );
		}

		// bombes
		var l = game.getList(Data.BOMB);
		for (var i=0;i<l.length;i++) {
			l[i].destroy();
			game.fxMan.inGameParticles( Data.PARTICLE_CLASSIC_BOMB, l[i].x, l[i].y, Std.random(3)+1 );
		}

		// entités diverses
		game.destroyList(Data.SHOOT);
		game.destroyList(Data.BOMB);

	}


	/*------------------------------------------------------------------------
	GRAND NETTOYAGE FINAL + OUVERTURE DE SORTIE
	------------------------------------------------------------------------*/
	function final() {
		if ( fl_defeated ) {
			return;
		}
		halt();
		openExit();
		game.fxMan.attachExplodeZone(x,y+CENTER_OFFSET,150);
		game.fxMan.inGameParticles( Data.PARTICLE_TUBERCULOZ, x,y+CENTER_OFFSET, Data.MAX_FX );
		game.shake(Data.SECOND,5);
		playAnim(Data.ANIM_BOSS_DEATH);
		game.destroyList(Data.BAD);
		game.fl_clear = true;
		fl_defeated = true;
	}


	/*------------------------------------------------------------------------
	ACTIONS APRÈS LA MORT DU BOSS
	------------------------------------------------------------------------*/
	function openExit() {
		if ( fl_defeated ) {
			return;
		}
		game.depthMan.swap( upcast(this), Data.DP_SPRITE_BACK_LAYER );
		var cloak = entity.item.SpecialItem.attach(game, Data.GAME_WIDTH*0.5, Data.GAME_HEIGHT-40, 113, null);
		cloak.dy = -20;

		var tubkey = entity.item.ScoreItem.attach(game, Data.GAME_WIDTH*0.5-40, Data.GAME_HEIGHT-40, 199, null);
		tubkey.dy = -25;

		var door = game.world.view.attachSprite(  "$door", game.flipCoordReal(Entity.x_ctr(5)), Entity.y_ctr(6), true );
		game.fxMan.inGameParticles( Data.PARTICLE_STONE, door._x+Data.CASE_WIDTH, door._y, 3+Std.random(10) );
		game.fxMan.attachExplodeZone( door._x+Data.CASE_WIDTH, door._y-Data.CASE_HEIGHT, 40 );
		game.playMusic(0);

		// bonus vies
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			var bonus = p.lives*20000;
			p.getScore( p, bonus );
			game.fxMan.attachAlert( Lang.get(35) + p.lives + " x " + Data.formatNumber(20000) );
		}
	}



	/*** EVENTS ***/

	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);

		// Retournement
		if ( id==Data.ANIM_BOSS_SWITCH.id ) {
			walk();
		}

		// Démarrage
		if ( id==Data.ANIM_BOSS_BAT_FORM.id ) {
			walk();
		}

		// Atterrissage
		if ( id==Data.ANIM_BOSS_JUMP_LAND.id ) {
			walk();
		}

		// dash
		if ( id==Data.ANIM_BOSS_DASH_START.id ) {
			playAnim(Data.ANIM_BOSS_DASH_BUILD);
			setNext( null,null, Data.SECOND*2, DASH );
		}

		// dash
		if ( id==Data.ANIM_BOSS_DASH.id ) {
			playAnim(Data.ANIM_BOSS_DASH_LOOP);
		}

		// bombes
		if ( id==Data.ANIM_BOSS_BOMB.id ) {
			spawnBombs(2);
			walk();
		}

		// hit
		if ( id==Data.ANIM_BOSS_HIT.id ) {
			playAnim(Data.ANIM_BOSS_WAIT);
		}

		// Enflammé
		if ( id==Data.ANIM_BOSS_BURN_START.id ) {
			playAnim(Data.ANIM_BOSS_BURN_LOOP);
		}

		// Tornado
		if ( id==Data.ANIM_BOSS_TORNADO_START.id ) {
			playAnim(Data.ANIM_BOSS_TORNADO_LOOP);
		}

		// Fin de tornade
		if ( id==Data.ANIM_BOSS_TORNADO_END.id ) {
			walk();
		}
	}


	/*------------------------------------------------------------------------
	EVENT: ACTION SUIVANTE
	------------------------------------------------------------------------*/
	function onNext() {
		// Dash
		if ( next.action==DASH ) {
			playAnim(Data.ANIM_BOSS_DASH);
			dx = dir * DASH_SPEED;
			fl_hitBorder = false;
		}


		// Burn
		if ( next.action==BURN ) {
			playAnim(Data.ANIM_BOSS_TORNADO_END);
			var n=10;
			for (var i=0;i<n;i++) {
				var bx = i*Data.GAME_WIDTH/n + Data.CASE_WIDTH;
				if ( Math.abs(bx-x)>60 ) {
					var s = entity.shoot.FireBall.attach(
						game,
						bx,
						Data.GAME_HEIGHT
					);
					s.moveUp(FIREBALL_SPEED);
				}
			}
		}

		// Tornade
		if ( next.action==TORNADO ) {
			if ( !fl_twister ) {
				fl_twister = true;
				setNext(null,null,TORNADO_DURATION,TORNADO);
				return;
			}
			else {
				playAnim(Data.ANIM_BOSS_TORNADO_END);
			}
		}

		// Mort
		if ( next.action==DIE ) {
			final();
		}

		next = null;
	}


	/*------------------------------------------------------------------------
	MORT DU JOUEUR
	------------------------------------------------------------------------*/
	function onPlayerDeath() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	MORT D'UN BAD
	------------------------------------------------------------------------*/
	function onKillBad() {
		badKills++;
		totalKills++;

		// Items multi-bombe
		if ( badKills>=B_STEP ) {
			itemB.destroy();
			itemB = entity.item.SpecialItem.attach(game, Data.GAME_WIDTH-31,0, 5,null);
			itemB.setLifeTimer(0);
			badKills=0;
		}
		else {
			if ( badKills==A_STEP ) {
				itemA.destroy();
				itemA = entity.item.SpecialItem.attach(game, 31,0, 4,null);
				itemA.setLifeTimer(0);
			}
		}

		// Vie supplémentaire
		if ( totalKills==EXTRA_LIFE_STEP ) {
			var it = entity.item.SpecialItem.attach(game, 214,340, 36,null);
			it.setLifeTimer(0);
		}
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION D'UNE BOMBE DANS LE LEVEL
	------------------------------------------------------------------------*/
	function onExplode(x,y,radius) {
		if ( fl_death ) {
			return;
		}
		var d = Math.sqrt(  Math.pow(this.x-x,2)  +  Math.pow(this.y+CENTER_OFFSET-y,2)  );
		if ( d<=radius && action!=DASH ) {
			loseLife(1);
		}
	}


	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();

		if ( dir<0 ) {
			_xscale = -Math.abs(_xscale);
		}
		else {
			_xscale = Math.abs(_xscale);
		}


		// Tornade
		if ( action==TORNADO ) {
			updateTornado();
		}

		// Link la barre de vie aux tremblements du jeu
		lifeBar._x = game.mc._x-game.xOffset;
		lifeBar._y	= game.mc._y+Data.GAME_HEIGHT*0.5;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		var prev;

		// Hurry up désactivé
		if ( !fl_death ) {
			game.huTimer = 0;
		}
		else {
			game.huTimer += Timer.tmod*3;
		}

		ia();

		// Immunité
		if ( fl_immune ) {
			immuneTimer-=Timer.tmod;
			if (immuneTimer<=0) {
				fl_immune = false;
				stopBlink();
			}
		}

		// Phases de saut
		if ( action==JUMP ) {
			if ( dy>=0 && animId==Data.ANIM_BOSS_JUMP_UP.id ) {
				playAnim(Data.ANIM_BOSS_JUMP_DOWN);
			}
			if ( dy>0 && y>=GROUND_Y ) {
				land();
			}
		}

		// Tir de fireball de dernier recours
		if ( !fl_death && lives<=50 ) {
			fbCoolDown-=Timer.tmod;
			if ( action==WALK && fbCoolDown<=0 && game.countList(Data.SHOOT)<2 && Std.random(1000)<=CHANCE_FINAL_ANGER ) {
				fbCoolDown = Data.SECOND*0.5;
				var s = entity.shoot.FireBall.attach(
					game,
					x,
					y
				);
				s.moveToTarget(game.getOne(Data.PLAYER), FIREBALL_SPEED*2);
			}
		}

		// Phases hit
		if ( action==HIT ) {
			if ( dy>0 && y>=GROUND_Y ) {
				land();
			}
		}


		// Fix: tuberculoz ne mourrant pas ?
		if ( defeatTimeOut>0 && !fl_defeated ) {
			defeatTimeOut-=Timer.tmod;
			if ( defeatTimeOut<=0 ) {
				final();
			}
		}

		// Mort
		if ( fl_death ) {
			updateDeath();
		}

		super.update();

		// Dash
		if ( action==DASH ) {
			updateDash();
		}

		// DEBUG
		if ( game.manager.isDev() && Key.isDown(Key.ENTER) ) {
			die();
		}

		if ( game.manager.isDev() && Key.isDown(Key.SHIFT) ) {
			lives-=1;
			updateBar();
		}

		checkHits();

	}
}

