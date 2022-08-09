import swapou2.Data ;

class swapou2.Particules {

	public var fxList ;

	var depthMan ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function Particules(depth_m : asml.DepthManager ) {
		depthMan = depth_m;
		fxList = new Array() ;
	}


	/*------------------------------------------------------------------------
	ATTACHE UNE ANIM INSTANTANÉE
	------------------------------------------------------------------------*/
	function attachFx( link, x,y, dp ) {
		var mc ;

		mc = Std.cast( depthMan.attach(link,dp) ) ;

		mc._x = x ;
		mc._y = y ;
		mc.stop() ;

		mc.frame = 0 ;
		mc.managers = new Array() ;
		mc.managers.push( animManager ) ;
		mc.animMode = Data.FORWARD ;
		fxList.push(mc) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	DÉFINI LE MODE DE LECTURE D'UNE ANIM
	------------------------------------------------------------------------*/
	function setAnimMode( mc, mode ) {
		mc.animMode = mode ;
		switch ( mc.animMode ) {
		case Data.BACKWARD :
			mc.gotoAndStop(mc._totalframes) ;
			break ;
		}
	}


	/*------------------------------------------------------------------------
	DESTRUCTION D'UN FRUIT
	------------------------------------------------------------------------*/
	function explodeFruit( x,y ) {
		var total = Data.FX_FRUIT_EXPLOSION ;
		if ( Data.lod == Data.MEDIUM )  total = Math.round(total/2) ;
		if ( Data.lod == Data.LOW )     return ;
		for ( var i=0;i<total;i++) {
			var mc = generate( x+Data.FRUIT_WIDTH/2, y+Data.FRUIT_HEIGHT/2, 1 ) ;
		}

	}



	/*------------------------------------------------------------------------
	DESTRUCTION D'UN FRUIT MÉTALLIQUE
	------------------------------------------------------------------------*/
	function explodeMetal( x,y ) {
		var total = Data.FX_METAL_EXPLOSION ;
		if ( Data.lod == Data.MEDIUM )  total = Math.round(total/2) ;
		if ( Data.lod == Data.LOW )     return ;
		for ( var i=0;i<total;i++)
			generate( x+Data.FRUIT_WIDTH/2, y+Data.FRUIT_HEIGHT/2, random(3)+4 ) ;
	}



	/*------------------------------------------------------------------------
	DESTRUCTION D'UN FRUIT MÉTALLIQUE
	------------------------------------------------------------------------*/
	function explodeFrozen( x,y ) {
		var total = Data.FX_METAL_EXPLOSION ;
		if ( Data.lod == Data.MEDIUM )  total = Math.round(total/2) ;
		if ( Data.lod == Data.LOW )     return ;
		for ( var i=0;i<total;i++)
			generate( x+Data.FRUIT_WIDTH/2, y+Data.FRUIT_HEIGHT/2, random(3)+7 ) ;
	}



	/*------------------------------------------------------------------------
	DESTRUCTION D'UNE ÉTOILE DE SUPER POUVOIR
	------------------------------------------------------------------------*/
	function explodeStar( x,y ) {
		var total = Data.FX_STAR_EXPLOSION ;
		if ( Data.lod == Data.MEDIUM )  total = Math.round(total/2) ;
		if ( Data.lod == Data.LOW )     return ;
		for ( var i=0;i<total;i++)
			generate( x, y, random(2)+2 ) ;
	}

	/*------------------------------------------------------------------------
	EXPLOSION IMPORTANTE PROJETÉE SELON UN DX,DY DONNÉ
	------------------------------------------------------------------------*/
	function heavyExplosion(x,y,dx,dy) {
		var total = Math.round(Data.FX_STAR_EXPLOSION*2.5) ;
		if ( Data.lod == Data.MEDIUM )  total = Math.round(total/2) ;
		if ( Data.lod == Data.LOW )     return ;
		for ( var i=0;i<total;i++) {
			var mc = generate( x, y, 1 ) ;
			if ( mc != undefined ) {
				mc.dx = dx * random(100)/100 ;
				mc.dy = dy * random(100)/100 ;
			}
		}
	}



	/*------------------------------------------------------------------------
	ATTACHE UNE PARTICULE
	------------------------------------------------------------------------*/
	function generate(x,y, frame) {
		if ( fxList.length >= Data.MAX_FX )
			return undefined ;

		var mc ;
		mc = Std.cast( depthMan.attach("particule",Data.DP_FX) ) ;
		mc._x = x ;
		mc._y = y ;
		mc._rotation = random(360) ;
		mc._xscale = random(60)+40 ;
		mc._yscale = mc._xscale ;
		mc.gotoAndStop(frame) ;
		mc.dx = (random(2)*2-1) * (random(Data.FX_SPEED*100)/100+1) ;
		if (Data.lod == Data.HIGH)
			if (mc.dx<0)
				mc.dr = -Data.FX_SPEED*2 ;
			else
				mc.dr = Data.FX_SPEED*2 ;
		mc.dy = -(random(Data.FX_SPEED*2*100)/100+1) ;
		mc.dalpha  = 0 ;
		if ( Data.lod == Data.HIGH )
			mc.lifeTime = Data.FX_LIFETIME ;
		else
			mc.lifeTime = 0 ;
		mc.managers = new Array() ;
		mc.managers.push( fallManager ) ;
		fxList.push(mc) ;
		return Std.cast(mc) ;
	}



	/*------------------------------------------------------------------------
	MANAGER: PARTICULE SUBISSANT LA GRAVITÉ
	------------------------------------------------------------------------*/
	function fallManager(mc) {
		mc._rotation += Std.tmod * mc.dr ;
		mc._x += mc.dx * Std.tmod ;
		mc._y += mc.dy * Std.tmod ;
		mc._alpha -= mc.dalpha * Std.tmod ;

		mc.dy += Data.FX_GRAVITY * Std.tmod ;


		if ( mc.lifeTime>0 )
			mc.lifeTime-=Std.tmod ;
		else {
			mc.dalpha += Data.FX_ALPHA_SPEED * Std.tmod ;
			if ( mc._alpha <= 0 )
				mc.kill = true ;
		}
	}


	/*------------------------------------------------------------------------
	MANAGER: ANIMATION STEP PAR STEP
	------------------------------------------------------------------------*/
	function animManager(mc) {
		if ( mc.waitBack != undefined && mc.waitBack > 0 ) {
			mc.waitBack-=Std.tmod ;
			return ;
		}

		mc.frame+=Std.tmod ;
		while ( mc.frame>=1 ) {
			if ( mc.animMode == Data.BACKWARD )
				mc.prevFrame() ;
			else
				mc.nextFrame() ;
			mc.frame-- ;
		}

		if ( mc.animMode==Data.BACKWARD && mc._currentframe == 1 ) {
			mc.kill = true ;
		}
		if ( mc.animMode==Data.FORWARD && mc._currentframe == mc._totalframes )
			mc.kill = true ;
		if ( mc.animMode==Data.PINGPONG && mc._currentframe == mc._totalframes ) {
			mc.waitBack = 30 ;
			mc.animMode = Data.BACKWARD ;
		}
	}


	/*------------------------------------------------------------------------
	MANAGER: MOUVEMENT SINUSOIDAL EN X
	------------------------------------------------------------------------*/
	function sinManager(mc) {
		if (mc.sinCpt==undefined) {
			mc.sinCpt = 0 ;
			mc.x = mc._x ;
		}
		mc.sinCpt += 0.4*Std.tmod ;
		mc._x = mc.x + Math.sin(mc.sinCpt)*7 ;
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		for (var i=0;i<fxList.length;i++) {
			var mc = fxList[i] ;

			// Managers
			for (var m=0;m<mc.managers.length;m++)
				mc.managers[m](mc) ;

			// Mort
			if ( mc.kill ) {
				mc.removeMovieClip() ;
				fxList.splice(i,1) ;
				i-- ;
			}
		}
	}

	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		for (var i=0;i<fxList.length;i++)
			fxList[i].removeMovieClip() ;

		fxList = new Array() ;
	}
}

