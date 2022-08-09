import mt.bumdum9.Lib;
//typedef BibliAtome = {>Phys,pos:{x:Int,y:Int},t:Float};

class Bibli extends Game{//}
	// CONSTANTES
	static var RAY = 9;
	static var DIR = [
		{ x:1,	y:0	},
		{ x:0,	y:1	},
		{ x:-1,	y:0	},
		{ x:0,	y:-1	},
	];


	// VARIABLES
	var flWillWin:Bool;
	var speed:Float;
	var aList:Array<Phys>;
	var grid:Array<Array<Bool>>;
	var last:Array<Int>;

	override function init(dif:Float){
		gameTime = 480- dif * 80;
		super.init(dif);
	
		speed = 1.2+dif*3;
		last = new Array();
		grid = new Array();
		for( x in 0...3 ){
			grid[x] = new Array();
			for( y in 0...3 )grid[x][y] = ( x==1 && y==1 );
		}

		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("bibli_bg",0);
		// ATOMES
		aList = new Array();
		for( i in 0...9 ){
			var sp = newPhys("mcAtome");
			sp.x = RAY+Math.random()*(Cs.omcw-2*RAY);
			sp.y = RAY+Math.random()*(Cs.omch-2*RAY);
			sp.frict= 1;
			if(i==0){
				sp.root.gotoAndStop("1");
				sp.pos = {x:0,y:0}
			}else{
				sp.root.gotoAndStop("3");
				var a = Math.random()*6.28;
				sp.vx = Math.cos(a)*speed;
				sp.vy = Math.sin(a)*speed;
			}
			sp.updatePos();
			aList.push(sp);
		}


	}

	override function update(){

		flWillWin = true;

		for( sp in aList ){
			if( sp.x<RAY || sp.x>Cs.omcw-RAY ){
				sp.x = Num.mm(RAY,sp.x,Cs.omcw-RAY);
				sp.vx *= -1;
			}
			if( sp.y<RAY || sp.y>Cs.omch-RAY ){
				sp.y = Num.mm(RAY,sp.y,Cs.omch-RAY);
				sp.vy *= -1;
			}

			if(sp.t!=null){
				sp.t--;
				if(sp.t<0)sp.t = null;
			}

			if(sp.pos!=null){

				var mp = getMousePos();
				var p = {
					x:mp.x + sp.pos.x*RAY*2,
					y:mp.y + sp.pos.y*RAY*2,
				}

				sp.toward(p,0.15,null);

				var n = 0;
				for( spo in aList ){
					if(spo.pos==null && spo.t == null ){
						var dist = sp.getDist(spo);
						if( dist<RAY*2 ){

							var dx = spo.x - sp.x;
							var dy = spo.y - sp.y;
							var d = null;
							if(Math.abs(dx)<Math.abs(dy)){
								d = {
									x:0,
									y:Std.int(dy/Math.abs(dy)),
								}
							}else{
								d = {
									x:Std.int(dx/Math.abs(dx)),
									y:0,
								}
							}
							var nx = sp.pos.x+d.x;
							var ny = sp.pos.y + d.y;
							
							var fit = true;
							var ins = isIn(nx + 1, ny + 1);
							if( ins && grid[nx + 1][ny + 1] ) fit = false;
							
							if( fit ){
								if(ins)grid[nx+1][ny+1] = true;
								spo.pos = {x:nx,y:ny};
								spo.vx = 0;
								spo.vy = 0;
								last.push(n);
								if( Math.abs(nx)<2 && Math.abs(ny)<2 )	{
									spo.root.gotoAndStop("2");
								}else {
									spo.root.gotoAndStop("4");
								}
							}
						}
					}
					n++;
				}

				if( sp.root.currentFrame==4 )flWillWin = false;

			}else{

				flWillWin = false;
			}

		}

		if(flWillWin) {

			setWin(true,20);
		}


		super.update();
	}

	function isIn(x, y) {
		return x >= 0 && x < 3 && y >= 0 && y < 3;
	}
	
	override function onClick(){
	
		if(last.length==0)return;

		var sp:Phys = null;
		var kn:Null<Int> = 0;
		for( n in last ){
			var ls = aList[n];
			if( sp == null || sp.root.currentFrame == 2 || (sp.root.currentFrame == 4 && ls.root.currentFrame == 4) ){
				sp = ls;
				kn = n;
			}

		}

		if( kn != null )last.remove(kn);



		//var sp = aList[last.pop()];
		if( isIn(sp.pos.x+1,sp.pos.y+1) ) grid[sp.pos.x+1][sp.pos.y+1] = false;
		var a = Math.atan2(sp.pos.y,sp.pos.x);
		sp.vx = Math.cos(a)*speed;
		sp.vy = Math.sin(a)*speed;
		sp.pos = null;
		sp.t = 10;
		sp.root.gotoAndStop("3");

	}

//{
}

