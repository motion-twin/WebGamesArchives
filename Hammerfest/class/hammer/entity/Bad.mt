import entity.item.ScoreItem;

class entity.Bad extends entity.Mover
{
	var player			: entity.Player ;
	var fl_playerClose	: bool;
	var closeDistance	: int;

	var freezeTimer		: float;
	var freezeTotal		: float;
	var fl_freeze		: bool;

	var fl_ninFriend	: bool;
	var fl_ninFoe		: bool;

	var knockTimer		: float;
	var fl_knock		: bool;
	var fl_showIA		: bool; // shows an icon overhead when player is close

	var deathTimer		: float;

	var fl_trap			: bool; // false if immunity against traps (spears)
	var comboId			: int;
	var yTrigger		: float;
	var anger			: int;
	var angerFactor		: float;
	var speedFactor		: float;

	var chaseFactor		: float;
	var maxAnger		: int;

	var realRadius		: float; // if not null, will be used as additionnal check for "hitTest"

	var iceMc			: MovieClip;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();

		comboId = null;

		freezeTimer	= 0;
		fl_freeze	= false;

		knockTimer	= 0;
		fl_knock	= false;
		yTrigger	= null;

		fl_ninFoe	= false;
		fl_ninFriend= false;
		fl_showIA 	= false;
		fl_trap		= true; //
		fl_strictGravity	= false;
		fl_largeTrigger		= true;
		closeDistance		= Data.IA_CLOSE_DISTANCE;


		realRadius	= Data.CASE_WIDTH;

		maxAnger	= Data.MAX_ANGER;
		speedFactor	= 1.0;
		anger		= 0;
		angerFactor	= 0.7 ; // Ajout au speedFactor pour chaque point de anger
		chaseFactor	= 5.0; // multiplicateur aux chances de décision (pour suivre le joueur)
		calcSpeed();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g);
		register(Data.BAD);
		register(Data.BAD_CLEAR);
	}


	/*------------------------------------------------------------------------
	INITIALISATION SPÉCIALE DES BADS
	------------------------------------------------------------------------*/
	function initBad(g:mode.GameMode,x:float,y:float):void {
		init(g);
		moveTo(x+Data.CASE_WIDTH*0.5, y+Data.CASE_HEIGHT) ; // colle les bads au sol
		endUpdate();
	}


	/*------------------------------------------------------------------------
	ANIM DE MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		if ( fl_freeze ) {
			game.fxMan.inGameParticles( Data.PARTICLE_ICE, x,y, Std.random(3)+2 );
			game.fxMan.attachExplosion( x,y-Data.CASE_HEIGHT*0.5, Data.CASE_WIDTH*2 );
			melt();
		}
		if ( fl_knock) {
			wakeUp();
		}
		if (dx==null) {
			dx = Std.random(200)/10 * (Std.random(2)*2-1);
		}
		playAnim(Data.ANIM_BAD_DIE);
		super.killHit(dx);
	}


	/*------------------------------------------------------------------------
	MORT SANS CONDITION, NON-CONTRABLE
	------------------------------------------------------------------------*/
	function forceKill(dx) {
		killHit(dx);
	}


	/*------------------------------------------------------------------------
	MORT SUR PLACE
	------------------------------------------------------------------------*/
	function burn() {
		var fx = game.fxMan.attachFx( x,y, "hammer_fx_burning" );
		dropReward() ;
		onKill();
		destroy();
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE MONSTRE EST EN ÉTAT DE FONCTIONNER
	------------------------------------------------------------------------*/
	function isHealthy() {
		return !fl_kill && !fl_freeze && !fl_knock;
	}


	/*------------------------------------------------------------------------
	RENCONTRE UNE AUTRE ENTITÉ
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		// Joueur
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et:entity.Player = downcast(e);

			// additionnal (optionnal) check with distance
			var fl_hit = true;
			if ( realRadius!=null ) {
				if (  distance(et.x,et.y) > realRadius  ) {
					fl_hit = false;
				}
			}
			if ( fl_hit ){
				if ( et.specialMan.actives[86] ) {
					// bonbon fantome
					game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_shine");
					et.getScore(this, 666);
					this.destroy();
				}
				else {
					if ( isHealthy() ) {
						if ( et.specialMan.actives[114] && et.oldY<=y-Data.CASE_HEIGHT*0.5 && et.dy>0 ) {
							et.dy = -Data.PLAYER_AIR_JUMP*2.5;
							freeze(Data.FREEZE_DURATION);
							setCombo(null);
							game.fxMan.attachExplodeZone(x,y-5,30);
							game.fxMan.inGameParticles(Data.PARTICLE_CLASSIC_BOMB, x,y-5, 3+Std.random(3));
						}
						else {
							if ( !et.fl_shield ) {
								if (et.x<x) {
									et.killHit(-1);
								}
								else {
									et.killHit(1);
								}
							}
						}
					}
				}
			}
		}

		// Bads
		if ( (e.types & Data.BAD) > 0 ) {
			// Gelé qui shoot un autre monstre
			var et:entity.Bad = downcast(e);
			if ( fl_freeze && et.fl_freeze==false ) {
				var spd = evaluateSpeed();
				if ( spd>=Data.ICE_HIT_MIN_SPEED ) {
					et.setCombo(comboId);
					et.killHit(dx);
				}
				else {
					if ( spd>=Data.ICE_KNOCK_MIN_SPEED ) {
						et.setCombo(comboId);
						et.knock(Data.KNOCK_DURATION);
					}
				}

			}
		}
	}


	/*------------------------------------------------------------------------
	DÉFINI L'ID DE COMBO
	------------------------------------------------------------------------*/
	function setCombo(id:int) {
		if (!fl_kill) {
			comboId = id;
		}
	}


	/*------------------------------------------------------------------------
	JOUE UNE ANIM
	------------------------------------------------------------------------*/
	function playAnim(o) {
		if ( o.id==Data.ANIM_BAD_WALK.id && anger>0 ) {
			super.playAnim(Data.ANIM_BAD_ANGER);
		}
		else {
			super.playAnim(o);
		}
	}


	/*------------------------------------------------------------------------
	CALCULE LE FACTEUR VITESSE
	------------------------------------------------------------------------*/
	function calcSpeed() {
		speedFactor = 1.0 + angerFactor*anger;
		if ( game.globalActives[69] ) speedFactor *= 0.6 ; // tortue
		if ( game.globalActives[80] ) speedFactor *= 0.3 ; // escargot
	}


	/*------------------------------------------------------------------------
	MODIFIE LE FACTEUR SPEED
	------------------------------------------------------------------------*/
	function updateSpeed() {
		calcSpeed();
		// extended classes will add call for dx/dy update
	}


	/*------------------------------------------------------------------------
	GÉNÈRE UNE RÉCOMPENSE SUR LE MONSTRE
	------------------------------------------------------------------------*/
	function dropReward() {
		var itY;
		// Y de spawn de l'item
		if ( world.inBound(cx,cy) ) {
			itY = y;
		}
		else {
			itY = -30;
		}

		if ( comboId!=null ) {
			// Crystal normal
			var n = game.countCombo(comboId) - 1;
			if ( n+1 > game.statsMan.read( Data.STAT_MAX_COMBO ) ) {
				game.statsMan.write( Data.STAT_MAX_COMBO, n+1 );
			}
			ScoreItem.attach(game, x,itY, 0,n);
		}
		else {
			// Diamant
			ScoreItem.attach(game, x,itY, Data.DIAMANT,null);
		}
	}


	/*------------------------------------------------------------------------
	CALCULE LA VITESSE APPROXIMATIVE
	------------------------------------------------------------------------*/
	function evaluateSpeed() {
		return Math.sqrt( Math.pow(dx,2)+Math.pow(dy,2) );
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		super.destroy();
//		if ( (types&Data.BAD_CLEAR)>0 ) {
//			game.checkLevelClear();
//		}
		iceMc.removeMovieClip();
	}


	/*------------------------------------------------------------------------
	AUTORISE L'APPLICATION DU PATCH COLLISION AU SOL (ESCALIERS)
	------------------------------------------------------------------------*/
	function needsPatch() {
		return fl_freeze || fl_knock;
	}


	// *** EVENTS


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		var mc = game.depthMan.attach("hammer_fx_death", Data.FX);
		mc._x = x;
		mc._y = Data.GAME_HEIGHT*0.5;
		game.shake(10,3);
		game.soundMan.playSound("sound_bad_death", Data.CHAN_BAD);
		deathTimer = 0;

		super.onDeathLine();

		if ( !fl_kill ) {
			onKill();
		}
		dropReward();
		destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE FREEZE
	------------------------------------------------------------------------*/
	function onMelt() {
		iceMc.removeMovieClip();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE KNOCK
	------------------------------------------------------------------------*/
	function onWakeUp() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: FREEZE
	------------------------------------------------------------------------*/
	function onFreeze() {
		playAnim(Data.ANIM_BAD_FREEZE);
		if ( iceMc._name==null ) {
			iceMc = game.depthMan.attach("hammer_bad_ice", Data.DP_BADS);
		}
	}


	/*------------------------------------------------------------------------
	EVENT: ASSOMÉ
	------------------------------------------------------------------------*/
	function onKnock() {
		playAnim(Data.ANIM_BAD_KNOCK);
	}


	/*------------------------------------------------------------------------
	EVENT: HURRY UP!
	------------------------------------------------------------------------*/
	function onHurryUp() {
		angerMore();
	}


	/*------------------------------------------------------------------------
	EVENT: MORT
	------------------------------------------------------------------------*/
	function onKill() {
		super.onKill();

		// friend is killed !
		if ( fl_ninFriend ) {
			var plist = game.getPlayerList();
			for (var i=0;i<plist.length;i++) {
				var p = plist[i];
				if ( !p.fl_kill ) {
					p.unshield();
					p.killHit( Std.random(20) );
					game.fxMan.detachLastAlert();
					game.fxMan.attachAlert(Lang.get(44));
				}
			}
		}

		// foe killed
		if ( fl_ninFoe ) {
			var blist = game.getBadClearList();
			var n=1;
			for (var i=0;i<blist.length;i++) {
				var b = blist[i];
				b.fl_ninFriend = false;
				if ( b.uniqId!=uniqId ) {
					ScoreItem.attach(game, b.x,b.y, 0, n);
					b.destroy();
					n++;
				}
				b.unstick();
			}

			ScoreItem.attach(game, Data.GAME_WIDTH*0.5,-20, 236, null);
			game.fxMan.detachLastAlert();
			game.fxMan.attachAlert(Lang.get(45));
		}

		deathTimer = Data.SECOND*5;
		game.onKillBad(this);
	}

	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		if ( fl_freeze ) {
			game.fxMan.inGameParticles( Data.PARTICLE_ICE_BAD, x,y, Std.random(3)+2 );
			if ( h >= Data.DUST_FALL_HEIGHT ) {
				game.fxMan.dust(cx,cy+1);
			}
		}
	}


	// *** CHANGEMENTS ÉTATS

	/*------------------------------------------------------------------------
	GÈLE CE MONSTRE
	------------------------------------------------------------------------*/
	function freeze(timer) {
		if ( fl_kill ) {
			return;
		}
		if ( fl_knock ) {
			wakeUp();
		}

//		game.soundMan.playSound("sound_freeze", Data.CHAN_BAD);

		fallFactor = Data.FALL_FACTOR_FROZEN;
		fl_slide = true;
		freezeTimer = timer;
		freezeTotal = timer;
		fl_freeze = true;
		onFreeze();
	}


	/*------------------------------------------------------------------------
	ASSOME LE MONSTRE
	------------------------------------------------------------------------*/
	function knock(timer:float) {
		if ( fl_freeze ) {
			melt();
		}

		fallFactor = Data.FALL_FACTOR_KNOCK;
		knockTimer = timer;
		fl_knock = true;
		game.statsMan.inc(Data.STAT_KNOCK,1);
		onKnock();
	}


	/*------------------------------------------------------------------------
	MET FIN AU FREEZE
	------------------------------------------------------------------------*/
	function melt() {
		next = null;
		angerMore();
		freezeTimer=0;
		fl_freeze = false;
		fl_slide = false;
		fallFactor = 1.0;
		onMelt();
	}


	/*------------------------------------------------------------------------
	MET FIN AU KNOCK
	------------------------------------------------------------------------*/
	function wakeUp() {
		next = null;
		knockTimer = 0;
		fl_knock = false;
		fallFactor = 1.0;
		onWakeUp();
	}


	/*------------------------------------------------------------------------
	LE BAD RETROUVE SON CALME
	------------------------------------------------------------------------*/
	function calmDown() {
		if ( fl_kill ) {
			return;
		}
		anger = 0;
		updateSpeed();
	}

	/*------------------------------------------------------------------------
	ÉNERVEMENT
	------------------------------------------------------------------------*/
	function angerMore() {
		anger = Math.round( Math.min( anger+1, maxAnger ) );
		updateSpeed();
	}

	/*------------------------------------------------------------------------
	DÉFINI LE JOUEUR CIBLE DU MONSTRE
	------------------------------------------------------------------------*/
	function hate(p:entity.Player) {
		player = p;
	}



	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( fl_ninFriend || fl_ninFoe ) {
			if( isHealthy() && sticker._name==null ) {
				var mc = game.depthMan.attach("hammer_interf_ninjaIcon", Data.DP_BADS);
				if ( fl_ninFoe ) {
					mc.gotoAndStop("1");
				}
				else {
					mc.gotoAndStop("2");
				}
				stick(mc,0,-Data.CASE_HEIGHT*1.8);
			}
		}
		var oldX = _x;
		var oldY = _y;

		if ( fl_softRecal ) {
			softRecalFactor += 0.1 * Timer.tmod * speedFactor;
		}

		super.endUpdate();

		var minSpeed = 2;
		if ( GameManager.CONFIG.fl_detail ) {
			if ( fl_freeze && fl_stable && Math.abs(dx)>minSpeed) {
				var nb = Std.random(5)+2;
				for (var i=0;i<nb;i++) {
					var part = game.fxMan.attachFx(
						oldX+Std.random(12)*(Std.random(2)*2-1),
						oldY-Std.random(5)+2,
						"hammer_fx_partIce"
					);
					part.mc._rotation = Std.random(360);
					part.mc._xscale = Std.random(80)+20;
					part.mc._yscale = part.mc._xscale;
					part.mc._alpha = Math.min(100, (Math.abs(dx)-minSpeed)/5*100);

					// particules physiques derrière le bloc
//					if ( Math.abs(dx)>minSpeed*2 && Std.random(40)==0 ) {
//						game.fxMan.inGameParticles( part.mc._x, y, 1 );
//					}
				}
			}
		}

		if ( iceMc._name!=null ) {
			iceMc._x = this._x;
			iceMc._y = this._y;
			iceMc._xscale = 0.85*scaleFactor*100;
			iceMc._yscale = 0.85*scaleFactor*freezeTimer/freezeTotal*100;
		}
		if ( !fl_stable && isHealthy() && ( animId==null || animId==Data.ANIM_BAD_WALK.id || animId==Data.ANIM_BAD_ANGER.id ) ) {
			playAnim( Data.ANIM_BAD_JUMP );
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( player._name==null ) {
			hate( downcast( game.getOne(Data.PLAYER) ) );
		}

		fl_playerClose = isHealthy() && ( distance(player.x,player.y) <= closeDistance*(anger+1) );

		if ( fl_showIA ) {
			if ( fl_playerClose ) {
				if ( !fl_stick ) {
					var mc = game.depthMan.attach("curse", Data.DP_FX) ;
					mc.gotoAndStop(""+Data.CURSE_TAUNT) ;
					stick(mc,0,-Data.CASE_HEIGHT*2.5);
				}
			}
			else {
				unstick();
			}
		}

		// Freezé
		if ( freezeTimer>0 ) {
			freezeTimer-=Timer.tmod;
			if ( freezeTimer<=0 ) {
				melt();
			}
		}


		// Fix: mort forcée (utile ?)
		if ( deathTimer>0 ) {
			deathTimer-=Timer.tmod;
			if ( deathTimer<=0 ) {
				game.fxMan.attachExplosion(x,y,80);
				y = 1000;
			}
		}


		// Sonné
		if ( knockTimer>0 ) {
			knockTimer-=Timer.tmod;
			if ( knockTimer<=0 ) {
				wakeUp();
			}
		}

		super.update();

		// Ré-active le contact au sol qui avait été désactivé
		if ( yTrigger!=null && !fl_kill ) {
			if ( y>=yTrigger ) {
				fl_hitGround = true;
				yTrigger=null;
			}
		}

		// Perte de l'id de combo si est de nouveau healthy
		if ( comboId!=null ) {
			if ( isHealthy() ) {
				setCombo(null);
			}
		}
	}

}

