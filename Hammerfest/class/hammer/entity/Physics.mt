import levels.TeleporterData;

class entity.Physics extends entity.Animator
{

	var dx	: float;
	var dy	: float;

	var fallStart		: float; // use for fall height

	var gravityFactor	: float;
	var fallFactor		: float;
	var slideFriction	: float; // default world value if "null"
	var shockResistance	: float; // resistance to shockwaves

	var fl_stable		: bool;
	var fl_physics		: bool;
	var fl_friction		: bool;
	var fl_gravity		: bool;
	var fl_strictGravity: bool;
	var fl_hitGround	: bool;
	var fl_hitCeil		: bool;
	var fl_hitWall		: bool;
	var fl_hitBorder	: bool;
	var fl_slide		: bool;
	var fl_teleport		: bool;
	var fl_portal		: bool;
	var fl_wind			: bool;
	var fl_moveable		: bool;
	var fl_bump			: bool;

	var fl_stopStepping		: bool;
	var fl_skipNextGravity	: bool;
	var fl_skipNextGround	: bool;

	var lastTeleporter	: TeleporterData;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();

		dx = 0;
		dy = 0;
		gravityFactor = 1.0;
		fallFactor = 1.0;
		shockResistance = 1.0;

		fl_stable = false;

		fl_physics		= true;
		fl_friction		= true;
		fl_gravity		= true;
		fl_strictGravity= true;
		fl_hitGround	= true;
		fl_hitCeil		= false;
		fl_hitWall		= true;
		fl_hitBorder	= true;
		fl_slide		= true;
		fl_teleport		= false;
		fl_portal		= false;
		fl_wind			= false;
		fl_moveable		= true;
		fl_bump			= false;

		fl_stopStepping = false;
		fl_skipNextGravity = true;
		fl_skipNextGround = false;
	}


	/*------------------------------------------------------------------------
	INIT
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g);
		this.register(Data.PHYSICS);
	}


	/*------------------------------------------------------------------------
	ACTIVATION/DÉSACTIVATION DU MOTEUR PHYSIQUE
	------------------------------------------------------------------------*/
	function enablePhysics() {
		fl_physics = true;
	}

	function disablePhysics() {
		fl_physics = false;
	}


	/*------------------------------------------------------------------------
	EFFET D'ONDE DE CHOC AUTOUR DE L'ENTITÉ
	------------------------------------------------------------------------*/
	function shockWave(e:entity.Physics, radius:float, power:float) {
		if ( !e.fl_moveable ) {
			return;
		}
		power /= e.shockResistance; // le poids réduit la puissance
		var dist = e.distance(x,y); // Math.sqrt( Math.pow(e.x-x,2) + Math.pow(e.y-y,2) );
		var ratio = 1-dist/radius;
		var ang = Math.atan2(e.y-y,e.x-x);
		e.dx = Math.cos(ang) * ratio * power;
		if ( e.fl_stable ) {
			e.dy = -5;
		}
		else {
			if ( downcast(e).fl_intercept ) { // amélioration du freeze des volants
				e.dy = 0;
				e.dx *=2;
			}
			else {
				e.dy += Math.sin(ang) * ratio * power;
			}
			e.dy = Math.max(e.dy, -10);
		}
		e.fl_stable = false;
	}


	/*------------------------------------------------------------------------
	MORT AVEC ANIMATION DE SAUT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		if ( fl_kill ) {
			return;
		}

		this.dx = dx;
		this.dy = -10;
		fl_hitGround = false;
		fl_hitWall = false;
		fl_kill = true;
		fallFactor = Data.FALL_FACTOR_DEAD;
		onKill();
	}


	/*------------------------------------------------------------------------
	RÉSURRECTION
	------------------------------------------------------------------------*/
	function resurrect() {
		fl_hitGround = true;
		fl_hitWall = true;
		fl_kill = false;
		fallFactor = 1.0;
		fl_stopStepping = true;
	}


	// *** MACROS DE DÉPLACEMENT

	/*------------------------------------------------------------------------
	CALCULE LES DX,DY SELON UN ANGLE (EN DEGRÉ) ET UNE VITESSE
	------------------------------------------------------------------------*/
	function moveToAng(angDeg, speed) {
		var rad = Math.PI*angDeg / 180;
		dx = Math.cos(rad)*speed;
		dy = Math.sin(rad)*speed;
	}

	/*------------------------------------------------------------------------
	CALCULE LES DX,DY SELON UNE AUTRE ENTITÉ CIBLE
	------------------------------------------------------------------------*/
	function moveToTarget(e:Entity, speed) {
		var rad = Math.atan2(e.y-y,e.x-x);
		dx = Math.cos(rad)*speed;
		dy = Math.sin(rad)*speed;
	}

	/*------------------------------------------------------------------------
	CALCULE DX / DY SELON UNE COORDONNÉE
	------------------------------------------------------------------------*/
	function moveToPoint(x,y, speed) {
		var rad = Math.atan2(y-this.y,x-this.x);
		dx = Math.cos(rad)*speed;
		dy = Math.sin(rad)*speed;
	}


	/*------------------------------------------------------------------------
	DÉPLACEMENT DANS UNE DIRECTION AU CHOIX
	------------------------------------------------------------------------*/
	function moveUp(speed) {
		moveToAng( -90, speed );
	}
	function moveDown(speed) {
		moveToAng( 90, speed );
	}
	function moveLeft(speed) {
		moveToAng( 180, speed );
	}
	function moveRight(speed) {
		moveToAng( 0, speed );
	}


	/*------------------------------------------------------------------------
	DÉPLACEMENT EN PARTANT D'UNE ENTITÉ
	------------------------------------------------------------------------*/
	function moveFrom(e:Entity, speed) {
		x = e.x;
		y = e.y;
		var ang = -Std.random(Math.round(100*Math.PI))/100;
		x = e.x+Math.cos(ang)*Data.CASE_WIDTH*2;
		y = e.y+Math.sin(ang)*Data.CASE_HEIGHT*2;
		moveToTarget(e,speed);
		dx=-dx;
		dy=-dy;
	}


	/*------------------------------------------------------------------------
	POSE L'ENTITÉ AU SOL LE PLUS PROCHE (AVEC CYCLE DE NIVEAU HAUT/BAS)
	------------------------------------------------------------------------*/
	function moveToGround() {
		if ( fl_stable ) {
			return;
		}
		var pt = world.getGround(cx,cy);
		moveToCase(pt.x,pt.y);
	}


	// *** STEPPING


	/*------------------------------------------------------------------------
	EXÉCUTE LES COLLISIONS ENTRE ENTITÉS
	------------------------------------------------------------------------*/
	function checkHits() {
		var l = getByType(Data.ENTITY);
		for (var i=0;i<l.length;i++) {
			if ( !l[i].fl_kill && !fl_kill && this.hitBound(l[i]) && l[i].uniqId!=this.uniqId ) {
				this.hit( l[i] );
				l[i].hit( this );
			}
		}
	}

	/*------------------------------------------------------------------------
	PRÉFIXE DU STEPPING
	------------------------------------------------------------------------*/
	function prefix() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	INFIXE DU STEPPING (CHANGEMENT DE CASE)
	------------------------------------------------------------------------*/
	function infix() {
		checkHits();

		var cid = world.getCase( {x:cx,y:cy} );

		// Téléportation
		if ( fl_teleport && !fl_kill ) {
			if ( cid == Data.FIELD_TELEPORT ) {
				var start = world.getTeleporter(this, cx,cy);
				if ( start!=null ) {
					var target = world.getNextTeleporter(start);
					game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_pop");
					if ( target.td.dir==Data.HORIZONTAL ) {
						if ( target.fl_rand ) {
							moveTo( target.td.centerX-Data.CASE_WIDTH*0.5, target.td.centerY );
						}
						else {
							moveTo( target.td.centerX+Entity.x_ctr(cx)-start.centerX, target.td.centerY );
						}
					}
					else {
						if ( target.fl_rand ) {
							moveTo( target.td.centerX, target.td.centerY );
						}
						else {
							moveTo( target.td.centerX, target.td.centerY+Entity.y_ctr(cy)-start.centerY );
						}
					}
					game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_shine");
					game.soundMan.playSound("sound_teleport",Data.CHAN_FIELD);
					fl_stopStepping = true;
					lastTeleporter = target.td;
					onTeleport();
				}
			}
			else {
				lastTeleporter = null;
			}
		}


		if ( fl_portal && !fl_kill ) {
			if ( cid==Data.FIELD_PORTAL ) {
				if ( game.fl_clear ) {
					var px = cx;
					var py = cy;
					// Cherche le portal correspondant
					while ( world.getCase( {x:px-1,y:py} ) == Data.FIELD_PORTAL ) {
						px--
					}
					while ( world.getCase( {x:px,y:py-1} ) == Data.FIELD_PORTAL ) {
						py--
					}

					var pid = null;
					for (var i=0;i<world.portalList.length;i++) {
						if ( world.portalList[i].cx==px && world.portalList[i].cy==py ) {
							pid = i;
						}
					}

					onPortal(pid);
				}
				else {
					onPortalRefusal();
				}
			}
		}


		// Bumpers
		if ( fl_bump && !fl_kill && cid==Data.FIELD_BUMPER ) {
			var fdir = Data.VERTICAL;
			if ( world.getCase( {x:cx-1,y:cy} )==cid || world.getCase( {x:cx+1,y:cy} )==cid ) {
				fdir = Data.HORIZONTAL;
			}

			// Projection verticale
			if ( fdir==Data.HORIZONTAL && Math.abs(dy)<20 ) {
				dx = 0;
				dy *= 5;
			}
			// Projection horizontale
			if ( fdir==Data.VERTICAL && Math.abs(dx)<20 ) {
				dx *= 7;
				dy = 0;
			}
			onBump();
		}

	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		// Do nothing
	}



	/*------------------------------------------------------------------------
	RECALAGE Y
	------------------------------------------------------------------------*/
	function recal() {
		y = Entity.y_ctr( Entity.y_rtc(y) );
		updateCoords();
		while ( world.getCase( {x:cx,y:cy} )==Data.GROUND ) {
			y-=Data.CASE_HEIGHT;
			updateCoords();
		}
	}


	/*------------------------------------------------------------------------
	CALCUL DE STEPS
	------------------------------------------------------------------------*/
	function calcSteps(dxStep,dyStep) {
		var dxTotal = dxStep*Timer.tmod;
		var dyTotal = dyStep*Timer.tmod;
		var total = Math.ceil(Math.abs(dxTotal)/Data.STEP_MAX);
		total = Math.max(total, Math.ceil(Math.abs(dyTotal)/Data.STEP_MAX) );

		return {
			total: total,
			dx: dxTotal/total,
			dy: dyTotal/total
		};
	}


	/*------------------------------------------------------------------------
	AUTORISE L'APPLICATION DU PATCH COLLISION AU SOL (ESCALIERS)
	------------------------------------------------------------------------*/
	function needsPatch() {
		return false;
	}


	// *** EVENTS

	/*------------------------------------------------------------------------
	EVENT: MORT
	------------------------------------------------------------------------*/
	function onKill() {
		// do nothing
	}

	/*------------------------------------------------------------------------
	EVENT: TOMBE SOUS LA LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		// do nothing
	}

	/*------------------------------------------------------------------------
	EVENT: BLOQUE CONTRE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		dx = 0;
	}

	/*------------------------------------------------------------------------
	EVENT: ATTERISSAGE
	------------------------------------------------------------------------*/
	function onHitGround(height) {
		fl_stable = true;
		dy = 0;
		recal();
	}

	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE PLAFOND
	------------------------------------------------------------------------*/
	function onHitCeil() {
		dy=0;
	}


	/*------------------------------------------------------------------------
	EVENT: TÉLÉPORTATION
	------------------------------------------------------------------------*/
	function onTeleport() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: TÉLÉPORTATION PORTAL
	------------------------------------------------------------------------*/
	function onPortal(pid:int) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: PORTAIL FERMÉ
	------------------------------------------------------------------------*/
	function onPortalRefusal() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: BUMPER
	------------------------------------------------------------------------*/
	function onBump() {
		// do nothing
	}


	// *** UPDATES

	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( fl_hitBorder ) { // patch contre les sorties d'écran latérales
			if ( x<Data.BORDER_MARGIN ) x=Data.BORDER_MARGIN;
			if ( x>=Data.GAME_WIDTH-Data.BORDER_MARGIN ) x=Data.GAME_WIDTH-Data.BORDER_MARGIN-1;
		}

		if ( game.fl_aqua ) {
			if ( !isType(Data.FX) && (dx!=0 || dy!=0) ) {
				if ( Std.random(100)<=10 ) {
					game.fxMan.inGameParticles(
						Data.PARTICLE_BUBBLE,
						x+Std.random(Data.CASE_WIDTH) * (Std.random(2)*2-1),
						y-Std.random(Data.CASE_HEIGHT),
						1
					);
				}
			}
		}
		super.endUpdate();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		if ( !fl_physics ) {
			return;
		}

		updateCoords();


		// Vent
		if ( fl_wind ) {
			if ( fl_stable && game.fl_wind ) {
				dx += game.windSpeed*Timer.tmod;
			}
		}


		// Chute
		if ( fl_stable ) {
			if ( dy!=0 || world.getCase( {x:fcx,y:fcy} )!=Data.GROUND ) {
				fl_stable = false;
			}
		}


		if (dx!=0 || dy!=0 || !fl_stable) {
			var step;

			// Gravité
			if ( !fl_skipNextGravity && !fl_stable && fl_gravity ) {

				// facteur de correction pour les tmods extrèmes
				var patchFactor = 1.0;
				if ( Timer.tmod>=2 ) {
					patchFactor = 1.1;
				}

				if ( dy<0 ) {
					dy += gravityFactor * Data.GRAVITY * Timer.tmod * patchFactor;
				}
				else {
					if ( fallStart==null ) {
						fallStart = y;
					}
					if ( game.fl_aqua && !fl_strictGravity ) {
						dy += 0.3 * fallFactor * Data.FALL_SPEED * Timer.tmod * patchFactor;
					}
					else {
						dy += fallFactor * Data.FALL_SPEED * Timer.tmod * patchFactor;
					}

				}
			}
			fl_skipNextGravity = false;


			prefix();

			var stepInfos = calcSteps(dx,dy);
			step=0;

			// Début du stepping
			while ( !fl_stopStepping && step < stepInfos.total ) {
				var ocx = cx;
				var ocy = cy;
				var ofcx = fcx;
				var ofcy = fcy;
				var ox = x;
				var oy = y;
				oldX = x;
				oldY = y;

				x += stepInfos.dx;
				y += stepInfos.dy;
				updateCoords();

				// Patch pénétration dans les murs
				if ( fl_hitWall ) {
					var fl_hasHitWall = false;
					if ( dx>0 && world.getCase( {x:Entity.x_rtc(ox+Data.CASE_WIDTH*0.5),y:Entity.y_rtc(oy)} )>0) {
						fl_hasHitWall = true;
					}
					if ( dx<0 && world.getCase( {x:Entity.x_rtc(ox-Data.CASE_WIDTH*0.5),y:Entity.y_rtc(oy)} )>0) {
						fl_hasHitWall = true;
					}
					if ( fl_hasHitWall ) {
						x=ox;
						stepInfos.dx = 0;
						updateCoords();
						onHitWall();
					}
				}

				// Collision horizontale
				if ( (fl_hitBorder && (x<Data.BORDER_MARGIN || x>=Data.GAME_WIDTH-Data.BORDER_MARGIN)) ||
					(fl_hitWall && world.getCase( {x:cx,y:Entity.y_rtc(oy)} )>0) ) {
					x = ox;
					stepInfos.dx = 0;
					updateCoords();
					onHitWall();
				}


				// Patch traversée de murs par le haut
				if ( fl_hitWall && stepInfos.dy>0 && !fl_kill ) {
					if ( world.getCase(Entity.rtc(ox,oy+Math.floor(Data.CASE_HEIGHT/2)))!=Data.WALL && world.getCase( {x:fcx,y:fcy} )==Data.WALL ) {
						x = ox;
						stepInfos.dx = 0;
						updateCoords();
						onHitWall();
					}
				}

				// Atterrissage
				if ( fl_hitGround && stepInfos.dy>=0 ) {
					if ( world.getCase(Entity.rtc(ox,oy+Math.floor(Data.CASE_HEIGHT/2)))!=Data.GROUND && world.getCase( {x:fcx,y:fcy} )==Data.GROUND ) {
						if ( world.checkFlag( {x:fcx,y:fcy}, Data.IA_TILE) ) {
							if ( fl_skipNextGround ) {
								fl_skipNextGround = false;
							}
							else {
								stepInfos.dy = 0;
								onHitGround( y-fallStart );
								fallStart = null;
								updateCoords();
							}
						}
					}
				}

				// Plafond
				if ( fl_hitCeil && stepInfos.dy<=0 ) {
					if ( world.getCase(Entity.rtc(ox,oy-Math.floor(Data.CASE_HEIGHT/2)))<=0 && world.getCase(Entity.rtc(x,y-Math.floor(Data.CASE_HEIGHT/2)))>0 ) {
						stepInfos.dy = 0;
						onHitCeil();
						updateCoords();
					}
				}

				// Changement de case
				if ( ocx!=cx || ocy!=cy ) {
					var fl_patch = false;

					// Patch d'entrée dans un sol avec air jump
					if ( fl_hitGround && ocy<cy) {
						if ( needsPatch() ) {
							if ( world.getCase({x:ocx,y:ocy})<=0 && dy>0 && world.getCase({x:cx,y:cy})>0 && cy<Data.LEVEL_HEIGHT ) {
								x = Entity.x_ctr(ocx);
								y = Entity.y_ctr(ocy);
								stepInfos.dy=0;
								updateCoords();
								onHitGround(y-fallStart);
								fl_patch = true;
							}
						}
					}

					// Patch entrée dans un sol (coins en diagonal)
					if ( fl_hitGround && dy>=0 && ocx!=cx && ocy!=cy ) {
						if ( world.getCase({x:ocx,y:ocy})<=0 && world.getCase({x:cx,y:cy})==Data.GROUND ) {
							x = Entity.x_ctr(ocx);
							y = Entity.y_ctr(ocy);
							stepInfos.dx=0;
							updateCoords();
							onHitWall();
							fl_patch = true;
						}
					}
					if ( !fl_patch ) {
						tRem(ocx,ocy);
						infix() ; // appel infixe
						updateCoords();
						tAdd(cx,cy);
					}
				}

				step++;
			}
			// Fin du stepping


		}

		fl_stopStepping = false;
		postfix();

		// Frictions
		if ( fl_friction ) {
			if ( (game.fl_ice || fl_slide) && fl_stable ) {
				if ( slideFriction==null ) {
					dx *= game.sFriction;
				}
				else {
					dx *= Math.pow(slideFriction, Timer.tmod);
				}
			}
			else {
				dx *= game.xFriction;
				dy *= game.yFriction;
			}
		}
		if (Math.abs(dx)<=0.2) {
			dx = 0;
		}
		if (Math.abs(dy)<=0.2) {
			dy = 0;
		}


		// Mort
		if ( y>=Data.DEATH_LINE ) {
			onDeathLine();
		}
	}

}

