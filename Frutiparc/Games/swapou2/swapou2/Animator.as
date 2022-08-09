import swapou2.Data ;
import swapou2.Fruit ;
import swapou2.Sounds ;

class swapou2.Animator {

	var player;
	var depthMan ;

	var animPhase ;
	var qf ;

	var gravityList ;
	var explosions ;
	var fallList ;
	var invisibleList ;
	var moveUpList ;
	var suddens ;
	var specialName, specialTimer, specialCallback, specialData, specialEndTimer ;
	//	var vague ;

	var skipMoveUp ;
	var wait ;
	var endExpTimer ;

	var maxFallingFruits ;

	var lod;
	public var pos_x,pos_y;
	public var particules ;
	//	var explosionMap ;

	var mcFruits;
	var depthManFruits : asml.DepthManager;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	qf: quality factor (0.0->1.0) // XXX todo
	------------------------------------------------------------------------*/
	function Animator(pl : swapou2.IPlayer, pos_x, pos_y) {
		this.pos_x = pos_x;
		this.pos_y = pos_y;
//		this.qf = qf ;

		player = pl;
		animPhase = -1;
		depthMan = player.depthManager() ;
		mcFruits = depthMan.empty(Data.DP_FRUITS);
		depthManFruits = new asml.DepthManager(mcFruits);

		particules = new swapou2.Particules(depthMan) ;
		wait = -1 ;
		invisibleList = new Array() ;
		moveUpList = new Array() ;
		suddens = new Array() ;

		lod = Data.lod;
		if( player.isIA() ) {
			lod = Data.LOW;
			particules.generate = undefined;
		}
	}


	/*------------------------------------------------------------------------
	MASQUE UN MC, EN VUE DE SON RÉAFFICHAGE PROCHAIN
	------------------------------------------------------------------------*/
	function hideMC( mc ) {
		mc._visible = false ;
		invisibleList.push(mc) ;
	}



	/*------------------------------------------------------------------------
	RÉAFFICHE TOUS LES MCS MASQUÉS
	------------------------------------------------------------------------*/
	function showAll() {
		for (var i=0;i<invisibleList.length;i++)
			invisibleList[i]._visible = true ;
		invisibleList = new Array() ;
	}

	function setFruitsVisible(b) {
		mcFruits._visible = b;
	}

	function setPhase(p) {
		// if( animPhase != -1 )
		//	Log.trace("OVERLAP PHASE "+animPhase+ " -> "+p);
		animPhase = p;

		// clear moveups
		for (var i=0;i<moveUpList.length;i++)
			moveUpList[i]._y -= Data.FRUIT_HEIGHT/2 ;
		moveUpList = new Array() ;
	}

	/*------------------------------------------------------------------------
	ÉCHANGE
	------------------------------------------------------------------------*/
	function swap(f1,f2) {
		var f1Swap, f2Swap ;

		Sounds.play(Sounds.SWAP);

		setPhase(Data.A_SWAP);

		if ( f1._x > f2._x ) {
			f1Swap = "swapLeft" ;
			f2Swap = "swapRight" ;
		}
		if ( f1._x < f2._x ) {
			f1Swap = "swapRight" ;
			f2Swap = "swapLeft" ;
		}

		if ( f1._y > f2._y ) {
			f1Swap = "swapUp" ;
			f2Swap = "swapDown" ;
		}
		if ( f1._y < f2._y ) {
			f1Swap = "swapDown" ;
			f2Swap = "swapUp" ;
		}

		hideMC( f1 ) ;
		hideMC( f2 ) ;
		var anim1 = Std.cast( particules.attachFx( f1Swap, f1._x, f1._y, Data.DP_FXTOP ) ) ;
		var anim2 = Std.cast( particules.attachFx( f2Swap, f2._x, f2._y, Data.DP_FXTOP ) ) ;
		anim1.sub.sub.gotoAndStop(f1.sub._currentframe) ;
		anim2.sub.sub.gotoAndStop(f2.sub._currentframe) ;


		var x = f2._x;
		var y = f2._y;
		f2._x = f1._x;
		f2._y = f1._y;
		f1._x = x;
		f1._y = y;

	}



	/*------------------------------------------------------------------------
	RÉCEPTION D'UNE LISTE DE FRUITS À DÉTRUIRE
	------------------------------------------------------------------------*/
	function explode(mcs,armorMcs, score) {
		var i;

		setPhase(Data.A_EXPLODE);

		// Fruits gelés
		var armors = new Array();
		for(i=0;i<armorMcs.length;i++) {
			var d = armorMcs[i] ;
			d.peteArmure();

			if( lod == Data.HIGH ) {
				var f : swapou2.Fruit = attachFruit(0,0,d.t,Data.FLAG_ARMURE);
				f._x = d._x;
				f._y = d._y;
				armors.push(f);
			}

			//var mcExp = Std.cast( particules.attachFx( "explosion", Math.round(d._x+Data.FRUIT_WIDTH/2), Math.round(d._y+Data.FRUIT_HEIGHT/2), Data.DP_FX ) )	;
			//mcExp.sub.gotoAndStop(2) ;
			particules.explodeFrozen(d._x,d._y) ;
		}


		// Fruits normaux
		var sumX, sumY ;
		sumX = 0 ;
		sumY = 0 ;
		for(i=0;i<mcs.length;i++) {
			var mc = mcs[i] ;
			mc.x = mc._x ;
			mc.y = mc._y ;
			mc.expTimer = random( Math.round(mcs.length*2) ) ;
			sumX += mc.x ;
			sumY += mc.y ;
		}

		endExpTimer = Data.END_EXPLOSION_TIMER ;

		explosions = { list:mcs, armors : armors, x:Math.round(sumX/mcs.length), y:Math.round(sumY/mcs.length) }
	}



	/*------------------------------------------------------------------------
	ATTACHE UN FRUIT
	------------------------------------------------------------------------*/
	function attachFruit(x,y,color,flags) {
		var f : swapou2.Fruit = Std.cast(depthManFruits.attach("swapou2_fruit",Data.DP_FRUITS));
		f._x = pos_x + Data.FRUIT_WIDTH * x;
		f._y = pos_y + Data.FRUIT_HEIGHT * y;
		f.init(color,flags);
		return f;
	}


	/*------------------------------------------------------------------------
	DÉTRUIT UN FRUIT
	------------------------------------------------------------------------*/
	function explodeFruit(f) {
		var mcExp ;
		particules.explodeFruit( f._x, f._y ) ;
		mcExp = Std.cast( particules.attachFx("explosion",Math.round(f._x+Data.FRUIT_WIDTH/2),Math.round(f._y+Data.FRUIT_HEIGHT/2),Data.DP_FX) ) ;
		mcExp.sub.stop() ;
		f.removeMovieClip() ;
	}


	/*------------------------------------------------------------------------
	REMONTE UN FRUIT
	------------------------------------------------------------------------*/
	function moveUp( f : Fruit ) {
		if ( lod == Data.HIGH ) {
			skipMoveUp = true ;
			f._y -= Data.FRUIT_HEIGHT/2;
			moveUpList.push(f) ;
		}
		else {
			f._y -= Data.FRUIT_HEIGHT ;
		}
	}


	/*------------------------------------------------------------------------
	RÉCEPTION D'UNE LISTE DE FRUITS À FAIRE TOMBER
	------------------------------------------------------------------------*/
	function gravity(mcList) {

		setPhase(Data.A_GRAVITY);

		gravityList = Std.cast(mcList);
		for(var i=0;i<gravityList.length;i++) {
			var mc = gravityList[i];
			mc.ty = mc.f._y + mc.delta * Data.FRUIT_HEIGHT ;
		}
	}

	/*------------------------------------------------------------------------
	RÉCEPTION D'UNE LISTE DE FRUITS À AJOUTER (MODE DUEL)
	------------------------------------------------------------------------*/
	function falling(mcList) {
		//	  var countList = new Array() ;
		//	  var width = player.gameParams().width ;
		fallList = mcList ;

		//    // Compteur des fruits parasites dans chaque colonne
		//		for(var i=0;i<width;i++)
		//      countList[i]=0 ;

		for(var i=0;i<fallList.length;i++) {
			var mc = fallList[i] ;
			mc.x = mc._x ;
			mc.y = mc._y ;
			mc._y = -Data.DOCHEIGHT + mc._y ;
			//		  mc._y = -Data.FRUIT_HEIGHT ;
			mc.cpt = random(300)/100 ;
		}

		setPhase(Data.A_FALL);
	}

	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		
		particules.main() ;

		// Fruits en sudden death
		for (var i=0;i<suddens.length;i++) {
		  var mc = suddens[i] ;
			mc.sub._x = random(20)/10 * (random(2)*2-1) ;
			mc.sub._y = random(20)/10 * (random(2)*2-1) ;
		}

		switch ( animPhase ) {
		case -1 :
			break ;

		case Data.A_SWAP :
			// *** ANIM DE SWAP
			if ( particules.fxList.length == 0 ) {
				if ( wait<=0 ) {
					showAll() ;
					wait = 3 ;
				}
				wait-=Std.tmod ;
				if ( wait<=0 ) {
					animPhase = -1 ;
					player.swapDone();
				}
			}
			break ;


		case Data.A_GRAVITY :
			// *** CHUTE DES FRUITS
			if ( suddens.length>0 )
				clearSuddenFruits() ;
				for(var i=0;i<gravityList.length;i++) {
					var mc = gravityList[i];
					mc.f._y += Std.tmod * Data.GRAVITY_DELTA ;
					if ( mc.f._y >= mc.ty ) {
						mc.f._y = mc.ty ;
						gravityList.splice(i,1) ;
						i-- ;
						if ( gravityList.length==0 ) {
							animPhase = -1 ;
							player.gravityDone() ;
						}
					}
			}
			break ;


		case Data.A_EXPLODE :
			// *** EXPLOSION
			explodeMain();
			break ;


		case Data.A_FALL :
			// *** FRUITS PARASITES
			for (var i=0;i<fallList.length;i++) {
				var mc = fallList[i] ;
				if ( lod == Data.HIGH ) {
					mc.cpt += 0.8 * Std.tmod ;
					mc._x = mc.x + Math.sin(mc.cpt)*5 ;
				}
				mc._y += Data.PARASITE_SPEED * Std.tmod ;
				if ( mc._y >= mc.y ) {
					mc._x = mc.x ;
					mc._y = mc.y ;
					fallList.splice(i,1) ;
					i-- ;
				}
			}
			if ( fallList.length == 0 ) {
				animPhase = -1 ;
				player.fallingDone();
			}
			break ;


	  case Data.A_GAMEOVER :
			// *** GAMEOVER
			for(var i=0;i<explosions.list.length;i++) {
				var mc = explosions.list[i] ;
				mc.timer-=Std.tmod ;
				if ( mc.timer<=0 ) {
				  Sounds.play((random(2)==0)?Sounds.POP1:Sounds.POP2);
				  explodeFruit(mc) ;
				  explosions.list.splice(i,1) ;
				  i-- ;
				}
			}
			break ;

	  case Data.A_SPECIAL :

			// Boucles de gestion des effets de pouvoirs
			if ( specialCallback!=undefined ) {
				specialTimer -= Std.tmod ;
				if ( specialTimer<=0 )
					Std.cast(specialCallback).call( this, specialData ) ;
			}
			if ( specialEndTimer>0 ) {
				specialEndTimer -= Std.tmod ;
				if ( specialEndTimer<=0 ) {
					animPhase = -1;
					player.specialDone() ;
				}
			}

		  break;
	}


		// Anim de move up
		if ( !skipMoveUp && moveUpList.length>0 ) {
			for (var i=0;i<moveUpList.length;i++)
				moveUpList[i]._y -= Data.FRUIT_HEIGHT/2 ;
			moveUpList = new Array() ;
		}
		skipMoveUp = false ;

	}

	function explodeMain() {
		for(var i=0;i<explosions.list.length;i++) {
			var mc = explosions.list[i] ;
			if ( lod >=Data.HIGH ) {
				mc._x = mc.x + random(30)/10*(random(2)*2-1) ;
				mc._y = mc.y + random(30)/10*(random(2)*2-1) ;
				mc._alpha = random(30)+40 ;
			}
			else
				mc._alpha = 65 ;
			mc.expTimer -= Std.tmod ;
			if ( mc.expTimer<=0 ) {
				Sounds.play((random(2)==0)?Sounds.POP1:Sounds.POP2);
				explodeFruit(mc) ;
				explosions.list.splice(i,1) ;
				i-- ;
			}
		}
		for(var i=0;i<explosions.armors.length;i++) {
			var mc = explosions.armors[i] ;
			mc._alpha -= Std.tmod * 5;
			if( mc._alpha <= 10 ) {
				mc.removeMovieClip();
				explosions.armors.splice(i,1);
				i--;
			}
		}


		if ( explosions.list.length == 0 && explosions.armors.length == 0 ) {
			var i;
			endExpTimer -= Std.tmod ;
			if ( endExpTimer<=0 ) {
				animPhase = -1 ;
				player.explodeDone() ;
			}
		}
	}


  /*------------------------------------------------------------------------
  EVENT: GAMEOVER
  ------------------------------------------------------------------------*/
  function gameOver(wins,fruits) {
    var x,y ;
    clearSuddenFruits() ;
    if ( !wins ) {
		explosions = { list : [], armors : [], x : 0, y : 0 };
      for (x=0;x<fruits.length;x++)
        for (y=0;y<fruits[x].length;y++) {
          var f = fruits[x][y] ;
          if ( f._name != undefined ) {
            f.timer = (Data.DOCHEIGHT - f._y)*0.2 ;
            var xmin = (f._x-pos_x)*100;
            var xmax = (f._x-pos_x)*200;
            f.timer += (random(xmax-xmin)+xmin)/1000;
            f.timer *= 0.6 ;
            explosions.list.push(f) ;
          }
        }
    }
    setPhase(Data.A_GAMEOVER);
  }


	/*------------------------------------------------------------------------
	RENVOIE LES DIMENSIONS GRAPHIQUES
	------------------------------------------------------------------------*/
	function getInfos() {
		return { px : pos_x, py : pos_y, sx : Data.FRUIT_WIDTH, sy : Data.FRUIT_HEIGHT };
	}


	/*------------------------------------------------------------------------
	AFFICHAGE DES POINTS D'UNE EXPLOSION
	------------------------------------------------------------------------*/
	function comboScore( score, nbCombos ) {
	}

	/*------------------------------------------------------------------------
	FRUITS SUDDEN DEATHS
	------------------------------------------------------------------------*/
	function suddenFruits( mcs ) {
	  clearSuddenFruits() ;
	  for (var i=0;i<mcs.length;i++)
	    suddens.push(mcs[i]) ;
	}


  /*------------------------------------------------------------------------
  STOPPPE L'ANIM DE SUDDEN DEATH
  ------------------------------------------------------------------------*/
	function clearSuddenFruits() {
	  for (var i=0;i<suddens.length;i++) {
	    var mc = suddens[i] ;
	    mc.sub._x = 0 ;
	    mc.sub._y = 0 ;
	  }
	  suddens = new Array() ;
	}


	/*------------------------------------------------------------------------
	AFFICHAGE DES POINTS TOTAUX D'UNE SÉRIE DE COMBOS
	------------------------------------------------------------------------*/
	function finalComboScore( score, nbCombos ) {
	}


	/*------------------------------------------------------------------------
	DISPATCH LES SUPER-ATTAQUES
	------------------------------------------------------------------------*/
	// fruits : le tableau complet (mis a jour)
	function dispatchDefense( data, fruits ) {
		clearSuddenFruits();
		switch( data.id ) {
		case 0:
			ecarteur(data.mc1,data.mc2,fruits);
			break;
		case 1:
			egaliseur(data.rems,data.adds,fruits);
			break;
		case 2:
			coupeur(data.cuts,fruits);
			break;
		case 3:
			pete1Ligne(data.cuts,fruits);
			break;
		case 4:
			convertiseur(data.converts,data.src,data.dst,fruits);
			break;
		case 5:
			peteArmures(data.mcs,fruits);
			break;
		case 6:
			combos2(data.mcs,data.arms);
			break;
		}

		var width = player.getLevelWidth() * Data.FRUIT_WIDTH ;
		var mc = Std.cast( particules.attachFx( "defense", pos_x+width/2, Data.SPECIAL_Y, Data.DP_FXTOP ) ) ;
		mc.animMode = Data.PINGPONG ;
		mc.sub.txtField.text = specialName+" !" ;
		Sounds.play(Sounds.COMBO);
	}


	/*------------------------------------------------------------------------
	DISPATCH LES SUPER-ATTAQUES
	------------------------------------------------------------------------*/
	// fruits : le tableau complet (mis a jour)
	function showAttack(name) {		
		var width = player.getLevelWidth() * Data.FRUIT_WIDTH ;
		var mc = Std.cast( particules.attachFx( "defense", pos_x+width/2, Data.SPECIAL_Y, Data.DP_FXTOP ) ) ;
		mc.animMode = Data.PINGPONG ;
		mc.sub.txtField.text = name+" !" ;
		Sounds.play(Sounds.COMBO);
	}



	function setCallback(c,d) {
		setPhase(Data.A_SPECIAL);
		specialCallback = c;
		specialData = d;
	}

	/** INITS DES POUVOIRS ************************/

	/*------------------------------------------------------------------------
	INIT: ÉCARTEUR
	mc1 : colonne de gauche
	mc2 : colonne de droite
	------------------------------------------------------------------------*/
	function ecarteur( mc1, mc2, fruits ) {
		var mid = fruits.length/2 ;
		var left = new Array() ;
		var right = new Array() ;
		var expl = new Array() ;
		var timer = 10 ;


		var cpt=0 ;
		for (var i=0;i<fruits.length;i++) {
			for (var j=0;j<fruits[i].length;j++) {
				var mc = fruits[i][j] ;
				if ( mc._name!=undefined ) {
					mc.timer = timer+Math.abs(i-mid)*4 ;
					mc.cpt = 0 ;
					mc.oldX = mc._x ;
					if ( i<=Math.floor(mid) ) {
						mc.tx = mc._x - Data.FRUIT_WIDTH ;
						left.push(mc) ;
					}
					else {
						mc.tx = mc._x + Data.FRUIT_WIDTH ;
						right.push(mc) ;
					}
				}
			}
		}

		for (var i=0;i<mc1.length;i++) {
			var mc = mc1[i] ;
			if ( mc!=undefined ) {
				mc.timer = mc._y/Data.FRUIT_HEIGHT * 2 ;
				expl.push(mc) ;
			}
		}
		for (var i=0;i<mc2.length;i++) {
			var mc = mc2[i] ;
			if ( mc!=undefined ) {
				mc.timer = mc._y/Data.FRUIT_HEIGHT * 2 ;
				expl.push(mc) ;
			}
		}


		specialName = Data.DEFENSE_NAMES[0] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(ecarteurMain),{ timer:timer, left:left, right:right, expl:expl, fruits:fruits });
	}

	/*------------------------------------------------------------------------
	INIT: ÉGALISEUR
	rems : fruits a supprimer
	adds : fruits a ajouter
	------------------------------------------------------------------------*/
	function egaliseur( rems, adds, fruits ) {

		var falls = new Array() ;
		var ups = new Array() ;

		for (var i=0;i<rems.length;i++) {
			var mc = rems[i] ;
			if ( mc!=undefined ) {
				mc.timer = 4 * i ;
				for (var j=0;j<fruits[i].length;j++) {
					fruits[i][j].ty = fruits[i][j]._y + Data.FRUIT_HEIGHT ;
					falls.push(fruits[i][j]) ;
				}
			}
		}

		for (var i=0;i<adds.length;i++) {
			var mc = adds[i] ;
			if ( mc!=undefined ) {
				mc._alpha = 0;
				mc.timer = 4 * i + 2 ;
				for (var j=0;j<fruits[i].length-1;j++) {
					fruits[i][j].ty = fruits[i][j]._y - Data.FRUIT_HEIGHT ;
					ups.push(fruits[i][j]) ;
				}
			}
		}

		specialName = Data.DEFENSE_NAMES[1] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(egaliseurMain),Std.cast({ rems:rems, adds:adds, fruits:fruits, falls:falls, ups:ups}));
	}

	/*------------------------------------------------------------------------
	INIT: COUPEUR
	cuts : fruits a couper
	------------------------------------------------------------------------*/
	function coupeur( cuts, fruits ) {
		for (var i=0;i<cuts.length;i++) {
			var mc = cuts[i] ;
			mc.timer = 2 * i ;
		}
		specialName = Data.DEFENSE_NAMES[2] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(coupeurMain),Std.cast({ cuts:cuts, fruits:fruits }));
	}

	/*------------------------------------------------------------------------
	INIT: PETE1LIGNE
	cuts : ligne du bas qui pete
	------------------------------------------------------------------------*/
	function pete1Ligne( cuts, fruits ) {
		for (var i=0;i<cuts.length;i++) {
			var mc = cuts[i] ;
			mc.timer = 3 * Math.abs(cuts.length/2-i) ;
		}
		for (var i=0;i<fruits.length;i++) {
			var mc = Std.cast(fruits[i]) ;
			mc.ty = mc._y + Data.FRUIT_HEIGHT ;
			mc.timer = 3 * (Data.DOCHEIGHT - mc._y)/Data.FRUIT_HEIGHT ;
		}
		specialName = Data.DEFENSE_NAMES[3] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(pete1LigneMain),Std.cast({ cuts:cuts, fruits:fruits }));
	}

	/*------------------------------------------------------------------------
	INIT: CONVERTISSEUR
	converts : fruits convertis (a updater graphiquement)
	src : source color
	dst : dest color
	note : on les a tous mis avec 1 d'armure
	------------------------------------------------------------------------*/
	function convertiseur( converts, src, dst, fruits ) {
		for (var i=0;i<converts.length;i++)
			converts[i].timer = 3 * (Data.DOCHEIGHT - converts[i]._y)/Data.FRUIT_HEIGHT ;

		specialName = Data.DEFENSE_NAMES[4] + string(dst) ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(convertisseurMain),Std.cast({ converts:converts, src:src, dst:dst, fruits:fruits }));
	}

	/*------------------------------------------------------------------------
	INIT: PETEARMURES
	mcs : fruits dont l'armure pete
	------------------------------------------------------------------------*/
	function peteArmures( mcs, fruits ) {
		for (var i=0;i<mcs.length;i++) {
			var mc = mcs[i] ;
			mc.timer = (Data.DOCHEIGHT - mc._y)/Data.FRUIT_HEIGHT ;
			mc.timer += (Data.DOCWIDTH - mc._x)/Data.FRUIT_WIDTH ;
		}

		specialName = Data.DEFENSE_NAMES[5] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(peteArmuresMain),Std.cast({ mcs:mcs, fruits:fruits }));
	}

	/*------------------------------------------------------------------------
	INIT : COMBOS 2 COUPS
	------------------------------------------------------------------------*/
	function combos2(mcs,arms) {
		explode(mcs,arms,0);
		specialName = Data.DEFENSE_NAMES[6] ;
		specialTimer = Data.SPECIAL_TIMER ;
		setCallback(Std.cast(explodeMain),undefined);
	}

	/*------------------------------------------------------------------------
	INIT : TREMBLEMENT DE TERRE
	rems : mcs déplacés
	adds : mcs ajoutés
	------------------------------------------------------------------------*/
	function tremblementDeTerre( rems, adds, fruits ) {
		var falls = new Array() ;
		var ups = new Array() ;		

		for (var i=0;i<rems.length;i++) {
			var mc = Std.cast(rems[i]) ;
			if ( mc!=undefined ) {
				mc.timer = 4 * i ;
				for (var j=0;j<fruits[i].length;j++) {
					fruits[i][j].ty = pos_y + Data.FRUIT_HEIGHT * j;
					falls.push(fruits[i][j]) ;
				}
			}
		}

		for (var i=0;i<adds.length;i++) {
			var mc = Std.cast(adds[i]) ;
			if ( mc!=undefined ) {
				mc._alpha = 0 ;
				mc.timer = 4 * i + 2 ;
				for (var j=0;j<fruits[i].length-1;j++) {
					fruits[i][j].ty = pos_y + Data.FRUIT_HEIGHT * j;
					ups.push(fruits[i][j]) ;
				}
			}
		}

		specialTimer = Data.SPECIAL_ATTACK_TIMER;
		setCallback(Std.cast(tremblementDeTerreMain),Std.cast({ rems:rems, adds:adds, fruits:fruits, falls:falls, ups:ups}));
	}

	/*------------------------------------------------------------------------
	INIT : COULEE DE METAL
	mcs : liste des fruits a transformer en metal
	------------------------------------------------------------------------*/
	function couleeMetal( mcs, fruits ) {
		specialTimer = Data.SPECIAL_ATTACK_TIMER;
		setCallback( Std.cast(couleeMetalMain), Std.cast({ mcs:mcs, fruits:fruits }));
	}


	/** BOUCLES DES POUVOIRS ************************/

	/*------------------------------------------------------------------------
	MAIN: ÉGALISEUR
	------------------------------------------------------------------------*/
	function egaliseurMain(data) {

		for (var i=0;i<data.falls.length;i++) {
			var mc = data.falls[i] ;
			mc.timer-=Std.tmod ;
			mc._y += (random(4)+2)*Std.tmod ;
			if ( mc._y>=mc.ty ) {
				mc._y = mc.ty ;
				data.falls.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.ups.length;i++) {
			var mc = data.ups[i] ;
			mc.timer-=Std.tmod ;
			mc._y -= (random(4)+2)*Std.tmod ;
			if ( mc._y<=mc.ty ) {
				mc._y = mc.ty ;
				data.ups.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.rems.length;i++) {
			var mc = data.rems[i] ;
			mc._alpha-=Std.tmod*4 ;
			if ( mc._alpha<=0 ) {
				mc.removeMovieClip() ;
				data.rems.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.adds.length;i++) {
			var mc = data.adds[i] ;
			mc._alpha+=Std.tmod*4 ;
			if ( mc._alpha>=100 ) {
				mc._alpha=100 ;
				data.adds.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.rems.length==0 && data.adds.length==0 && data.falls.length==0 && data.ups.length==0 )
			specialDone() ;

	}


	/*------------------------------------------------------------------------
	MAIN: COUPEUR
	------------------------------------------------------------------------*/
	function coupeurMain(data) {
		for (var i=0;i<data.cuts.length;i++) {
			var mc = data.cuts[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				explodeFruit(mc) ;
				data.cuts.splice(i,1) ;
				i-- ;
			}
		}
		if ( data.cuts.length==0 )
			specialDone() ;
	}


	/*------------------------------------------------------------------------
	MAIN: PETE1LIGNE
	------------------------------------------------------------------------*/
	function pete1LigneMain(data) {
		for (var i=0;i<data.cuts.length;i++) {
			var mc = data.cuts[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				explodeFruit(mc) ;
				data.cuts.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.cuts.length==0 ) {
			specialCallback = undefined ;
			player.specialDoneGravity() ;
		}
	}


	/*------------------------------------------------------------------------
	MAIN: CONVERTISSEUR
	------------------------------------------------------------------------*/
	function convertisseurMain(data) {
		for (var i=0;i<data.converts.length;i++) {
			var mc = data.converts[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				var mcExp = Std.cast( particules.attachFx( "explosion", Math.round(mc._x+Data.FRUIT_WIDTH/2), Math.round(mc._y+Data.FRUIT_HEIGHT/2), Data.DP_FX ) )	;
				mcExp.sub.gotoAndStop(2) ;
				mc.updateSkin();
				data.converts.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.converts.length==0 )
			specialDone() ;
	}


	/*------------------------------------------------------------------------
	MAIN: PETE ARMURES
	------------------------------------------------------------------------*/
	function peteArmuresMain(data) {
		for (var i=0;i<data.mcs.length;i++) {
			var mc = data.mcs[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				var mcExp = Std.cast( particules.attachFx( "explosion", Math.round(mc._x+Data.FRUIT_WIDTH/2), Math.round(mc._y+Data.FRUIT_HEIGHT/2), Data.DP_FX ) )	;
				mcExp.sub.gotoAndStop(2) ;
				particules.explodeFrozen(mc._x,mc._y) ;
				mc.updateSkin();				
				data.mcs.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.mcs.length==0 )
			specialDone() ;
	}

	/*------------------------------------------------------------------------
	MAIN: COULEE METAL
	------------------------------------------------------------------------*/
	function couleeMetalMain(data) {
		for(var i=0;i<data.mcs.length;i++) {
			var mc = data.mcs[i] ;
			mc.updateSkin();
			{
				data.mcs.splice(i,1);
				i--;
			}
		}
		if ( data.mcs.length==0 )
			specialDone() ;
	}

	/*------------------------------------------------------------------------
	MAIN: ÉCARTEUR
	------------------------------------------------------------------------*/
	function ecarteurMain(data) {
		data.timer -= Std.tmod ;
		if ( data.timer<=0 ) {
			particules.attachFx("strike", pos_x+(data.fruits.length*Data.FRUIT_WIDTH) /2,0, Data.DP_FXTOP) ;
			data.timer = 999999 ;
		}

		for (var i=0;i<data.left.length;i++) {
			var mc = data.left[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				mc.cpt += 0.4*Std.tmod ;
				mc._x = mc.tx + Math.cos(mc.cpt)*Data.FRUIT_WIDTH*0.7 ;
				if ( mc.cpt>=Math.PI*1.5) {
					mc._x = mc.tx ;
					data.left.splice(i,1) ;
					i-- ;
				}
			}
		}

		for (var i=0;i<data.right.length;i++) {
			var mc = data.right[i] ;
			mc.timer-=Std.tmod ;
			if ( mc.timer<=0 ) {
				mc.cpt += 0.4*Std.tmod ;
				mc._x = mc.tx - Math.cos(mc.cpt)*Data.FRUIT_WIDTH*0.7 ;
				if ( mc.cpt>=Math.PI*1.5 ) {
					mc._x = mc.tx ;
					data.right.splice(i,1) ;
					i-- ;
				}
			}
		}

		for (var i=0;i<data.expl.length;i++) {
			var mc = data.expl[i] ;
			mc.timer-=Std.tmod ;
			if (mc.timer<=0) {
				explodeFruit(mc) ;
				data.expl.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.expl.length==0 && data.left.length==0 && data.right.length==0 )
			specialDone() ;
	}

	/*------------------------------------------------------------------------
	MAIN: TREMBLEMENT DE TERRE
	------------------------------------------------------------------------*/
	function tremblementDeTerreMain(data) {

		for (var i=0;i<data.falls.length;i++) {
			var mc = data.falls[i] ;
			mc.timer-=Std.tmod ;
			mc._y += Math.abs(random(5)-2)*Std.tmod ;
			if ( mc._y>=mc.ty ) {
				mc._y = mc.ty ;
				data.falls.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.ups.length;i++) {
			var mc = data.ups[i] ;
			mc.timer-=Std.tmod ;
			mc._y -= Math.abs(random(5)-2)*Std.tmod ;
			if ( mc._y<=mc.ty ) {
				mc._y = mc.ty ;
				data.ups.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.rems.length;i++) {
			var mc = data.rems[i] ;
			mc._alpha-=Std.tmod*4 ;
			if ( mc._alpha<=0 ) {
				mc.removeMovieClip() ;
				data.rems.splice(i,1) ;
				i-- ;
			}
		}

		for (var i=0;i<data.adds.length;i++) {
			var mc = data.adds[i] ;
			mc._alpha+=Std.tmod*4 ;
			if ( mc._alpha>=100 ) {
				mc._alpha=100 ;
				data.adds.splice(i,1) ;
				i-- ;
			}
		}

		if ( data.rems.length==0 && data.adds.length==0 && data.falls.length==0 && data.ups.length==0 )
			specialDone();
	}


	/*------------------------------------------------------------------------
	ACTION SPÉCIALE TERMINÉE
	------------------------------------------------------------------------*/
	function specialDone() {
		specialCallback = undefined ;
		specialEndTimer = 10 ;
	}

	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		for(var i=0;i<explosions.list.length;i++)
			explosions.list[i].removeMovieClip() ;
		particules.destroy() ;
	}

}