mainProgram=function() {

  mainTimer() ;
  // Mise à jour du décor selon l'heure de la journée
  now=new Date() ;
  if (now.getHours()!=lastHour) {
  	_global.updateBackground(decor) ;
  	lastHour=now.getHours() ;
  }
  
  // TIMERS
  // info-bulle
  if (_global.infoBulleTimeOut!=-1 and getTimer()>_global.infoBulleTimeOut) {
  	MCinfoBulle.play() ;
  	_global.infoBulleTimeOut=-1 ;
  }
  // levels
  if (getTimer()>timerLevel) {
  	timerLevel=getTimer()+_global.dureeLevel ;
  	_global.nextLevel() ;
  }
  // poissons
  if (getTimer()>timerSpawnFish and pj._y>=_global.yWater) {
  	timerSpawnFish=getTimer()+_global.levels[_global.level].fish ;
  	_global.spawnFish() ;
  }
  
  
  // Ecran de game over
  if (gameOverTimeOut!=-1 and getTimer()>=gameOverTimeOut) {
  	gotoAndPlay("gameOver") ;
  }
  
  // Gestion de tous les objets
  if (!_global.freezeAll) {
  	_global.moveTiles() ;
  	_global.moveUnderWaterItems() ;
  	_global.moveFx() ;
  	_global.spawnRandomFx() ;
  }
  
  
  // ASPHYXIE
  if (_global.air<=0 and  !pj.kill) {
  	pj.kill=true ;
  	typeMort=1 ;
  	if (_global.soundOn) _global.playSound("sonPiqure") ;
  }
  
  // MORT
  if (pj.kill and !pj.killOnce) {
  	gameOverTimeOut=getTimer()+4000 ;
  	pj.killOnce=true ;
  	pj._visible=false ;
  	pjUW._visible=false ;
  	for (i=0;i<15;i++) 
  		_global.spawnGib(pj._x,pj._y) ;
  }
  
  
  
  
  if (!pj.kill and !_global.freezeAll) {
  	if (pj.freeze) {
  		if (pj.phase!=8) {
  			pj.phase=8 ;
  			pj.skin.gotoAndPlay("freeze") ;
  		}
  		if (getTimer()>pj.freezeTimer) 
  			pj.freeze=false ;
  	}
  	else {
  		
  		
  	/*** DEBUG ONLY ***
  		if (Key.isDown(Key.ENTER) and !freezeEnter) {
  			freezeEnter=true ;
  			_global.nextLevel() ;
  		}
  		if (freezeEnter and !Key.isDown(Key.ENTER)) 
  			freezeEnter=false ;
  			
  		if (Key.isDown(Key.END)) {
  			var d,mc ;
  			d=getd("_global.DEPTH_PJ") ;
  			attachMovie("bulle","lala"+d,d) ;
  			mc=eval("lala"+d) ;
  			nbDebug++ ;
  			xdeb+=10 ;
  			if (xdeb>450) {ydeb+=10;xdeb=50;}
  			mc._x=xdeb;
  			mc._y=ydeb;
  			_root.txt=nbDebug+" @ depth "+d ;
  		}
  	/*** DEBUG ONLY ***/
  	
  	
  	
  		// DEPLACEMENT
  		inWater=false ;
  		if (pj._y>=_global.yWater) {
  			poussee=_global.pousseeWater ;
  			inWater=true ;
  		}
  		else {
  			timerSpawnFish=getTimer()+_global.levels[_global.level].fish ;
  			poussee=_global.poussee ;
  		}
  			
  		if (Key.isDown(Key.UP) and inWater) {
  			pj.stable=false ;
  			jumpLocked=false ;
  			pj.dy-=_global.adjustTimer(poussee) ;
  		}
  		
  		if (!Key.isDown(Key.UP)) {
  			jumpLocked=false ;
  			pj.highJump=false ;
  		}
  		
  		if (Key.isDown(Key.UP) and !inWater and !jumpLocked and (pj.stable or oldInWater) ) {
  			inWater=false ;
  			jumpLocked=true ;
  			pj.stable=false ;
  			pj.tileLocked=false ;
  			pj.dy=pousseeSaut ;
  			pj.highJump=true ;
  			if (oldInWater) {
  				if (_global.soundOn) _global.playSound("sonSautUW"); 
  			}
  			else
  				if (_global.soundOn) _global.playSound("sonSaut"); 
  		}
  
  		oldInWater=inWater ;
  		
  		pj.highJump=false ;
  		if (Key.isDown(Key.UP) and !inWater and !pj.stable and pj.dy<0) {
  			pj.highJump=true ;
  		}
  		
  		
  		if (Key.isDown(Key.DOWN)) {
  			pj.dy+=_global.adjustTimer(poussee) ;
  		}
  		
  		if (Key.isDown(Key.LEFT)) {
  			pj.dx-=_global.adjustTimer(poussee) ;
  			if (!inWater and pj.phase!=2) {
  				pj.skin.gotoAndPlay("marche") ;
  				pj.phase=2 ;
  			}
  			if (inWater and pj.phase!=6) {
  				pj.skin.gotoAndPlay("marcheUW") ;
  				pjUW.skin.gotoAndPlay("marcheUW") ;
  				pj.phase=6 ;
  			}
  		}
  		
  		if (Key.isDown(Key.RIGHT)) {
  			pj.dx+=_global.adjustTimer(poussee) ;
  			if (!inWater and pj.phase!=2) {
  				pj.skin.gotoAndPlay("marche") ;
  				pj.phase=2 ;
  			}
  			if (inWater and pj.phase!=6) {
  				pj.skin.gotoAndPlay("marcheUW") ;
  				pjUW.skin.gotoAndPlay("marcheUW") ;
  				pj.phase=6;
  			}
  		}
  
  		if (pj.phase==9 and pj.stable) {
  			pj.phase=-1 ;
  		}
  
  		if (pj.phase!=1 and pj.phase!=9 and !inWater and !Key.isDown(Key.LEFT) and !Key.isDown(Key.RIGHT)) {
  			pj.phase=1 ;
  			pj.skin.gotoAndStop("arret") ;
  			pjUW.skin.gotoAndStop("arret") ;
  		}
  	
  		if (pj.phase!=5 and inWater and !Key.isDown(Key.LEFT) and !Key.isDown(Key.RIGHT)) {
  			pj.phase=5 ;
  			pj.skin.gotoAndPlay("arretUW") ;
  			pjUW.skin.gotoAndPlay("arretUW") ;
  		}
  	
  		
  		// TIR
  		if (Key.isDown(Key.SPACE) and inWater and _global.getTile(pj._x)!=undefined) {
  			pj.skin.gotoAndPlay("tir") ;
  			pjUW.skin.gotoAndPlay("tir") ;
  			pj.phase=7 ;
  			if (!tir) {
  				tir=true ;
  				pj.tir.gotoAndPlay("start") ;
  				pjUW.tir.gotoAndPlay("start") ;
  			}
  		}
  		if ((!Key.isDown(Key.SPACE) or !inWater or _global.getTile(pj._x)==undefined) and tir) {
  			tir=false ;
  			pj.tir.gotoAndPlay("end") ;
  			pjUW.tir.gotoAndPlay("end") ;
  		}
  	}
  	
  	// Montée d'une dalle
  	if (tir) {
  		if (_global.getTile(pj._x)._y > _global.tileYmin) {
  			var tile=_global.getTile(pj._x) ;
  			tile._y-=_global.adjustTimer(_global.goUpSpeed) ;
  			tile.freeze=true ;
  		}
  	}
  	
  	// Scale du tir
  	if (_global.getTile(pj._x)!=undefined)
  		pj.tir._height = pj._y - _global.getTile(pj._x)._y-9 ;
  	else 
  		pj.tir.height-- ;
  	pjUW.tir._height = pj._y - _global.getTile(pj._x)._y-9 ;
  	
  	// Gestion de l'air 
  	if (!inWater) {
  		_global.air-=_global.adjustTimer(_global.perteAir) ;
  		jauge.masque._xscale=_global.air ;
  	}
  	else {
  		if (_global.air<100) {
  			_global.air+=_global.adjustTimer(_global.recupAir) ;
  			if (_global.air>100) _global.air=100 ;
  			jauge.masque._xscale=_global.air ;
  		}
  	}
  	
  	// Friction et mouvement du joueur
  	_global.movePJ() ;
  	pjUW._x=pj._x ;
  	pjUW._y=pj._y ;
  }
  
  if (!_global.freezeAll) {
  	_global.moveItems() ;
  	_global.moveBads() ;
  	_global.moveBadsUW() ;
  }
  
}