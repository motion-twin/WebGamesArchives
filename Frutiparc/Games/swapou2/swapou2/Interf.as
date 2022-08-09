import swapou2.Data ;
import swapou2.Manager ;


class swapou2.Interf {

	var depthMan ;
	var particules;

	// Movies
	var bg, leftPanel, rightPanel, sdLimit ;
	var fruitRollOver ;

	// Données
	var game;
	public var pl ;
	var powerFx ;
	var lock ;
	var glueList ;

	// Divers
	var starScale ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function Interf( game, depth_m : asml.DepthManager, nbPlayers ) {
		depthMan = depth_m;
		this.game = game;

		// Attachement
		bg = depthMan.attach("bg",Data.DP_BG) ;
	  bg.stop() ;
		particules = new swapou2.Particules(depthMan) ;

    sdLimit = Std.cast( depthMan.attach("sdLimit",Data.DP_BG) ) ;
    sdLimit._x = 0 ;
    sdLimit._y = Data.SUDDEN_Y ;

		leftPanel = Std.cast(depthMan.attach("leftPanel",Data.DP_BG));
		leftPanel.sub.stop() ;

		rightPanel = Std.cast( depthMan.attach("rightPanel",Data.DP_BG) ) ;
		rightPanel.sub.stop() ;
		rightPanel._x = Data.DOCWIDTH ;

		fruitRollOver = Std.cast( depthMan.attach("fruitRollOver",Data.DP_INTERF) ) ;
		fruitRollOver.v._visible = false ;
		fruitRollOver._visible = false ;


		// Données de joueurs
		pl = new Array() ;
		for (var i=0;i<nbPlayers;i++) {
			pl[i] = new swapou2.InterfPlayerData ;
		}

		// Variables
		powerFx = new Array() ;
		glueList = new Array() ;
		lock = false ;
		starScale = 0 ;
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {

		// Gestion des MCs collés
		for (var i=0;i<glueList.length;i++) {
			var dat = glueList[i] ;
			dat.mc._x = dat.master._x + dat.x ;
			dat.mc._y = dat.master._y + dat.y ;
		}

		// Gestion des joueurs
		for (var p=0;p<pl.length;p++) {
			var player = pl[p] ;
			player.face.update() ;

			// Mouvement des étoiles de pouvoir dans l'interface
			if ( player.powerList.length>0 ) {
				starScale+=0.25 ;
				if ( starScale>=Math.PI*Data.POWER_JUMP_CYCLES )
					starScale-=Math.PI*Data.POWER_JUMP_CYCLES ;

				for ( var i=0; i<player.powerList.length; i++ ) {
					var mc = player.powerList[i] ;
					var cpt = starScale - i*0.6 ;
					if ( cpt>=0 && cpt<=Math.PI ) {
						mc._xscale = Math.abs(Math.sin(cpt))*Data.POWER_JUMP_SCALE + Data.POWER_SCALE ;
						mc._yscale = mc._xscale ;
					}
					else {
						mc._xscale = Data.POWER_SCALE ;
						mc._yscale = mc._xscale ;
					}
				}
			}
		}


		// Mouvement des étoiles de pouvoir gagnées
		for (var i=0;i<powerFx.length;i++) {
			var mc = powerFx[i] ;
			mc._x += mc.dx*Std.tmod ;
			mc._y += mc.dy*Std.tmod ;
			if ( (mc.dx<0 && mc._x<=mc.tx) || (mc.dx>0 && mc._x>=mc.tx) ) {
				particules.attachFx("getPowerStar",mc.tx, mc.ty, Data.DP_FX) ;
				particules.heavyExplosion( mc.tx,mc.ty, mc.dx,mc.dy ) ;
				updatePower(mc.plId) ;
				mc.removeMovieClip() ;
				powerFx.splice(i,1) ;
				i-- ;
			}
		}


		particules.main() ;
	}


	/*------------------------------------------------------------------------
	DÉFINI L'ÉTAT DU LOCK
	------------------------------------------------------------------------*/
	function setLock(flag) {
		lock = flag ;
	}


	/*------------------------------------------------------------------------
	ACTUALISE LES ÉTOILES DU SUPER POUVOIR
	------------------------------------------------------------------------*/
	function updatePower(plId) {
		var player = pl[plId] ;
		// Ajout
		while ( player.power > player.oldPower ) {
			var mc = Std.cast(depthMan.attach("powerStar", Data.DP_INTERF));
			mc._x = player.powerX ;
			mc._y = player.powerY - player.oldPower * Data.POWER_HEIGHT ;
			mc._xscale = Data.POWER_SCALE ;
			mc._yscale = mc._xscale ;
			mc._rotation = random(40)/10 * (random(2)*2-1) ;
			mc.cpt = 0.3*player.oldPower ;
			particules.explodeStar( mc._x, mc._y ) ;
			player.oldPower ++ ;
			player.powerList[player.oldPower] = mc ;
		}

		// Retrait
		while ( player.power < player.oldPower ) {
			var mc = player.powerList[player.oldPower] ;
			particules.explodeStar( mc._x, mc._y ) ;
			mc.removeMovieClip() ;
			player.powerList.splice(player.oldPower,1) ;
			player.oldPower -- ;
		}

		// Indicateur "max!"
		if ( player.power == Data.MAX_POWER && player.maxIndicator._name == undefined ) {
			player.maxIndicator = depthMan.attach("maxIndicator",Data.DP_INTERF) ;
			player.maxIndicator._x = player.powerX ;
			player.maxIndicator._y = player.powerY - Data.POWER_HEIGHT * player.power ;
		}

		if ( player.power < Data.MAX_POWER && player.maxIndicator._name != undefined )
			player.maxIndicator.removeMovieClip() ;
	}


	/*------------------------------------------------------------------------
	UN FRUIT-ETOILE EXPLOSE
	mc: le mc du fruit
	------------------------------------------------------------------------*/
	function addPower(plId, fruit:MovieClip) {
		var player = pl[plId] ;

		player.power++;
		if( player.power > Data.MAX_POWER ) {
			player.power = Data.MAX_POWER;
			particules.attachFx("getPowerStar",fruit._x+Data.FRUIT_WIDTH/2, fruit._y+Data.FRUIT_HEIGHT/2, Data.DP_FX) ;
		}
		else {
			var mc = Std.cast( depthMan.attach("flyingStar",Data.DP_FX) ) ;

			mc._x = fruit._x+Data.FRUIT_WIDTH/2 ;
			mc._y = fruit._y+Data.FRUIT_HEIGHT/2 ;
			mc.tx = player.powerX+plId*200 ;
			mc.ty = player.powerY-Data.POWER_HEIGHT*player.power + Data.POWER_HEIGHT ;
			mc.dx = (mc.tx - mc._x)*0.1 ;
			mc.dy = (mc.ty - mc._y)*0.1 ;
			mc.plId = plId ;

			powerFx.push(mc) ;
		}
	}


	/*------------------------------------------------------------------------
	AFFICHE LA PAIRE EN ROLLOVER
	paire: { x, y, dx, dy }
	------------------------------------------------------------------------*/
	function displayPair(p) {
		if ( p.x == undefined || p.dx == undefined ) {
			fruitRollOver._visible = false ;
		}
		else {
			if ( p.f1 == undefined || p.f2 == undefined )
				fruitRollOver._visible = false ;
			else {
				// Affichage de la paire
				fruitRollOver._visible = true ;

				if ( p.dx >= 0 ) {
					// Droite
					fruitRollOver.tx = p.f1._x ;
					fruitRollOver.ty = p.f1._y ;
				}
				else {
					// Gauche
					fruitRollOver.tx = p.f2._x ;
					fruitRollOver.ty = p.f2._y ;
				}

				// Haut/bas
				if ( p.dy > 0 ) {
					fruitRollOver.tr = 90 ;
					fruitRollOver.tx+=Data.FRUIT_HEIGHT ;
				}
				else
					if ( p.dy < 0 ) {
						fruitRollOver.tr = 90 ;
						fruitRollOver.tx+=Data.FRUIT_HEIGHT ;
						fruitRollOver.ty-=Data.FRUIT_HEIGHT ;
					}
					else {
						fruitRollOver.tr = 0 ;
					}

					// Déplacement intermédiaire entre le rollover précédent et l'actuel
					fruitRollOver._x += ( fruitRollOver.tx - fruitRollOver._x ) * Data.ROLLOVER_FACTOR ;
					fruitRollOver._y += ( fruitRollOver.ty - fruitRollOver._y ) * Data.ROLLOVER_FACTOR ;
					fruitRollOver._rotation += ( fruitRollOver.tr - fruitRollOver._rotation ) * Data.ROLLOVER_FACTOR ;
					if ( p.f1.canSwap() && p.f2.canSwap() && (p.dy != 0 || game.player.horizontal_lock == 0) ) {
						fruitRollOver.sub.gotoAndStop(1) ;
						fruitRollOver.v._visible = false ;
					} else {
						fruitRollOver.v._visible = (game.player.horizontal_lock > 0);
						fruitRollOver.v.field.text = int(game.player.horizontal_lock);
						fruitRollOver.sub.gotoAndStop(2) ;
					}
			}


		}

	}

	/*------------------------------------------------------------------------
	PLAY GAME OVER SEQUENCE
	------------------------------------------------------------------------*/
	function gameOver(is_player) {
		var plId = 0;
		var player = pl[plId];
		player.face.shakeItBaby(50);
	}


	/*------------------------------------------------------------------------
	EVENT: CLIC SUR L'ICONE ATTAQUE
	------------------------------------------------------------------------*/
	function doAttack(plId) {
		var player = pl[plId] ;
		if ( player.power>=Data.ATTACK_STARS[Data.players[plId]] ) {
			player.face.setAttack(100) ;
			player.power-=Data.ATTACK_STARS[Data.players[plId]] ;
			updatePower(plId) ;
			return true;
		}
		return false;
	}

	function attack() {
		if( doAttack(0) )
			game.attack();
	}


	/*------------------------------------------------------------------------
	EVENT: CLIC SUR LA DÉFENSE
	------------------------------------------------------------------------*/
	function doDefend(plId) {
		var player = pl[plId] ;
		if ( (plId == 1 || !lock) && player.power>=Data.DEFENSE_STARS[Data.players[plId]] ) {
			player.power-=Data.DEFENSE_STARS[Data.players[plId]] ;
			player.face.setAttack(100) ;
			updatePower(plId) ;
			return true;
		}
		return false;
	}

	function defend() {
		if( doDefend(0) )
			game.defend();
	}


	/*------------------------------------------------------------------------
	COLLE UN MC À UN AUTRE
	------------------------------------------------------------------------*/
	function glue(masterMc, gluedMc, x,y ) {
		gluedMc._x = masterMc._x + x ;
		gluedMc._y = masterMc._y + y ;
		glueList.push( {mc:gluedMc, master:masterMc, x:x, y:y} ) ;
	}


	/*------------------------------------------------------------------------
	ATTACHE LE VISAGE D'UN JOUEUR
	------------------------------------------------------------------------*/
	function attachFace(plId, x,y, scale, masterMc) {
		var f : swapou2.Face = Std.cast( depthMan.attach("swapou2_faceFull", Data.DP_INTERF) ) ;
		pl[plId].face = f ;
		pl[plId].face.init(0,0, Data.players[plId]) ;
		pl[plId].face._xscale = 100*scale ;
		pl[plId].face._yscale = 100*scale ;
		//		pl[plId].faceBorder = depthMan.attach("faceBorder", Data.DP_INTERF) ;
		//		pl[plId].faceBorder._xscale = 100*scale ;
		//		pl[plId].faceBorder._yscale = 100*scale ;
		glue( Std.cast(masterMc), Std.cast(pl[plId].face), x, y) ;
		//    glue( Std.cast(masterMc), Std.cast(pl[plId].faceBorder), Math.round(x-Data.FACEBORDER_X*scale), Math.round(y-Data.FACEBORDER_Y*scale) ) ;
	}


	/*------------------------------------------------------------------------
	CLEAN ALL
	------------------------------------------------------------------------*/
	function destroy() {
		particules.destroy() ;
		depthMan.destroy() ;
	}

}
