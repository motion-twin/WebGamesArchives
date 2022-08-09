// Poulpi 1.2 avec les features StandAlone
//

#include "inc/mainProgram.as"
#include "../ext/inc/sounds.as"

/* Phases d'animation de mouvement: (pj.phase)
    1-arrêt
    2-marche
    3-saut
    4-crunch
    5-arrêt sous l'eau
    6-déplacement sous l'eau
    7-tir sous l'eau
    8-freeze
    9-bounce sur un item
*/

// Depths
_global.DEPTH_COMPTEUR=80 ;
_global.DEPTH_PJ_DEAD=90 ;
_global.DEPTH_LINES=99 ;
_global.DEPTH_ITEM=100 ;
_global.DEPTH_PJ=200 ;
_global.DEPTH_FX=300 ;
_global.DEPTH_TILE=400 ;
_global.DEPTH_BAD=500 ;
_global.DEPTH_TOP=600 ;
_global.DEPTH_TOPTOP=700 ;

// Tiles
_global.tiles=[undefined,undefined,undefined,undefined,undefined,undefined] ;
_global.maxTiles=6 ;
_global.tileWidth=460/_global.maxTiles ;
_global.tileYmin=70 ;
_global.initialSpeed=3 ;
_global.tileTimeOut=8500 ;
_global.nbTiles=0 ;

// Ennemis
_global.bads=new Array() ;
_global.badsUW=new Array() ;
_global.dureeFish=100 ; // Temps au bout duquel on peut spawner un poisson xxx 5000
_global.beeSpeed=0.6 ;
_global.beeFreeze=2700 ; // 2700 Durée en ms de freeze dû à une piqure de guêpe
_global.nbBads=0 ;

// FX
_global.underWater=new Array() ;
_global.fx=new Array() ;

// Items
_global.items=new Array() ;
_global.dureeFruit=20000 ; // 23000
_global.dureeRuche=23000 ; // 23000

// Joueur
_global.pjY=470 ;
_global.pjWidth=26 ;
_global.poussee=0.5 ; // Poussée d'un déplacement hors de l'eau
_global.pousseeWater=1.5 ; // Poussée d'un déplacement sous l'eau
_global.pousseeSaut=-12 ; // Puissance du saut
_global.goUpSpeed=7 ; // Vitesse de remontée des dalles
_global.maxSpeed=10 ; // vitesse de chute max
_global.air=100 ; // 100
_global.perteAir=0.25 ;
_global.recupAir=1 ;

// Gameplay
_global.levelTheorique=0 ;// Cette valeur est celle affichée aux joueurs
_global.level=-1 ; // Cette valeur sert aux adressages du tableau _global.levels (elle se bloque à une valeur maximale)
_global.dureeLevel=52000 ;
_global.seuilLevelOneBee=4 ;
_global.bonusBeeBounce=3 ; // Bonus pour des bounces sur des ruches
_global.bonusMiniBounce=5 ; // Bonus pour 4 crunches consécutifs sur une même pomme
_global.bonusBounce=15 ; // Bonus pour 4 crunches consécutifs sur une même pomme
_global.bonusDunk=30 ; // Bonus pour un dunk
_global.seuilDunk=27.4 ; // 27.4 Seuil à atteindre pour dy pour qu'un dunk soit comptabilisé

// Divers
_global.seuilFPS=26 ;
_global.score=0 ;
_global.ySol=430 ;
_global.yWater=445 ;
_global.frictionWater=0.87 ; // Facteur de friction globale sous l'eau
_global.friction=0.85 ; // Facteur de friction horizontal hors de l'eau
_global.gravite=0.7 ; // Additioneur au DY dû à la gravité
_global.graviteLowJump=1 ; // Multiplicateur au DY si Haut n'est pas maintenu en saut
_global.graviteTile=1.03 ; // Facteur d'accélération des chutes de dalles
_global.pousseeArchi=-0.04 ; // Additionneur de poussée d'archimède
_global.lastHour=-1 ;

_global.levels=[
  {tiles:+0, bonus:+1, bads:+0, fish:60000},
  {tiles:+1, bonus:+0, bads:+0, fish:60000},
  {tiles:+1, bonus:+0, bads:+0, fish:60000},
  {tiles:+0, bonus:+0, bads:+1, fish:60000}, //
  {tiles:+1, bonus:+0, bads:+0, fish:50000},
  {tiles:+1, bonus:+1, bads:+0, fish:40000},
  {tiles:+0, bonus:+0, bads:+0, fish:30000},
  {tiles:+1, bonus:+1, bads:+0, fish:20000},
  {tiles:+1, bonus:+0, bads:+0, fish:10000},
  {tiles:+0, bonus:+0, bads:+0, fish:8000},
  {tiles:+0, bonus:+0, bads:+1, fish:8000},//
  {tiles:+0, bonus:+0, bads:+0, fish:6000},
  {tiles:+0, bonus:+0, bads:+0, fish:5000},
  {tiles:+0, bonus:+1, bads:+0, fish:4000},
  {tiles:+0, bonus:+0, bads:+0, fish:3500},
  {tiles:+0, bonus:+0, bads:+0, fish:3000},
  {tiles:+0, bonus:+0, bads:+0, fish:2500},
  {tiles:+0, bonus:+1, bads:+0, fish:2000}
] ;

// Options de jeu
_global.soundOn=true ;
_global.musicOn=true ;
_global.helpOn=true ;
//_global.son=false ;



/*-----------------------------------------------
              DEPLACEMENT DU JOUEUR
 ------------------------------------------------*/
_global.movePJ=function() {
  var inWater, tile ;

  // Gouttes de sueur en cas de danger
  if (_global.air<=30) {
    pj.peur.play() ;
    if (!pj.aPeur)
      if (_global.soundOn) _global.playSound("sonDanger") ;
    pj.aPeur=true ;
  }
  else
    if (pj.peur._currentframe>1) {
      pj.peur.gotoAndStop(1) ;
      pj.aPeur=false ;
    }

  // Déplacement, puis application de la gravité et de la friction
  if (pj._y>=_global.yWater)
  	inWater=true ;
  if (pj.oldY<_global.yWater and inWater) {
    if (random(2)) {
      if (_global.soundOn) _global.playSound("sonPlouf1") ;
    }
    else
      if (_global.soundOn) _global.playSound("sonPlouf2") ;
    pj.freeze=false ;
    pj.peur.gotoAndStop(1) ;
  }

  pj.oldY=pj._y ;

  // Rebond sur les bords
  if (pj._x<20+_global.pjWidth/2) pj.dx=Math.abs(pj.dx) ;
  if (pj._x>480-_global.pjWidth/2) pj.dx=-Math.abs(pj.dx) ;
  if (pj._y>500-_global.pjWidth/2) pj.dy=-Math.abs(pj.dy) ;

  // Déplacement
  pj._x+=_global.adjustTimer(pj.dx) ;
  pj._y+=_global.adjustTimer(pj.dy) ;

  // Inertie, gravité et effets spéciaux
  if (inWater) {
    // *** DANS L'EAU ***
  	pj.dx*=_global.adjustTimerFact(_global.frictionWater) ;
  	pj.dy*=_global.adjustTimerFact(_global.frictionWater) ;
  	if (pj._y>_global.yWater+15) pj.dy+=_global.adjustTimer(_global.pousseeArchi) ;
  	pj.wet=100 ;
  	// Bulles d'air lors d'un plongeon
    if (pj.dive>0) {
      pj.dive-=_global.adjustTimer(1) ;
      if (_global.randomT(2)==0 and _global.FPS>_global.seuilFPS)
      _global.spawnBulle(pj._x+random(_global.pjWidth)-_global.pjWidth/2, pj._y+random(20)-5) ;
    }
    else
      if (_global.randomT(13)==0 and _global.FPS>_global.seuilFPS)
        _global.spawnBulle(pj._x+random(_global.pjWidth)-_global.pjWidth/2, pj._y) ;
  }
  else {
    // *** HORS DE L'EAU ***
  	pj.dx*=_global.adjustTimerFact(_global.friction) ;
  	if (!pj.highJump and pj.dy<0)
  	  pj.dy+=_global.adjustTimer(_global.graviteLowJump) ;
	  pj.dy+=_global.adjustTimer(_global.gravite) ;
	  if (pj.dy>_global.maxSpeed) pj.dy=_global.maxSpeed ;
	  pj.dive=30 ;
	  // Gouttes retombant à la sortie de l'eau
    if (pj.wet>0) {
      pj.wet-=_global.adjustTimer(1) ;
      if (_global.randomT(7)==0 and _global.FPS>_global.seuilFPS)
        _global.spawnGoutte(pj._x+random(_global.pjWidth)-_global.pjWidth/2, pj._y+10) ;
    }
  }

  // Lock sur les dalles
  tile=_global.getTile(pj._x) ;
  if (tile!=undefined and !inWater) {
    if (pj.tileLocked!=tile) {
      pj.tileLocked=false ;
      if (pj.stable)
          pj.oldY=pj._y-10 ; // on vient de sortir d'une dalle
      pj.stable=false ;
      if (pj.oldY<=tile.oldY-8 and pj._y>tile._y-8 and pj.dy>=0)
        pj.tileLocked=tile ;
    }
    if (pj.tileLocked==tile) {
      pj._y = pj.tileLocked._y-8 ;
      pj.dy=0 ;
      pj.stable=true ;
    }
  }

  // Tourne le joueur dans le sens du mouvement
  if (pj.dx>0 and pj.direct<0) {
    pj.direct=1 ;
    pj._xscale=-Math.abs(pj._xscale) ;
    pjUW._xscale=pj._xscale ;
  }
  if (pj.dx<0 and pj.direct>0) {
    pj.direct=-1 ;
    pj._xscale=Math.abs(pj._xscale) ;
    pjUW._xscale=pj._xscale ;
  }

  if (Math.abs(pj.dx)<=0.01) pj.dx=0 ;
  if (Math.abs(pj.dy)<=0.01) pj.dy=0 ;

}



/*-----------------------------------------------
              DEPLACEMENT DES DALLES
 ------------------------------------------------*/
_global.moveTiles=function() {
  var i,tile,temps ;
  temps=getTimer() ;

  for (i=0;i<_global.tiles.length;i++) {
    tile=_global.tiles[i]
    tile.oldY=tile._y ;
    // Chute de la dalle au bout du temps timeout
    if (temps>tile.timeOut and tile.speed==0)
      tile.speed=_global.initialSpeed ;

    if (tile._y>=_global.ySol) {
    	tile._y=_global.ySol ;
    	tile.wet=30 ;
    }
    else {
      // En train d'être poussée (freeze=true) ou non
    	if (tile.freeze) {
    	  tile.speed=0 ;
    	  tile.timeOut=getTimer() + _global.tileTimeOut ;
    	}
    	else {
    	  tile.speed*=_global.adjustTimerFact(_global.graviteTile) ;
    		tile._y+=_global.adjustTimer(tile.speed/10) ;
    	}
      if (tile.wet>0) {
        tile.wet-=_global.adjustTimer(1) ;
        if (_global.randomT(4)==0 and _global.FPS>_global.seuilFPS)
          _global.spawnGoutte(tile._x+random(_global.tileWidth),tile._y+10) ;
      }
    }

    tile.freeze=false ;
  }
}


/*-----------------------------------------------
                DEPLACEMENT DES FX
 ------------------------------------------------*/
_global.moveFx=function() {
  var i,mc,limitFx,delThis ;

  // En cas de low FPS, on supprime 1 fx sur 2
  if (_global.FPS<=_global.seuilFPS)
    limitFx=true ;
  else
    limitFx=false ;
  delThis=true ;
  for (i=0;i<_global.fx.length;i++) {
    mc=_global.fx[i] ;
    if (limitFx and delThis and !mc.dontKill) {
      mc.removeMovieClip();
      _global.fx.splice(i,1) ;
      i-- ;
    }
    else {
      mc._x+=_global.adjustTimer(mc.dx) ;
      mc._y+=_global.adjustTimer(mc.dy) ;
      // Gravité
      if (mc.fall) mc.dy+=_global.adjustTimer(_global.gravite) ;
      // Suppression
      if (mc._y>_global.yWater) {
        mc.removeMovieClip();
        _global.fx.splice(i,1) ;
        i-- ;
      }
    }
    delThis=!delThis ;

  }
}



/*-----------------------------------------------
        DEPLACEMENT DES OBJETS SOUS-MARINS
 ------------------------------------------------*/
_global.moveUnderWaterItems=function() {
  var i,mc ;
  for (i=0;i<_global.underWater.length;i++) {
    mc=_global.underWater[i] ;
    mc._y+=_global.adjustTimer(mc.dy) ;
    mc._rotation+=2 ;
    if (mc.generator and _global.randomT(10)==0 and _global.FPS>_global.seuilFPS) {
      _global.spawnBulle(mc._x+random(20)-10,mc._y+6) ;
    }
    if ( (mc.dy>0 and mc._y>=510) or (mc.dy<0 and mc._y<=_global.yWater-2) )
      mc.play() ;

    if (mc.kill or mc._y>515) {
      mc.removeMovieClip();
      _global.underWater.splice(i,1) ;
      i-- ;
    }

  }
}



/*-----------------------------------------------
              DEPLACEMENT DES ITEMS
 ------------------------------------------------*/
_global.moveItems=function() {
  var oldDx,oldDy, dist,ex,ey, i,j, mc2,mc, score, temps ;
  temps=getTimer() ;

  mcLines.clear() ;
  mcLines.lineStyle(1,0x006600) ;

  for (i=0;i<_global.items.length;i++) {
    mc=_global.items[i] ;

    // Recyclage de l'item
    if (!mc.recall and mc.timeOut!=-1 and temps>=mc.timeOut) {
      _global.recallItem(i) ;
    }

    // Contact items / items
    if (!mc.kill and !mc.recall) {
      for (j=i+1;j<_global.items.length;j++) {
        mc2=_global.items[j] ;
        if (!mc2.recall and mc.hitTest(mc2)) {
          if (mc.bouncePrevious!=mc2) {
            oldDx=mc.dx ;
            oldDy=mc.dy ;
            mc.dx=mc2.dx ;
            mc.dy=mc2.dy ;
            mc2.dx=oldDx ;
            mc2.dy=oldDy ;
            mc.stable=0 ;
            mc2.stable=0 ;
            mc.bouncePrevious=mc2 ;
            mc2.bouncePrevious=mc ;
            if (mc.type==2 and pj._y<_global.yWater and !pj.freeze) _global.spawnBee(mc) ;
            if (mc2.type==2 and pj._y<_global.yWater and !pj.freeze) _global.spawnBee(mc2) ;
          }
        }
        else
          if (mc.bouncePrevious==mc2) mc.bouncePrevious=undefined ;
      }
    }

    // Mini combo
    if (mc.type==1 and !mc.kill and mc.bounces==2 and getTimer()>mc.timeOutBounce) {
      score = _global.bonusMiniBounce*mc.mul ;
      _global.spawnPopUpBonus(mc._x,mc._y-15,"mini +"+score,-14) ;
      _global.addScore(score) ;
      mc.bounces=0 ;
    }

    // Bee Combo & Kamikaze combo !
    if (mc.type>=2 and !mc.kill and mc.bounces>=2 and getTimer()>mc.timeOutBounce) {
      score = _global.bonusBeeBounce*mc.bounces ;
      if (mc.bounces<=5) _global.spawnPopUpBonus(mc._x,mc._y-15,"bee combo! +"+score,-14) ;
      if (mc.bounces>5) _global.spawnPopUpBonus(mc._x,mc._y-15,"KAMIKAZE! +"+score,-14) ;
      _global.addScore(score) ;
      mc.bounces=0 ;
    }

    // Contact Items / PJ
    if (!mc.kill and !pj.kill and mc.hitTest(pj.hitMask)) {
      if (!mc.justHit and !pj.freeze) {
        mc.justHit=true ;
        mc.dy=pj.dy*1.5 ;
        mc.stable=0 ;
        // Compteur de rebonds sur le dessus d'un item
        if (getTimer()<=mc.timeOutBounce) {
          mc.bounces++ ;
        }
        else {
          mc.bounces=0 ;
        }
        mc.timeOutBounce=getTimer()+700 ;
        // Rebond du joueur s'il est au dessus du fruit
        bounced=false ;
        if (pj._y<=mc._y-7) {
          bounced=true ;
          pj.skin.gotoAndPlay("bounce") ;
          pj.phase=9 ;
          pj.dy=-3 ;
          if (mc._x-pj._x <= -3)
            mc.dx=-5 ;
          if (mc._x-pj._x >= 3)
            mc.dx=5 ;
        }
        else
          mc.dx=pj.dx*1.5 ;

        switch (mc.type) {
          case 1 :
              mc.skin.nextFrame() ;
              mc.crunch++ ;
              score=mc.crunch*3*mc.mul ;
              _global.addScore(score) ;
              if (_global.soundOn) _global.playSound("sonDing") ;
              _global.spawnPopUpBonus(mc._x,mc._y,score,-10) ;
              if (mc.crunch>=mc.maxCrunch) {
                if (bounced) mc.dy*=1.5 ;
                // Mini combo (3 coups)
                if (mc.bounces==2) {
                  score = _global.bonusMiniBounce*mc.mul ;
                  _global.spawnPopUpBonus(mc._x,mc._y-15,"mini +"+score,-14) ;
                  _global.addScore(score) ;
                }
                // Combo (4 coups)
                if (mc.bounces==3) {
                  score = _global.bonusBounce*mc.mul ;
                  _global.spawnPopUpBonus(mc._x,mc._y-15,"combo +"+score,-14) ;
                  _global.addScore(score) ;
                }
                mc.kill=1 ;
                _global.spawnBonus() ;
              }
              break ;
          case 2 :
/*              _global.spawnPopUpBonus(mc._x,mc._y-15,1,-14) ;
              _global.addScore(1) ;*/
              _global.spawnBee(mc) ;
              break ;
        }
      }
    }
    else {
      mc.justHit=false ;
    }


    if (mc.stable<25) {

      if (!mc.kill) {
        // Tension de la corde
        ex=(mc._x-mc.attX) ;
        ey=(mc._y-mc.attY) ;
        dist=Math.sqrt((ex*ex)+(ey*ey)) ;

        if (dist>mc.maxLength) {
          ex=-(ex*0.01) ;
          ey=-(ey*0.01) ;
          facteur=(dist-mc.maxLength)/mc.maxLength ;
          mc.dx+=_global.adjustTimer(ex*facteur) ;
          mc.dy+=_global.adjustTimer(ey*facteur) ;
          mc.dy*=_global.adjustTimerFact(0.98) ;
        }
        mc._rotation=-(mc._x-mc.attX)/2 ;
      }

      // Rebords
      if (mc._x<20+mc._width/2) mc.dx=Math.abs(mc.dx) ;
      if (mc._x>480-mc._width/2) mc.dx=-Math.abs(mc.dx) ;
      if (!mc.kill and mc._y>=_global.yWater-16) mc.dy=-Math.abs(mc.dy) ;

      mc._x+=_global.adjustTimer(mc.dx) ;
      mc._y+=_global.adjustTimer(mc.dy) ;

      // Stabilisation
      if (!mc.kill and Math.abs(mc.dy)<0.15)
        mc.stable++ ;
      else
        mc.stable=0 ;

      // Gravité
      mc.dx*=_global.adjustTimerFact(0.97) ;
      mc.dy+=_global.adjustTimer(_global.gravite) ;
      //if (mc.dy>15) mc.dy=15 ;

      // Killé et tombe à l'eau
      if (mc.kill and mc._y>_global.yWater) {
        // Dunk !!
        if (mc.dy>=_global.seuilDunk) {
          if (_global.soundOn) _global.playSound("sonYahou") ;
          var mcDunk, d ;
          d=_global.getd("_global.DEPTH_TOP") ;
          attachMovie("dunk","dunkIndicator",d) ;
          dunkIndicator._x=250 ;
          dunkIndicator._y=200 ;
          score=_global.bonusDunk*mc.mul ;
          _global.spawnPopUpBonus(250,180,"extra +"+score,-10) ;
        }
        _global.spawnUnderWaterItem(1,mc._x,mc._y,mc._xscale) ;
        mc.removeMovieClip() ;
        _global.items.splice(i,1) ;
        i-- ;
      }
    }
    // Affichage de la corde
    if (!mc.kill) {
      mcLines.moveTo(mc.attX,mc.attY) ;
      mcLines.lineTo(mc._x,mc._y) ;
    }

    if (mc.recall and mc._y<mc.attY) {
      oldType=mc.type ;
      mc.removeMovieClip() ;
      _global.items.splice(i,1) ;
      i-- ;
      _global.spawnItem(oldType,true) ;
    }
  }
}



/*-----------------------------------------------
            DEPLACEMENT DES ENNEMIS
 ------------------------------------------------*/
_global.moveBads=function() {
  var i,mc ;
  for (i=0;i<_global.bads.length;i++) {
    mc=_global.bads[i] ;

    // Suppression si la ruche a disparu
    if (mc.mcHome._x==undefined and mc._y<-3) {
      mc.removeMovieClip() ;
      _global.bads.splice(i,1) ;
      i-- ;
    }

    mc._x+=_global.adjustTimer(mc.dx) ;
    mc._y+=_global.adjustTimer(mc.dy) ;

    // Changement de cible
    if (mc.cible!=pj and pj._y<_global.yWater and !mc.kill and !pj.freeze and !pj.kill) mc.cible=pj ;
    if (mc.cible==pj and (pj._y>=_global.yWater or mc.kill or pj.freeze or pj.kill)) mc.cible=mc.mcHome ;

    // Atteint la cible
    if (mc.hitTest(mc.cible)) {
      // Retour à la ruche
      if (mc.kill) {
        if (mc.backHomeCounter>9) {
          mc.mcHome.activeBees-- ;
          mc.removeMovieClip() ;
          _global.bads.splice(i,1) ;
          i-- ;
          continue ;
        }
        else
          mc.backHomeCounter++ ;
      }
      else {
        // Pique le PJ
        mc.kill=true ;
        if (mc.cible==pj) {
          pj.freezeTimer=getTimer()+_global.beeFreeze ;
          pj.freeze=true ;
          if (_global.soundOn) _global.playSound("sonPiqure") ;
        }
      }
    }

    // Tracking de la cible (on se croirait dans Top Gun)
    if (mc._x<mc.cible._x) mc.dx+=_global.adjustTimer(_global.beeSpeed) ;
    if (mc._x>mc.cible._x) mc.dx-=_global.adjustTimer(_global.beeSpeed) ;
    if (mc._y<mc.cible._y) mc.dy+=_global.adjustTimer(_global.beeSpeed) ;
    if (mc._y>mc.cible._y) mc.dy-=_global.adjustTimer(_global.beeSpeed) ;

    mc.dx*=_global.adjustTimerFact(_global.friction) ;
    mc.dy*=_global.adjustTimerFact(_global.friction) ;
  }
}



/*-----------------------------------------------
       DEPLACEMENT DES ENNEMIS SOUS MARINS
 ------------------------------------------------*/
_global.moveBadsUW=function() {
  var i,mc ;
  for (i=0;i<_global.badsUW.length;i++) {
    mc=_global.badsUW[i] ;

    // Touche le PJ
    if (!pj.kill and mc.active and mc.hitTest(pj.hitMask)) {
      if (_global.soundOn) _global.playSound("sonDevore") ;
      pj.kill=true ;
      mc.kill=true ;
      typeMort=2 ;
      mc.targetX=mc._x ;
      mc.targetY=mc._y ;
      mc.gotoAndPlay(1) ;
    }

    frameDebut=20 ;// Constante: première frame de l'ouverture de la bouche
    if (!mc.kill and mc.active)
      if (pj._y>=_global.yWater and !pj.kill)
        mc.gotoAndStop( Math.max(frameDebut,frameDebut+ 7-Math.floor(Math.abs(mc._x-pj._x)/25)) ) ;
      else
        if (mc._currentframe>frameDebut)
          mc.prevFrame() ;

    // Timer d'attente quand une cible est atteinte
    if (getTimer()>=mc.goTimer) {
      // Activation du monstre au premier checkpoint
      if (mc.checkPoint>=1) mc.active=true ;

      if (mc.dir>0 and mc._x<mc.targetX) mc.dx+=_global.adjustTimer(mc.speed) ;
      if (mc.dir<0 and mc._x>mc.targetX) mc.dx-=_global.adjustTimer(mc.speed) ;

      // Cible atteinte
      if (mc.dir>0 and mc._x>=mc.targetX) { // Droite
        mc.goTimer=getTimer()+2000 ;
        mc.targetX=540 ;
        mc.checkPoint++ ;
      }
      if (mc.dir<0 and mc._x<=mc.targetX) { // Gauche
        mc.goTimer=getTimer()+2000 ;
        mc.targetX=-40 ;
        mc.checkPoint++ ;
      }


    }
    mc._x+=_global.adjustTimer(mc.dx) ;
    mc._y+=_global.adjustTimer(mc.dy) ;

    mc.dx*=_global.adjustTimerFact(_global.frictionWater) ;
    mc.dy*=_global.adjustTimerFact(_global.frictionWater) ;

    // Deuxième cible atteinte, le mc est sorti de l'écran
    if (mc.checkPoint>=2 and !mc.kill) {
      mc.removeMovieClip() ;
      _global.badsUW.splice(i,1) ;
      i-- ;
    }

  }
}



/*-----------------------------------------------
           RAPPEL D'UN ITEM EN RESERVE
 ------------------------------------------------*/
_global.recallItem=function (id) {
  var mc ;
	mc=_global.items[id] ;
	mc.maxLength=10 ;
	mc.stable=0 ;
	mc.dy=20 ;
	mc.dx=random(20)-10 ;
	mc.recall=true ;
}



/*-----------------------------------------------
                SPAWN D'UN BONUS
 ------------------------------------------------*/
_global.spawnBonus=function () {
  _global.spawnItem(1,true) ;
}



/*-----------------------------------------------
                SPAWN D'UNE RUCHE
 ------------------------------------------------*/
_global.spawnBadItem=function () {
  _global.spawnItem(2,true) ;
  _global.nbBads++ ;
}



/*-----------------------------------------------
                SPAWN D'UN ITEM
 ------------------------------------------------*/
_global.spawnItem=function (itemType,safePos) {
  var mc,d,i,noFreeze,notSafe ;

  d=_global.getd("_global.DEPTH_ITEM") ;
  attachMovie("item","item_"+d,d) ;
  mc=eval("item_"+d) ;
  noFreeze=0 ;
  if (safePos)
    // Recherche d'une position sûre (cad. qui ne collisionne pas avec un autre item)
    do {
      mc._x=random(440)+30 ;
      notSafe=false;
      for (i=0;i<_global.items.length;i++)
        if (Math.abs(_global.items[i]._x-mc._x)<25 and _global.items[i].type==1)
          notSafe=true ;
      noFreeze++ ;
    } while (notSafe and noFreeze<100) ;
  else
    mc._x=random(440)+30 ;

  mc._y=-10 ;
  mc.maxLength=_global.getItemMaxLength(mc._x) ;
  mc.type=itemType ;
  mc.gotoAndStop(itemType) ;

  mc.mul=1 ;
  mc.bounces=0 ;
  // Gros fruit en haut
  if (mc.maxLength<100 and itemType==1) {
    mc.mul=3 ;
    mc._xscale=160 ;
    mc._yscale=mc._xscale ;
  }

  // Gros fruit en haut
  if (itemType==2) {
    mc.mul=3 ;
  }

  mc.dy=0 ;
  mc.dx=random(5)+1 ;
  if (random(2)==0) mc.dx=-mc.dx ;

  mc.skin.stop() ;
  if (itemType==2) {
    mc.timeOut=_global.dureeRuche+getTimer() ;
    mc.activeBees=0 ;
  }
  else
    mc.timeOut=_global.dureeFruit+getTimer() ;

  mc.recall=false ;
  mc.stable=0 ;
  mc.kill=0 ;
  mc.crunch=0 ;
  mc.maxCrunch=4 ;

  // Point d'attache de la corde
  mc.attX=mc._x ;
  mc.attY=mc._y ;
  _global.items.push(mc) ;
}


/*-----------------------------------------------
               SPAWN D'UNE GUEPE
 ------------------------------------------------*/
_global.spawnBee=function (mcHome) {
  var mc,d ;

  if (mcHome.activeBees<1) {
    mcHome.activeBees++ ;

    d=_global.getd("_global.DEPTH_BAD") ;
    attachMovie("bee","bee_"+d,d) ;
    mc=eval("bee_"+d) ;
    mc.dx=mcHome.dx ;
    mc.dy=mcHome.dy ;
    if (pj._x>mcHome._x) mc._x=mcHome._x-20 ;
    if (pj._x<=mcHome._x) mc._x=mcHome._x+20 ;
    if (pj._y>mcHome._y) mc._y=mcHome._y-20 ;
    if (pj._y<=mcHome._y) mc._y=mcHome._y+20 ;
    mc._x+=random(20)-10 ;
    mc._y+=random(20)-10 ;
    mc._x+=_global.adjustTimer(mc.dx) ;
    mc._y+=_global.adjustTimer(mc.dy) ;

    mc.kill=false ;
    mc.backHomeCounter=0 ;
    mc.cible=pj ;
    mc.mcHome=mcHome ;

    mc.skin.stop() ;
    _global.bads.push(mc) ;
  }
}


/*-----------------------------------------------
               SPAWN D'UNE GUEPE
 ------------------------------------------------*/
_global.spawnFish=function () {
  var mc,d ;

  d=_global.getd("_global.DEPTH_BAD") ;
  attachMovie("fish","fish_"+d,d) ;
  mc=eval("fish_"+d) ;
  mc.dx=0 ;
  mc.dy=0 ;
  mc._y=random(25)+15+_global.yWater ;

  if (random(2)) {
    mc.dir=1 ;
    mc._x=-20 ;
    mc.targetX=0 ;
  }
  else {
    mc.dir=-1 ;
    mc._x=520 ;
    mc.targetX=500 ;
    mc._xscale=-mc._xscale ;
  }

  mc.active=false ;
  mc.checkPoint=0 ;
  mc.goTimer=0 ;
  mc.speed=0.85 ;

  mc.gotoAndStop("normal") ;

  _global.badsUW.push(mc) ;
}




/*-----------------------------------------------
      SPAWN D'UNE PAILLETTE DE TEMPS A AUTRE
 ------------------------------------------------*/
_global.spawnRandomFx=function() {
  if (_global.FPS>_global.seuilFPS) {
    if (_global.randomT(100)==0)
      _global.spawnBulle(random(440)+30,505) ;
  }
}



/*-----------------------------------------------
                SPAWN D'UNE DALLE
 ------------------------------------------------*/
_global.spawnTile=function (x) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_TILE") ;
  attachMovie("tile","tile_"+d,d) ;
  mc=eval("tile_"+d) ;
  mc._x=20+x*_global.tileWidth ;
  mc._y=-5;//_global.ySol ;
  mc.speed=0 ;
  mc.timeOut=500 ;
  _global.nbTiles++ ;
  _global.tiles[x]=mc ;
}



/*-----------------------------------------------
        SPAWN D'UN BONUS TOMBé A L'EAU
 ------------------------------------------------*/
_global.spawnUnderWaterItem=function (skin,x,y,scale) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_ITEM") ;
  attachMovie("itemUnderWater","itemUnderWater_"+d,d) ;
  mc=eval("itemUnderWater_"+d) ;
  mc._x=x ;
  mc._y=y ;
  mc.gotoAndStop(skin) ;
  mc._xscale=scale ;
  mc._yscale=scale ;
  mc.skin.gotoAndStop(999) ;
  mc.dy=(random(5)+5)/10 ;
  mc.generator=true ;
  _global.underWater.push(mc) ;
}



/*-----------------------------------------------
            SPAWN D'UNE BULLE D'AIR
 ------------------------------------------------*/
_global.spawnBulle=function (x,y) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_FX") ;
  attachMovie("bulle","bulle_"+d,d) ;
  mc=eval("bulle_"+d) ;
  mc._x=x ;
  mc._y=y ;
  mc.dy=-random(5)/10-1.2 ;
  mc._xscale=random(60)+40 ;
  mc._yscale=mc._xscale ;
  mc.generator=false ;
  _global.underWater.push(mc) ;
}



/*-----------------------------------------------
           SPAWN D'UN GIB SANGUINOLANT
 ------------------------------------------------*/
_global.spawnGib=function (x,y) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_FX") ;
  attachMovie("gib","gib_"+d,d) ;
  mc=eval("gib_"+d) ;
  mc._x=x ;
  mc._y=y ;
  mc.dx=(random(3)+1) * (random(2)*2-1) ;
  mc.dy=-random(6)-6 ;
  mc.fall=true;
  mc._rotation=random(360) ;
  mc._xscale=random(80)+20 ;
  mc._yscale=mc._xscale ;
  _global.fx.push(mc) ;
}



/*-----------------------------------------------
           SPAWN D'UNE GOUTTE D'EAU
 ------------------------------------------------*/
_global.spawnGoutte=function (x,y) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_FX") ;
  attachMovie("goutte","goutte_"+d,d) ;
  mc=eval("goutte_"+d) ;
  mc._x=x ;
  mc._y=y ;
  mc.dx=0 ;
  mc.dy=2 ;
  mc.fall=true;
  mc._xscale=random(60)+40 ;
  mc._yscale=mc._xscale ;
  _global.fx.push(mc) ;
}



/*-----------------------------------------------
           SPAWN D'UNE POP UP DE BONUS
 ------------------------------------------------*/
_global.spawnPopUpBonus=function (x,y,valeur,dy) {
  var mc,d ;

  d=_global.getd("_global.DEPTH_FX") ;
  attachMovie("popUpBonus","popUpBonus_"+d,d) ;
  mc=eval("popUpBonus_"+d) ;
  mc._x=x ;
  mc._y=y ;
  mc.dy=dy ;
  mc.fall=true ;
  mc.valeur=valeur ;
  mc.dontKill=true ;
  _global.fx.push(mc) ;
}



/*-----------------------------------------------
    RENVOIE L'ID D'UNE DALLE POUR UN X DONNé
 ------------------------------------------------*/
_global.getTileId=function(x) {
  return ( Math.floor((x-20)/_global.tileWidth) ) ;
}



/*-----------------------------------------------
   RENVOIE LE MC D'UNE DALLE POUR UN X DONNé
 ------------------------------------------------*/
_global.getTile=function(x) {
  return ( _global.tiles[_global.getTileId(x)] ) ;
}



/*-----------------------------------------------
    AJOUTE DES POINTS AU SCORE
 ------------------------------------------------*/
_global.addScore=function(valeur) {
  _global.score+=valeur ;
  compteur.valeur=_global.score ;
}



/*-----------------------------------------------
    RENVOIE UN ID DE COLONNE NE CONTENANT PAS
    DE TILE
 ------------------------------------------------*/
_global.getRandomFreeTileSlot=function() {
  var i ;
  i=-1 ;
  if (_global.nbTiles<6)
    do {
      i=random(6) ;
    } while (_global.tiles[i]!=undefined) ;
  return i ;
}



/*-----------------------------------------------
    RENVOIE UNE LONGUEUR DE CORDE POUR UN ITEM EN UN X DONNé
 ------------------------------------------------*/
_global.getItemMaxLength=function(x) {
  var maxLength, lmin,lran, nbTiles ;

  nbTiles=_global.nbTiles ;
  if (_global.getTile(x)==undefined) nbTiles-- ;

  lmin=266 - 41*nbTiles ;
  lran=41 * nbTiles ;

  maxLength=random(lran)+lmin ; // 250 +20
  return maxLength ;
}


/*-----------------------------------------------
   GESTION DU NIVEAU
 ------------------------------------------------*/
_global.nextLevel=function() {

  _global.levelTheorique++ ;
  // MC annonçant le passage du niveau
  var d ;
  d=_global.getd("_global.DEPTH_BAD") ;
  levelIndicator.removeMovieClip() ;
  attachMovie("levelIndicator","levelIndicator",d) ;
  levelIndicator._x=250 ;
  levelIndicator._y=0 ;
  levelIndicator.level=_global.levelTheorique ;

  // Evolution des objets présents en jeu selon le level
  if (_global.level<_global.levels.length-1) {
    _global.level++ ;


    if (_global.level==0)
      _global.spawnInfoBulle("Utilisez les <B>flèches</B> pour vous déplacer et <B>croquer les pommes</B> !") ;

    if (_global.level<_global.levels.length) {
      if (_global.levels[_global.level].tiles) {
        _global.spawnTile(_global.getRandomFreeTileSlot());
        if (_global.nbTiles==1)
          _global.spawnInfoBulle("Vous pouvez <B>soulever</B> une dalle en vous plaçant <B>en dessous d'elle</B> et en appuyant sur <B>ESPACE</B> !") ;
      }
      if (_global.levels[_global.level].bonus)
        _global.spawnBonus() ;
      if (_global.levels[_global.level].bads) {
        _global.spawnBadItem() ;
        if (_global.nbBads==1)
          _global.spawnInfoBulle("Attention aux <B>ruches</B> ! Les abeilles peuvent vous <B>assomer</B> pour quelques secondes !") ;
      }
    }
  }
}


/*-----------------------------------------------
               SPAWN D'UNE GUEPE
 ------------------------------------------------*/
_global.spawnInfoBulle=function (chaineParam) {
  if (_global.helpOn) {
    var d ;
    MCinfoBulle.removeMovieClip() ;
    d=_global.getd("_global.DEPTH_TOP") ;
    attachMovie("infoBulle","MCinfoBulle",d) ;
    MCinfoBulle._x=250 ;
    MCinfoBulle._y=160 ;
    MCinfoBulle.txt=chaineParam ;
    _global.infoBulleTimeOut=getTimer()+8000 ;
  }
}


/*-----------------------------------------------
   CLEAN-EM-ALL !!!
 ------------------------------------------------*/
_global.cleanAll=function() {
  var i;

  mcLines.clear() ; // Lianes

  while (_global.items.length) {
    _global.items[0].removeMovieClip() ;
    _global.items.splice(0,1) ;
  }
  while (_global.tiles.length) {
    _global.tiles[0].removeMovieClip() ;
    _global.tiles.splice(0,1) ;
  }
  while (_global.bads.length) {
    _global.bads[0].removeMovieClip() ;
    _global.bads.splice(0,1) ;
  }
  while (_global.badsUW.length) {
    _global.badsUW[0].removeMovieClip() ;
    _global.badsUW.splice(0,1) ;
  }

  while (_global.underWater.length) {
    _global.underWater[0].removeMovieClip() ;
    _global.underWater.splice(0,1) ;
  }
  while (_global.fx.length) {
    _global.fx[0].removeMovieClip() ;
    _global.fx.splice(0,1) ;
  }

  // MCs divers
  MCinfoBulle.removeMovieClip() ;
  maskWater.removeMovieClip() ;
  compteur.removeMovieClip() ;
  feuillage.removeMovieClip() ;
  mcLines.removeMovieClip() ;
  jauge.removeMovieClip() ;
  pj.removeMovieClip() ;
  pjUW.removeMovieClip() ;
  levelIndicator.removeMovieClip() ;
  dunkIndicator.removeMovieClip() ;
}



/*-----------------------------------------------
   CREE LES MCs POUR LES PISTES AUDIOS
 ------------------------------------------------*/
initMusic=function() {
	this.createEmptyMovieClip("audioMC",10) ;
	audioMC.createEmptyMovieClip("soundMC",20) ;
	audioMC.createEmptyMovieClip("musicMC",10) ;
	sounds=new Sound(audioMC.soundMC);
	music=new Sound(audioMC.musicMC);
}



/*-----------------------------------------------
   STOPPE LA MUSIQUE
 ------------------------------------------------*/
_global.stopMusic=function() {
	music.stop() ;
}



/*-----------------------------------------------
   COMMENCE LA MUSIQUE (AVEC INTRO)
 ------------------------------------------------*/
_global.startMusic=function() {
	music.stop() ;
	music.attachSound("musicIntro") ;
	music.onSoundComplete =function() {
		music.attachSound("musicLoop") ;
		music.start(0,999) ;
	}
	music.start(0,1) ;
}


/*-----------------------------------------------
   MET A JOUR UN MC DE DECOR EN FONCTION DE L'HEURE
 ------------------------------------------------*/
_global.updateBackground=function(mc) {
  var now, heure ;
  now=new Date() ;
  heure=now.getHours() ;

  // Jour
  if (heure>=8 and heure<=18) mc.gotoAndStop(1) ;
  // Nuit
  if (heure>18 or heure<8) mc.gotoAndStop(2) ;
}
