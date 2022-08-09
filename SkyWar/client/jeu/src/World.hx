import Datas;


class World{//}


	public var data:DataWorld;
	public var lastUpdate:Float;
	public var autoUpdateCycle:Float;

	public function new(){

	}

	public function load(d:DataWorld){
		Game.me.setTimeDif( d._time );
		lastUpdate = Game.me.now();
		//autoUpdateCycle = 60000;
		//if(d._mode == _GameMode.MODE_WAIT )autoUpdateCycle = 15000;
		autoUpdateCycle = Cs.AUTO_UPDATE;
		if(d._mode == _GameMode.MODE_WAIT )autoUpdateCycle =  Cs.AUTO_UPDATE_WAIT_FOR_PLAYER;

		data = d;
		Inter.me.launchMode();
		for( pl in Game.me.planets )pl.lastUpdate = null;

	}

	public function isOld(){
		if( (Game.me.now() - lastUpdate) > autoUpdateCycle  || lastUpdate == null) return true;
		for( tr in data._travels ){
			var o = Game.me.getCounterInfo(tr._move);
			if( o.c >= 1 )return true;
		}
		return false;
	}

	public function getTravel(id){
		for( tr in data._travels ){
			if(tr._id == id)return tr;
		}
		return null;
	}












//{
}