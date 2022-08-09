package race;
import Datas;


class Caush extends Race {//}


	public function new(){
		super();
	}


	public function getBuildingCost(b){
		return switch(b){

			case TOWNHALL :		[ _Fix(300), _Wrk(600),							];
			case WORKSHOP :		[ _Fix(60), _Wrk(240),							];
			case FIELD :		[ _Fix(60), _Wrk(30) 							];
			case HUT :		[ _Fix(20), _Wrk(60), 	_Material(10)					];
			case WEAVER :		[ _Fix(20), _Wrk(60), 	_Material(30)					];
			case QUARRY :		[ _Fix(20), _Wrk(320), 							];

			case WINDMILL :		[ _Fix(20), _Wrk(200),	_Material(30), _Cloth(30)			];

			case BARRACKS :		[ _Fix(10), _Wrk(60),   _Material(50) 					];
			case SHIPYARD :		[ _Fix(10), _Wrk(600),  _Material(120) 					];

			default :		null;
		}
	}
	public function getShipCost(s){
		return switch(s){
			default :		null;
		}
	}




//{
}






















