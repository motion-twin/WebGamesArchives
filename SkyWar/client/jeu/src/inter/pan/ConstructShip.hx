package inter.pan;
import Datas;
import inter.Panel;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


class ConstructShip extends inter.Panel {//}

	var pl:Planet;
	var yardStats:Array<Int>;

	public function new(pl){

		this.pl = pl;
		super();

		display();

		Inter.me.board.setSkin(0,1);


	}


	override function display(){
		super.display();

		cy+= inter.Board.TAB_LINE;

		// GEN YARDSTATS
		genYardStats();


		// SLIDER
		genSlider(height-cy);
		displaySlots(pl.availableShp.length);


	}
	function genYardStats(){

		yardStats = [];
		for(c in pl.yard){
			switch(c._type){
				case Ship(type):
					var n = Type.enumIndex(type);
					if( yardStats[n] == null ) yardStats[n] = 0;
					yardStats[n]++;
				default:
			}
		}
	}


	override function initSlot(mc:Slot,id){

		var type = pl.availableShp[id];
		var sid = Type.enumIndex(type);

		// COST
		var cost = Tools.getShpCost(type);
		displaySlotCost( mc ,cost);

		// NUM
		var num = yardStats[sid];
		if( num > 0 ){

			var mmc = mc.dm.attach("mcConstuctNum",0);
			cast(mmc)._val = Math.min(99, num);

		}

		// BUT
		var flAvailable = true;
		//if( cost.material > Game.me.res._material ) 	flAvailable = false;
		//if( cost.cloth > Game.me.res._cloth ) 		flAvailable = false;
		//if( cost.ether > Game.me.res._ether ) 		flAvailable = false;
		//if( cost.population > Inter.me.isle.pl.pop ) 	flAvailable = false;

		Trick.butAction(mc,callback(selectSlot,mc,type),callback(rOverSlot,mc),callback(rOutSlot,mc));

		if( !flAvailable ){
			mc._alpha = 50;
			mc.blendMode = "layer";
		}

		// HINT
		var str = Lang.getShipDesc(type,pl.owner,0,null,null);
		if( num!=null )	str += "\n"+num+Lang.pluriel( Lang.CONSTRUCT_SHIPS, num>1 ) ;
		Inter.me.makeHint(mc,str,null,true);

		// PIC
		var bat = new mt.DepthManager(mc.pic.smc).attach("mcShipVig",0);
		bat.gotoAndStop( sid+1 );

	}

	// SLOT
	function selectSlot(mc:Slot,type){
		var mult = 1;
		if( flash.Key.isDown(flash.Key.SHIFT) )mult = 5;
		mc.pic.filters = [];
		var me = this;
		Api.constructShip( Inter.me.isle.pl.id, type, mult, function() me.display() );
		Inter.me.isle.removeCursor();
	}
//{
}
