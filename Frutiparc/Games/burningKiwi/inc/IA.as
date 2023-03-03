
/*-----------------------------------------------
    GESTIONS DES IAs
 ------------------------------------------------*/

function moveIA() {
  var i ;

//  for (i=1;i<cars.length;i++) {
//    carIA = cars[i] ;
//    gdebug(i+":"+
//      " spd="+(Math.round(carIA.speed*100)/100) +
//      " max="+(Math.round(carIA.currentMaxSpeed*100)/100) +
//      " statMax="+(Math.round(carIA.statMaxSpeed*100)/100) +
//      ""
//    ) ;
//  }

  for (i=1;i<cars.length;i++) {
    carIA = cars[i] ;

    // BUG: currentMaxSpeed foireux, origine inconnue
    if ( carIA.currentMaxSpeed < carIA.statMaxSpeed ) {
      carIA.currentMaxSpeed = carIA.statMaxSpeed
//      _parent.build = "CORRECTED for IA:"+i ;
    }

    // Checkpoint
    testCheckPoints( i ) ;

    if ( carIA.preImmune>0 ) {
      carIA.preImmune -= gtmod ;
      if ( carIA.preImmune <= 0 )
        carIA.vs.immuneHit = baseImmuneHit ;
    }

    if ( carIA.vs.immuneHit>0 ) {
      carIA.vs.immuneHit -= gtmod ;
      if ( carIA.vs.immuneHit < 0 )
        carIA.vs.immuneHit = 0 ;
    }

    // IA: hit-tests avec les autres véhicules
//    for (i=0;i<cars.length;i++)
//      if ( carIA!=cars[i] )
//        testHitCar( carIA, cars[i] ) ;
    testHitCar( carIA, cars[0] ) ;



    // IA: aller vers le checkpoint
    if ( carIA.panic<=0 && !carIA.finished ) {
      rotationVitesseLente=Math.max(0, carIA.statRot-(carIA.speed*5)*0.7) ;
      rotationVitesseRapide=Math.max(0,carIA.speed*0.52) ;
      angCPrad = Math.atan2( carIA.y-carIA.nextY , carIA.x-carIA.nextX ) ;
      angCP = angCPrad/(Math.PI/180)-180 ;
      ecart = getAngle( ( angCP-carIA._rotation ) ) ;
      if (ecart>=-15 && ecart<=15)
        carIA._rotation = angCP ;
      else
        if (ecart<-3) {
          // Rotation gauche
          carIA._rotation -= gtmod * ( Math.max(0,carIA.statRotTemp-rotationVitesseRapide) ) * carIA.rotationBoost ;
          carIA.speed*=Math.pow(carIA.statTurning, gtmod) ;
        }
        if (ecart>3) {
          // Rotation droite
          carIA._rotation += gtmod * ( Math.max(0,carIA.statRotTemp-rotationVitesseRapide) ) * carIA.rotationBoost ;
          carIA.speed*=Math.pow(carIA.statTurning, gtmod) ;
        }

      // L'algo suivant permet de caler la voiture sur l'angle à atteindre si elle passe "au dessus"
      // avec sa dernière rotation
      newEcart = getAngle( ( angCP-carIA._rotation ) ) ;
      if (newEcart!=0) {
        signe = ecart/newEcart ;
        if ( signe<0 )
          carIA._rotation = angCP ;
      }
    }


    // IA: utilisation de nitro
    if ( carIA.vs.kiwis && carIA.nitroTimer == 0 ) {
      // Tirage aléatoire
      if ( randomT(40*1/carIA.nitroAgg) == 0 ) {
        // si on ne roule pas vers un CP avec limitation de vitesse
        if ( CP[track.id][carIA.currentCP+1].maxSpeed >= 10 ) {
          // si le joueur a mis un gros vent à cette IA
          if ( carPJ.totalCP - carIA.totalCP > carIA.CPdistanceTolerance && activeIAKiwis<=maxIAKiwis ) {
            carIA.vs.kiwis -- ;
            activeIAKiwis ++ ;
            carIA.nitroTimer = baseNitroTimer*1.5 ;
//            carIA.maxSpeedBoost = 1.8 ;
            carIA.currentMaxSpeed = nitroMaxSpeedIA ;
            carIA.rotationBoost = 1.5 ;
//            carIA.speed *= Math.pow( 1.1, gtmod ) ;
            startBoostAnim(carIA) ;
          }
        }
      }
    }

    if ( carIA.nitroTimer ) {
      carIA.nitroTimer -= gtmod ;
      if ( carIA.nitroTimer <= 0 ) {
        carIA.nitroTimer = 0 ;
        activeIAKiwis -- ;
        carIA.currentMaxSpeed = carIA.statMaxSpeed ;
        carIA.rotationBoost = 1 ;
        stopBoostAnim(carIA) ;
      }
    }


    // IA: accélération
    if ( !carIA.finished )
      if (Math.abs(ecart)<45 || carIA.speed<0.5)
        carIA.speed += gtmod * ( ((carIA.currentMaxSpeed-carIA.speed)/(carIA.currentMaxSpeed+15))*carIA.statAccel) ;

    // IA: freinage
    if (Math.abs(ecart)>55 || carIA.finished )
      carIA.speed *= Math.pow( carIA.statBrake, gtmod ) ;


    // Dérapage en fin de course
    if ( carIA.finished ) {
      // Init du dérapage
      if ( carIA.derapage == 0 ) {
        carIA.targetRotation = carIA._rotation + (90+random(50)) * ( random(2)*2-1 ) ;
        if ( carIA.targetRotation <= -180 ) carIA.targetRotation = 360 - Math.abs(carIA.targetRotation) ;
        if ( carIA.targetRotation >= 180 ) carIA.targetRotation = carIA.targetRotation - 360 ;
        carIA.derapage = 1 ;
        carIA.oldRotation = carIA._rotation ;
      }
      // On "dérape" jusqu'à la rotation désirée
      if ( carIA.derapage == 1 ) {
        carIA._rotation += gtmod * ( (carIA.targetRotation - carIA._rotation)/20 ) ;
        if ( Math.abs(carIA.targetRotation-carIA._rotation) <= 10*gtmod || Math.abs(carIA.targetRotation-carIA._rotation) > 160 )
          carIA.derapage = 2 ;
        // Fumée
        if ( gameQuality >= MEDIUM )
          spawnSmoke ("smokeSkid", carIA.x,carIA.y, random(80)+20, preSinA*carIA.speedA*1.5*((random(4)+6)/10), carIA.speedA*100/10, 5, false) ;
      }
    }


    // Calcul des vitesses
    carIA.speed *= Math.pow( roadFriction, gtmod) ;
    carIA.speed = Math.min(carIA.speed, carIA.currentMaxSpeed) ;

    // IA: Freinage dans les zones dangeureuses
    if ( !carIA.finished )
      if (carIA.speed > CP[track.id][carIA.currentCP].maxSpeed) {
        carIA.speed *= Math.pow(0.85, gtmod) ;
      }

    carIA.realSpeed = carIA.speed ;




    ratio=Math.pow(0.9, gtmod) ;
    carIA.speedA=carIA.speedA*ratio+carIA.speed*(1-ratio) ;
    ecart=getAngle(carIA._rotation-carIA.accelAng) ;
    pi180 = (Math.PI/180) ;
    if ( carIA.derapage ) {
      carIA.accelAng = getAngle (carIA.accelAng + gtmod * (0.005*ecart*2)) ;
      rotRad = pi180 * carIA.oldRotation ;
    }
    else {
      carIA.accelAng = getAngle (carIA.accelAng + gtmod * (0.1*ecart*2)) ;
      rotRad = pi180 * carIA._rotation ;
    }

    dx = Math.cos(rotRad)*carIA.speed ;
    dy = Math.sin(rotRad)*carIA.speed ;

    rotRadA = pi180 * carIA.accelAng ;
    dxA = Math.cos(rotRadA)*carIA.speedA ;
    dyA = Math.sin(rotRadA)*carIA.speedA ;

    dxTotal = ( carIA.statGrip*dx + (1-carIA.statGrip)*dxA ) ;
    dyTotal = ( carIA.statGrip*dy + (1-carIA.statGrip)*dyA ) ;

    dxTotal = gtmod * dxTotal ;
    dyTotal = gtmod * dyTotal ;
    carIA.dx = dxTotal ;
    carIA.dy = dyTotal ;
    carIA.x += dxTotal ;
    carIA.y += dyTotal ;
    carIA._x = carIA.x ;
    carIA._y = carIA.y ;
    carShadows[i]._x = carIA._x + shadowShift ;
    carShadows[i]._y = carIA._y + shadowShift ;
    if ( carIA.speed > 7 ) {
      var randomShift = -random(2) ;
      carShadows[i]._x += randomShift ;
      carShadows[i]._y += randomShift ;
    }
    carShadows[i]._rotation = carIA._rotation ;

    // Baisse du taux de "panic"
    if ( carIA.panic > 0 ) {
      carIA.panic -= gtmod ;
      if ( carIA.panic < 0 )
        carIA.panic = 0 ;
    }

  if (carIA.spawnImmune>0) carIA.spawnImmune-- ;

  }
}
