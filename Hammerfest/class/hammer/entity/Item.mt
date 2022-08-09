class entity.Item extends entity.Physics
{

	var id : int ;
	var subId : int ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		disableAnimator() ;
		fl_alphaBlink		= true;
		fl_largeTrigger		= true;
		fl_strictGravity	= false;
		minAlpha			= 0;
	}


	/*------------------------------------------------------------------------
	INIT
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g) ;
		setLifeTimer(Data.ITEM_LIFE_TIME) ;
		register(Data.ITEM) ;
	}


	/*------------------------------------------------------------------------
	INIT D'ITEM
	------------------------------------------------------------------------*/
	function initItem(g:mode.GameMode,x,y,id,subId) {
		if (Std.isNaN(id)) {
			id = null ;
		}
		if (Std.isNaN(subId)) {
			subId = null ;
		}
		if (id==null) {
			GameManager.fatal("null item ID !");
		}

		init(g) ;
		moveTo(x,y) ;
		this.id = id ;
		this.subId = subId ;
		if ( id>=1000 ) {
			this.gotoAndStop(""+(id-1000+1)) ;
		}
		else {
			this.gotoAndStop(""+(id+1)) ;
		}
		this.sub.gotoAndStop(""+(subId+1)) ;
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_shine") ;
		endUpdate() ;
	}


	/*------------------------------------------------------------------------
	ACTIVE L'ITEM AU PROFIT DE "E"
	------------------------------------------------------------------------*/
	function execute(p:entity.Player):void {
		destroy() ;
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		super.onDeathLine() ;
		moveTo(x,-30) ;
		dy = 0 ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		super.onLifeTimer() ;
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT/2,"hammer_fx_pop") ;
		game.soundMan.playSound("sound_pop",Data.CHAN_ITEM);
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update() ;
	}

}
