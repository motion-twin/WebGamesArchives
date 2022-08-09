package inter.pan;
import inter.Map;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


typedef SlotShip = {
	>flash.MovieClip,
	ico:flash.MovieClip,
	bar:flash.MovieClip,
	sel:flash.MovieClip,
	field:flash.TextField,
	back:flash.MovieClip,
	car:ShipLogic,
};

typedef SlotObjectif= {
	>flash.MovieClip,
	fieldName:flash.TextField,
	fieldPrc:flash.TextField,
	but:flash.MovieClip
}

class Fleet extends inter.Panel {//}

	var flOwn:Bool;
	var glow:Float;
	var sgr:ShipGroup;

	static var selection:Array<Bool>;
	var fleet:Array<SlotShip>;
	var baseStatus:FleetStatus;

	var mcSkirmish:flash.MovieClip;
	var travel:Travel;
	var planet:McPlanet;
	var kl:Dynamic;


	public function new(sgr,tr,pl){

		this.sgr = sgr;
		travel = tr;
		planet = pl;
		super();


		flOwn = sgr.owner == Game.me.playerId;

		height = 460;
		glow = 0;
		baseStatus = travel.data._status;
		if(travel==null) baseStatus = { _priorities:new List(), _autocol:false, _oneshot:true };

		// ORDER
		var f = function(a:inter.McShip,b:inter.McShip){
			var na = Type.enumIndex(a.data._type);
			var nb = Type.enumIndex(b.data._type);
			if(na<nb)	return 1;
			else 		return -1;
		}
		sgr.list.sort(f);

		// SKIN
		var skin = 5;
		if(flOwn)skin--;
		Inter.me.board.setSkin(skin);
		Inter.me.attachBackBut();

		Trick.makeButton(board.root.prev,null,callback(Inter.me.map.selectNextFleet,sgr,-1));
		Trick.makeButton(board.root.next,null,callback(Inter.me.map.selectNextFleet,sgr,1));

		Inter.me.makeHint(board.root.prev,Lang.SEE_PREV_FLEET,80);
		Inter.me.makeHint(board.root.next,Lang.SEE_NEXT_FLEET,80);



		// SELECTION
		var flAll = true;
		for( fl in selection )if(fl==false)flAll = false;
		if( flAll ){
			selection = [];
			for( i in sgr.list )selection.push(true);
		}

		//
		kl = {};
		Reflect.setField(kl,"onKeyDown",keyPress);
		flash.Key.addListener(cast kl);

		// DISPLAY
		display();

	}
	function keyPress(){
		var n = flash.Key.getCode();
		switch(n){
			case 46: tryDeleteFleet();
		}
	}

	override function display(){
		super.display();

		cy -= 7;
		//genTitle(Lang.TITLE_FLEET);
		board.root.fieldTitle.text = Lang.TITLE_FLEET.toUpperCase();
		cy += 60;


		var flSend = planet != null && flOwn;
		var flObjectives = flOwn;
		var flReturn = false;
		var flReturn = travel != null && Game.me.getPlanet( travel.data._origin ).owner == sgr.owner && travel.data._dest != travel.data._origin && flOwn;


		// SLIDER
		cy -= 11;
		var sliderHeight = 252;
		if(!flOwn) sliderHeight = 420;
		genSlider( sliderHeight );

		var mod = 3;
		var ww = 70;
		var hh = 83;
		var ma = 0;

		fleet = [];
		var id = 0;

		var controller = Game.me.getPlayer(sgr.owner);

		for( ship in sgr.list ){


			var mc:SlotShip = cast slider.dm.attach(Cs.gil("slotShip"),0);
			mc.gotoAndStop(Game.me.raceId+1);
			mc._x = 11+ (ww+ma)*(id%mod);
			mc._y = Std.int(id/mod)*(hh+ma);
			mc.car = Tools.getShipCaracs(ship.data._type, controller._tec, travel.data._attributes, planet.pl.attributes );
			mc.car.applyStatus(ship.data._status);
			mc.ico.gotoAndStop(Type.enumIndex(ship.data._type)+1);

			// STATUS
			var as = [];

			for( i in 0...6 )if( Cs.isStatus(ship.data._status,i) )as.push(i);
			var n = 0;
			var dm = new mt.DepthManager(mc);
			for( id in as ){
				var ico = dm.attach("mcShipStatusIcon",1);
				ico._x = 55 - 12*n;
				ico._y = 14;
				ico.gotoAndStop(id+1);
				n++;
				var str = "<b>"+Lang.SHIP_STATUS[id]+":</b>\n"+Lang.SHIP_STATUS_DESC[id];
				Inter.me.makeHint(ico,str);
			}

			// LIFE
			mc.bar._xscale = ship.data._life / mc.car.life * 100;
			mc.field.text = ship.data._life+" / "+mc.car.life;


			// HINT
			var str = Lang.getShipDesc(ship.data._type,ship.data._owner,ship.data._status,travel.data._attributes, planet.pl.attributes );
			Inter.me.makeHint(mc.back,str,null,true);

			//
			if( flSend  )mc.back.onPress = callback(toggleSelection,id);
			fleet.push(mc);
			id++;

		}
		updateSliderMin();
		if( !flOwn )return;


		// SEND BUTTON
		var a = [];
		if( flSend  )  			a.push({id:0,name:Lang.SEND_FLEET,f:sendFleet});
		if( flSend && hasDrop()  )  	a.push({id:1,name:Lang.DROP_FLEET,f:tryDropFleet});
		if( travel != null ) 		a.push({id:2,name:Lang.CANCEL_FLEET,f:tryCancelFleet});



		var id = 0;
		for( o in a ){
			var f = o.f;
			if( o.name == Lang.CANCEL_FLEET && !flReturn )f = null;
			var str = o.name;
			if( Game.me.raceId==1 )str = str.toUpperCase();
			var mc = genButton(str, f );
			var sens = id*2-1;
			if(a.length==1)sens = 0;
			if( Game.me.raceId==0 )	mc._x += 4 +sens*55 ;
			else			mc._x += 3 +sens*53 ;
			mc._y = 310 ;
			if( Game.me.raceId==1 )mc._y += 8;

			if(f==null){
				mc._alpha = 50;
				Trick.butKill(mc);
			}else{
				// Inter.me.makeHint(mc,Lang.FLEET_ACTIONS[o.id]);
				var fromIsleId = travel.data._origin;
				var fromIsleName = Game.me.getPlanetName(fromIsleId);
				Inter.me.makeHint(mc, Lang.rep(Lang.FLEET_ACTIONS[o.id], fromIsleName));
			}

			id++;



		}

		// SKIRMISH
		displayStatus();

		// TIME
		board.root.fieldTime.text = "";

		// OBJECTIVES
		if(flObjectives)attachObjectives();

		//
		updateSlotSelection();

		//
		if(flSend)updateRange();



	}

	function getSelectionList(){
		var a = [];
		var id = 0;
		for( ship in sgr.list ){
			if(selection[id])a.push(ship.data._id);
			id++;
		}
		return a;
	}

	// ACTIONS
	function sendFleet(){

		Inter.me.hideHint();

		//flSkirmish;

		Inter.me.map.move = {
			start:planet,
			list:getSelectionList(),
			range:getSelectionRange(),
			line:null,
			near:null,
			status:baseStatus,
			speed:getSelectionSpeed()
		};

		Inter.me.map.initMoveMode();
		cancel();





	}

	function tryDropFleet(){
		Inter.me.hideHint();
		Inter.me.msgBox(Lang.DROP_FLEET_CONFIRM,Lang.ARE_YOU_SURE,[{name:Lang.YES,f:dropFleet},{name:Lang.NO,f:null}]);
	}
	function tryCancelFleet(){
		Inter.me.msgBox(Lang.CANCEL_FLEET_CONFIRM,Lang.ARE_YOU_SURE,[{name:Lang.YES,f:cancelFleet},{name:Lang.NO,f:null}]);
	}
	function tryDeleteFleet(){
		Inter.me.msgBox(Lang.DELETE_FLEET_CONFIRM,Lang.ARE_YOU_SURE,[{name:Lang.YES,f:deleteFleet},{name:Lang.NO,f:null}]);
	}
	/*
	function trySendFleet(){
		Inter.me.hideHint();
		if(flOwn)sendFleet();
		//Inter.me.msgBox(Lang.SEND_FLEET_CONFIRM,Lang.ARE_YOU_SURE,[{name:Lang.YES,f:sendFleet},{name:Lang.NO,f:null}]);
	}
	*/

	function dropFleet(){
		Inter.me.hideHint();
		Api.colonize(this.planet.pl.id,getSelectionList(), Inter.me.map.maj);
		cancel();
	}
	function cancelFleet(){
		Api.cancelMove(travel.data._id, Inter.me.map.maj);
		cancel();
	}
	function deleteFleet(){
		var a = getSelectionList();
		Api.destroyFleetUnits(a, Inter.me.map.maj);
		/*
		var list = sgr.list.copy();
		var id = 0;
		for( ship in list ){
			if(selection[id]){
				trace("remove!");
				sgr.list.remove(ship);
			}
			id++;
		}
		*/
	}

	// SKIRMISH
	function displayStatus(){


		//Trick.butAction(board.root.prev);

		// ESCARMOUCHE


		board.root.butA.gotoAndStop(baseStatus._oneshot?2:1);
		board.root.butB.gotoAndStop(baseStatus._oneshot?1:2);
		Trick.butKill(board.root.butA);
		Trick.butKill(board.root.butB);
		Trick.butKill(board.root.butC);

		cast (board.root.butA)._hint = false;
		cast (board.root.butB)._hint = false;
		cast (board.root.butC)._hint = false;

		Trick.butAction(board.root.butA,null,null,null,callback(setSkirmish,true));
		Trick.butAction(board.root.butB,null,null,null,callback(setSkirmish,false));
		Inter.me.makeHint(board.root.butA,Lang.getTitleDesc(Lang.FLEET_ONE_WAY,Lang.FLEET_ONE_WAY_DESC));
		Inter.me.makeHint(board.root.butB,Lang.getTitleDesc(Lang.FLEET_ROUND,Lang.FLEET_ROUND_DESC));

		//


		if( hasDrop() ){
			Trick.butAction(board.root.butC,toggleAutoColonize);
			board.root.butC.gotoAndStop(baseStatus._autocol?2:1);
			Inter.me.makeHint(board.root.butC,Lang.getTitleDesc(Lang.FLEET_AUTO_DROP,Lang.FLEET_AUTO_DROP_DESC));
		}else{
			Trick.butKill(board.root.butC);
			board.root.butC.gotoAndStop(3);
		}


	}
	function setSkirmish(fl:Bool){
		Inter.me.hideHint();
		var flUpdate = fl!=baseStatus._oneshot;
		baseStatus._oneshot = fl;
		displayStatus();

		if(flUpdate && travel!= null )	Api.updateFleet(travel.data._id,baseStatus);


	}
	function toggleAutoColonize(){
		Inter.me.hideHint();
		baseStatus._autocol = !baseStatus._autocol;
		displayStatus();
		if( travel!= null )	Api.updateFleet(travel.data._id,baseStatus);

	}

	// OBJECTIVES
	var mcObjectives : {>flash.MovieClip,list:Array<SlotObjectif>};
	function attachObjectives(){
		cy += 3;
		mcObjectives = cast dm.attach(Cs.gil("mcObjectives"),0);
		mcObjectives.gotoAndStop(Game.me.raceId+1);
		mcObjectives._x = 13;
		mcObjectives._y = 415;
		mcObjectives.list = [] ;
		if( Game.me.raceId == 1 ){
			mcObjectives._x -= 6;
			mcObjectives._y += 1;
		}

		for( i in 0...8 ){
			var mc:SlotObjectif = cast dm.attach("mcObjectif",0);
			mc._x = mcObjectives._x + (i%2)*110;
			mc._y = mcObjectives._y + Std.int(i/2)*16;
			mc.fieldName.text = Lang.BUILDING_TYPE[i];
			mc.fieldPrc.text = "-";
			mc.onPress = callback( selectObjectif, i );
			mcObjectives.list[i] = mc;

			var str = Lang.FLEET_STRIKE+" "+Lang.BUILDING_TYPE_DESC[i];
			Inter.me.makeHint(mc,str);
		}
		displayObjectives();
	}
	function displayObjectives(){

		//var player = Game.me.getPlayer(sgr.owner);
		var a = getPrios();
		var id = 0;
		for( mc in mcObjectives.list )mc.fieldPrc.text  ="-";
		for( n in baseStatus._priorities){
			var index = Type.enumIndex(n);
			var mc = mcObjectives.list[index];
			var str = a[id]+"%";
			if( a[id] == null )str = "-";
			mc.fieldPrc.text = Std.string(str);
			id++;
		}

	}
	function selectObjectif(id){

		//var player = Game.me.getPlayer(sgr.owner);
		var a = getPrios();
		//baseStatus._priorities.push( En.get(_BldType,id) );
		baseStatus._priorities.push( Type.createEnum(_BldType,Type.getEnumConstructs(_BldType)[id]) );
		while( baseStatus._priorities.length> a.length ){
			baseStatus._priorities.remove( baseStatus._priorities.last() );
		}
		displayObjectives();

		if(travel!=null)Api.updateFleet(travel.data._id,baseStatus);

	}

	function getPrios(){
		var player = Game.me.getPlayer(sgr.owner);
		var a = player._tprio.copy();
		var id = 0;
		for( shp in sgr.list ){
			if(selection[id]){
				for( cap in shp.car.capacities ){
					switch(cap){
						case FleetTarget(v):
							var flAdd = true;
							for( n in a ){
								if( n == v ){
									flAdd = false;
									break;
								}
							}
							if( flAdd )a.push(v);
						default:
					}
				}
			}
			id++;
		}
		var f = function(a:Int,b:Int){	if(a>b)return -1; return 1; };
		a.sort(f);
		return a;
	}

	override function update(){
		super.update();
		glow = (glow+17)%628;
		var c = 0.5+Math.cos(glow*0.01)*0.5;
		sgr.filters = [];
		Filt.glow(sgr,2+c*4,1+c*3,0xFFFFFF);

		//
		// TEMPS RESTANT

		if( travel!=null ){
			var o = Game.me.getCounterInfo(travel.data._move);
			board.root.fieldTime.text = /* Lang.REMAINING_TIME+" : "+ */ Cs.getTime(o.run,false,false);
		}



	}


	// SELECTION
	function toggleSelection(id){


		if( flash.Key.isDown(flash.Key.CONTROL) ){

			for( i in 0...selection.length )selection[i] = id== i;

		}else if( flash.Key.isDown(flash.Key.SHIFT) ){

			var type = sgr.list[id].data._type;
			selection = [];
			var i = 0;
			for( mc in sgr.list ){
				selection[i] = Type.enumEq( mc.data._type , type);
				i++;
			}

		}else{
			selection[id] = !selection[id];
		}

		display();
		updateRange();
	}
	function updateSlotSelection(){
		var id = 0;
		for( mc in fleet ){
			Col.setPercentColor(mc,selection[id]?0:60,0);
			id++;
		}
		displayObjectives();

	}

	// RANGE
	function updateRange(){
		//trace(getSelectionRange());
		Inter.me.map.traceRange( planet._x,planet._y, getSelectionRange() );
	}
	function getSelectionRange(){

		var range = null;
		var id = 0;
		var ranges = getRanges(sgr);
		for( mc in sgr.list ){
			if( selection[id] && ( ranges[id]<range || range == null ) )range = ranges[id];
			id++;
		}
		if(range==null)return 0;

		return range;
	}
	function getRanges(sgr:ShipGroup){
		var a = [];


		var id = 0;
		for( mc in sgr.list ){
			a[id] = mc.car.range;
			id++;
		}



		if(Game.me.haveTechno(_Tec.WINCH)){

			// MAX RANGE
			var id = 0;
			var maxRange = 0;
			for( mc in sgr.list ){
				if( selection[id] && mc.car.range>maxRange )maxRange = mc.car.range;
				id++;
			}

			// MODIFY RANGE
			var id = 0;
			for( mc in sgr.list ){
				if( selection[id]){
					if( mc.car.kind == BALLOON ||  mc.car.kind == BOMBER ){
						a[id] = maxRange;
					}
				}
				id++;
			}
		}


		return a;
	}

	// SPEED
	function getSelectionSpeed(){

		var speed = null;
		var id = 0;
		var speeds = getSpeeds(sgr);
		for( mc in sgr.list ){
			if( selection[id] && ( speeds[id]<speed || speed == null ) )speed = speeds[id];
			id++;
		}
		if(speed==null)return 0;

		return speed;
	}
	function getSpeeds(sgr:ShipGroup){
		var a = [];
		var id = 0;
		for( mc in sgr.list ){
			var speed = mc.car.speed;
			if( Cs.isStatus(mc.data._status, Type.enumIndex(Parasite) ) )
				speed = Math.round(speed / 2);
			a[id] = speed;
			id++;
		}

		if(Game.me.haveTechno(_Tec.WINCH)){
			// MAX RANGE
			var id = 0;
			var maxSpeed = 0;
			for( mc in sgr.list ){
				if( selection[id] && mc.car.speed>maxSpeed )maxSpeed = mc.car.speed;
				id++;
			}
			// MODIFY RANGE
			var id = 0;
			for( mc in sgr.list ){
				if( selection[id]){
					if( mc.car.kind == BALLOON ||  mc.car.kind == BOMBER ){
						a[id] = maxSpeed;
					}
				}
				id++;
			}
		}
		return a;
	}

	// HAS
	function hasDrop(){
		var id = 0;
		for( mc in sgr.list ){
			if(selection[id]!=false){
				for( cap in mc.car.capacities ){
					if( Type.enumEq( cap, ShipCapacity.Colonization ) ){
						return true;
					}
				}
			}
			id++;
		}
		return false;
	}


	override function cancel(){
		Inter.me.map.selectionPlanetFleet = null;
		Inter.me.map.selectionTravel = null;
		selection = null;
		super.cancel();
		Inter.me.map.recalScroll();
		Inter.me.board.vanish();
	}
	override function remove(){
		Inter.me.map.removeRange();
		Inter.me.map.backToMouseScroll();
		sgr.filters = [];
		//Inter.me.board.remove();
		//Inter.me.board.vanish();
		//if(flCancel)
		//else		Inter.me.board.remove();
		flash.Key.removeListener(cast kl);
		super.remove();
	}


	/*
	"la honte...","pas de bol.","il t'as pas loupé !","mais il lui reste encore des dents.","c'est dommage.","retente ta chance apres-demain.","elle ne veut plus quitter la civière.","souhaite lui bonne chance pour la suite !","et apparament ça le fait bien rire","il n'y est pas allé de poings morts.","muhahaha!","c'est vraiment trop injuste","ça c'est joué à pas grand chose.","vengeance !!","grrrrr...","flute alors!","bah ça alors...","quelle retournement de situation !","pas croyable !","qui aurait cru ?","sans forcer...","qui semble bien parti pour gagner ce tournoi.","mais il s'est excusé","apparament il regrette déjà","mais il est parti en courant a la fin du combat","le favori du tournoi.","un outsider bien surprenant.","apparamen, c'est pas son premier tournoi...","mais bon on s'en fiche un peu...","il prétend qu'il peut le refaire a mains nues.","il t'a bien saladé.","quel opportuniste !","qu'est ce qu'il t'a mis !","un vrai mastodonte","ce type est increvable.","ca fait mal...","en plus il t'as sali tes fringues.","il n'en a fait qu'une bouchée.","quel pseudo pourri!","et aussi a cause des conditions climatiques qui n'etaient pas terribles","mais il méritait pas vraiment de gagner.","le tricheur","c'est pas bon pour ta réputation, ça...","qui aurait pu faire mieux ?","ou peut etre a cause de ton manque d'entrainement...","Ca fait bien marrer tes élèves !"
	*/



//{
}















