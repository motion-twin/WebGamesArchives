import mt.bumdum9.Lib;
import Protocole;

typedef ChessPiece = {mc:flash.display.MovieClip, type:Int, color:Int, px:Int, py:Int };
typedef ChessPart = {>Phys, z:Float,vz:Float, wz:Float,shade:flash.display.MovieClip};



class Chess extends Game{//}

	static var SIZE = 8;
	static var CS = 40;

	var mx:Float;
	var my:Float;
	var pieces:Array<ChessPiece>;
	var squares:Array<Array<flash.display.MovieClip>>;
	var selection:Array<flash.display.MovieClip>;
	var yl:Array<flash.display.MovieClip>;
	var kn:ChessPiece;
	var sdm:mt.DepthManager;


	override function init(dif:Float){
		gameTime =  560-100*dif;
		super.init(dif);
		yl = [];
		parts= [];
		attachElements();
		initSelection();

	}

	function attachElements(){
		bg = dm.attach("chess_bg",0);


		// BOARD
		mx = (Cs.mcw-SIZE*CS)*0.5;
		my = (Cs.mch-SIZE*CS)*0.5;
		squares = [];
		for( x in 0...SIZE ){
			squares[x] = [];
			for( y in 0...SIZE ){
				var mc = dm.attach("chess_square",0);
				mc.x = mx+x*CS;
				mc.y = my+y*CS;
				mc.gotoAndStop(1+((x+y)%2));
				squares[x][y] = mc;
			}
		}

		// SHADE
		var shade = dm.empty(0);
		sdm = new mt.DepthManager(shade);
		shade.blendMode = flash.display.BlendMode.LAYER;
		shade.alpha = 0.2;

		// PIECES
		genPieces();
	}

	override function update(){


		switch(step){
			case 1 : // SELECTION
			case 2 : // KNIGHT MOVE
				updateMove();
			case 3 : // BLACK MOVE
				updateBlackMove();
		}


		yl.sort(ySort);
		/*
		for( mc in yl ){
			if( mc.visible!=true )yl.remove(mc);
			else dm.over(mc);
		}
		*/

		super.update();
		//root.y = Std.int(root.y/3)*3;

		var a = parts.copy();
		for( p in a ){

			if(p.root.visible!=true){
				parts.remove(p);
				p.shade.parent.removeChild(p.shade);
			}else{

				if(p.frict!=null)p.vz *= p.frict;
				p.z += p.vz;
			
				p.vz += p.wz;
				if( p.z > 0 ){
					p.z =0;
					p.vz *= -0.75;
				}
				p.root.y += p.z;
				p.shade.x = p.x;
				p.shade.y = p.y;
				p.shade.scaleX = p.shade.scaleY = p.root.scaleX;
				
			}
		}



	}
	function ySort(a:flash.display.MovieClip,b:flash.display.MovieClip){
		if(a.y<b.y)return -1;
		return 1;
	}

	// SELECTION
	function initSelection(){
		step = 1;
		var a = getZone(0,kn.px,kn.py);
		selection = [];
		for( p in a ){
			var mc = dm.attach("chess_sel",0);
			mc.x = getX(p.x)-CS*0.5;
			mc.y = getY(p.y)-CS;
			selection.push(mc);
			activate( squares[p.x][p.y], p.x, p.y );
		}
	}
	function activate(mc:flash.display.MovieClip, x, y ) {
		var me = this;
		if( mc.tabIndex != 99 ) {
			mc.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.select(x, y); } );
			mc.tabIndex = 99;
		}
		mc.mouseEnabled = true;
	}
	function deactivate(mc:flash.display.MovieClip){
		mc.mouseEnabled = false;
	}
	function select(x,y){
		for( x in 0...SIZE )for( y in 0...SIZE )deactivate(squares[x][y]);
		while(selection.length > 0) {
			var mc = selection.pop();
			mc.parent.removeChild(mc);
		}

		tw = new Tween(getX(kn.px),getY(kn.py),getX(x),getY(y));
		step = 2;
		coef = 0;
		kn.px = x;
		kn.py = y;
	}


	// MOVE
	var tw:Tween;
	var coef:Float;
	function updateMove(){
		coef = Math.min(coef+0.1,1);
		var p = tw.getPos(coef);
		kn.mc.x = p.x;
		kn.mc.y = p.y - Math.sin(coef*3.14)*40;
		if(coef ==1 ){
			for( p in pieces ){
				if(p.px == kn.px && p.py == kn.py && p!=kn){
					p.mc.parent.removeChild(p.mc);
					pieces.remove(p);
					fxExplode(kn.px,kn.py,1);
					fxShake(8);
					break;
				}
			}
			var map = genTrapMap();
			att = map[kn.px][kn.py];
			//for( x in 0...SIZE)for( y in 0...SIZE)if( map[x][y] != null )squares[x][y]._alpha = 30;
			if( att == null ){
				if(pieces.length>1){
					initSelection();
				}else{
					step = 4;
					setWin(true,30);

				}
			}else{
				step = 3;
				coef = 0;
				tw = new Tween(getX(att.px),getY(att.py),getX(kn.px),getY(kn.py));
			}
		}

	}
	function genTrapMap():Array<Array<ChessPiece>>{
		var lgr = getLockZone();
		var map = [];
		for( x in 0...SIZE )map[x] = [];
		for( p in pieces ){
			if( p!=kn ){
				var a = getZone(p.type,p.px,p.py,lgr);
				for( pos in a )map[pos.x][pos.y] = p;
			}
		}
		return map;
	}

	// MOVE BLACK
	var att:ChessPiece;
	function updateBlackMove(){

		var dx = (tw.sx-tw.ex);
		var dy = (tw.sy-tw.ey);
		var c = 10/Math.sqrt(dx*dx+dy*dy);

		coef = Math.min(coef+c,1);
		var p = tw.getPos(coef);
		att.mc.x = p.x;
		att.mc.y = p.y; // - Math.sin(coef*3.14)*40;
		if( coef == 1 ){

			fxExplode(kn.px,kn.py,0);
			kn.mc.parent.removeChild(kn.mc);
			step = 4;
			setWin(false,30);
		}

	}



	// GENERATION
	static var KNIGHT = [[1,2],[1,-2],[2,1],[2,-1],[-1,2],[-1,-2],[-2,1],[-2,-1]];
	static var PAWN = [[1,1],[-1,1]];
	var lgr:Array<Array<Bool>>;
	function genPieces(){

		pieces = [];

		// START POS
		var x = Std.random(SIZE);
		var y = Std.random(SIZE);

		// DIF
		var types = [3,null,null,3,null,3,3,null,2,null,1,null,2,null,1,4,null];
		var max = types.length*Math.min(Math.max(0.1,dif),1);
		while(types.length>max)types.pop();


		//
		while( types.length>0 ){

			// POSE UNE PIECE
			var last:ChessPiece = null;
			var index = Std.random(types.length);
			var t = types[index];
			types.splice(index,1);
			if( t!=null )last = genPiece(t,1,x,y);

			//
			var lgr = getLockZone();

			// CALCULE POSITION VALABLES
			var b = getZone(0,x,y);
			var a = [];
			for( p in b )if( lgr[p.x][p.y] == null )a.push(p);
			if( a.length == 0 ){
				if(last != null) {
					var o = pieces.pop();//
					o.mc.parent.removeChild(o.mc);
					//.removeMovieClip();
				}
				break;
			}

			// CHOISIS UNE NOUVELLE POSITION
			var np = a[Std.random(a.length)];
			x = np.x;
			y = np.y;

		}

		// PLACE LE CAVALIER
		kn = genPiece(0,0,x,y);

		// VERIFIE SI LA GENERATION EST VALABLE
		if(types.length>1){
			while(pieces.length > 0) {
				var o = pieces.pop();
				o.mc.parent.removeChild(o.mc);
			}
			genPieces();
		}


	}
	function getZone(type,x,y,?lgr:Array<Array<Null<Int>>>):Array<{x:Int,y:Int}>{
		var a = [];
		var dir:Array<Array<Int>> = null;
		switch(type){
			case 0:	// KNIGHT
				for( d in KNIGHT ){
					var nx = x+d[0];
					var ny = y+d[1];
					if( isIn(nx,ny) )a.push({x:nx,y:ny});
				}

			case 1: // ROOK
				dir = Cs.DIR;

			case 2: // BISHOP
				dir = Cs.GDIR;
			case 3 : // PAWN
				for( d in PAWN ){
					var nx = x+d[0];
					var ny = y+d[1];
					if( isIn(nx,ny) )a.push({x:nx,y:ny});
				}
			case 4	: //QUEEN
				dir = Cs.DDIR;

		}
		if( dir!=null ){
			for( d in dir ){
				var n = 1;
				while( n<SIZE){
					var nx = x+d[0]*n;
					var ny = y+d[1]*n;
					if( isIn(nx,ny) && lgr[nx][ny] != 0 )a.push({x:nx,y:ny});
					else break;
					n++;
				}
			}
		}
	
		return a;
	}
	function getLockZone():Array<Array<Null<Int>>>{
		var lgr = [];
		for( x in 0...SIZE )lgr[x] = [];
		var a = pieces.copy();
		a.remove(kn);

		for( p in a )lgr[p.px][p.py] = 0;
		for( p in a ){
			var a = getZone(p.type,p.px,p.py,lgr);
			for( p in a )lgr[p.x][p.y] = 1;
		}


		return lgr;
	}

	function genPiece(type,color,x,y){
		var o:ChessPiece = {
			mc:dm.attach("Chess_piece", 1),
			type:type,
			color:color,
			px:x,
			py:y
		}
		var mmc:Chess_piece = cast o.mc;
		mmc.smc.gotoAndStop(type + 1);
		
		o.mc.x = getX(x);
		o.mc.y = getY(y);
		if(color==1)	Filt.glow(o.mc,2,4,0xFFFFFF);
		Filt.glow(o.mc,2,4,0);
		if(color==0)	Filt.glow(o.mc,2,4,0xFFFFFF);
		pieces.push(o);
		yl.push(cast o.mc);
		o.mc.mouseEnabled = false;
		o.mc.mouseChildren = false;
		
		return o;

	}

	// FX
	var parts:Array<ChessPart>;
	function fxExplode(x,y,color){
		var max = 20;
		var cr = 3;
		for( i in 0...max ){
			var p:ChessPart = cast new Phys(dm.attach("chess_part",1));
			var a = i/max * 6.28 ;
			var sp = Math.random()*3;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.vz = sp-5;
			p.x = getX(x) + p.vx*cr;
			p.y = getY(y) + p.vy*cr;
			p.z = p.vz*cr;
			p.wz = 0.15+Math.random()*0.4;
			p.timer = 20+Std.random(40);
			p.fadeType = 0;
			p.root.gotoAndStop(color+1);
			Filt.glow(p.root,2,4,[0,0xFFFFFF][color]);
			yl.push(p.root);
			
			parts.push(p);

			p.shade = sdm.attach("chess_part",0);
			p.shade.x = p.x;
			p.shade.y = p.y;
			
			var mc :flash.display.MovieClip = cast p.shade;
			mc.gotoAndStop(2);

		}

	}

	// TOOLS
	function isIn(x,y){
		return x>=0 && x<SIZE && y>=0 && y<SIZE;

	}
	function getX(x:Int){
		return mx + (x+0.5)*CS;
	}
	function getY(y:Int){
		return my + (y+1)*CS;
	}


//{
}

