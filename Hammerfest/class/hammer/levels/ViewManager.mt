import flash.display.BitmapData;

class levels.ViewManager extends levels.SetManager
{

	var view			: levels.View;
	var fake			: MovieClip;
	var fl_hideTiles	: bool;
	var fl_hideBorders	: bool;
	var fl_shadow 		: bool;
	var scroller		: MovieClip;
	var scrollDir		: int;

	var fl_restoring	: bool;
	var fl_scrolling	: bool;
	var fl_hscrolling	: bool;
	var fl_fading		: bool;
	var fl_fadeNextTransition	: bool;
	var darknessFactor	: float;

	var prevSnap		: BitmapData;

	var depthMan		: DepthManager;

	// Scrolling
	var scrollCpt : float ;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,setName) {
		super(m,setName);
		fl_scrolling	= false;
		fl_hscrolling	= false;
		fl_hideTiles	= false;
		fl_hideBorders	= false;
		fl_shadow		= true;

		fl_restoring	= false;
		fl_fading		= false;

		darknessFactor	= 0;
	}

	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		super.destroy();
		view.destroy();
		fake.removeMovieClip();
	}

	/*------------------------------------------------------------------------
	LINK UN DEPTH-MANAGER EXTERNE
	------------------------------------------------------------------------*/
	function setDepthMan(d:DepthManager) {
		depthMan = d;
	}



	/*------------------------------------------------------------------------
	GESTION DE LA VUE FAKE
	------------------------------------------------------------------------*/
	function cloneView(v) {
		var snap = v.getSnapShot(0,0);
		createFake(snap);
	}

	function createFake(snap) {
		fake.removeMovieClip();
		fake = depthMan.empty(Data.DP_SCROLLER);
		fake.blendMode = BlendMode.LAYER;
		var mc = Std.createEmptyMC(fake,0);
		mc._x = -10;
		mc.attachBitmap(snap,0);
		fake._alpha = Math.max(0, 100-darknessFactor);
	}




	// *** EVENTS *****

	/*------------------------------------------------------------------------
	EVENT: GENERIC TRANSITION CALLBACK
	------------------------------------------------------------------------*/
	function onTransitionDone() {
		view.moveTo(0,0);
		fake.removeMovieClip();
		if ( fl_mirror ) {
			flipPortals();
		}
	}

	/*------------------------------------------------------------------------
	EVENT: SCROLLING TERMINÉ
	------------------------------------------------------------------------*/
	function onScrollDone() {
		fl_scrolling = false;
		onViewReady();
	}


	/*------------------------------------------------------------------------
	EVENT: SCROLLING HORIZONTAL TERMINÉ
	------------------------------------------------------------------------*/
	function onHScrollDone() {
		fl_hscrolling = false;
	}


	/*------------------------------------------------------------------------
	EVENT: FADE TERMINÉ
	------------------------------------------------------------------------*/
	function onFadeDone() {
		fl_fading = false;
	}


	/*------------------------------------------------------------------------
	EVENT: VUE PRÊTE À ÊTRE JOUER
	------------------------------------------------------------------------*/
	function onViewReady() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: DÉCODAGE TERMINÉ
	------------------------------------------------------------------------*/
	function onDataReady() {
		super.onDataReady();


		if ( !view.fl_attach ) {
			view.destroy();
			view = createView(currentId);
			if ( fl_restoring ) {
				view.moveTo(Data.GAME_WIDTH,0);
				onRestoreReady();
			}
			else {
				view.moveTo(0,0);
				onViewReady();
			}
		}
		else {
			cloneView(view);

			teleporterList = new Array();

			view.destroy();
			view = createView(currentId);
			view.moveTo(0,Data.GAME_HEIGHT);
			scrollCpt = 0;

			fl_scrolling = true;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: RESTORE TERMINÉ
	------------------------------------------------------------------------*/
	function onRestoreReady() {
		super.onRestoreReady();
		fl_restoring = false;
		if ( fl_fadeNextTransition ) {
			fl_fadeNextTransition = false;
			fl_fading = true;
			view.moveTo(0,0);
		}
		else {
			fl_hscrolling = true;
			scrollCpt = 0;
		}

		// hack: scrolldir is set in GameMechanics
	}


	/*------------------------------------------------------------------------
	ATTACH: VUE
	------------------------------------------------------------------------*/
	function createView(id) {
		var v = new levels.View(this, depthMan);
		v.fl_hideTiles = fl_hideTiles;
		v.fl_hideBorders = fl_hideBorders;
		v.detach();
		if ( !fl_shadow ) {
			v.removeShadows();
		}
		v.display(id);
		return v;
	}


	/*------------------------------------------------------------------------
	GESTION MISE EN ATTENTE
	------------------------------------------------------------------------*/
	function suspend() {
		super.suspend();
		view.detach();
		fake.removeMovieClip();
	}

	function restore(lid) {
		super.restore(lid);
		fl_restoring = true;
		goto(lid);
	}


	/*------------------------------------------------------------------------
	RÉACTIVATION AVEC ANIM DE TRANSITION DEPUIS UN SNAPSHOT
	------------------------------------------------------------------------*/
	function restoreFrom(snap,lid) {
		prevSnap = snap;
		createFake(prevSnap);
		view.moveTo(Data.GAME_WIDTH,0);
		restore(lid);
	}


	/*------------------------------------------------------------------------
	RENVOIE UN SNAP SHOT DE LA VUE EN COURS
	------------------------------------------------------------------------*/
	function getSnapShot() : BitmapData {
		return view.getSnapShot(0,0);
	}



	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE (SCROLLING)
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		if ( fl_scrolling ) {
			scrollCpt += Data.SCROLL_SPEED * Timer.tmod ;
			view.moveTo(0, Data.GAME_HEIGHT+Math.sin(scrollCpt)*(0-Data.GAME_HEIGHT) ) ;
//			fake.moveTo(0, -Math.sin(scrollCpt)*(Data.GAME_HEIGHT) ) ;
			fake._x = 0;
			fake._y = -Math.sin(scrollCpt)*(Data.GAME_HEIGHT);

			if ( scrollCpt>=Math.PI/2 ) {
				onTransitionDone();
				onScrollDone() ;
			}
		}

		if ( fl_hscrolling ) {
			scrollCpt += scrollDir * Data.SCROLL_SPEED * Timer.tmod ;
			if ( scrollDir>0 ) {
				view.moveTo( 20+Data.GAME_WIDTH+Math.sin(scrollCpt)*(0-Data.GAME_WIDTH-20), 0 ) ;
			}
			else {
				view.moveTo( -Data.GAME_WIDTH-20-Math.sin(scrollCpt)*(Data.GAME_WIDTH+20), 0 ) ;
			}
			fake._x = -Math.sin(scrollCpt)*(Data.GAME_WIDTH+20);
			fake._y = 0;

			if ( scrollCpt>=Math.PI/2 || scrollCpt<=-Math.PI/2 ) {
				onTransitionDone();
				onHScrollDone() ;
			}
		}

		if ( fl_fading ) {
			fake._alpha -= Timer.tmod*Data.FADE_SPEED;

			var f = new flash.filters.BlurFilter();
			f.blurX			= 100-fake._alpha;
			f.blurY			= f.blurX*0.3;
			fake.filters	= [f];

			if ( fake._alpha<=0 ) {
				onTransitionDone();
				onFadeDone();
			}
		}

	}

}


