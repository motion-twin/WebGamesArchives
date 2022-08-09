import Datas;
import Protocol;

class Api {//}

	#if prod

	#else
		static var FAKE_LAG = 500;
		static var DEV_MODE = MODE_PLAY;
		static var RANDOM_SHIP = false;
	#end

	public static var IS_YOTA = false;
	static var ERROR = false;
	public static var VERSION : Int = null;
	static var KEY : String = null;
	static var REQUEST_COUNTER = 0;
	static inline var MAX_REQUESTS = 100;
	static inline var MAX_PARALLEL_REQUESTS = 1;
	static var QUEUE = new List();

	public static function isReady() : Bool {
		return (!ERROR) && (REQUEST_COUNTER + QUEUE.length) < MAX_PARALLEL_REQUESTS;
	}

	static function decode( k:String, s:String ) : String {
		return Base64.decode(new Codec(k).decode(s));
	}

	static function encode( k:String, s:String ) : String {
		return new Codec(k).encode(Base64.encode(s));
	}

	static function redirectError( url:String, err:String ){
		ERROR = true;
		if (IS_YOTA)
			haxe.Firebug.trace("redirecting to "+url+" because of "+err);
		var err = StringTools.urlEncode(err);
		flash.Lib.getURL(url+"?err="+err, "_self");
	}

	// CLIENT --> SERVEUR
	static function request( cmd:_ServerRequest, ?onConfirm:Void->Void, retry:Int=3 ){
		if (KEY == null)
			KEY = Reflect.field(flash.Lib._root, "k");
		IS_YOTA = (Game.me.playerId == 1 || Game.me.playerId == 2);
		if (retry < 0){
			redirectError("/game/"+Game.gameId, "Maximum retry reached");
			throw "Maximum retry reached for command "+Std.string(cmd);
		}
		if (QUEUE.length + REQUEST_COUNTER >= MAX_REQUESTS){
			redirectError("/game/"+Game.gameId, "Too many requests");
			throw "Too many requests, something wrong occured with the client";
		}
		var request = new haxe.Http("/game/"+Game.gameId+"/command.xml");
		haxe.Serializer.USE_ENUM_INDEX = true;
		request.setParameter('pv', '2');
		request.setParameter('rnd', Std.string(Std.random(99999999)));
		request.setParameter("x", encode(KEY, haxe.Serializer.run(cmd)));
		request.onError = function(e:Dynamic){
			--REQUEST_COUNTER;
			if (retry >= 0){
				haxe.Timer.delay(function() Api.request(cmd, onConfirm, retry-1), 10000);
			}
			else {
				Inter.me.trace("Request error : "+Std.string(e));
				Inter.me.toggleTracer(true);
			}
		}
		request.onData = function(str:String){
			--REQUEST_COUNTER;
			try {
				var xml = Xml.parse(str).firstElement();
				if (xml.nodeName == "error"){
					if (xml.firstChild().nodeValue.indexOf("decode CRC failed") != -1
						|| xml.firstChild().nodeValue.indexOf("ActionReservedToObjectOwner") != -1){
						// Assume user has been disconnected (and reconnected) from another tab
						redirectError("/home", "CRC or owner");
					}
					throw "WEB ERROR: "+xml.firstChild().nodeValue;
				}
				if (xml.get("v") != null && VERSION != null && Std.parseInt(xml.get("v")) != VERSION){
					// New client.swf version available
					flash.Lib.getURL("/game/"+Game.gameId, "_self");
					return;
				}
				var msg = null;
				try {
					msg = if (xml.get("nc") == null)
						decode(KEY, StringTools.htmlUnescape(xml.firstChild().nodeValue))
						else
							Base64.decode(xml.firstChild().nodeValue);
				}
				catch (e:Dynamic){
					// Assume user has been disconnected from another tab
					if (IS_YOTA){
						haxe.Firebug.trace(Std.string(e));
						haxe.Firebug.trace(Std.string(xml));

					}
					else {
						redirectError("/home", "Decode error nc="+xml.get("nc"));
					}
					return;
				}
				var res : { _t:Float, _r:_ServerResponse } = haxe.Unserializer.run(msg);

				Game.me.setTimeDif( res._t );

				switch (res._r){
					case GameStatus(data): receiveDataGame(data);
					case PlayerStatus(data): receiveStatus(data, onConfirm);
					case IsleStatus(data, pstatus): receiveDataPlanet(data, pstatus, onConfirm);
					case SearchStatus(data): throw "Received SearchStatus this should not occur"; //receiveDataResearch(data);
					case WorldStatus(data): receiveWorld(data, onConfirm);
					case Confirm:
						confirm(onConfirm);
					case Chat(data): receiveChat(data, onConfirm);
					case GameEnded:
						flash.Lib.getURL("/game/"+Game.gameId, "_self");
					case Settled(mode,isle): confirmSettle(isle, mode, onConfirm);
					case Error(kind): receiveError(kind);
					case Fight(data): receiveFight(data, onConfirm);
				}
			}
			catch (e:Dynamic){
				var m = Std.string(e);
				if (m.indexOf("Xml parse error") != -1){
					if (retry >= 0){
						haxe.Timer.delay(function() Api.request(cmd, retry-1), 10000);
					}
					else {
						Inter.me.trace("Xml parse error : \n"+m.substr(0,400));
						Inter.me.toggleTracer(true);
					}
					return;
				}
				Inter.me.trace("Erreur détectée, si cela se reproduit merci de vérifier votre connexion internet et de vider le cache de votre navigateur (vous pouvez demander de l'aide sur le forum).");
				Inter.me.trace(m);
				Inter.me.toggleTracer(true);
			}
			if (QUEUE.length > 0 && REQUEST_COUNTER < MAX_PARALLEL_REQUESTS){
				REQUEST_COUNTER++;
				QUEUE.pop().request(false);
			}
		}
		if (REQUEST_COUNTER < MAX_PARALLEL_REQUESTS){
			REQUEST_COUNTER++;
			request.request(false);
		}
		else
			QUEUE.push(request);
	}

	// Demande les infos de la partie [gid];
	static public function getDataGame(gid:Int){
		Inter.me.initLoading();

		#if prod
			request(_ServerRequest.GameStatus);
		#else

			var plts = Tools.buildMap2(0,8).list;

			// NEAR
			var plts = Tools.buildMap2(0,8).list;
			var nears = [];
			var list = [];
			for( pl in plts ){
				var a = [];
				var id = 100;
				for( pl2 in plts ){
					if( pl!=pl2 ){
						var dx = pl.x-pl2.x;
						var dy = pl.y-pl2.y;
						if( Math.sqrt(dx*dx+dy*dy) < 350 )a.push(id);
					}
					id++;
				}
				list.push(a);
			}


			// PLANETS
			var planets = [];
			var ships = [];
			var travels = [];
			var a = [];
			for( i in 0...24 ){
				var pl = {_id:100+i,_owner:null, _view:100, _attributes:new List()};
				if( Std.random(2)==0 )pl._view = 300;
				//if( Std.random(3)>0 )pl._owner = Std.random(8);
				//if( Std.random(5)==0 )pl._owner = 0;
				//if( pl._owner == 0 && SETTLER )pl._owner = null;
				planets.push(pl);
				a.push(i);
			}

			for( i in 0...8 ){
				var index = Std.random(a.length);
				if( i == 0 ) index = 21;
				var pl = planets[a[index]];
				a.splice(index,1);
				pl._owner = i;
				if( DEV_MODE==MODE_INSTALL && i==0 )pl._owner = null;
			}

			if(RANDOM_SHIP){
				// SHIPS + TRAVELS
				var id = 0;
				for( pl in planets ){
					if( pl._owner!=null ){
						// SHIPS
						var max = 1+Std.random(80);
						var cships = [];
						for( i in 0...max ){
							var ship = { _id:ships.length, _status:0, _type:[APICOPTER,DRAKKAR,BALLOON,BOMBER,HARPIE,MIRE,CONDOR][Std.random(7)], _owner:pl._owner, _life:20+Std.random(80), _pid:pl._id, _tid:null };
							ships.push(ship);
							cships.push(ship);
						}

						// TRAVELS
						var tmax = 1+Std.random(3);
						var a = list[id];

						for( i in 0...tmax ){
							var tr:DataTravel = {
								_id:travels.length,
								_owner:pl._owner, _start:pl._id,
								_dest:null,
								_move:{_start:1000000.0-Std.random(50000),
								_end:1000000.0+Std.random(100000)},
								_status:{_priorities:new List(),_oneshot:true,_autocol:false},
								_origin:0,
								_attributes:new List(),
							};
							var flAdd = false;
							for( ship in cships ){
								if( ship._pid!=null && Std.random(3)==0 ){
									ship._pid = null;
									ship._tid = tr._id;
									flAdd = true;
								}
							}

							//
							if(flAdd){
								var did = Std.random(a.length);
								tr._dest = a[did];
								a.splice(did,1);
								travels.push(tr);
							}


							if(a.length==0)break;


						}
					}
					id++;
				}

			}
			//
			var data:DataGame = {
				_id:0,
				_playerId:0,
				_world:{
					_mode:DEV_MODE,
					//_time:(SETTLER || WAIT_PLAYER )?null:1000000.0,
					_time:1000000.0,
					_ships:ships,
					_travels:travels,
					_planets:planets,
					_players:[],
				},
				_tecModels:[],

				_plMax:8,

				_status:devGenStatus( {_start:900000.0,_end:1020000.0} ),

				_urlImg:"../img/",

			}

			// GEN SKIN
			for( o in data._world._players ){
				var str= "";
				for( i in 0...8 )str+=Std.random(20)+",";
				o._skin = str;
			}

			haxe.Timer.delay( callback(receiveDataGame,data), Std.random(FAKE_LAG) );
		#end

	}

	// Demande les infos de la planète [pid];
	static public function getDataPlanet(pid:Int, onConfirm:Void->Void){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.IsleStatus(pid), onConfirm);
		#else
		var data = devGenBlankPlanet(pid);
		haxe.Timer.delay( callback(receiveDataPlanet, data, null, onConfirm), Std.random(FAKE_LAG) );
		#end

	}

	// Demande le yard de la planète [pid];
	/*
	static public function getYard(pid:Int){
		Inter.me.initLoading();
		#if prod
			request(_ServerRequest.YardStatus(pid));
		#else
			var pl = Game.me.getPlanet(pid);//Game.me.planets[pid];
			haxe.Timer.delay( callback(receiveDataYard,pl.yard,null), Std.random(FAKE_LAG) );
		#end
	}
	*/

	// Demande le status du joueur principal
	static public function getStatus( onConfirm:Void->Void ){
		//Inter.me.initLoading();
		#if prod
		request(_ServerRequest.PlayerStatus, onConfirm);
		#else
		var falseStatus = devGenStatus(Inter.me.mcBar.counter);
		haxe.Timer.delay( callback(receiveStatus, falseStatus, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// Demande le détail du combat [id];
	static public function getFight(id:Int){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.FightGet(id));
		#else
		haxe.Timer.delay( callback(receiveFight,devGenFight()), Std.random(FAKE_LAG) );
		#end
	}

	// Demande les infos du monde
	static public function getWorld( onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.WorldStatus, onConfirm);
		#else
		var data = Game.me.world.data;
		data._time = Game.me.now();//+Game.me.timeDif;
		haxe.Timer.delay( callback(receiveWorld, data, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// Installation du joueur sur la planete [pid];
	static public function settleDown(pid:Int,x,y){
		Inter.me.initLoading();
		#if prod
			request(_ServerRequest.StartThere(pid, x, y));
		#else
			//haxe.Timer.delay( callback(receiveWorld,null), Std.random(FAKE_LAG) );
			var data = devGenBlankPlanet(pid);
			data._owner = 0;
			data._bld = [
				{ _id:0, _type:TOWNHALL, _life:100, _x:x, _y:y, _progress:1.0 },

			];
			haxe.Timer.delay( callback(confirmSettle,data,MODE_WAIT), Std.random(FAKE_LAG) );
		#end

	}

	// lance la construction de [bld], sur la planète [pid] à la position [x][y]
	static public function construct( pid:Int, bld:_Bld, ?x:Int, ?y:Int, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.BuildBuilding(pid, bld, x, y), onConfirm);
		#else
		var pl = Game.me.getPlanet(pid);
		var bat = BuildingLogic.get(bld);
		var now = Game.me.now();
		var c = {_start:now, _end:now+bat.life*1000};
		var o:DataConstruct = {_type:Building(bld),_counter:c, _progress:0.0};
		if( Std.random(pl.yard.length+1)==0 )o._progress = Math.random();
		pl.yard.push(o);
		haxe.Timer.delay( callback(receiveDataPlanet,devGenPlanet(pid),null,onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// lance la construction de [shp], sur la planète [pid]
	static public function constructShip( pid:Int, shp:_Shp, mult=1, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.BuildShip(pid, shp, mult), onConfirm);
		#else
		var pl = Game.me.getPlanet(pid);
		pl.yard.push({_type:Ship(shp),_counter:null, _progress:Math.random()});
		var dp = devGenPlanet(pid);
		haxe.Timer.delay( callback(receiveDataPlanet,dp,null,onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// detruit le batiment a la position x:Int, y:Int
	static public function destroyBuilding(pid:Int, x:Int, y:Int, type:_Bld, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.DestroyBuilding(pid,x,y), onConfirm);
		#else
		var dp = devGenPlanet(pid);
		for( b in dp._bld ){
			if( b._type == type && b._x == x && b._y == y ){
				dp._bld.remove(b);
				break;
			}
		}
		haxe.Timer.delay( callback(receiveDataPlanet, dp, null, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// abandonne la construction numero [index]
	static public function abortConstruct( pid:Int, index:Int, flKillGroup:Bool, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.BuildCancel(pid, index, flKillGroup), onConfirm);
		#else
		var pl = Game.me.getPlanet(pid);
		pl.yard.splice(index,1);
		var dp = devGenPlanet(pid);
		haxe.Timer.delay( callback(receiveDataPlanet, dp, null, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	// Change la position de la construction [id] vers l'index [id2]
	static public function swapConstruct(pid:Int, id:Int, id2:Int, onConfirm:Void->Void){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.YardSwap(pid, id, id2), onConfirm);
		#else
			var pl = Game.me.getPlanet(pid);
			pl.yard.splice(id,1);
			//
			var dp = devGenPlanet(pid);
			haxe.Timer.delay( callback(receiveDataPlanet,dp,null,onConfirm), Std.random(FAKE_LAG) );
		#end

	}

	// Active/désactive une technologie
	static public function enableTec( t:_Tec, enabled:Bool, onConfirm ){
		haxe.Firebug.trace("enableTec "+t+" "+enabled);
		Inter.me.initLoading();
		request(_ServerRequest.EnableTec(t, enabled), onConfirm);
	}

	//  Change la position de la recherche [id] vers l'index [id2]
	static public function swapResearch( id:Int, id2:Int, onConfirm ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.SearchSwap(id, id2), onConfirm);
		#else
		var status = devGenStatus(null);

		var res = Game.me.research;
		var tec = res[id];
		var tec2 = res[id2];
		res[id] = tec2;
		res[id2] = tec;

		status._research = res;
		haxe.Timer.delay( callback(receiveStatus, status, onConfirm), Std.random(FAKE_LAG));
		#end
	}

	// Donne un nouvel ordre pour les technos non finies
	static public function loadTechnoOrder( a:Array<_Tec>, onConfirm:Void->Void ){
		Inter.me.initLoading();
		request(_ServerRequest.SearchOrder(a), onConfirm);
	}

	// rase le batiment [bid] de la planète [pid]
	static public function raz( pid:Int, bid:Int ){

	}

	// envoie une flotte [list] a la planete [from] a la planete [to]
	static public function sendFleet( from:Int, to:Int, list:Array<Int>,fst:FleetStatus ){
		if (from == null || to == null || list.length == 0)
			return;
		Inter.me.initLoading();
		#if prod
			request(_ServerRequest.StartTravel(from, list, to, fst));
		#else
			//var world = Game.me.getLastWorld();
			var world = Game.me.world.data;//Inter.me.map.lastWorld;
			var now = Game.me.now();
			var prio = new List();
			prio.push(BT_RES);
			var tr = {
				_id:world._travels.length,
				_owner:Game.me.getPlanet(from).owner,
				_start:from,
				_dest:to,
				_move:{_start:now,_end:now+5000+Std.random(100000)},
				_origin:0,
				_status:fst,
				_attributes:new List(),
			};
			world._travels.push(tr);
			var a = list.copy();
			for( sh in world._ships ){
				var flAdd = false;
				for( sid in a ){
					if( sid == sh._id ){
						flAdd = true;
						a.remove(sid);
						break;
					}
				}
				if( flAdd ){
					sh._pid = null;
					sh._tid = tr._id;
				}
			}


			haxe.Timer.delay( callback(receiveWorld,world), Std.random(FAKE_LAG) );
		#end
	}

	static public function updateFleet( travelId:Int, fst:FleetStatus ){
		Inter.me.initLoading();
		#if prod
			request(_ServerRequest.ModifyTravel(travelId, fst));
		#else
			haxe.Timer.delay( confirm, Std.random(FAKE_LAG) );
		#end
	}

	// annule le déplacement d'une flotte.
	static public function cancelMove( travelId:Int, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.CancelTravel(travelId), onConfirm);
		#else
		#end
	}

	static public function colonize( isleId:Int, units:Array<Int>, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.Drop(isleId, units), onConfirm);
		#else
		haxe.Timer.delay( callback(receiveWorld,null, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	static public function destroyFleetUnits ( units:Array<Int>, onConfirm:Void->Void ){
		request(_ServerRequest.DestroyUnits( units), onConfirm);
	}

	static public function getChat( onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.ChatGet, onConfirm);
		#else
		var chat =[
			{ _from:0, _txt:"Kikou !!",	_time:0.0, _canal:Std.random(256) },
			{ _from:1, _txt:"Ca va !?",	_time:0.0, _canal:Std.random(256) },
			{ _from:2, _txt:"Burp",		_time:0.0, _canal:Std.random(256) },
			{ _from:1, _txt:"Bien et toi",	_time:0.0, _canal:Std.random(256) },
			{ _from:2, _txt:"Kikou !!",	_time:0.0, _canal:Std.random(256) },
			{ _from:0, _txt:"Kikou !!",	_time:0.0, _canal:Std.random(256) },
			{ _from:3, _txt:"Kikou !!",	_time:0.0, _canal:Std.random(256) },
			{ _from:0, _txt:"Kikou !!",	_time:0.0, _canal:Std.random(256) },

		];
		haxe.Timer.delay( callback(receiveChat, chat, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	static public function writeChat( msg:String, canal:Int, onConfirm:Void->Void ){
		Inter.me.initLoading();
		#if prod
		request(_ServerRequest.ChatWrite(msg,canal), onConfirm);
		#else
		var msg = { _from:Game.me.playerId, _txt:msg, _time:Game.me.now(), _canal:canal };
		inter.mod.Chat.content.push(msg);
		haxe.Timer.delay( callback(receiveChat,inter.mod.Chat.content, onConfirm), Std.random(FAKE_LAG) );
		#end
	}

	static public function next(isleId, onConfirm:Void->Void){
		Inter.me.initLoading();
		request(_ServerRequest.Next(isleId), onConfirm);
		// null return World
		// X return Planet
	}

	static public function saveTecModels(){
		Inter.me.initLoading();
		request(_ServerRequest.SaveTecModels(Param.tecModels));
	}

	// SERVEUR --> CLIENT
	static public function receiveDataGame( data:DataGame ){
		Inter.me.removeLoading();
		Game.me.init(data);
	}

	static public function receiveDataPlanet( data:DataPlanet, ?pstatus:DataStatus, onConfirm:Void->Void ){
		if(pstatus!=null) Game.me.loadStatus(pstatus);
		var pl = Game.me.getPlanet(data._id);
		pl.loadData(data);
		confirm(onConfirm);
	}

	static public function receiveStatus( d:DataStatus, onConfirm:Void->Void ){
		var dif = d._maj._end - Game.me.now();
		Game.me.loadStatus(d);
		confirm(onConfirm);
	}

	static public function receiveWorld( d:DataWorld, onConfirm:Void->Void ){
		Game.me.world.load(d);
		confirm(onConfirm);
	}

	static public function receiveFight( d:DataFight, onConfirm:Void->Void ){
		Inter.me.isle.loadFight(d);
		confirm(onConfirm);
	}

	static public function receiveFailure(str){
		Inter.me.removeLoading();
		// onFailure();
	}

	// confirmation d'une commande
	static public function confirmSettle(data:DataPlanet, mode:_GameMode, onConfirm:Void->Void){
		Game.me.world.data._mode = mode;
		if( mode == MODE_INSTALL ){
			Inter.me.isle.leave();
		}else{
			var pl = Game.me.getPlanet(data._id);
			pl.loadData(data);
			Inter.me.isle.superMaj();
			Inter.me.launchMode();
		}
		Game.me.world.lastUpdate = null;
		confirm(onConfirm);
	}

	static public function confirm( onConfirm:Void->Void ){
		if (Inter.me.flLoading)
			Inter.me.removeLoading();
		if (onConfirm != null)
			onConfirm();
	}

	static public function receiveChat( data:Array<DataMsg>, onConfirm:Void->Void ){
		inter.mod.Chat.load(data);
		confirm(onConfirm);
	}

	static public function receiveError( e:_ErrorKind ){
		if (Inter.me.flLoading)
			Inter.me.removeLoading();
		Inter.me.trace(e);
		Inter.me.msgBox( Lang.ERROR, Lang.getErrorMsg(e));
	}

	// DEV ONLY
	#if prod
	#else
	static function devGenBlankPlanet(pid){
		var data:DataPlanet = {
			_id:pid,
			_x:0,
			_y:0,
			_def:1,
			_att:1,
			_seed:0,
			_owner:0,
			_pop:5,
			_food:5,
			_yard:[],
			_ship:[],
			_bld:[
				{ _id:0, _type:TOWNHALL, _life:100, _x:12, _y:12, _progress:1.0 },
				{ _id:0, _type:FIELD, _life:100, _x:12, _y:14, _progress:0 },
			],
			_breed:{ _start:900000.0,_end:2000000.0 },
			_news:[
				{
					_date:153651616161551.0,
					_type: _Attack({
						_fightId:0,
						_from:1,
						_to:0,
						_damageAtt:12,
						_damageDef:14,
						_damageBld:0,
						_damageYard:0,
						_damageTwr:0,
						_damagePop:0,

						_casualtyAtt:[APICOPTER,BOMBER,MIRE],
						_casualtyDef:[DRAKKAR,DRAKKAR,DRAKKAR],
						_casualtyBld:[],
						_casualtyPop:0,

					})
				},
				{
					_date:153651616161551.0,
					_type:_Attack({
						_fightId:0,
						_from:1,
						_to:0,
						_damageAtt:12,
						_damageDef:14,
						_damageBld:75,
						_damageYard:0,
						_damageTwr:0,
						_damagePop:0,


						_casualtyAtt:[DRAKKAR],
						_casualtyDef:[DRAKKAR,ATLAS],
						_casualtyBld:[],
						_casualtyPop:4,

					})
				},
				{
					_date:153651616161551.0,
					_type: _Attack({
						_fightId:0,
						_from:2,
						_to:0,
						_damageAtt:0,
						_damageDef:0,
						_damageBld:344,
						_damageYard:0,
						_damageTwr:0,
						_damagePop:0,


						_casualtyAtt:[],
						_casualtyDef:[],
						_casualtyBld:[FIELD,WINDMILL],
						_casualtyPop:2,

					})
				}
			],
			_ruins:[],
		}
		if( DEV_MODE == MODE_INSTALL ){
			data._owner = null;
			data._bld = [];
			data._news = [];
		}
		return data;
	}

	static function devGenPlanet(pid:Int){
		var pl = Game.me.getPlanet(pid);
		var data:DataPlanet = {
			_id:pid,
			_x:pl.x,
			_y:pl.y,
			_seed:0,
			_owner:pl.owner,
			_pop:pl.pop,
			_food:pl.food,
			_yard:pl.yard,
			_ship:pl.shp,
			_bld:pl.bld,
			_breed:{ _start:900000.0,_end:2000000.0 },
			_news:pl.news,
			_ruins:[],
			_def:1,
			_att:1,

		}
		return data;
	}

	static function devGenStatus(oc:Counter){
		var res = Game.me.res;
		if( res == null ){
			res = {
				_material:100,
				_cloth:0,
				_ether:30,
				_pop:null,
			};
		}
		return {
			_tickMaterial:21,
			_tickEther:5,
			_maj:{_start:oc._end,_end:oc._end+100000},
			_res:res,
			_tec:[_Tec.PARACHUTE,_Tec.CANON_POWDER,_Tec.HELICE],
			_research:[
				{ _type:_Tec.FERTILIZER,	_counter:{ _start:900000.0,_end:2000000.0 }, _progress:0.75},
				{ _type:_Tec.ACIETHER,		_counter:null, _progress:Math.random()},
				{ _type:_Tec.FORTIFIED_CLOTH,	_counter:null, _progress:Math.random()},
			],
			_searchRate:0.75,
			_units:5,
			_unitMax:15,
		}
	}

	static function devGenFight(){
		var data = {
			_defenderId:4,
			_bld:[],
			_ships:[],
			_history:[],
			_yard:{ _id:1, _type:_Bld.FIELD, _life:200, _x:12, _y:14, },
		}

		var ents_life = [];

		//_bld
		data._bld = [
			{ _id:1, _type:_Bld.TOWNHALL, _life:200, _x:12, _y:12, _progress:1.0	},
			{ _id:2, _type:_Bld.CANON, _life:100, _x:9, _y:9, _progress:1.0		},
			{ _id:3, _type:_Bld.CANON, _life:60, _x:9, _y:7, _progress:1.0		},
			{ _id:4, _type:_Bld.CANON, _life:20, _x:14, _y:13, _progress:1.0	},
			{ _id:5, _type:_Bld.FIELD, _life:30, _x:11, _y:9, _progress:1.0		},
			{ _id:6, _type:_Bld.FIELD, _life:30, _x:12, _y:14, _progress:0.5	},
		];
		for( b in data._bld )	ents_life.push(b._life);

		// FLEET
		var base = 1000;
		var max = 1+Std.random(100);
		for( i in 0...max ){
			for( n in 0...2 ){
				var ship = {
					_id:base+i+n*max,
					_type:[APICOPTER,DRAKKAR,MIRE,CONDOR,CONDOR,ATLAS][Std.random(6)],
					_owner:(n==0)?4:7,
					_life:0,
					_pid:null,		// PLANET ID
					_tid:null,
					_status:0,
				}
				var car = Tools.getShipCaracs(ship._type,null,null,null);
				ship._life = Std.int(car.life*(0.1+Math.random()*0.9));
				data._ships.push(ship);
				ents_life[ship._id] = ship._life;
			}
		}

		// ASSAULTS - SHIPS
		var assaults = [];
		for( o in data._ships ){
			var amax = 1;
			var car = Tools.getShipCaracs(o._type,null,null,null);
			for( cap in car.capacities ){
				switch(cap){
					case Multi(x):
						amax=x;
					default:
				};
			}
			var sid = Type.enumIndex(o._type)*2 + ((o._owner==4)?0:1);
			if( assaults[sid] == null ) assaults[sid] = [];

			for( i in 0...amax ){
				var ass = {
					_id:o._id,
					_trg:base+Std.random(max),
					_damage:car.power,
				}
				if( o._owner == 4 )ass._trg += max;
				else if( Std.random(5) == 0 )ass._trg = 1+Std.random(5);
				assaults[sid].push(ass);
				ents_life[ass._trg] -= ass._damage;
			}
		}

		//for( a in assaults )if(a!=null)data._history.push( Assault(a) );
		data._history.push( Assault(assaults[Std.random(assaults.length)+1]) );

		// ASSAULT - CANON
		var a = [];
		for( b in data._bld ){
			if( b._type == _Bld.CANON ){
				var ass = {
					_id:b._id,
					_trg:base+max + Std.random(max),
					_damage:15,
				}
				a.push( ass );
			}
		}
		data._history.push( Assault(a) );

		// DEATH
		var a = [];
		for( id in 0...ents_life.length ){
			if( ents_life[id]!=null && ents_life[id] <= 0 )a.push(id);
		}
		data._history.push( Destroy(a) );
		return data;
	}
	#end
//{
}
