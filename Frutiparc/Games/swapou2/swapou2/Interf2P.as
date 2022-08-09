import swapou2.Data ;

class swapou2.Interf2P extends swapou2.Interf {

	// Movies
	var attackIcon : swapou2.SimpleButton ;
	var defenseIcon : swapou2.SimpleButton ;
	var centerPanel, centerPanelMask, leaves, arrow ;
	var pool;
	var pool_temp;
	var pool_for_ia;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function Interf2P( game:swapou2.Duel, depth_m : asml.DepthManager ) {
		super(game,depth_m,2) ;

		leftPanel.sub.gotoAndStop(2) ;
		rightPanel.sub.gotoAndStop(2) ;

		centerPanel = depthMan.attach("centerPanel",Data.DP_BG) ;
		centerPanel._x = Data.DOCWIDTH/2 ;

		centerPanelMask = depthMan.attach("centerPanelMask",Data.DP_INTERFTOP) ;
		centerPanelMask._x = Data.DOCWIDTH/2 ;

		leaves = depthMan.attach("leaves",Data.DP_INTERFTOP) ;
		glue( Std.cast(leftPanel.sub), Std.cast(leaves), Data.DUEL_LEAVES_X, Data.DUEL_LEAVES_Y) ;

		pl[0] = new swapou2.InterfPlayerData ;
		pl[0].powerX = Data.DUEL_POWER_X ;
		pl[0].powerY = Data.DUEL_POWER_Y ;
		attachFace(0, Data.DUEL_FACE_X, Data.DUEL_FACE_Y, Data.DUEL_FACE_SCALE, leftPanel.sub) ;

		pl[1] = new swapou2.InterfPlayerData ;
		pl[1].powerX = Data.DOCWIDTH-Data.DUEL_POWER_X ;
		pl[1].powerY = Data.DUEL_POWER_Y ;
		attachFace(1, Data.DUEL_FACE_IA_X, Data.DUEL_FACE_Y, Data.DUEL_FACE_SCALE, rightPanel.sub) ;
		pl[1].face.flip() ;

		attackIcon = Std.cast( depthMan.attach("swapou2_simpleButton",Data.DP_INTERFTOP) ) ;
		attackIcon.attach( Std.cast(this), "powerIcon", 0,0, Std.cast(attack) ) ;
		attackIcon.skin.sub.gotoAndStop(1) ;
		glue( Std.cast(leftPanel.sub), Std.cast(attackIcon), Data.DUEL_ATTDEF_ICON_X, Data.POWER_Y-(Data.ATTACK_STARS[Data.players[0]]-1)*Data.POWER_HEIGHT) ;

		defenseIcon = Std.cast( depthMan.attach("swapou2_simpleButton",Data.DP_INTERFTOP) ) ;
		defenseIcon.attach( Std.cast(this), "powerIcon", 0,0, Std.cast(defend) ) ;
		defenseIcon.skin.sub.gotoAndStop(2) ;
		glue( Std.cast(leftPanel.sub), Std.cast(defenseIcon), Data.DUEL_ATTDEF_ICON_X, Data.POWER_Y-(Data.DEFENSE_STARS[Data.players[0]]-1)*Data.POWER_HEIGHT) ;

		arrow = Std.cast( depthMan.attach("arrow",Data.DP_INTERFTOP) ) ;
		arrow._x = Data.DOCWIDTH/2 ;
		arrow._y = Data.DOCHEIGHT-32 ;

		pool = new Array();
		pool_temp = new Array();
		pool_for_ia = false;
	}


	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		super.main() ;

		var i;
		for(i=0;i<pool_temp.length;i++) {
			var f = pool_temp[i];
			if( f.timer > 0 )
				f.timer -= Std.tmod * Math.max(10-i,2);
			else {
				f._xscale += f.scale_speed * Std.tmod;
				f._yscale += f.scale_speed * Std.tmod;
				if( f._xscale <= 0 ) {
					f.removeMovieClip();
					pool_temp.splice(i,1);
					i--;
				} else if( f._xscale >= f.target_scale ) {
					f._xscale = f.target_scale;
					f._yscale = f.target_scale;
					pool_temp.splice(i,1);
					i--;
				}
			}
		}

		attackIcon.update() ;
		defenseIcon.update() ;

		updateArrow();
	}

	/*------------------------------------------------------------------------
	ACTUALISE LA FLECHE DU POOL
	------------------------------------------------------------------------*/
	function updateArrow() {
		var trot;
		if( pool.length == 0 )
			trot = 90;
		else if( pool_for_ia )
			trot = 0;
		else
			trot = 179;

		var rot = arrow.arrow._rotation;
		if( rot < trot ) {
			rot += Std.tmod * 20;
			if( rot > trot )
				rot = trot;
		} else if( rot > trot ) {
			rot -= Std.tmod * 20;
			if( rot < trot )
				rot = trot;
		}
		arrow.arrow._rotation = rot;
		arrow.side._rotation = rot;
		arrow.shadow._rotation = rot;
	}

	/*------------------------------------------------------------------------
	ACTUALISE LE SCORE
	------------------------------------------------------------------------*/
	function updateScore(score) {
		leftPanel.scoreTxt.text = string(score) ;
	}

	function destroyPoolItem() {
		var f = pool[pool.length-1];
		pool.splice(pool.length - 1,1);
		f.scale_speed = -12;
		if( f.timer <= 0 ) {
			f.timer = 50;
			pool_temp.push(f);
		}
	}

	function addPoolItem(col,flags) {
		var f = Std.cast( depthMan.empty(Data.DP_INTERF) );
		var fruit : swapou2.Fruit = Std.cast( Std.attachMC(f,"swapou2_fruit",0) );
		fruit._x = -Data.FRUIT_WIDTH / 2;
		fruit._y = -Data.FRUIT_HEIGHT / 2;
		fruit.init(col,flags);
		fruit.sub.shine.gotoAndStop(1);
		fruit.sub.shine._visible = false;

		f._xscale = 0;
		f._yscale = 0;
		f._x = random(5) - 2 + Data.DOCWIDTH / 2 - 3;
		f._y = 380 - pool.length * 16;
		f.timer = 50;
		f.scale_speed = 12;
		f.target_scale = 60+random(10);
		pool_temp.push(f);
		pool.push(f);
		var i;
		for(i=pool.length-1;i>0;i--)
			pool[i].swapDepths(pool[i-1]);
	}

	/*------------------------------------------------------------------------
	ACTUALISE LE POOL DE FRUITS
	mcs : array de {
		col : int // couleur du fruit
		flags : int // flags armure, star, noswap...
		x : int // colonne d'arrivée ou -1 si dynamique
	}
	pool_for_ia : bool , si pour la gueule de l'ia
	------------------------------------------------------------------------*/
	function updatePool(mcs,pool_for_ia) {

		while( pool.length > mcs.length )
			destroyPoolItem();
		while( pool.length < mcs.length && pool.length < 19 ) {
			var p = mcs[pool.length];
			addPoolItem(p.col,p.flags);
		}

		this.pool_for_ia = pool_for_ia;

		var plface = pl[0].face;
		var iaface = pl[1].face
		if( pool.length >= 10 ) {
			if( pool_for_ia ) {
				plface.setHappy(50);
				iaface.panic();
			} else {
				iaface.setHappy(50);
				plface.panic();
			}
		}
	}

	/*------------------------------------------------------------------------
	DÉFINI L'ÉTAT DU LOCK
	------------------------------------------------------------------------*/
	function setLock(flag) {
		super.setLock(flag) ;

		if ( flag ) {
			defenseIcon.disable() ;
		}
		else {
			defenseIcon.enable() ;
		}

	}


	function lockAttack(flag) {
		if( flag )
			attackIcon.disable();
		else
			attackIcon.enable();
	}

}
