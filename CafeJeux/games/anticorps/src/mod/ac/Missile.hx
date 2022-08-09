package mod.ac;
import Common;
import mt.bumdum.Lib;



class Missile extends mod.Action{//}

	var flFire:Bool;
	var flDirect:Bool;

	var mcArrow:flash.MovieClip;
	var mcPower:flash.MovieClip;
	var type:Int;
	var step:Int;
	var angle:Float;
	var power:Float;

	public function new(?cosmo:pix.Cosmo,type,?flDirect) {
		this.type = type;
		this.flDirect = flDirect;
		super(cosmo);

		step = 0;

		flFire = false;




	}

	override function init(){
		Game.me.flMouseView = true;
		Game.me.mouseViewCoef = 1;
		mcArrow = cosmo.dm.attach("mcArrow",0);
		mcArrow.gotoAndStop(5);
		MMApi.queueMessage(ShowWeapon(type));

		if(flDirect){
			Game.me.setMsg("cliquez pour tirer");
		}else{
			Game.me.setMsg("laissez le bouton appuyé pour charger");
		}

	}
	override function remove(){
		Game.me.flMouseView = false;
		mcArrow.removeMovieClip();
		if(!flFire)MMApi.queueMessage(HideWeapon);
	}

	// UPDATE
	override function update(){
		super.update();
		if(flMenu)return;

		switch(step){
			case 0:
				var mp = getMousePos();
				angle =  Math.atan2(mp.y,mp.x);

				var ca = Math.cos(angle);
				var sa = Math.sin(angle);

				var ray = 32;
				mcArrow._x = cosmo.head.x + ca*ray;
				mcArrow._y = cosmo.head.y + sa*ray;


				cosmo.aimAt(angle);

				/*
				var da = Num.hMod(angle-cosmo.ga,3.14);
				var sens = Std.int(da/Math.abs(da));
				cosmo.setSens(sens);

				//cosmo.head.root._rotation = Math.atan2(sa,ca)/0.0174;
				cosmo.head.root._rotation = angle/0.0174 + ((-sens+1)*0.5)*180;
				*/


				if(Game.me.flClick && !Game.me.flSpaceView && MMApi.isMyTurn() ){
					//trace(flDirect);
					if(flDirect){
						shot();
					}else{
						initShot();
					}
				}

			case 1: // CHARGE
				updateCharge();

		}


		//mcHead._rotation
		//cosmo.mcHead._rotation = a/0.0174;



	}

	function initShot(){

		initCharge();
	}

	function shot(){
		Game.me.flClick = false;
		MMApi.sendMessage(PlayShot(type,cosmo.lastActionId,angle,power));
		flFire =true;
		Game.me.setMsg("");
		kill();
	}

	function initCharge(){
		flCancel = false;
		step = 1;
		power = 0;
		mcPower = Game.me.dm.attach("mcPower",Game.DP_INTER);
		//mcPower._x = cosmo.x + cosmo.head.x;
		//mcPower._y = cosmo.y + cosmo.head.y;
		mcPower._y = 10;
		mcPower.smc._xscale =  0;
		mcPower._xscale =  Cs.mcw;
		//mcPower._rotation = angle/0.0174;
		Game.me.setMsg("Relachez le bouton pour tirer !");

	}
	function updateCharge(){
		power = Math.min(power+0.02*mt.Timer.tmod,1);
		mcPower.smc._xscale = power*100;

		if(  !Game.me.flClick ){
			mcPower.removeMovieClip();
			shot();
		}
	}

	//



//{
}





