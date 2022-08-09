class entity.bomb.bad.BossBomb extends entity.bomb.BadBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration		= Data.SECOND*2 + ( Std.random(50)/10 * (Std.random(2)*2-1) );
		fl_blink		= true;
		fl_alphaBlink	= false;
		blinkColorAlpha	= 50;
		explodeSound	= null;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_boss";
		var mc : entity.bomb.bad.BossBomb = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb(g, x,y );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION: BOMBE
	------------------------------------------------------------------------*/
	function initBomb(g,x,y) {
		super.initBomb(g,x,y);
		setLifeTimer(duration*1.5);
		updateLifeTimer(duration);
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return attach(game, x,y);
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();
		var b = entity.bad.walker.Orange.attach(game,x-Data.CASE_WIDTH*0.5,y-Data.CASE_HEIGHT*0.5);
		var boss : entity.boss.Tuberculoz = downcast( game.getOne(Data.BOSS) );
		if ( boss.lives<=70 ) {
			b.angerMore();
		}
		if ( boss.lives<=50 ) {
			b.angerMore();
		}
		b.moveUp(10);
		b.knock(Data.SECOND);
		b.dropReward = null;
		playAnim(Data.ANIM_BOMB_EXPLODE);
	}


	/*------------------------------------------------------------------------
	EVENT: KICK (CES BOMBES SONT FACILEMENT REPOUSSABLES)
	------------------------------------------------------------------------*/
	function onKick(p) {
		super.onKick(p);
		setLifeTimer( lifeTimer + Data.SECOND*0.5 );
	}

}

