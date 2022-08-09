package mod.ac;
import Common;
import mt.bumdum.Lib;



class Brawl extends mod.Action{//}

	var flFire:Bool;
	var type:Int;
	var angle:Float;

	public function new(?cosmo:pix.Cosmo,type) {
		this.type = type;
		super(cosmo);


	}

	override function init(){
		MMApi.queueMessage(ShowWeapon(type));
	}
	override function remove(){
		if(!flFire)MMApi.queueMessage(HideWeapon);
	}

	// UPDATE
	override function update(){
		super.update();

		var mp = getMousePos();
		angle =  Math.atan2(mp.y,mp.x);

		var ca = Math.cos(angle);
		var sa = Math.sin(angle);

		var da = Num.hMod(cosmo.ga-angle,3.14);
		var sens = Std.int(-da/Math.abs(da));
		cosmo.setSens(sens);

		if(flMenu)return;
		if(Game.me.flClick)initShot();

	}

	function initShot(){
		Game.me.flClick = false;
		MMApi.sendMessage( PlayShot(type,cosmo.lastActionId,angle) );
		flFire = true;
		kill();
	}



//{
}





