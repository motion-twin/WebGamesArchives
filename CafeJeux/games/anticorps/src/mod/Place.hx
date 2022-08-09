package mod;
import Common;
import mt.bumdum.Lib;



class Place extends Mode{//}

	var rainbowCoef:Float;
	var step:Int;
	var cid:Int;
	var timer:Float;



	public function new() {
		super();
		rainbowCoef = 0;

		if(Game.me.myCosmos.length==0){
			initStartPos();
			initStep(0);
		}else{
			timer = 30;
			//focusOnZone();
		}





	}

	function initStep(n){

		switch(step){
			case 0:

			case 1:
				Reflect.deleteField(Game.me.bg,"onPress");
				Game.me.mcCosmoBar.smc.onPress = null;
				Game.me.mcCosmoBar.smc.useHandCursor = false;
			case 2:


		}
		step  =n;
		switch(step){
			case 0: initSelect();
			case 1: initPlace();
			case 2:


		}
	}
	function initStartPos(){
		var p = Cs.MAP_INFOS[Game.me.mid].startPos[Game.me.colorId];
		Game.me.mcStartPos = Game.me.mdm.attach("mcStartPos",Game.DP_ZONE);
		Game.me.mcStartPos._x = p[0];
		Game.me.mcStartPos._y = p[1];

		Game.me.setFocus( { x:p[0]*1.0, y:p[1]*1.0 } );

	}

	// UPDATE
	override function update(){
		super.update();

		if(timer!=null){
			timer-=mt.Timer.tmod;
			if(timer<0){
				timer = null;
				focusOnZone();
				initStep(0);
			}
		}


		switch(step){
			case 0: updateSelect();
			case 1: updatePlace();

		}


	}


	function initSelect(){
		//
		for( i in 0...Cs.COSMO_MAX ){
			var mc = Game.me.mcCosmoBar.list[i];
			if(mc._visible){
				mc.onPress = callback(select,i);
				mc.useHandCursor = true;
			}

		}
		//
		var pos = ["premier","second","dernier"][Game.me.myCosmos.length];
		Game.me.setMsg("Choisissez votre "+pos+" cosmo");
	}
	function updateSelect(){
		rainbowCoef = (rainbowCoef+0.05)%1;
		var rcol = Col.objToCol(Col.getRainbow(rainbowCoef));
		Game.me.mcCosmoBar._y *= 0.5;
		Game.me.mcCosmoBar.group.filters = [];
		Filt.glow( Game.me.mcCosmoBar.group, 2, 255, rcol );


		Game.me.mcStartPos._rotation++;
		Game.me.mcStartPos.filters = [];

		Filt.glow(Game.me.mcStartPos,2,4,rcol);
		//Filt.glow(mcStartPos,2,4,0);
	}

	function select(id){


		cid= id;
		var mc = Game.me.mcCosmoBar.list[id];
		//trace(id);
		if(id>1)mc._visible = false;

		// INTER
		for( mc in Game.me.mcCosmoBar.list ){
			mc.onPress = cancel;
			//mc.useHandCursor = false;
		}
		Game.me.mcCosmoBar.smc.onPress = cancel;
		Game.me.mcCosmoBar.smc.useHandCursor = true;
		Game.me.mcCosmoBar.group.filters = [];

		//

		initStep(1);
		if( Game.me.mcStartPos!=null ){
			var p = Cs.MAP_INFOS[Game.me.mid].startPos[Game.me.colorId];
			cosmo.x = Std.int(Game.me.mcStartPos._x);
			cosmo.y = Std.int(Game.me.mcStartPos._y);
			//mcStartPos.removeMovieClip();
			validate();
		}

	}

	function initPlace(){

		cosmo = new pix.Cosmo( Game.me.mdm.empty(Game.DP_COSMO), Cs.getCosmoType(cid), true );
		cosmo.setState(Levit);
		cosmo.updateMousePlace();
		cosmo.updatePos();
		Game.me.setFocus(null);

		//
		Game.me.setMsg("Placez le sur la carte dans la zone "+["rouge","bleue"][cosmo.colorId]);

	}
	function updatePlace(){

		// INTER
		var bar = Game.me.mcCosmoBar;
		if( Game.me.root._ymouse >15 ){
			if(bar._y>-31)bar._y += bar._y-1;
		}else{
			bar._y *= 0.5;
		}

		// COSMO
		cosmo.updateMousePlace();




		if( cosmo.gid!=null && isIn(cosmo.x,cosmo.y) ){
			cosmo.root._alpha = 100;
			Game.me.bg.onPress = validate;
			Game.me.bg.useHandCursor = true;
		}else{
			cosmo.root._alpha = 50;
			Reflect.deleteField(Game.me.bg,"onPress");
			Game.me.bg.useHandCursor = false;
		}


		if(bar._y<=-31)Game.me.mouseSideScroll();


	}


	function cancel(){
		cosmo.kill();
		cosmo = null;

		Game.me.mcCosmoBar.list[cid]._visible = true;
		cid = null;
		initStep(0);
	}
	function validate(){

		MMApi.queueMessage( Place(cid,cosmo.x,cosmo.y) );

		cosmo.kill();
		cosmo = null;
		initStep(2);

		//
		if( Game.me.oppCosmos.length==Cs.COSMO_TEAM_MAX ){
			MMApi.queueMessage(PlayNext());
		}

		//
		//Game.me.setMsg();

		//
		Game.me.mcCosmoBar._y = -31;
		MMApi.endTurn();

	}


	//
	function focusOnZone(){
		var x = 0.0;
		var y = 0.0;
		for( c in Game.me.myCosmos ){
			x+=c.x;
			y+=c.y;
		}

		x /= Game.me.myCosmos.length;
		y /= Game.me.myCosmos.length;

		Game.me.setFocus({x:x,y:y});

	}
	function isIn(x,y){

		var list = Game.me.myCosmos.copy();
		list.pop();
		if(list.length==0)return true;

		for( c in list ){

			if(c == cosmo)trace("o_O");

			var dx = c.x - cosmo.x;
			var dy = c.y - cosmo.y;
			if( Math.sqrt(dx*dx+dy*dy) < c.startZone ){
				return true;
			}
		}

		return false;

	}


//{
}











