import mt.bumdum.Lib;

class Level{//}

	static public var NEVER = 		50000;

	static public var PB_STEEL_BAR = 	0;
	static public var PB_STEEL_CLOUD = 	1;
	static public var PB_PUSHER = 	2;
	static public var PB_BOOM = 		3;
	static public var PB_JUMPER = 		4;
	static public var PB_STORM = 		5;
	static public var PB_CAGE = 		6;
	static public var PB_GENERATOR =	7;
	static public var PB_DRAGON =		8;
	static public var PB_MISSILE =		9;
	static public var PB_DOOR =		10;
	static public var PB_KILL =		11;
	static public var PB_DEATH =		12;

	public var flDepleted:Bool;
	public var flEdit:Bool;
	public var flLure:Bool;

	public var wx:Int;
	public var wy:Int;
	public var zid:Int;
	public var itemId:Int;

	public var dst:Float;
	public var ang:Float;
	public var lvl:Int;
	public var ymax:Int;

	public var struct:Array<Array<Int>>;

	public var seed: mt.OldRandom;

	public var proba:Array<Int>;
	public var bonusTable:Array<Array<Int>>;

	public var bmpPaint:flash.display.BitmapData;
	public var model:Array<Array<Int>>;
	public var distances:Array<Float>;

	public function new(x,y,id,flMinerai,?level:String){

		wx = x;
		wy = y;
		zid = id;

		flDepleted = !flMinerai;


		if(level!=null){
			var pc = new mt.PersistCodec();
			pc.crc = true;
			struct = pc.decode(level);

			/*
			for( x in 0...Cs.XMAX ){
				var str = "";
				for( y in 0...Cs.XMAX ){
					if(struct[x][y]!=null)str+"O";
					str+="-";
				}
				trace(str);
			}
			*/

			/*
			struct = [];
			var a = level.split(",");
			for( ch in a )struct.push(Std.parseInt(ch));
			*/
		}


		// DISTANCES
		distances = [];
		for( zone in ZoneInfo.list ){
			var dx = x-zone.pos[0];
			var dy = y-zone.pos[1];
			distances.push( Math.sqrt(dx*dx+dy*dy) );
		}

		dst = Math.sqrt(wx*wx+wy*wy);
		ang = Math.atan2(wy,wx);

		lvl = Std.int( Math.pow( dst*0.1, 0.5 ) );
		ymax = Std.int(Math.min(12+lvl,Cs.YMAX-6) );
		initSeed();

		initProba();



	}
	function initSeed(){
		seed = new mt.OldRandom(wx*10000+wy);
	}
	function initProba(){
		proba = [];

		var NEVER = 100000.0;

		for( i in 0...30 ){
			var n = NEVER;
			switch(i){
				case PB_STEEL_BAR:
					n = Math.max(5-(dst/200),2);
					if( distances[ZoneInfo.SOUPALINE]< 12 )n=1000;
					n *= Math.min( distances[ZoneInfo.MOLTEAR]/50,1 );

				case PB_STEEL_CLOUD:
					n = 5;
					if( zid==ZoneInfo.SOUPALINE )n=NEVER;

				case PB_PUSHER:
					n = 12;
					if( dst<6 )n=NEVER;
					else if( dst<20 )n=40;

				case PB_BOOM:
					n = 12;
					if( dst<4 )n=NEVER;
					if( wy<0 || wx<0 )n+=dst*0.5;
					if( zid==ZoneInfo.LYCANS )n=1;

				case PB_JUMPER:

					if( distances[ZoneInfo.KARBONIS]<100 && dst>10 )n=40;

				case PB_STORM:
					if( dst>30 )n = Math.max(60-dst*0.5,4);

				case PB_CAGE:
					if( dst>15 )n = Math.max(50-dst,3);

				case PB_GENERATOR:
					if( dst>20 )n = Math.max(100-dst*0.5,12);

				case PB_DRAGON:
					if( wy>10 )n = 10;
					var lim = 30;
					if( distances[ZoneInfo.POFIAK] < lim )n = 1+(distances[ZoneInfo.POFIAK]/lim)*10;

				case PB_MISSILE:
					if( dst > 4 ) n = Math.min( 3+dst*0.1, 20);
					if( zid == ZoneInfo.LYCANS ) n = 2;
					//if( zid == ZoneInfo.SOUPALINE ) n = NEVER;

				case PB_DOOR:
					if( dst>13 && dst<18 )n=7;
					if( dst > 58 ) n = 16;

				case PB_KILL:
					if( dst>80 ){
						n = Math.max( 3, 80*Math.abs(Num.hMod(ang-2.504,3.14)) );
					}

				case PB_DEATH:
					if( dst>40 ){
						n = Math.max( 2, 100-Math.pow(dst*10,0.5) );
					}


				default : break;

			}
			//trace("proba["+i+"] = "+n);
			proba[i] = Math.floor(n);
		}

		//trace("proba:"+proba);
	}

	// BUILD PALETTE
	public function genPalette(){
		// PAINT
		//var id = 0;
		var zone = {  col:0x888888, pal:[[55,55,55,200,200,200]] }
		if(zid!=null)zone = ZoneInfo.list[zid];

		bmpPaint = new flash.display.BitmapData(Cs.XMAX,Cs.YMAX,false,zone.col);
		var brush = Game.me.dm.attach("mcBrush",0);
		var sc = 0.1;
		var ma = -2;
		for( i in 0...16 ){
			var m = new flash.geom.Matrix();
			m.scale(sc,sc);
			m.translate(ma+seed.random(Cs.XMAX-2*ma),ma+seed.random(Cs.YMAX-2*ma));

			var pr = zone.pal[seed.random(zone.pal.length)];

			var r = pr[0]+seed.random(pr[3]);
			var g = pr[1]+seed.random(pr[4]);
			var b = pr[2]+seed.random(pr[5]);

			var ct = new flash.geom.ColorTransform(0,0,0,0,r,g,b,40);
			bmpPaint.draw(brush,m,ct,"add");

		}
		brush.removeMovieClip();

		// 256 colors !
		/*
		var bs = 16;
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var o = Col.colToObj(bmpPaint.getPixel(x,y));
				var col = {
					r:Std.int(o.r/bs)*bs,
					g:Std.int(o.g/bs)*bs,
					b:Std.int(o.b/bs)*bs
				}
				bmpPaint.setPixel(x,y,Col.objToCol(col));
			}
		}
		//*/

	}
	public function genBonusTable(){
		if(zid==ZoneInfo.GRIMORN)return;
		Option.genProb(this);
		bonusTable = [];
		for( x in 0...Cs.XMAX ){
			bonusTable[x] = [];
			for( y in 0...Cs.YMAX ){
				if( seed.rand()<Cs.OPTION_COEF )bonusTable[x][y] = Option.getRandomId(seed);

			}
		}
		//for(a in bonusTable)trace(">"+a);

	}

	// BUILD MODEL
	public function genModel(){

		// ITEM
		var id = 0;
		for( n in Cs.pi.items ){
			var item = MissionInfo.ITEMS[id];
			if( item.x == wx && item.y == wy ){
				itemId = id;
				break;
			}
			id++;
		}


		// MOLECULES LIST



		// GENERATION
		if( struct==null ){
			var to = 0;
			while(true){
				genPrimeModel();
				var goal = getGoal();
				if( goal>12 && isModelOpen(goal) && goal<(lvl+1)*100)break;
				if( to++>12 ){
					forceModel();
					break;
				}
			}


			// PLACE MOLS
			var mols = [];
			while( mols.length < 20 ){
				var max = 1+seed.random(10);
				var n = el.Molecule.getRandomMolType(seed);
				for( i in 0...max )mols.push(n);
			}
			var mi = 0;
			for( x in 0...Cs.XMAX ){
				for( y in 0...Cs.YMAX ){
					var n = model[x][y];
					if( n == Block.CAGE || n == Block.GENERATOR ){
						mi = (mi+1)%mols.length;
						model[x][y] += mols[mi];
					}
				}
			}

		}else{
			genStruct();
		}


		//trace(itemId+";"+Cs.pi.items[itemId]);

	}
	public function genPrimeModel(){



		flLure = false;


		// PARAMS
		var flMirror = seed.random(2)==0;
		var flMirrorPalette = seed.random(2)==0 && flMirror;
		var density = 1 + 3/(lvl+1);

		// MASSE
		var bmp = new flash.display.BitmapData(Cs.XMAX,Cs.YMAX,false,0);
		var brush = Manager.dm.attach("mcShape",0);
		var sc = 0.06;
		var ma = -2;
		var max = Std.int(4+lvl);
		for( i in 0...max ){

			var m = new flash.geom.Matrix();
			//m.rotate(seed.rand()*6.28);
			var scc = (sc*(1+seed.rand()*0.5));
			m.scale(scc,scc);
			m.translate(ma+seed.random(Cs.XMAX-2*ma),ma+seed.random(ymax-2*ma));
			brush.gotoAndStop(seed.random(brush._totalframes)+1);
			//var ct = new flash.geom.ColorTransform(0,0,0,0,r,g,b,40);
			bmp.draw(brush,m);

		}
		brush.removeMovieClip();


		// FILL
		model = [];



		//ymax = Cs.YMAX;
		for( x in 0...Cs.XMAX ){
			model[x] = [];
			for( y in 0...ymax){

				if( bmp.getPixel(x,y) != 0 ){
					model[x][y] = 0;
				}
			}


		}

		// LINE
		var max = lvl;
		if( zid==ZoneInfo.DOURIV || zid==ZoneInfo.GRIMORN )max = 0;

		for( i in 0...max ){
			var lim = 4;
			var list = getHoriLine( 2+seed.random((ymax-2)), 0.05, 0 );
			for( p in list ){
				if( model[p[0]][p[1]] <5 ){
					model[p[0]][p[1]]++;
				}
			}
			/*
			var y = lim+seed.random(ymax-lim);
			for( x in 0...Cs.XMAX ){
				if( model[x][y] <5 ){
					model[x][y]++;
				}
			}
			*/
		}


		// DIG
		while(lvl>=0 && seed.random(2)==0 ){

			var m = 3;
			var di = seed.random(4);
			var sx = m+seed.random(Cs.XMAX-(2*m));
			var sy = m+seed.random(ymax-(2*m));
			while(true){
				var bl = model[sx][sy];
				if( sx>=0 && sx<Cs.XMAX && sy>=0 && sy<ymax){
					model[sx][sy] = null;
					var d = Cs.DIR[di];
					sx += d[0];
					sy += d[1];
					if(seed.random(4)==0){
						di=Std.int(Num.sMod( di+(seed.random(2)*2-1), 4 ));
					}
				}else{
					break;
				}
			}
		}

		// BORDER
		var brd = seed.random(lvl+1);
		//if( Math.max(Math.abs(wx),Math.abs(wy)) == 3 )brd = 1;
		if(  zid==ZoneInfo.DOURIV || zid==ZoneInfo.GRIMORN || zid==ZoneInfo.CILORILE  )brd = 0;
		if( brd>0 ){
			var inc = 1;
			if( brd > 2 )inc++;
			if( brd > 4 )inc++;

			for( x in 0...Cs.XMAX ){
				for( y in 0...ymax ){
					if( model[x][y] < 5 ){
						for( d in Cs.DIR ){
							var nx = x+d[0];
							var ny = y+d[1];
							if( nx>=0 && nx<Cs.XMAX && ny>=0 && ny<ymax+1 && model[nx][ny]==null ){
								model[x][y] = Std.int(Math.min(model[x][y]+inc,5));
								break;
							}
						}
					}
				}
			}
		}

		// FOSSE
		while(seed.random(3)==0){
			var list = getHoriLine(1+seed.random(ymax-2),0.1 );
			for( p in list )model[p[0]][p[1]] = null;
		}

		// BALL
		while( lvl>=1 && seed.random(3)==0 ){
			var x = seed.random(Cs.XMAX);
			var y = seed.random(5);
			model[x][y] = Block.BALL;
		}

		// REDUCTRINES
		if( wy < -40 && seed.random(4)==0 ){
			var max = Std.int( Math.min( seed.random(  Std.int(2+(Math.abs(wy)*0.05)) ), 10) ) ;
			genRandom(Block.REDUC,max);
			flLure = true;
		}

		// STEEL BAR
		if( seed.random(proba[PB_STEEL_BAR])==0 ){
			var type = null;
			if( seed.random(3)==0 ) type = seed.random(2);
			var hmin = Math.round( Math.max(3-(dst/30),1) );
			var list = getHoriLine( 3+seed.random((ymax-3)), 0.1, type, hmin+seed.random(2) );
			for( p in list ){
				model[p[0]][p[1]] = Block.STEEL;
				//model[4][16] = Block.STEEL;
				//model[3][16] = Block.STEEL;
				//model[4][16] = Block.STEEL;
				//model[5][16] = Block.STEEL;

			}
			//trace(list);
		}

		// STEEL CLOUD
		if( seed.random(proba[PB_STEEL_CLOUD])==0 ){
			var n  = Std.int( Math.min( Math.sqrt( dst*0.25 ) , 20));
			var max = n+seed.random(n);
			for( i in 0...max )genCloud( Block.STEEL );
		}


		// BOOM
		if( seed.random(proba[PB_BOOM]) == 0 ){
			var max = 0;
			while(max%10==0)max+=seed.random(11);
			genRandom(Block.BOOM, max, 0);
		}

		// CAGE
		if( seed.random(proba[PB_CAGE]) == 0 ){

			var max = 1+seed.random(lvl+1);
			while(seed.random(5)==0)max+=seed.random(max);
			genRandom(Block.CAGE,max, 0);
		}

		// GENERATOR
		if( seed.random(proba[PB_GENERATOR]) == 0 ){
			var max = 1+seed.random(lvl);
			genRandom(Block.GENERATOR,max, 1 );
		}

		// DOOR
		if( seed.random(proba[PB_DOOR]) == 0 ){
			var max = 1+seed.random(5);
			for( i in 0...max )genCloud( Block.DOOR );
			if(seed.random(8)==0){
				var list = getHoriLine(1+seed.random(ymax-2),0.1,null, 2 );
				for( p in list )model[p[0]][p[1]] = Block.DOOR;
			}
		}

		// MISSILES
		if( seed.random(proba[PB_MISSILE]) == 0 ){
			var max = 1+seed.random(6);
			genRandom(Block.MISSILE,max );
		}

		// KILL
		if( seed.random(proba[PB_KILL]) == 0 ){
			var max = 1+seed.random(  Std.int( Math.pow(dst,0.5) ) );
			genRandom( Block.KILL , max );
		}

		// LIFE
		while( seed.rand()*(Math.pow(dst,0.5)+3) < 1 ){
			var max = 1+seed.random(2);
			genRandom( Block.LIFE , max );
		}

		// DEATH
		while( seed.random(proba[PB_DEATH]) == 0){
			var max = 1+seed.random(2);
			genRandom( Block.DEATH, max );
		}




		// TEST
		/*
		var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
		for( p in list )model[p[0]][p[1]] = Block.CAGE+el.Molecule.BUILDER;
		*/

		// ZONES MODIFS
		if( zid == null ){

			// HORILINE SPACE
			if( dst>11 && (dst<12 || seed.random(10)==0 ) ){
				var list = getHoriLine(Std.int(ymax*0.5),0.1);
				for( p in list )model[p[0]][p[1]] = Block.SPACE;
			}

			// REDUCTRINES TEST
			var d = distances[ZoneInfo.BALIXT];
			var lim = 15;
			if( d<lim ){
				var max = seed.random(  Std.int( (1-(d/lim))*6)+1 );
				genRandom(Block.REDUC,max);
				flLure = true;
			}

			// PUSHER
			if( seed.random(proba[PB_PUSHER]) == 0 ){
				var n  = Std.int( Math.min( Math.sqrt( dst*0.25 ) , 10));
				var max = n+seed.random(n);
				genRandom(Block.PUSHER,max,null,1);
			}

			// JUMPER
			if( seed.random(proba[PB_JUMPER]) == 0 ){
				genRandom(Block.JUMPER,6);
			}

			// STORM
			if( seed.random(proba[PB_STORM]) == 0 ){
				var ym = Std.int( Math.min(1+dst*0.15, ymax) );
				genRandom( Block.STORM, 1+Std.int(Math.pow(seed.rand(),3)*16), null, null, ym   );
				flLure = true;
			}

			// DRAGON
			if( seed.random(proba[PB_DRAGON]) == 0 ){
				var max = 1+seed.random(8);
				for( i in 0...max ){
					var n = seed.random(2);
					var ma = 5;
					var x = seed.random(Cs.XMAX-ma);
					var y = seed.random(ymax);
					if( n == 0 ) x+=ma;
					var bl = model[x][y];
					if( model[x][y]!= null ) model[x][y] = Block.DRAGON_LEFT+n;
				}
			}

			// INVERSE
			if( dst>20 && seed.random(500) == 0 ){
				genRandom(Block.SWAP,1+seed.random(2));
				if(seed.random(100)==0)genRandom(Block.SWAP,20);
			}

			// NUT
			if( dst > 30 && seed.random(300) == 0 ){
				var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
				for( p in list )model[p[0]][p[1]] = Block.NUT;
			}

			// DEATH
			if( seed.random(proba[PB_DEATH]) == 0 ){
				genRandom( Block.DEATH , 1+seed.random(2) );
			}

			// GUARDIAN
			if( seed.random(16) == 0  && dst>50 ){
				genRandom(Block.GUARDIAN, 1+seed.random(6));
			}

			// GLUE
			if( seed.random(8) == 0 && distances [ZoneInfo.SAMOSA] < 50 ){
				genRandom(Block.GLUE, 1+seed.random(4));
			}




		}else{
			genZoneModif();
		}

		// BONUS
		initSeed();
		var n = 1;
		var lim = 1;
		if(zid == ZoneInfo.GRIMORN)lim = 0;
		if(zid == ZoneInfo.TIBOON)lim = 0;
		if(zid == ZoneInfo.DOURIV)lim = 2;
		if(zid == ZoneInfo.EARTH)lim = 8;
		if(distances[ZoneInfo.DOURIV]<2)lim = 3;
		while( seed.random(n++) < lim  )genBonusBlock(ymax);


		// LURE
		if( flLure && dst > 130 ){
			if( seed.random(4)==0 ){
				genRandom(Block.LURE,1+seed.random(20));
			}
			if( seed.random(8)==0 ){
				var list = getHoriLine(seed.random(ymax),0.1,0);
				for( p in list )model[p[0]][p[1]] = Block.LURE;
			}
		}

		// MIRROR
		if(flMirror){
			var mx = Std.int(Cs.XMAX*0.5);
			for( x in 0...mx){
				var nx = Cs.XMAX-(x+1);
				//bmp.copyPixels(bmp,new flash.geom.Rectangle(x,0,1,Cs.YMAX), new flash.geom.Point(nx,0)  );
				model[nx] = model[x].copy();
				if(flMirrorPalette){
					bmpPaint.copyPixels(bmpPaint,new flash.geom.Rectangle(x,0,1,Cs.YMAX), new flash.geom.Point(nx,0)  );
				}
				var a = model[nx];
				for( y in 0...ymax ){
					var n = model[nx][y];
					if( n == Block.DRAGON_LEFT ) model[nx][y] = Block.DRAGON_RIGHT;
					if( n == Block.DRAGON_RIGHT ) model[nx][y] = Block.DRAGON_LEFT;
				}

			}


		}

		// START CROP
		if( dst<8 ){
			var crop = 1;
			if(dst<2)crop++;
			if(dst<1)crop++;
			for( x in 0...Cs.XMAX ){
				for( y in 0...ymax ){
					if(x<crop || x>=Cs.XMAX-crop || y<crop){
						model[x][y] = null;
					}
				}
			}

		}

		// START CEINTURE
		if( ( Math.max(Math.abs(wx),Math.abs(wy)) == 3 ) ){
			var list = getHoriLine( 12, 0.0 );
			for( p in list )model[p[0]][p[1]]=1;
		}

		// OBJETS
		if( itemId!=null && isItemVisible() )insertItem();




	}
	public function forceModel(){
		model = [];
		for( x in 0...Cs.XMAX ){
			model[x] = [];
			for( y in 0...ymax )model[x][y] = 0;
		}
	}
	public function genStruct(){

		model = [];
		for( x in 0...Cs.XMAX ){
			model[x] = [];
			for( y in 0...Cs.YMAX ){
				var n = struct[x][y];
				if( n == Block.ITEM ){
					if( !isItemVisible() ) n = null;
				}
				if(n!=null)model[x][y] = n;

			}

		}
	}
	function genZoneModif(){

		switch(zid){
			case ZoneInfo.MOLTEAR:
				genRandom(Block.CAGE, 10 );
			case ZoneInfo.SOUPALINE:
				var list = getHoriLine(Std.int(ymax*0.5),0.1,0);
				for( p in list )model[p[0]][p[1]] = Block.SPACE;
			case ZoneInfo.LYCANS:
				if(seed.random(4)==0){
					var list = getHoriLine(Std.int(ymax*0.5),0.1,0);
					for( p in list )model[p[0]][p[1]] = Block.BOOM;
				}
			case ZoneInfo.SAMOSA:
				if( seed.random(2)==0 ){
					genRandom(Block.GLUE,1+seed.random(16));
				}
				if( seed.random(8)==0 ){
					var list = getHoriLine(Std.int(ymax*0.5),0.1,0);
					for( p in list )model[p[0]][p[1]] = Block.GLUE;
				}
			case ZoneInfo.TIBOON:
			case ZoneInfo.BALIXT:
				var max = 2+seed.random(12);
				genRandom(Block.REDUC,max);
				flLure = true;
			case ZoneInfo.KARBONIS:

				var max = 1;
				if(distances[ZoneInfo.KARBONIS]<1.5)max++;

				for( i in 0...max){
					var list = getHoriLine(4+seed.random(ymax-8),0.15);
					for( p in list )model[p[0]][p[1]] = Block.JUMPER;
				}

			case ZoneInfo.SPIGNYSOS:
				genRandom( Block.CAGE+el.Molecule.LIGHTER, 1+seed.random(3) );
				if(seed.random(5)==0)genRandom( Block.CAGE+el.Molecule.SPACER, 1+seed.random(5) );

			case ZoneInfo.POFIAK:
				genRandom( Block.CAGE+el.Molecule.BUILDER, 1+seed.random(2) );
				if( seed.random(3)==0 )genRandom(Block.INSECT,1+seed.random(4));

			case ZoneInfo.SENEGARDE:
				var c = 1 - distances[ZoneInfo.SENEGARDE]/ZoneInfo.list[ZoneInfo.SENEGARDE].pos[2];
				var max = Std.int(1+c*8);
				genRandom( Block.GENERATOR, max );

			case ZoneInfo.DOURIV:
				for( i in 0...3 ){
					var list = getHoriLine( 2+i*5,0.2,0);
					for( p in list )model[p[0]][p[1]] = 4;
				}
				if( seed.random(4)==0 )genRandom(Block.INSECT,3+seed.random(12));

			case ZoneInfo.GRIMORN:
				for( i in 0...20 )genCloud( Block.STEEL );

			case ZoneInfo.DTRITUS:
				genRandom(Block.INSECT,1+seed.random(24));

			case ZoneInfo.NALIKORS:
				genRandom( Block.LIFE , 1 );
				genRandom( Block.DEATH , 1+seed.random(2) );

				if( seed.random(20)==0 ){
					var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
					for( p in list )model[p[0]][p[1]] = Block.DEATH;
				}


			case ZoneInfo.HOLOVAN:
				if(seed.random(2)==0){
					var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
					for( p in list )model[p[0]][p[1]] = Block.KILL;
				}
				while(seed.random(2)==0){
					var max = 1+seed.random(6);
					genRandom( Block.KILL, max );
				}

			case ZoneInfo.KHORLAN:

				var n = 1;
				while( seed.rand()*n < 1 ){
					var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
					for( p in list )model[p[0]][p[1]] = Block.NUT;
					n*=2;
				}
				if(seed.random(2)==0){
					genRandom( Block.CAGE+el.Molecule.ARMORER, 1+seed.random(3) );
				}

			case ZoneInfo.CILORILE:
				genRandom( Block.GUARDIAN, 1+seed.random(16) );

			case ZoneInfo.TARCITURNE:
				var n = 1;
				while(seed.rand()*n<3){
					genCloud( Block.STEEL );
					n++;
				}
			case ZoneInfo.CHAGARINA:
				if( seed.random(2)==0 ){
					var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 6 );
					for( p in list )model[p[0]][p[1]] = Block.DEATH;
				}
			case ZoneInfo.VOLCER:

				var max = Std.int( (8-distances[ZoneInfo.VOLCER])*2 );
				genRandom( Block.REDUC, max );
				genRandom( Block.KILL, max );
				if(seed.random(2)==0)genRandom( Block.LURE, max );

			case ZoneInfo.BALMANCH:
				var max = 10+seed.random(10);
				for( i in 0...max )genCloud( Block.NUT );

				var max = 1+seed.random(4);
				for( i in 0...2 ){
					var sens = i*2-1;
					for( n in 0...max ){
						var x = i*(Cs.XMAX-1) - sens*seed.random(4);
						var y = seed.random(ymax);
						model[x][y] = [Block.DRAGON_RIGHT,Block.DRAGON_LEFT][i];
					}

				}
				searchAndReplace(Block.STEEL,4);

			case ZoneInfo.FOLKET:

				var max = Std.int( (3-distances[ZoneInfo.FOLKET])*3 );
				for( i in 0...max )genCloud( Block.REDUC );

				searchAndReplace(Block.STEEL,Block.SPACE);
				searchAndReplace(Block.BONUS+1,Block.BONUS+1);
				searchAndReplace(Block.BONUS+2,Block.BONUS+1);
				searchAndReplace(Block.BONUS+3,Block.BONUS+1);
				searchAndReplace(Block.BONUS,Block.BONUS+1);
				for( i in 1...6 )searchAndReplace(i,Block.SPACE);

			case ZoneInfo.EARTH:
				for( x in 0...Cs.XMAX ){
					for( y in 0...Cs.YMAX ){
						if(model[x][y]!=null) model[x][y] = 0;
					}
				}


				/*
				var max = 1;
				while(seed.random(max)==0){
					max++;
					var list = getHoriLine(1+seed.random(ymax-2),0.1, null, 2 );
					for( p in list )model[p[0]][p[1]] = Block.GUARDIAN;
				}
				*/


		}


	}

	// BUILD TOOL
	function genBonusBlock(ymax){
		var max = Std.int( Math.min(2+lvl,4) );

		var mx = 1+seed.random( max );
		var my = 1+seed.random( max );
		var sx = seed.random(Cs.XMAX-mx);
		var sy = seed.random(ymax-my);
		var po = 0;

		var bluePower = Math.max(2.5-dst*0.004,1);
		var pinkPower = Math.max(3.5-dst*0.004,2);


		if( seed.random( Std.int(Math.pow(mx+my+1,bluePower)) ) == 0 )po = 1;
		if( seed.random( Std.int(Math.pow(mx+my+1,pinkPower)) ) == 0 )po = 2;



		var type = 10+po;
		//if( flDepleted )type = null;

		for( x in 0...mx){
			for( y in 0...my){
				model[sx+x][sy+y] = type;
			}
		}


	}
	function getHoriLine(sy,turnCoef,?type,?hole){
		// TYPE
		// null Over
		// 0 	Fill
		// 1 	Behind

		var hx = null;
		if(hole!=null)hx = seed.random(Cs.XMAX-hole);

		var list = [];

		var y = sy;

		//var x = 0;
		//while( x < Cs.XMAX ){
		for( x in 0...Cs.XMAX ){

			if( hx==null || (x<hx || x>=hx+hole) ){
				if(type==null){
					list.push([x,y]);
				}else{
					var prec = model[x][y];
					if( prec != null ){
						if( type == 0 )list.push([x,y]);
					}else{
						if( type == 1 )list.push([x,y]);
					}
				}
				if( seed.rand() < turnCoef){
					var sens = seed.random(2)*2-1;
					var max = 1+seed.random(8);
					for( i in 0...max ){
						y += sens;
						if( y<ymax && y>=0 ){

							if(type==null){
								list.push([x,y]);
							}else{
								var prec = model[x][y];
								if( prec != null ){
									if( type == 0 )list.push([x,y]);
								}else{
									if( type == 1 )list.push([x,y]);
								}
							}
						}else{
							y -= sens;
							break;
						}
					}
				}
			}
		}
		return list;
	}
	function genRandom(type,max,?drawType,?ma,?ym){
		if(ym==null)ym = ymax;
		if(ma==null)ma = 0;
		for( i in 0...max ){
			var x = ma+seed.random(Cs.XMAX-2*ma);
			var y = ma+seed.random(ym-2*ma);
			var n = model[x][y];
			switch(drawType){
				case 0:		if(n!=null)model[x][y] = type;
				case 1:		if(n==null)model[x][y] = type;
				default:	model[x][y] = type;
			}

		}
	}
	function genCloud(type){
		var x = seed.random(Cs.XMAX);
		var y = seed.random(ymax);
		var d = Cs.DIR[seed.random(4)];
		var lmax = 2+seed.random(4);
		for( n in 0...lmax){
			var nx = x+d[0]*n;
			var ny = y+d[1]*n;
			if(isOut(nx,ny))break;
			model[nx][ny] = type;
		}
	}
	function insertItem(){
		var ma = 4;
		var x = ma+seed.random(Cs.XMAX-2*ma);
		var y = seed.random(3);
		model[x][y] = Block.ITEM;
		//trace(">>");

	}
	public function isItemVisible(){
		var n= Cs.pi.items[itemId];
		return n == MissionInfo.VISIBLE || n == MissionInfo.SURPRISE || flEdit;
	}
	function searchAndReplace(o,n){
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				if(model[x][y]==o)model[x][y]=n;
			}
		}

	}
	function getRandomBlock(){
		var to = 0;
		while(true){
			var x = seed.random(Cs.XMAX);
			var y = seed.random(ymax);
			var id = model[x][y];
			if(id>0 && id!=Block.MINE )return {x:x,y:y};
			if(to++>100)break;
		}
		return {x:1,y:1};
	}

	// BONUS
	function getMineCoord(){
		var to = 0;
		while(true){
			var x = seed.random(Cs.XMAX);
			var y = seed.random(ymax);
			if(model[x][y] == 0 )return {x:x,y:y};
			if(to++>100)break;
		}
		return getRandomBlock();
	}

	public function addMine(){
		var p = getMineCoord();
		model[p.x][p.y] = Block.MINE;
	}

	// TOOLS
	public function getString(){
		var str = "";
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var n = model[x][y];
				//if( n!=null )trace(n);
				if( n!=null )n+=1; else n=0;
				str += Std.string(n)+",";
			}
		}

		return str.substr(0,str.length-1);
	}
	public function getScreenshot(sc:Float,?defaultColor:Int){
		if(model==null){
			trace("no model loaded!");
			return null;
		}
		var ww = Std.int(Cs.mcw*sc);
		var hh = Std.int(Cs.mch*sc);
		var bmp = new flash.display.BitmapData(ww,hh,false,0x000000);
		var mc = navi.Map.me.dm.attach("mcBlock",0);

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var type = model[x][y];
				if(type!=null){

					var bl = new Block(0,0,type,mc,true);
					bl.dm.clear(0);
					if(bl.type==0 && defaultColor!=null )bl.setColor([defaultColor]);
					var m = new flash.geom.Matrix();
					m.scale(sc,sc);
					m.translate((x*Cs.BW)*sc,(y*Cs.BH)*sc);
					bmp.draw(mc,m);
				}

				// new Block(x,y,n,dm.attach("mcBlock",2),true);

			}
		}
		mc.removeMovieClip();


		return bmp;
	}


	// BUILD TEST
	public function isModelOpen(obj){

		var sx = null;
		var sy = ymax-1;
		var grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			if( sx== null && Block.isSoft(model[x][sy]) )sx = x;
		}
		if(sx==null){
			//trace("csModelOpen ERROR");
			return false;
		}

		//trace(sx);
		//return true;

		var n = getPath(sx,sy,grid,0);
		return n == obj;
	}
	function getPath(x,y,grid:Array<Array<Bool>>,profondeur){
		if(profondeur==240)return 0;

		var n = 0;
		grid[x][y] = true;
		if(model[x][y]==0)n++;
		for( d in Cs.DIR ){
			var nx = x+d[0];
			var ny = y+d[1];
			if(grid[nx][ny] == null && nx>=0 && nx<Cs.XMAX && ny>=0 && ny<ymax+1 ){
				if( Block.isSoft( model[x][y] ) )n += getPath(nx,ny,grid,profondeur+1);
			}
		}
		return n;
	}
	public function getGoal(){
		var obj = 0;
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				if( model[x][y] == 0 )obj++;
			}
		}
		return obj;
	}
	public function getMineraiTotal(){

		var min = 0;
		for( x in 0...Cs.XMAX ){
			for( y in 0...ymax ){
				var n = model[x][y];
				if( n==Block.BONUS   )	min += Block.MIN_GREEN.get();
				if( n==Block.BONUS+1 )	min += Block.MIN_BLUE.get();
				if( n==Block.BONUS+2 )	min += Block.MIN_PINK.get();
			}
		}
		return min;
	}
	public function isOut(x,y){
		return x<0 || x>=Cs.XMAX || y<0 || y>=ymax;
	}





//{
}
















