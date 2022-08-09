package inter.pan;
import Datas;
import inter.Panel;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


class ConstructBuilding extends inter.Panel {//}

	var flEther:Bool;
	var pl:Planet;
	var px:Int;
	var py:Int;
	var bigPoint:{x:Int,y:Int};
	var avBld:Array<_Bld>;


	public function new(pl,x,y,flEther){
		if(flEther == null )flEther =false;
		this.flEther = flEther;

		this.pl = pl;
		px = x;
		py = y;
		super();

		checkBig();
		display();

		Inter.me.attachBackBut();
		Inter.me.board.setSkin(1);


	}
	function checkBig(){

		for( d in Cs.BDIR ){
			var flOk = true;
			var z = null;
			for( d2 in Cs.BDIR ){
				var fx = px-d[0]+d2[0];
				var fy = py-d[1]+d2[1];
				var dalle = Inter.me.isle.grid[fx][fy];
				if( z==null )z = dalle.z;
				if( dalle.bt!=null || dalle.link!=null || dalle == null || z!= dalle.z || dalle.flEther ){
					flOk = false;
					break;
				}
			}
			if(flOk){
				bigPoint = {
					x: px-d[0],
					y: py-d[1],
				}
				break;
			}
		}
	}

	override function display(){
		super.display();

		cy+=80;

		// SLIDER
		genSlider(height-cy);

		// LIST
		avBld = pl.availableBld.copy();

		// EPURE LA LISTE
		var a = [];
		for( bt in avBld ){
			var flBig = Cs.isBig(bt);
			if( 	( bigPoint==null && flBig )
				|| ( Cs.isEther(bt) && !flEther )
				|| ( !Cs.isEther(bt) && flEther )
			){

			}else{
				a.push(bt);
			}
		}
		avBld = a;

		// ORDONNE LA LISTE
		var me = this;
		var f = function(a:_Bld,b:_Bld){
			if( me.getBuildingDisplayPriority(a) > me.getBuildingDisplayPriority(b) )return 1;
			return -1;
		}

		avBld.sort(f);

		displaySlots(avBld.length);

	}
	override function initSlot(mc:Slot,id){
		var bt = avBld[id];
		var bid = Type.enumIndex(bt);
		var flBig = Cs.isBig(bt);

		// PIC
		var bat = new mt.DepthManager(mc.pic.smc).attach("mcBuilding",0);
		bat._x = 38;
		bat._y = 58;
		if(flBig)bat._y += 10;
		bat.gotoAndStop( bid+2 );

		// COST
		var cost = Tools.getBldCost(bt);
		displaySlotCost(mc,cost);

		// BUT
		var lack = "";
		var flAvailable = true;
		/*
		if( cost.material > Game.me.res._material )	lack += "- "+Lang.LACK + Lang.QT_MATERIAL +".<br>";
		if( cost.cloth > Game.me.res._cloth )		lack += "- "+Lang.LACK + Lang.QT_CLOTH + ".<br>";
		if( cost.ether > Game.me.res._ether )		lack += "- "+Lang.LACK + Lang.QT_ETHER+ ".<br>";
		if( cost.population > pl.pop )			lack += "- "+Lang.LACK + Lang.QT_POP + ".<br>";
		//*/


		/*
		if( bigPoint==null && flBig ){
			flAvailable = false;
			lack += "- "+Lang.LACK + Lang.QT_VOLUME + ".<br>";
		}
		if(  Cs.isEther(bt) && !flEther ){
			flAvailable = false;
			lack += "- "+Lang.LACK_ETHER+".<br>";
		}
		if(  !Cs.isEther(bt) && flEther ){
			flAvailable = false;
			lack += "- "+Lang.LACK_GEYSER+".<br>";
		}
		*/

		if( flAvailable ){
			Trick.butAction( mc, callback(selectSlot,mc,bt), callback(rOverBatSlot,mc,bt), callback(rOutBatSlot,mc,bt) );
		}else{
			mc._alpha = 25;
			mc.blendMode = "layer";
		}

		// HINT
		var str = Cs.getTitleTxt( Lang.BUILDING[bid] )+"<br>";
		str += Lang.IGH_BUILDING[bid];
		if( !flAvailable )str +="<br><font color='#CC0000'>"+lack+"</font>";


		Inter.me.makeHint(mc,str,null,true);
	}

	// SLOT
	function selectSlot(mc:Slot,bt){
		mc.pic.filters = [];
		var x = px;
		var y = py;
		if(Cs.isBig(bt)){
			x = bigPoint.x;
			y = bigPoint.y;
		}
		Api.construct( pl.id, bt, x, y, function(){ Inter.me.isle.displayYard(); Inter.me.isle.maj(); });
		Inter.me.isle.removeCursor();
		remove();
	}

	function rOverBatSlot(mc:Slot,bt){
		rOverSlot(mc);
		Inter.me.isle.showGhost(bt,Inter.me.isle.getDalle(px,py));
	}
	function rOutBatSlot(mc:Slot,bt){
		rOutSlot(mc);
		Inter.me.isle.hideGhost();
	}

	override function remove(){
		super.remove();
		Inter.me.isle.removeCursor();
		Inter.me.isle.initDalleBuildActions();
		Inter.me.mcBackBut.removeMovieClip();
		Inter.me.isle.loadDefaultPanel();
	}


	//
	function getBuildingDisplayPriority(b:_Bld){
		switch(b){

			case FIELD:		return 0;
			case QUARRY:		return 1;
			case WEAVER:		return 2;
			case WORKSHOP:		return 3;
			case PUMP:		return 4;
			case BARRACKS:		return 8;
			case SCHOOL:		return 9;
			case ARCHITECT:		return 11;
			case WATCH_TOWER:	return 12;
			case FORT:		return 13;

			case CANON:		return 20;
			case YELLER:		return 21;
			case FARM:		return 22;
			case WINDMILL:		return 23;
			case FOUNDRY:		return 24;
			case FIRE_STATION:	return 25;
			case BUNKER:		return 26;
			case LABORATORY:	return 27;

			case UNIVERSITY:	return 28;
			case FACTORY:		return 29;
			case ARCHIMORTAR:	return 30;

			case TOWNHALL:		return 40;


			case HUT:		return 0;
			case CORN:		return 1;
			case FOUNTAIN:		return 2;
			case MENHIR:		return 3;
			case SCULPTOR:		return 4;

			case GOLEM:		return 10;
			case CAULDRON:		return 11;
			case MINE:		return 12;

			case DOJO:		return 20;

			case GARDENER:		return 30;
			case FOREST:		return 31;
			case FLOWERS:		return 32;

			case SOURCE:		return 40;
			case SHRINE:		return 41;
			case PURIFICATION_TANK:	return 42;


			case STONE_FORGE:	return 44;
			case ORB:		return 45;
			case HOT_SPRING:	return 46;
			case MAGIC_TREE: 	return 47;
			case GOLEM_LAUNCHER:	return 48;

			case SPRAYER:		return 50;


			case TEMPLE:		return 60;

		}

		return 0;
	}



//{
}















