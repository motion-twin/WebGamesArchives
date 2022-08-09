class entity.bomb.PlayerBomb extends entity.Bomb
{
	static var UPGRADE_FACTOR	= 1.5;
	static var MAX_UPGRADES		= 1;

	var owner			: entity.Player;
	var upgrades		: int;
	var fl_unstable		: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_airKick	= true;
		fl_unstable	= false;
		upgrades	= 0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.PLAYER_BOMB);
	}


	/*------------------------------------------------------------------------
	DÉFINI LE PLAYER PARENT DE LA BOMBE
	------------------------------------------------------------------------*/
	function setOwner(p) {
		owner = p;
	}


	/*------------------------------------------------------------------------
	TOUCHE UNE ENTITÉ
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		super.hit(e) ;
		if ( fl_unstable ) {
			if ( (e.types&Data.BAD)>0 ) {
				onExplode() ;
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h) ;
		if ( fl_unstable && fl_bounce ) {
			onExplode() ;
		}
	}

	/*------------------------------------------------------------------------
	EVENT: BOMBE KICKÉE
	------------------------------------------------------------------------*/
	function onKick(p) {
		if ( upgrades<MAX_UPGRADES ) {
			if ( p.pid!=owner.pid ) {
				upgradeBomb(p);
			}
		}

		super.onKick(p);
		if ( !fl_stable ) {
			fl_airKick = false;
		}
	}


	/*------------------------------------------------------------------------
	AUGMENTE LA PUISSANCE D'UNE BOMBE
	------------------------------------------------------------------------*/
	function upgradeBomb(p) {
		game.fxMan.attachFx(x,y,"hammer_fx_pop");
		radius*=UPGRADE_FACTOR;
		power*=UPGRADE_FACTOR;
		setLifeTimer(duration*0.7);
		dx*=1.5;
		fl_blink = true;
		fl_alphaBlink = false;
		blinkColor = 0xff0000;
		scale( scaleFactor*UPGRADE_FACTOR*100 );
		owner = p;
		upgrades++;
	}


	/*------------------------------------------------------------------------
	EVENT: DESTRUCTION
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		var p : entity.Player = downcast(parent);
//		if ( p!=null && world.currentId<100 ) { // patch anti score infini
//			p.getScore( null,10 );
//		}
		super.onLifeTimer();
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();

		if ( upgrades>0 ) {
			game.fxMan.attachExplosion(x,y,radius);
		}

		if ( game.fl_bombExpert ) {
			var pl = game.getPlayerList();
			for (var i=0;i<pl.length;i++) {
				var p = pl[i];
				var dist = distance( p.x, p.y );
				if ( dist<=radius ) {
					var ratio = (radius-dist)/radius;
					p.knock( Data.SECOND + 2*Data.SECOND*ratio );
					var ang = Math.atan2( p.y-y, p.x-x );
					p.dx = Math.cos(ang)*power*0.7*ratio;
					p.dy = Math.sin(ang)*power*0.7*ratio;
				}
			}
		}

		game.onExplode(x,y,radius);

		if ( owner!=null ) {

			if ( owner.specialMan.actives[14] ) { // champi bleu
				entity.item.ScoreItem.attach(game, x,y, 47,0);
			}
			if ( owner.specialMan.actives[15] ) { // champi rouge
				entity.item.ScoreItem.attach(game, x,y, 48,0);
			}
			if ( owner.specialMan.actives[16] ) { // champi vert
				entity.item.ScoreItem.attach(game, x,y, 49,0);
			}
			if ( owner.specialMan.actives[17] ) { // champi or
				entity.item.ScoreItem.attach(game, x,y, 50,0);
			}

		}
	}


	function update() {
		super.update();
		if ( !fl_blinking && upgrades>0 ) {
			blink(Data.BLINK_DURATION_FAST);
		}
	}

}

