class entity.bad.Shooter extends entity.bad.Jumper
{

	var fl_shooter		: bool;

	var shootCD			: float;
	var shootDuration	: float;
	var shootPreparation: float;
	var chanceShoot		: int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		shootCD	= Data.PEACE_COOLDOWN;
		disableShooter();
		setShoot(null);
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
	}


	/*------------------------------------------------------------------------
	INITIALISATION PARAMÈTRES DE TIR
	------------------------------------------------------------------------*/
	function initShooter( prepa, duration ) {
		shootPreparation = prepa;
		shootDuration = duration;
	}


	/*------------------------------------------------------------------------
	ACTIVE/DÉSACTIVE LE COMPORTEMENT SHOOTER
	------------------------------------------------------------------------*/
	function enableShooter() {
		fl_shooter = true;
	}
	function disableShooter() {
		fl_shooter = false;
	}


	function setShoot(chance) {
		if ( chance==null ) {
			fl_shooter = false;
		}
		else {
			fl_shooter = true;
			chanceShoot = chance*10;
		}
	}

	/*------------------------------------------------------------------------
	EVENT: FIN D'ATTENTE POUR UNE ACTION
	------------------------------------------------------------------------*/
	function onNext() {
		super.onNext();
		if ( next.action == Data.ACTION_SHOOT ) {
			setNext(null,null,shootDuration, Data.ACTION_WALK);
			halt();
			playAnim( Data.ANIM_BAD_SHOOT_END );
			onShoot();
		}
	}


	/*------------------------------------------------------------------------
	PRÉPARATION AU TIR
	------------------------------------------------------------------------*/
	function startShoot() {
		setNext(dx,dy,shootPreparation,Data.ACTION_SHOOT);
		halt();
		playAnim( Data.ANIM_BAD_SHOOT_START );
	}


	/*------------------------------------------------------------------------
	EVENT: ANIMATION LUE
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);
		if ( id==Data.ANIM_BAD_SHOOT_START.id ) {
			playAnim( Data.ANIM_BAD_SHOOT_LOOP );
		}
	}


	/*------------------------------------------------------------------------
	EVENT: TIR LANCÉ
	------------------------------------------------------------------------*/
	function onShoot() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( shootCD>0 ) {
			shootCD-=Timer.tmod;
		}
		if ( fl_shooter && shootCD<=0 ) {
			if ( isReady() && Std.random(1000)<chanceShoot ) {
				startShoot();
			}
		}
		super.update();
	}

}

