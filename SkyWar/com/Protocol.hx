import Datas;

enum _ServerRequest {
	PlayerStatus;
	GameStatus;
	WorldStatus;
	StartThere(isleId:Int, x:Int, y:Int);
	IsleStatus(isleId:Int);
	YardSwap(isleId:Int, idx:Int, destIdx:Int);
	SearchSwap(idx1:Int, idx2:Int);
	SearchOrder(a:Array<_Tec>);
	SearchStatus();
	Build(isleId:Int, s:_Struct, x:Int, y:Int); // Deprecated
	BuildCancel(isleId:Int, idx:Int, group:Bool );
	DestroyBuilding(isleId:Int, x:Int, y:Int);
	StartTravel(isleId:Int, units:Array<Int>, destId:Int, fst:FleetStatus);
	ModifyTravel(tid:Int, fst:FleetStatus);
	CancelTravel(tid:Int);
	Drop(isleId:Int, units:Array<Int>);
	ChatGet;
	ChatWrite(msg:String,canal:Int);
	Next(rcvType:Int);
	FightGet(id:Int);
	DestroyUnits(units:Array<Int>);
	BuildBuilding(isleId:Int, b:_Bld, x:Int, y:Int);
	BuildShip(isleId:Int, s:_Shp, n:Int);
	SaveTecModels(a:Array<TecModel>);
	EnableTec(t:_Tec, b:Bool);
}

enum _ServerResponse {
	PlayerStatus(data:DataStatus);
	GameStatus(data:DataGame);
	WorldStatus(data:DataWorld);
	IsleStatus(data:DataPlanet, pstatus:DataStatus);
	SearchStatus(data:Array<DataResearch>);
	Chat(messages:Array<DataMsg>);
	Confirm;
	GameEnded;
	Settled(mode:_GameMode, data:DataPlanet);
	Error(kind:_ErrorKind);
	Fight(data:DataFight);
}

