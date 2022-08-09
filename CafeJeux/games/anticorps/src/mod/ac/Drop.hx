package mod.ac;
import Common;
import mt.bumdum.Lib;



class Drop extends mod.Action{//}

	var flSecret:Bool;
	var type:Int;

	public function new(?cosmo:pix.Cosmo,type,flSecret) {
		this.type = type;
		this.flSecret = flSecret;
		super(cosmo);





	}

	override function init(){
		cosmo.initWeapon(type);
		MMApi.queueMessage(ShowWeapon(type,flSecret));
	}
	override function remove(){
		cosmo.removeWeapon();
		MMApi.queueMessage(HideWeapon);
	}

	// UPDATE
	override function update(){
		super.update();
		if(flMenu)return;

		if(Game.me.flClick)initShot();




	}

	function initShot(){
		Game.me.flClick = false;

		MMApi.sendMessage(PlayShot(type,cosmo.lastActionId));
		//kill();
		Game.me.setMod(Move);
	}



//{
}





