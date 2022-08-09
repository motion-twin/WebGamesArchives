import mt.bumdum9.Lib;
typedef PuzzleElement = {id:Int,x:Int,y:Int};
typedef PuzzleSquare = {>flash.display.MovieClip,id:Int,dec:Float,by:Float,sleep:Float};
typedef PuzzlePiece = {>flash.display.MovieClip,dm:mt.DepthManager,id:Int,dx:Int,dy:Int};

class Puzzle extends Game{//}

	// CONSTANTES

	static var DIR = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}];
	static var SIZE = 6;
	static var EC = 12;
	static var HEIGHT = 6;

	// VARIABLES
	var pmax:Int;
	var timer:Float;
	var gList:Array<Array<PuzzleElement>>;
	var lvl:Array<Array<PuzzleSquare>>;
	var piece:PuzzlePiece;

	//var anim:Array<{>flash.display.MovieClip,id:Int,dec:Float,z:Float,sleep:Float}>;
	var anim:Array<PuzzleSquare > ;
	
	// MOVIECLIPS


	override function init(dif:Float){
		gameTime = 600-dif*160;
		super.init(dif);
		pmax = 2+Std.int(dif*4);
		lvl = new Array();
		for( x in 0...20 )lvl[x]=new Array();
		genLevel();
		attachElements();
		zoomOld();
	}

	function genLevel(){

		bg = dm.attach("puzzle_bg",0);

		// PREPARE LA GRID
		var free = new Array();
		var grid = new Array();
		for( x in 0...SIZE ){
			grid[x] = new Array();
			for( y in 0...SIZE ){
				//var e = {id:null,x:x,y:y};
				var e = {id:-1,x:x,y:y};
				grid[x][y] = e;
				free.push(e);
			}
		}

		// POSE MAX SOUCHES
		gList = new Array();
		for( i in 0...pmax ){
			var e = takeRandomElement(free);
			e.id = i;
			gList[i] = [e];
		}


		// ETEND LES SOUCHES
		var to = 0;
		while( free.length>0 && to++< 200 ){
			for( i in 0...pmax ){
				// CREE UNE LISTE DES PIECES ADJACENTES
				var list = new Array();
				for( e in free ) {
					for( d in DIR ) {
						var nx = e.x + d.x;
						var ny = e.y + d.y;
						if( !isInGrid(nx,ny,0) ) continue;
						var eo = grid[nx][ny];
						if( eo.id == i ){
							list.push(e);
							break;
						}
					}
				}
				// SELECTION D'UN DES ELEMENTS
				if( list.length>0 ){
					var e = list[Std.random(list.length-1)];
					e.id = i;
					free.remove(e);
					gList[i].push(e);
				}
			}
			
		}

	}

	function takeRandomElement(list:Array<PuzzleElement>){
		var index = Std.random(list.length);
		var e = list[index];
		list.splice(index,1);
		return e;
	}

	function attachElements(){
		for(i in 0...pmax ){
			var list = gList[i];
			var x = 0;
			var y = 0;

			while(true){
				var r = 1;
				x = r + Std.random( 20-2*r );
				y = r + Std.random( 20-2*r );
				if(fit(i,x,y))break;
			}
			draw(i,x,y);
		}

	}

	function fit(i,x,y){
		var list = gList[i];
		for( e in list ){
			var nx = e.x+x;
			var ny = e.y + y;
			if( !isIn(nx,ny) || lvl[nx][ny] != null  )return false;
		}
		return true;
	}

	function isIn(x,y,m=1){
		return x >= m && x<20-m && y >= m && y<20-m;
	}
	function isInGrid(x,y,m=0){
		return x >= m && x<SIZE-m && y >= m && y<SIZE-m;
	}
	function draw(i,dx,dy){
		var list = gList[i];
		for( n in 0...list.length ){
			var e = list[n];
			var nx = e.x+dx;
			var ny = e.y+dy;

			var mc:PuzzleSquare = cast(dm.attach("mcPuzzlePiece",Game.DP_SPRITE2));
			mc.gotoAndStop(i+1);
			mc.x = nx*EC;
			mc.y = ny*EC;
			lvl[nx][ny] = mc;
			mc.id = i;
			
			var me = this;
			mc.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.take(i, dx, dy); } );

			//TODO;
		}

		for( x in 0...20 ){
			for( y in 0...20 ){
				var mc = lvl[x][y];
				if(mc!=null)dm.over(mc);
			}
		}
	}

	function take(num:Int,dx,dy){
		if( step !=1 )return;

		// SUMMON
		piece = summonPiece(num);
		piece.x += (piece.dx+dx)*EC;
		piece.y += (piece.dy + dy) * EC;
		dm.over(piece);

		// NETTOIE
		for( x in 0...20 ){
			for( y in 0...20 ) {
				if( isIn(x,y) ){
					var mc = lvl[x][y];
					if(mc!=null && mc.id==num){
						mc.parent.removeChild(mc);
						lvl[x][y] = null;
					}
				}
			}
		}

		//
		step = 2;

	}

	function summonPiece(num){
			var list = gList[num];
			var p:PuzzlePiece = cast(dm.empty(Game.DP_SPRITE));
			p.dm = new mt.DepthManager(p);
			p.id = num;

			// DETERMINE LES POS MIN ET MAX
			var b = {
				xMin:99.9,
				yMin:99.9,
				xMax:-99.9,
				yMax:-99.9,
			}
			for( e in list ){
				b.xMin = Math.min(b.xMin,e.x);
				b.yMin = Math.min(b.yMin,e.y);
				b.xMax = Math.max(b.xMax,e.x);
				b.yMax = Math.max(b.yMax,e.y);
			}

			p.dx = Std.int((b.xMin+b.xMax)*0.5);
			p.dy = Std.int((b.yMin+b.yMax)*0.5);

			// ORDONNE LA LISTE
			var f = function (a,b){
				if(a.y>b.y)return 1;
				if(a.y<b.y)return -1;
				return 0;
			}
			list.sort(f);

			// CREE LES PETITS CARRES
			for( e in list ){
				var mc = p.dm.attach("mcPuzzlePiece",1);
				mc.gotoAndStop(num+1);
				mc.x = (e.x-p.dx)*EC;
				mc.y = (e.y-p.dy)*EC;
			}

			return p;

	}



	override function update(){

		switch(step){
			case 1: // CHOIX


			case 2: // PIECE FLY
				movePiece();
				if(!click)step = 3;

			case 3:
				movePiece();
				if(click)drop();

			case 4:
				for(mc in anim ){

					if(mc.sleep>0){
						mc.sleep --;
					}else{
						mc.dec = (mc.dec +30)%628;
						mc.y = mc.by + (Math.cos(mc.dec/100)-1)*3;
					}
				}
				timer--;
				if(timer<0)setWin(true,20);


		}

		super.update();
	}

	function movePiece() {
		var mp = getMousePos();
		var dx = (mp.x - piece.x)-EC*0.5;
		var dy = (mp.y - piece.y)-EC*0.5;
		var c = 0.5;
		var lim = 18;
		piece.x += Num.mm(-lim,dx*c,lim);
		piece.y += Num.mm(-lim,dy*c,lim);

	}

	function drop() {
		var mp = getMousePos();
		var dx = Math.round((mp.x/EC)-0.5)-piece.dx;
		var dy = Math.round((mp.y/EC)-0.5)-piece.dy;

		var dir = DIR.copy();
		dir.unshift({x:0,y:0});

		for( d in dir ){
			var x = dx+d.x;
			var y = dy+d.y;

			if( fit(piece.id,x,y) ){
				draw(piece.id,x,y);
				piece.parent.removeChild(piece);
				step = 1;
				checkWin();
				return;
			}
		}
	}

	function checkWin(){
		anim = new Array();
		for( x in 7...13 ){
			for( y in 7...13 ){
				var mc = lvl[x][y];
				if(mc==null)return;
				mc.dec = 0;
				mc.by = mc.y;
				mc.sleep = ((x+y)-14)*1.5;
				anim.push( cast mc);
			}
		}

		timeProof = true;
		timer = 30;
		step = 4;


	}



//{
}


















