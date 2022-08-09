import Datas;



class Tools{//}

	static public function buildMap2( n, pmax ){
		try {
		var seed =  new mt.Rand(n);
		var list:Array<{x:Int,y:Int,seed:Int,range:Int}> = [];
		list.push({x:0,y:0,seed:seed.random(100000),range:0});
		var planetMax = pmax*2 + 1;
		// planetes meres
		var ray = 200;
		var tol = 35;
		var to = 0;
		var malus = 0;
		var maxRange = 2;
		while( list.length < planetMax ){
			var base = list[seed.random(list.length)];
			var a = seed.rand()*6.28;
			var x = base.x + Math.cos(a)*ray;
			var y = base.y + Math.sin(a)*ray;
			var flInsert = true;
			if( base.range < maxRange ){
				for( pl in list ){
					var dx = pl.x - x;
					var dy = pl.y - y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					var dif = Math.abs(dist-ray);
					if( dif > tol && dist<300   ){
						flInsert = false;
						break;
					}
				}
				if(flInsert){
					list.push( {x:Std.int(x),y:Std.int(y),seed:seed.random(100000),range:base.range+1} ) ;
					to = 0;
				}
			}
			if( to++ > 180 ){
				maxRange++;
				//trace("GENERATOR LOOP");
				//break;
			}
		}
		var margin = 80;
		var xMin = 0.0;
		var xMax = 0.0;
		var yMin = 0.0;
		var yMax = 0.0;
		for( pl in list ){
			xMin = Math.min( pl.x, xMin );
			xMax = Math.max( pl.x, xMax );
			yMin = Math.min( pl.y, yMin );
			yMax = Math.max( pl.y, yMax );
		}
		var ww = Std.int( xMax+2*margin - xMin );
		var hh = Std.int( yMax+2*margin - yMin );
		var dw = 0.0;
		var dh = 0.0;
		if( ww < GamePlay.WORLD_WIDTH ) dw = GamePlay.WORLD_WIDTH - ww;
		if( hh < GamePlay.WORLD_HEIGHT ) dh = (GamePlay.WORLD_HEIGHT-GamePlay.INTER_BH)-hh;
		for( pl in list ){
			pl.x += Std.int( dw*0.5+margin-xMin );
			pl.y += Std.int( dh*0.5+margin-yMin );

		}
		ww += Std.int(dw);
		hh += Std.int(dh);
		return {width:ww,height:hh,list:list};
		}
		catch (e:Dynamic){
			/*haxe.Firebug.trace(Std.string(e));
			haxe.Firebug.trace(haxe.Stack.exceptionStack().join("\n"));*/
			throw e;
		}
	}

	/*
	static public function buildMap(n,mcw,mch,plmax){

		var seed =  new mt.Rand(n);
		var list:Array<{x:Int,y:Int,seed:Int}> = [];

		var dmin = Cns.ISLE_DIST_MIN;
		var dmax = Cns.ISLE_DIST_MAX;
		var ray = 80;
		for( i in 0...plmax ){
			var to = 0;
			while(true){

				var x = ray+seed.random(mcw-2*ray);
				var y = ray+seed.random(mch-2*ray);

				var flOk = list.length==0;
				for( o in list ){
					var dx = x-o.x;
					var dy = y-o.y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist<dmax )	flOk = true;
					if( dist<dmin ){
						flOk = false;
						break;
					}
				}

				if( flOk ){
					list.push( { x:x, y:y, seed:seed.random(100000) } );
					break;
				}

				if( to++>400 ){
					trace("ERROR - loop buildMap( "+n+", "+mcw+", "+mch+", "+plmax+", "+dmin+", "+dmax+" )" );
					break;
				}
			}
		}

		return list;
	}


	*/
	static public function buildIsle(n){


		var seed =  new mt.Rand(n);
		var type = seed.random(3);

		var centerMin = 11;
		var centerMax = 14;


		var landSize = 47-type*8;
		//landSize += 100;
		var near = [];
		var grid = [];
		var list = [];
		//var first = [[12,12],[13,13],[12,13],[13,12]];
		for( x in 0...Cns.GRID_MAX )grid[x] = [];
		var first = [];
		for( x in centerMin...centerMax ){
			for( y in centerMin...centerMax ){
				first.push([x,y]);
			}
		}


		var side = 4.0;

		// FILL
		while( landSize>0 ){

			var p = null;
			if( first.length>0){
				p = first.pop();
			}else{
				var index = seed.random(near.length);
				p = near[index];
				near.splice(index,1);
			}

			if(grid[p[0]][p[1]]==null){
				landSize--;
				grid[p[0]][p[1]] = 0;
				list.push(p);
				for( d in Cns.DIR ){
					var nx = p[0] + d[0];
					var ny = p[1] + d[1];
					if( grid[nx][ny] == null && Cns.isIn(nx,ny)){
						near.push([nx,ny]);
					}
				}

			}
			// NEW FOYER
			if( seed.random(2)==0 && (landSize==30 || landSize==45 || landSize==50) ){
				var p  = Cns.randomPos(seed);
				near.push( [p.x,p.y] );
			}
		}


		// ETHER SOURCES
		var inc = 3;
		var pw = 4;
		var max = 1+type;
		var a = list.copy();
		var a2 = a.copy();
		//trace("---"+Std.random(4)+"-"+max);
		for( p in a2 ){
			if( p[0]>=centerMin && p[0]<centerMax && p[1]>=centerMin && p[1]<centerMax ){
				//trace("remove("+p[0]+";"+p[1]+")");
				a.remove(p);
			}
		}

		for( i in 0...max ){
			var index = seed.random(a.length);
			var p = a[index];
			a.splice(index,1);
			//trace(p[0]+";"+p[1]);
			grid[p[0]][p[1]] = 1;
		}
		return grid;

	}

	static public function getShipCaracs( type:_Shp,tecs:Array<_Tec>,fa:List<_FleetAttribute>,pa:List<_PlanetAttribute>){

		var car  = ShipLogic.get(type);
		car = car.applyUserTechnos(Lambda.list(tecs));

		// FLEET ATTRIBUTES
		for( att in fa ){
			switch(att){
				case FA_GOLEMISSARY :
					if( type == _Shp.HOPLITE || type == _Shp.GOLIATH ){
						car.power *= 2;
						var a = car.capacities.copy();
						for( c in a ){
							switch(c){
								case Raid(n) :
									car.capacities.remove(c);
									car.capacities.push(Raid(n));
								case Bomb(n) :
									car.capacities.remove(c);
									car.capacities.push(Bomb(n));
								default :
							}
						}
					}
				case FA_LAUNCHED :
					if( type == _Shp.HOPLITE || type == _Shp.GOLIATH ){
						car.speed += 100;
						car.range += 200;
					}
			}
		}

		// PLANET ATTRIBUTES
		for( att in pa ){
			switch(att){
				case PA_GOLEM_LAUNCHER:
					if( type == _Shp.HOPLITE || type == _Shp.GOLIATH ){
						car.speed += 100;
						car.range += 200;
					}

				case PA_WATCH_TOWER:
					// TODO: bla bla bla si c'est bien mon île et tout le bazar
			}
		}
		return car;

	}

	static public function getBldCost(type:_Bld){
		var b = BuildingLogic.get(type);
		return b.cost;
	}
	static public function getShpCost(type:_Shp){
		var s = ShipLogic.get(type);
		return s.cost;
	}

	static public function getTravelTime(speed:Float,dist:Float){
		return Math.round(  (dist / speed * GamePlay.TICK) * GamePlay.TRAVEL_TIME_RATIO);
	}

	/*
	static public function getAvailableConstruct( bld:Array<_Bld>, tec:Array<_Tec> ){
		var a = [];
		for( i in )

	}
	*/

//{
}
