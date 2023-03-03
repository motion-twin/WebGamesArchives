/*-----------------------------------------------
    EFFACE LES MCs DES CHECKPOINTS
 ------------------------------------------------*/
clearAllCP=function() {
  for (i=0 ; i<CP[track.id].length ; i++) {
    mc = track["spotCP_"+i] ;
    mc.removeMovieClip() ;
  }
}


/*-----------------------------------------------
    AFFICHE LES CHECKPOINTS SOUS FORME DE MCs
 ------------------------------------------------*/
viewAllCP=function() {
  for (i=0 ; i<CP[track.id].length ; i++) {
    mc = track["spotCP_"+i] ;
    mc.removeMovieClip() ;
    d = track.calcDepth(DP_DEBUG) ;
    track.attachMovie("spotCP","spotCP_"+i,d) ;
    mc = track["spotCP_"+i] ;
    mc._x=CP[track.id][i].x ;
    mc._y=CP[track.id][i].y ;
    mc.barre._width = (CP[track.id][i].dist*2) ;
    mc.rayon._xscale = distanceCP*10 ;
    if ( CP[track.id][i].distanceCheckFactor )
      mc.rayon._xscale *= CP[track.id][i].distanceCheckFactor ;
    mc.rayon._yscale = mc.rayon._xscale ;
    mc.rayonIA._xscale = distanceCPIA*10 ;
    mc.rayonIA._yscale = mc.rayonIA._xscale ;
    mc.barre._rotation = getAngle(CP[track.id][i].ang+90) ;
    mc.dist = CP[track.id][i].dist ;
    mc.maxSpeed = CP[track.id][i].maxSpeed ;
    mc.id=i ;
  }
}


/*-----------------------------------------------
    AFFICHE LA LISTE DES CHECKPOINTS 
 ------------------------------------------------*/
listAllCP=function() {
  for (i=0 ; i<CP[track.id].length ; i++) {
    cpTmp = CP[track.id][i] ;
    if ( cpTmp.distanceCheckFactor != undefined && cpTmp.distanceCheckFactor != 1 )
      traceTxt("{ x:"+cpTmp.x+", y:"+cpTmp.y+", ang:"+cpTmp.ang+", dist:"+cpTmp.dist+", maxSpeed:"+cpTmp.maxSpeed+", distanceCheckFactor:"+cpTmp.distanceCheckFactor+" }, //"+i) ;
    else
      traceTxt("{ x:"+cpTmp.x+", y:"+cpTmp.y+", ang:"+cpTmp.ang+", dist:"+cpTmp.dist+", maxSpeed:"+cpTmp.maxSpeed+" }, //"+i) ;
  }
}


/*-----------------------------------------------
    AFFICHE LES CHECKPOINTS SOUS FORME DE MCs
 ------------------------------------------------*/
getClosestCP=function(x,y) {
  bestDist=9999 ;
  closestId=0 ;
  i=0 ;
  do {
    dist=Math.sqrt( Math.pow(x-CP[track.id][i].x, 2) + Math.pow(y-CP[track.id][i].y, 2) ) ;
    if (dist<bestDist) {
      closestId=i ;
      bestDist=dist ;
    }
    i++ ;
  } while (i<CP[track.id].length) ;
  
  return closestId ;
}



/*-----------------------------------------------
    CONTRÔLES DE L'ÉDITEUR
 ------------------------------------------------*/
getEditorControls = function() {
  if (!Key.isDown(67)) lockCoord=false ; // C: voir coordonnées
  if (Key.isDown(67) and !lockCoord) {
    _root.traceur+="{ x:"+Math.round(carPJ.x)+", y:"+Math.round(carPJ.y)+", ang:"+Math.round(carPJ._rotation)+", dist:? , modMaxSpeed:1 },<BR>" ;
    lockCoord=true ;
  }
  if (!Key.isDown(Key.INSERT)) lockAdd=false ; // INSERT: ajout
  if (Key.isDown(Key.INSERT) and !lockAdd) {
    clearAllCP() ;
    CP[track.id].push( { x:Math.round(carPJ.x), y:Math.round(carPJ.y), ang:Math.round(carPJ._rotation), dist:0, maxSpeed:99} ) ;
    viewAllCP() ;
    traceTxt("added") ;
    lockAdd=true ;
  }
  if (!Key.isDown(Key.DELETEKEY)) lockDel=false ; // DEL: suppression
  if (Key.isDown(Key.DELETEKEY) and !lockDel) {
    clearAllCP() ;
    CP[track.id].splice( getClosestCP(carPJ.x, carPJ.y), 1 ) ;
    traceTxt("deleted #"+getClosestCP(carPJ.x, carPJ.y)) ;
    viewAllCP() ;
    lockDel=true ;
  }
  if (!Key.isDown(Key.ENTER)) lockView=false ; // ENTER: listing complet
  if (Key.isDown(Key.ENTER) and !lockView) {
    listAllCP() ;
    lockView=true ;
  }
  if (Key.isDown(107)) { // PLUS: augmente la distance
    clearAllCP() ;
    CP[track.id][getClosestCP(carPJ.x, carPJ.y)].dist++ ;
    viewAllCP() ;
  }
  if (Key.isDown(109)) { // MOINS: réduit la distance
    clearAllCP() ;
    CP[track.id][getClosestCP(carPJ.x, carPJ.y)].dist-- ;
    viewAllCP() ;
  }
  if (Key.isDown(Key.PGUP)) { // PAGE UP: augmente la vitesse max
    clearAllCP() ;
    cpTmp=CP[track.id][getClosestCP(carPJ.x, carPJ.y)] ;
    if (cpTmp.maxSpeed>25) 
      cpTmp.maxSpeed=99 ;
    else
      cpTmp.maxSpeed++ ;
    viewAllCP() ;
  }
  if (Key.isDown(Key.PGDN)) { // PAGE DOWN: réduit la vitesse max
    clearAllCP() ;
    cpTmp=CP[track.id][getClosestCP(carPJ.x, carPJ.y)] ;
    if (cpTmp.maxSpeed==99) cpTmp.maxSpeed=25 ;
    cpTmp.maxSpeed-- ;
    viewAllCP() ;
  }
  
  if (Key.isDown(Key.HOME)) { // HOME: augmente la distance PJ
    clearAllCP() ;
    cpTmp=CP[track.id][getClosestCP(carPJ.x, carPJ.y)] ;
    if ( cpTmp.distanceCheckFactor == undefined ) 
      cpTmp.distanceCheckFactor = 1 ;
    cpTmp.distanceCheckFactor += 0.1 ;
    viewAllCP() ;
  }
  if (Key.isDown(Key.END)) { // END: réduit la distance PJ
    clearAllCP() ;
    cpTmp=CP[track.id][getClosestCP(carPJ.x, carPJ.y)] ;
    if ( cpTmp.distanceCheckFactor == undefined ) 
      cpTmp.distanceCheckFactor = 1 ;
    cpTmp.distanceCheckFactor -= 0.1 ;
    if (cpTmp.distanceCheckFactor<1) 
      cpTmp.maxSpeed=1 ;
    viewAllCP() ;
  }
}


