/*------------------------------------------------- 
    FPSv3:
    Timer tool
    
  Copyright (c) 2001, Motion-Twin
  
  * Flash MX compliance
  Copyright (c) 2002, Motion-Twin

  * No more intern MC needed, Bug corrections
  Copyright (c) 2003, Motion-Twin
  
  
  Usage: 
    - execute initTimer(normalFPS) once, giving 
    "normalFPS" as the optimal FPS (usually 32)
    - execute mainTimer() within main program 
    loop
    - timer factor is in _global.timerFactor, or 
    local tmod
    - fps value is in _global.FPS and _global.fps
    
  For v2 compliance, remove the old Timer MC, and
  add the initTimer(32) command before the loop,
  and add the mainTimer() within the loop(s).
  
-------------------------------------------------*/

  /*******************************************  
                INITIALISATIONS
  *******************************************/
  averageTimer=true ;
  // Constantes
  _global.TIMER_VERSION = "3.03" ;
  
  
  /*******************************************  
                 INIT DU TIMER
  *******************************************/
  _global.initTimer = function(normalFPS) {
  	_global.normalFPS=normalFPS ;
  	_global.lagFactor=normalFPS ;
  	_global.oldTimer=getTimer();
  };
  
  
  /*******************************************  
                BOUCLE PRINCIPALE
  *******************************************/
  mainTimer = function() {
  	var clag ;
  	clag=getTimer()-_global.oldTimer;
  	_global.oldTimer=getTimer();
  	
  	if (averageTimer) {
    	_global.lagFactor=(0.97*_global.lagFactor)+(clag*0.03);
    }
    else {
    	_global.lagFactor=clag ;
    }
    
  	_global.timerFactor=(_global.lagFactor*_global.normalFPS)/1000;
  	_global.timerFactorInv=1/_global.timerFactor ;
  	_global.FPS=_global.timerFactorInv*_global.normalFPS ;
  	setTimerVarAliases() ;
  }
  
  
  /*******************************************  
        Tirage al�atoire ajust� au timer
          
   Usage: nombre = randomT(intervalle) 
  *******************************************/
  _global.randomT = function(valeur) {
  	return ( random(math.round(valeur*_global.timerFactorInv) ) ) ;
  };
  
  
  /*******************************************  
          Ajuste une valeur au timer
          
   Usage: nouvelle = adjust_timer(valeur) 
  *******************************************/
  _global.adjustTimer = function(valeur) {
  	return ( _global.timerFactor*valeur ) ;
  };
  
  
  /*******************************************  
          Ajuste une valeur au timer
               (facteur inverse)
  *******************************************/
  _global.adjustTimerInv= function(valeur) {
  	return ( _global.timerFactorInv*valeur) ;
  };


  /*******************************************  
          Ajuste un FACTEUR au timer
  *******************************************/
  _global.adjustTimerFact= function(valeur) {
  	return ( Math.pow(valeur,_global.timerFactor) ) ;
  };


  /*******************************************  
          Ajuste un FACTEUR au timer
            (inverse, racine ni�me)
  *******************************************/
  _global.adjustTimerFactInv= function(valeur) {
  	return ( Math.pow(valeur,_global.timerFactorInv) ) ;
  };
  
  
  /*******************************************  
            Synchronisation sur le timer
            
   Si le FPS est trop �lev�, permet d'�viter 
   qu'un op�ration � effectuer 1 fois/frame 
   en 24fps soit effectu�e 1 fois/frame en 
   60fps...
   
   Usage: if ( synchro_timer() ) { action }
  *******************************************/
  _global.synchroTimer = function() {
  	var autorise=0 ;
  	if (getTimer()-_global.oldTimer >= _global.adjustTimer(50)) {
  		_global.oldTimer=getTimer() ;
  		autorise=1 ;
  	}
  	return autorise ;
  };


  /*******************************************  
     Permet de d�finir le flag averageTimer
     
     � TRUE, ce flag fait que la valeur du
     timer est pond�r�e, et qu'aucun saut 
     brusque d� � un lag ne provoque de saut
     de timer. Mis � TRUE par d�faut.
  *******************************************/
  setAverageTimer=function(booleen) {
    averageTimer=booleen ;
  }


  /*******************************************  
                     ALIAS
      Pour la compatibilit� ascendante
  *******************************************/
  // Appel� � chaque tour pour tenir les anciennes variables � jour
  setTimerVarAliases=function() {
    frict=Math.pow(friction,_global.timerFactor) ;
    tmod=_global.timerFactor ;
    _global.fps = _global.FPS ;
  }
  
  // Pour FPS-v2
  _global.adjust_timer = function(valeur) { _global.adjustTimer(valeur); }
  _global.adjust_timer_inverse = function(valeur) { _global.adjustTimerInv(valeur); }
  _global.adjust_timer_facteur = function(valeur) { _global.adjustTimerFact(valeur); }
  _global.synchro_timer = function() { _global.synchroTimer(); }
  _global.startExport = function() { } ;  // obsol�te
