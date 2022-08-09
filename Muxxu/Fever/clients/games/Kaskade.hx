import mt.bumdum9.Lib;

typedef KGrid = 	{ gr:Array<Array<{id:Int,gid:Null<Int>}>>, lvl:Int, count:Int };
typedef KToken = 	{ > flash.display.MovieClip, id:Int, px:Int, py:Int, but:flash.display.Sprite };

class Kaskade extends Game{//}

static var DR = [[1,0],[0,1]];

	static var SPEED_EXPLO = 0.25;
	static var SPEED_FALL = 0.25;
	static var SIZE = 8;
	static var CS = 40;

	var tmax:Int;
	var coef:Float;
	var branch:Int;
	var grid:KGrid;
	var tgr:Array<Array<KToken>>;
	var work:Array<KToken>;



	override function init(dif:Float){

		gameTime =  550-200*dif;
		super.init(dif);
		attachElements();
		tmax = 10+Std.int(dif*25);

		while(true){
			grid = genPuzzle();
			branch = 0;
			if( getSoluce(grid) !=null ){
				display(grid);
				initSelection();
				break;
			}
		}
	}

	function attachElements(){
		bg = dm.attach("kaskade_bg",0);
	}
	override function update(){

		switch(step){
			case 1:
				var grid = genPuzzle();
				branch = 0;
				if( getSoluce(grid) !=null ){
					display(grid);
					initSelection();
				}
			case 2:

			case 3: updateFall();
			case 4:	updateExplosion();

		}

		super.update();
	}

	// GRID TOOL
	function genPuzzle(){
		grid = getGrid(0);
		fill(grid,tmax);
		grav(grid);
		return grid;
	}
	function getGrid(lvl){
		var gr = [];
		for( x in 0...SIZE ) gr.push([]);
		return {gr:gr,lvl:lvl,count:0};

	}
	function clone(o:KGrid){
		branch++;
		var gr =[];
		for( x in 0...SIZE ){
			gr.push([]);
			for( y in 0...SIZE ){
				var p = o.gr[x][y];
				if( p!= null)gr[x][y] = {id:p.id,gid:p.gid};
			}
		}
		return {gr:gr,lvl:o.lvl+1,count:o.count};
	}
	function grav(o:KGrid){
		// FALL Y
		for( x in 0...SIZE ){
			var fall = 0;
			for( dy in 0...SIZE ){
				var y = SIZE-(1+dy);
				var n = o.gr[x][y];
				if( n == null ){
					fall++;
				}else{
					if( fall>0 ){
						o.gr[x][y+fall] = n;
						o.gr[x][y] = null;
					}
				}
			}
		}

		// FALL X

		for( y in 0...SIZE ){
			var fall = 0;
			for( x in 0...SIZE ){
				var n = o.gr[x][y];
				if( n == null ){
					fall++;
				}else{
					if( fall>0 ){
						o.gr[x-fall][y] = n;
						o.gr[x][y] = null;
					}
				}
			}
		}

	}
	function fill(o:KGrid,max:Int){

		var free = [];
		for( x in 0...SIZE )for( y in 0...SIZE )free.push({x:x,y:y});
		for( i in 0...max ){
			var index = Std.random(free.length);
			var p = free[index];
			free.splice(index,1);
			o.gr[p.x][p.y] = {id:Std.random(3),gid:null};
			o.count++;
		}


	}
	function destroy(o:KGrid,gid:Int){
		for( x in 0...SIZE ){
			for( y in 0...SIZE ) {
				var gr = o.gr[x][y];
				if( gr!= null && gr.gid == gid ){
					o.gr[x][y] = null;
					o.count--;
				}
			}
		}
	}
	function getSoluce(o:KGrid):Null<Int>{

		if(branch>100)return null;

		var groups = getGroups(o);

		// ISOLE LES COUPS JOUABLE;
		var a = [];
		var gid = 0;
		for( gr in groups ){
			if(gr.length>1)a.push(gid);
			gid++;
		}

		// VERIFIE LES BRANCHES DE CHAQUE COUPS
		//trace("---"+o.lvl+"---"+a);
		//var str ="";
		//for( gid in a )str+= "- "+groups[gid].length;
		//trace(str);

		for( gid in a ){
			var o2 = clone(o);
			//trace(gid+">"+o2.count+"  groups[gid].length :"+groups[gid].length);
			destroy(o2,gid);
			//trace(gid+"<"+o2.count);
			if( o2.count <= 0 ){
				return o2.lvl;
			}else{
				if(o2.lvl<10){
					grav(o2);
					var sol = getSoluce(o2);
					if( sol!= null )return sol;
				}
			}


		}
		return null;
	}
	function getGroups(o:KGrid){
		var gid = 0;
		var groups = [];
		for( x in 0...SIZE ) for( y in 0...SIZE ) {
			var gr = o.gr[x][y];
			if( gr!=null) gr.gid = null;
		}
		
		for( x in 0...SIZE ){
			for( y in 0...SIZE ){
				var p = o.gr[x][y];
				if( p !=null ){
					if( p.gid == null ){
						p.gid = gid;
						groups[gid] = [p];
						gid++;
					}
					for( d in DR ){
						var nx = x + d[0];
						var ny = y + d[1];
						if( !isIn(nx, ny) ) continue;
						var p2 = o.gr[nx][ny];
						if( p2 !=null ){
							if( p2.id == p.id ){
								if( p2.gid == null ){
									p2.gid = p.gid;
									groups[p.gid].push(p2);
								}else if( p2.gid == p.gid){

								}else{
									var oid = p2.gid ;
									while( groups[oid].length>0 ){
										var p3 = groups[oid].pop();
										p3.gid = p.gid;
										groups[p.gid].push(p3);
									}
								}
							}
						}
					}

				}
			}
		}
		return groups;
	}
	function isIn(x, y) {
		return x >= 0 && x < SIZE && y >= 0 && y < SIZE;
	}

	// TOKENS
	function display(o:KGrid){
		tgr = [];
		for( x in 0...SIZE ){
			tgr.push([]);
			for( y in 0...SIZE ){
				var n = o.gr[x][y];
				if(n!=null){
					var mc:KToken = cast dm.attach("kaskade_token",2);
					mc.x = getX(x);
					mc.y = getY(y);
					mc.px = x;
					mc.py = y;
					mc.gotoAndStop(n.id+1);
					mc.id = grid.gr[x][y].id;
					tgr[x][y] = mc;
				}
			}
		}
	}

	// SELECTION
	function initSelection(){
		step = 2;
		var groups = getGroups(grid);

		if(groups.length==0)setWin(true);

		var flLoose = true;

		var last = [];
		for( x in 0...SIZE ){
			for( y in 0...SIZE ){
				var p = grid.gr[x][y];
				if( p!=null ){
					if( groups[p.gid].length>1 ){
						flLoose = false;
						var mc = tgr[x][y];
						//mc.onPress = callback(destroyGroup,p.gid);
						//mc.useHandCursor = true;
						
						var but = new flash.display.Sprite();
						but.graphics.beginFill(0xFF0000,0);
						but.graphics.drawCircle(0, 0, 20);
						var me = this;
						but.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.destroyGroup(p.gid); } );
						mc.but = but;
						mc.addChild(but);
					}
					last.push({x:x,y:y});
				}
			}
		}

		if(flLoose){
			for( p in last ){
				//trace("!");
				var mc = dm.attach("kaskade_goutte",3);
				mc.x = getX(p.x);
				mc.y = getY(p.y);
			}
			setWin(false,20);
		}

	}
	function destroyGroup(gid){
		work = [];
		for( x in 0...SIZE ){
			for( y in 0...SIZE ){
				var mc = tgr[x][y];
				if( mc == null ) continue;
				if( mc.but != null) {
					mc.removeChild(mc.but);
					mc.but = null;
				}
				mc.useHandCursor = false;
				var p = grid.gr[x][y];
				if( p.gid == gid ){
					work.push(mc);
					//mc.removeMovieClip();
					grid.gr[x][y] = null;
					tgr[x][y] = null;
				}
			}
		}
		destroy(grid,gid);
		step = 4;
		coef = 0;

	}

	// EXPLOSION
	function updateExplosion(){
		coef = Math.min(coef+SPEED_EXPLO,1);
		for( mc in work ){
			Col.setPercentColor(mc,Math.pow(coef,0.5),0xFFFFFF);
			if(coef == 1) mc.parent.removeChild(mc);
		}

		if(coef==1){
			fallType = 0;
			initFall();
			grav(grid);
		}
	}

	// FALL
	var fallType:Int;
	function initFall(){

		step = 3;
		coef = 0;
		work = [];

		switch(fallType){
			case 0 :
				for( x in 0...SIZE ){
					var flFall = false;
					for( dy in 0...SIZE ){
						var y = SIZE-(1+dy);
						if( tgr[x][y] == null )	flFall = true;
						else if( flFall )	work.push(tgr[x][y]);
					}
				}

			case 1 :
				for( y in 0...SIZE ){
					var flFall = false;
					for( x in 0...SIZE ){
						if( tgr[x][y] == null )	flFall = true;
						else if( flFall )	work.push(tgr[x][y]);
					}
				}
		}

		//trace(work.length);
		
		if( work.length == 0 ){
			if( fallType == 0 ){
				fallType++;
				initFall();
			}else{
				initSelection();
			}
		}


		/*

		// FALL X

		for( y in 0...SIZE ){
			var fall = 0;
			for( x in 0...SIZE ){
				var n = o.gr[x][y];
				if( n == null ){
					fall++;
				}else{
					if( fall>0 ){
						o.gr[x-fall][y] = n;
						o.gr[x][y] = null;
					}
				}
			}
		}
		*/


	}
	function updateFall(){
		coef = Math.min(coef+SPEED_FALL,1);

		var d = [[0,1],[-1,0]][fallType];

		for( mc in work ){
			mc.x = getX(mc.px+d[0]*coef);
			mc.y = getY(mc.py+d[1]*coef);
			if(coef==1){
				tgr[mc.px][mc.py] = null;
				mc.px += d[0];
				mc.py += d[1];
				tgr[mc.px][mc.py] = mc;
			}
		}

		if(coef==1)initFall();

	}


	function getX(x:Float){
		return 60+x*40;
	}
	function getY(y:Float){
		return 60+y*40;
	}


//{
}

