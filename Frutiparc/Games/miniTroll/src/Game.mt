class Game extends MovieClip{//}
	
	// CONSTANTE
	static var DP_PART = 		20;
	
	static var DP_PEOPLE = 		14;
	static var DP_PART2 = 		12;
	static var DP_LINE = 		11;
	static var DP_SPRITE_FRONT = 	10;
	static var DP_SPRITE = 		8;
	static var DP_PART3 = 		6;
	static var DP_UNDER = 		5;
	
	static var DP_BACKGROUND = 	1;
	
	// CONSTANTE INST
	var flSpellTodo:bool;
	var flActiveElementTodo:bool;
	var flHelp:bool;
	var flHelpRelease:bool;
	var flColorKill:bool;
	var flAutoRaiseSpeed:bool;
	var width:int;
	var height:int;
	var barSize:int;
	var xMax:int;
	var yMax:int;
	var groupMax:int;
	var nextLimit:int;
	var shapeNum:int;
	var sideMargin:float;
	var colMax:int;
	var pSpeedStart:float;
	var pSpeed:float;
	var timer:float;
	//var fallSpeed:float;
	var marginUp:float;
	var marginLeft:float;
	var shapeList:Array<Array<Array<{x:int,y:int}>>>
	var lvl:Array<Array<{et:int,n:int}>>
	
	// VARIABLES
	var shapeNumInc:int;
	var pieceTimer:int;
	var mainTimer:float;
	var step:int;
	var ts:float;
	var cFall:float;
	var starWait:float;
	var colorList:Array<int>			// LISTE DES COULEURS
	var grid:Array<Array<sp.Element>>;
	
	var eList:Array<sp.Element>			// ELEMENT LIST
	var activeElementList:Array<sp.Element>		// ITEM LIST
	
	var fList:Array<sp.Element>			// FALL LIST
	var dList:Array<sp.Element>			// DESTROY LIST
	var bList:Array<sp.Element>			// BLAST LIST	
	
	var shotList:Array<sp.part.Shot>		// SHOT LIST
	
	var pList:Array<sp.People>			// PEOPLE LIST
	var faerieList:Array<sp.pe.Faerie>		// FAERIE LIST
	var impList:Array<sp.pe.Imp>			// IMP LIST
	
	
	var gList:Array<Group>				// GROUP LIST
	var sList:Array<spell.Base>			// SPELL LIST
	var saList:Array<spell.Base>			// SPELL ACTIVE LIST
	var partList:Array<sp.Part>			// PARTICULE
	
	var quakeList:Array<{sp:Sprite,pos:{x:float,y:float},ray:float,timer:float,fadeLimit:float}>
	var nextList:Array<Array< ElementInfo >>

	var fs:{ bm:int, list:Array<int>, sum:int, flSpecial:bool }	// FALL STATS
	
	var nextPiece:Array<ElementInfo>
	
	var line:MovieClip;
	var base:Base;	
	var piece:Piece;
	var dm:DepthManager;
	
	function new(){
		dm = new DepthManager(this)
		Cs.game = this;
		initDefault();
		
	}
	
	function init(){
		
		Manager.log("[Game] initialisation.")
		
		flHelp = false;
		flColorKill = false;

		xMax = Math.floor((width-marginLeft)/ts)
		yMax = Math.floor((height-marginUp)/ts)

		pieceTimer = 0
		mainTimer = 0
		starWait = 0;
		
		line = dm.empty(DP_LINE)
		
		initList();

	}
	
	function initList(){

		eList = new Array();
		
		fList = new Array();
		gList = new Array();
		pList = new Array();
		faerieList = new Array();
		impList = new Array();
		sList = new Array();
		saList = new Array();
		partList = new Array();
		shotList = new Array();
		//
		nextList = new Array();
		quakeList = new Array();
		//

		
	}
	
	function initDefault(){
		//
		ts = 16; 
		barSize = 10;
		flAutoRaiseSpeed = true;
		groupMax = 4;
		colMax = 3;
		marginUp = -ts*2;
		marginLeft = 4;
		nextLimit = 10;
		shapeNum = 3;
		shapeNumInc = 0;
		//
		shapeList = [
			[],				// 0
			[				// 1
				[
					{x:0,y:0}
				]
			],				
			[				// 2
				[
					{x:0,y:0},
					{x:1,y:0}
				]
			],				
			[				// 3
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:0,y:1}
				],
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:-1,y:0}
				]				
			],
			[				// 4
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:0,y:1},
					{x:1,y:1}
					
				],
				[
					{x:0,y:0},
					{x:-1,y:0},
					{x:0,y:1},
					{x:1,y:1}
				]				
			],
			[				// 5
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:0,y:1},
					{x:-1,y:0},
					{x:0,y:-1}
				]
			],
			[				// 6
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:0,y:1},
					{x:-1,y:0},
					{x:-2,y:0},
					{x:0,y:-1}
				]
			],
			[				// 7
				[
					{x:0,y:0},
					{x:1,y:0},
					{x:0,y:1},
					{x:0,y:2},
					{x:-1,y:0},
					{x:-2,y:0},
					{x:0,y:-1}
				]
			]					
					
		]
		
	}
	
	//
	function launch(){

		colorList = new Array();
		for(var i=0; i<colMax; i++ )colorList.push(i)

		//
		updateNextList()
		initGrid()		
		
		//
		fillLevel()
		newCycle()
		
		
	}
	
	// GRID
	function initGrid(){
		grid = new Array();
		for(var x=0; x<xMax; x++ ){
			grid[x] = new Array();
			for(var y=0; y<yMax; y++ ){
				//grid[x][y] = false
			}		
		}
		
	}
	
	function insertInGrid(e){
		grid[e.px][e.py] = e;
		
	}
	
	function removeFromGrid(e){
		grid[e.px][e.py] = null
	}

	function insertRandomToken(){
		
		// HERE
		
		//* TOKEN
		
		for( var i=0; i<10; i++ ){
			var pos = getEmptyPos();
			var e = genElement( 0, pos.x, pos.y, 0)
		}
		//*/
		
		//* ITEM
		{
			var pos = getEmptyPos();
			var e = genElement( 1, pos.x, pos.y, Item.getRandomId(base.fi,99) );
		}
		//*/
		
		//* STONE
		for( var i=0; i<1; i++ ){
			var pos = getEmptyPos();
			var e = genElement( 2, pos.x, pos.y, 3 );
		}	
		//*/
		
		//* IMPCELL
		for( var i=0; i<1; i++ ){
			var pos = getEmptyPos();
			var e = genElement( 3, pos.x, pos.y, Std.random(3) );
		}	
		//*/
		
		//* BOMB
		for( var i=0; i<1; i++ ){
			var pos = getEmptyPos();
			var e = genElement( 4, pos.x, pos.y, null );
		}	
		//*/				
	}
	
	function fillLevel(){
		//Manager.log(lvl)
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var o = lvl[x][y]
				var e = genElement( o.et, x, y, o.n );
			}			
		}

		do{
			clearGroup();
			checkGroup();
			
		}while(protectGroup())
	
		
	}

	// FALL STAT
	
	function initFallStats(){
		fs = { bm:0, list:[], sum:0, flSpecial:false }
	}
	
	function checkFallStats(){
		var sum = 0
		for( var i=0; i<fs.list.length; i++ ){
			sum += fs.list[i]*(i+1)
		}
		
		if(!fs.flSpecial){
			// STAR
			starWait += fs.sum;
			
			// MANA
			for(var i=0; i<faerieList.length; i++ ){
				var fi = faerieList[i]
				var c = base.getManaReplenishCoef()
				var inc = -fs.sum*c
				fi.incManaTimer(inc)
			}
		}
		faerieList[0].fi.reactCombo(sum);
		
		
		base.onFallStats(fs);
		/* TRACER
		if(fs.sum>0){
			Log.clear()
			Manager.log( "Block max :"+fs.bm )
			Manager.log( "Sum :"+fs.sum )
			Manager.log( "list :"+fs.list )
		}
		//*/
	}
	
	function newCycle(){
		initStep(1)
		initFallStats()
	}
	
	function newUpkeep(){
		
		for(var i=0; i<sList.length; i++ ){
			sList[i].onUpkeep();
		}
		//initSpell();
		flSpellTodo = true;
		flActiveElementTodo = true;
		newCycle();
	}
	
	function initSpell(){
		if(flHelp){
			for(var i=0; i<faerieList.length; i++ ){
				var f = faerieList[i]
				f.colorBlink = null
				Mc.setPercentColor(f.body,0,0xFFFFFF)
			}
		}
		for( var i=0; i<faerieList.length; i++){
			faerieList[i].checkSpell();
		};
		if( getCoefFull() > 0.1 ){
			for( var i=0; i<impList.length; i++){
				impList[i].checkSpell();
			};
		}
		flHelp = false;
		/*

		*/
	}
	
	//
	function initStep(s:int){
		//Manager.log("initStep"+s)
		if(step==10)return;
		step = s
		switch(step){
			case 0:
				break;
			
			case 1:		// FALLING
				
				cFall = 0
				checkFall();
				break;
			
			case 2:		// GAME
				
				if( colorList.length == 0 ){
					initStep(10);
					return;
				}
				if(flAutoRaiseSpeed){
					pSpeed = Math.min( pSpeed+0.0015, pSpeedStart*3 ) 
				}
				piece = new Piece(this);
				
				if(nextPiece == null){
					piece.list = getNext();	
					updateNextList()
				}else{
					piece.list = nextPiece
					nextPiece = null;
				}
				piece.init();
				piece.fSpeed = pSpeed
				
				pieceTimer++;
				// 
				//var list = getGridModel();
				//evalGridModel(list);
				//
				break;
				
			case 3:		// DESTROY - DRAW
				fs.list.push(0)
				destroyGroup();
				timer = 0;
				checkBlast();
				if( dList.length == 0 ){
					//Manager.log("finalement , ca devait servir a quelquechose !");
					checkFallStats();
					if(flSpellTodo){
						initSpell()
						flSpellTodo = false;
					}
					if( saList.length > 0 ){
						initStep(4);
					}else{				
						if(flActiveElementTodo){
							flActiveElementTodo = false;
							initStep(5)
						}else{
							newTurn();
						}
					}
				}else{
					Cs.base.onDestroyElement(dList)
				}
				break; 
				
			case 4:		// MAGIE
				//Manager.log("initMagie ")
				break;
				
			case 5 :	// ACTIVE ELEMENT
				activeElementList = new Array();
				for( var i=0; i<eList.length; i++)eList[i].initActiveStep();
				break;
				
			case 10:	// FREEZE
				break;
							
		}
	}
	//
	
	function setPieceSpeed(speed){
		pSpeedStart = speed;
		pSpeed = pSpeedStart;
	}
	//
	
	// UPDATE
	function update(){
		
		line.clear();
		
		movePeople();
		movePart();
		moveShot();
		updateSpell();
		
		switch(step){
			
			case 0:		// WAIT
				break;
			
			case 1:		// FALLING
				cFall += 0.5*Timer.tmod
				fall(cFall)
				while( cFall>=1 )cFall--;
				if( fList.length == 0 ){
					clearGroup();
					checkGroup();
					initStep(3)
				}
				break;
				
			case 2:		// GAME
				mainTimer += Timer.tmod
				piece.update();
				if(Std.random(int(Cs.ambientRate/Timer.tmod))==0 && Manager.slot.dial==null ){
					faerieList[0].fi.reactAmbience()
				}	
				if( Key.isDown(Cm.pref.$key[4]) ){
					if( !flHelp && flHelpRelease ){
						flHelpRelease = false
						callHelp();
					}
				}else{
					flHelpRelease = true;
				}
				if( Manager.CHEAT >= 2 && Key.isDown( Key.ENTER)  ){
					downcast(base).level += Cs.getKeyCoef()-1
					initStep(10)
					base.setWin(true)
				}			
				break;
				
			case 3:		// DESTROY - DRAW
				timer += Timer.tmod
				for( var i=0; i<dList.length; i++ ){
					var e = dList[i]
					var p = (timer/10)
					var col = new Color(e.skin);
					var o = { ra:100, ga:100, ba:100, aa:100, rb:Math.round(255*p), gb:Math.round(255*p), bb:Math.round(255*p), ab:0 }
					col.setTransform(o)
					if(timer>10)e.kill();
				}
				
				if( timer > 10 ){
					initStep(1)
				}
				break;	
				
			case 4:		// MAGIE
				//Log.print(">>>"+saList.length)
				if(saList.length>0){
					if(!saList[0].flCast){
						Manager.log(saList[0].getName()+" en cours...")
						saList[0].cast();					
					}
					saList[0].activeUpdate();
				}else{
					newCycle();
				};
				break;
				
			case 5 :	// ACTIVE ELEMENT
				/*
				for(var i=0; i<activeElementList.length; i++ ){
					var e = activeElementList[i]
					e.activeUpdate();
				};
				*/
				activeElementList[0].activeUpdate();
				
				if( activeElementList.length == 0 ){
					//initStep(1)
					newCycle();
				};
				break;
				
			case 10:	// FREEZE
				break;
				
		}
	
		updateQuake();
	}
	//
	
	function movePeople(){
		for( var i=0; i<pList.length; i++ ){
			pList[i].update();
			
		}
	}
	
	function movePart(){
		for( var i=0; i<partList.length; i++ ){
			partList[i].update();
			
		}
	}

	function moveShot(){
		for( var i=0; i<shotList.length; i++ ){
			shotList[i].update();
			
		}
	}
	
	function callHelp(){
		
		for( var i=0; i<faerieList.length; i++ ){
			faerieList[i].callHelp();
		}
	}
		
	function updateSpell(){
		for( var i=0; i<sList.length; i++ ){
			sList[i].update();
		}
	}
	
	function fall(cFall){
		for( var i=0; i<fList.length; i++ ){
			var e = fList[i]
			var c = cFall
			while(c>=1){
				removeFromGrid(e)
				e.py++
				insertInGrid(e);
				if(e.haveGround()){
					c = 0
					e.flFalling = false
					fList.splice(i--,1)
				}else{
					c -= 1
				}
			}
			setPos(e,e.px,e.py+c)
		}	
	}
	
	function checkFall(){
		var list = new Array()
		for( var i=0; i< eList.length; i++ ){
			var e = eList[i]
			var n = 0
			while( list[n].py > e.py )n++
			list.insert(n,e);
		}
		for( var i=0; i<list.length; i++ ){
			var e = list[i];
			if( !e.haveGround() ){
				fList.push(e)
				e.flFalling = true;
			}
		}
	}

	function checkBlast(){
		bList = new Array();
		var dir = [
			{x:0,y:1},
			{x:-1,y:0},
			{x:0,y:-1},
			{x:1,y:0}
		]
		for( var i=0; i<dList.length; i++ ){
			var de = dList[i];
			for( var n=0; n<dir.length; n++ ){
				var d = dir[n];
				var e = grid[de.px+d.x][de.py+d.y];
				addToBlastList(e)
				/*
				switch(e.et){
					case 0 :
						var token:sp.el.Token = Std.cast(e)
						if( token.special == 2 )addToBlastList(token);
					break;
				}
				*/
			}
		}		
	}	
	
	function addToBlastList(token){
		for( var i=0; i<bList.length; i++ ){
			if(bList[i]==token)return;
		}
		bList.push(token);
		token.blast();
	}
	
	function updateQuake(){
		for( var i=0; i<quakeList.length; i++ ){
			
			var  o = quakeList[i]
			o.timer -= Timer.tmod; 
	
			var c = 1;
			if( o.timer<0 ){
				quakeList.splice(i--,1)
				c = 0
			}else if(o.timer < o.fadeLimit){
				c = o.timer/o.fadeLimit
			}

			
			var a = Math.random()*6.28
			var d = Math.random()*o.ray*c
			if( o.pos != null ){
				o.sp.skin._x = o.pos.x + Math.cos(a)*d
				o.sp.skin._y = o.pos.y + Math.sin(a)*d				
			}else{
				o.sp.skin._x += Math.cos(a)*d
				o.sp.skin._y += Math.sin(a)*d	
			}

			
		}
		
	}
	
	// DESTROY
	
	function destroyGroup(){
		dList = new Array();
		for( var i=0; i<gList.length; i++ ){
			var group = gList[i]
			group.draw()
			var max = group.list.length;
			for( var n=0; n<group.list.length; n++ ){
				var e = group.list[n];
				if( e.special == 1 )max--;
			}
			if( max >= groupMax ){
				for(var n=0; n<group.list.length; n++){
					var e = group.list[n]
					if( e.special == 3 ){	// STAR
						var p = newPart("partMiniStarFull",null)
						p.x = e.x+ts*0.5;
						p.y = e.y+ts*0.5;
						p.fadeTypeList = [1,3]
						p.timer = 12;
						p.init();					
						
						destroyColor(e.type)
						fs.flSpecial = true;
					}
					destroyElement(upcast(e))
				}
				gList.splice(i--,1);
				// STATS
				fs.bm = int( Math.max( fs.bm, max ) )
				fs.list[fs.list.length-1] += max
				fs.sum += max;
			}
		};	
	}
	
	function destroyElement(e:sp.Element){
		if(e.flDestroy)return;
		e.flDestroy = true;
		dList.push(upcast(e));		
	}
	
	function destroyColor(type:int){
		for( var i=0; i<eList.length; i++ ){
			var e = eList[i]
			if( e.et == Cs.E_TOKEN ){
				var token:sp.el.Token = downcast(e);
				if( token.type == type ){
					destroyElement(e)
				}
				for( var n=0; n<3 ; n++ ){
					var p = newPart("partVertiLight",DP_PART2)
					p.x = e.x + Math.random()*ts
					p.y = e.y + ts*0.5
					p.fadeTypeList = [1]
					p.timer = 2+Math.random()*10
					p.vity = -(1+Math.random()*6)
					p.init();
				}
				
			}
		}	
		
	}
	
	// PIECE
	
	function newTurn(){
		base.onNewTurn();
		if( checkFull() ){
			base.gameOver();
			initStep(10)
		}else{
			initStep(2)
		}
	}
	
	function onPieceValidate(){
		//initStep(4);	//--> MAGIE
		//newCycle();	//--> FALL
		piece = null
		newUpkeep();
	};
	
	function checkFull(){
		//Manager.log("checkFull!")
		for( var x=0; x<xMax; x++ ){
			if( grid[x][2] != null ){
				return true;
			}
		}
		return false
	}
	
	// GROUP
	function clearGroup(){
		while(gList.length>0)gList.pop().kill();
	}
	
	function checkGroup(){
		//var cList = new Array();
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var te = grid[x][y]
				if( te.et == 0 ){								// CHERCHE TOKEN
					var e:sp.el.Token = Std.cast(te)
					if( e.flGroupable ){							// CHERCHE GROUPABLE
						if(e.group == null ){
							var g = new Group(this);
							g.addElement(e)
						}
						var dir = [{x:1,y:0},{x:0,y:1}]
						for( var i=0; i<dir.length; i++ ){				// CHECK LES 2 SUIVANTS
							var d = dir[i]
							var ste = grid[x+d.x][y+d.y]
							if( ste.et == Cs.E_TOKEN ){					// CHECK TOKEN
								var se:sp.el.Token = Std.cast(ste)
								if( se.type == e.type && se.flGroupable ){	// CHECK SAME TYPE && SE GROUPABLE
									if(se.group != null ){
										if(e.group != se.group)e.group.eat(se.group);
									}else{
										e.group.addElement(se)
									}
								}
							}
						}
					}
				}
			}
		}
	}

	function protectGroup(){
		//var list = new Array();
		for( var i=0; i<gList.length; i++ ){
			var group = gList[i]
			var max = group.list.length;
			for( var n=0; n<group.list.length; n++ ){
				var e = group.list[n];
				if( e.special == 1 )max--;
			}
			if( max >= groupMax ){
				var e = group.list[Std.random(group.list.length)]
				e.setSpecial(1)
				return true;
				/*
				for(var n=0; n<group.list.length; n++){
					var e = group.list[n]
					if( e.special == 3 ){	// STAR
						var p = newPart("partMiniStarFull",null)
						p.x = e.x+ts*0.5;
						p.y = e.y+ts*0.5;
						p.fadeTypeList = [1,3]
						p.timer = 12;
						p.init();					
						
						destroyColor(e.type)
						fs.flSpecial = true;
					}
					destroyElement(upcast(e))
				}
				gList.splice(i--,1);
				// STATS
				fs.bm = int( Math.max( fs.bm, max ) )
				fs.list[fs.list.length-1] += max
				fs.sum += max;
				*/
				
			}
		}
		return false
	}
	
	// NEW
	function initSprite(link,sp,d){
		var mc = downcast( dm.attach( link, d ) );
		Std.cast(sp).setSkin(mc);
	}
	
	function newSprite(link):Sprite{
		var sp = new Sprite();
		initSprite( link, sp, Game.DP_SPRITE );
		return sp;
	}
	
	function newPart(link,d):sp.Part{
		var sp = new sp.Part();
		if(d==null)d = Game.DP_PART
		sp.setSkin( dm.attach( link, d  ) )
		sp.addToList(partList);
		return sp;
	}
	
	// SPELL
	function cast(n){
		
		
		
	}
	
	// COLOR
	function updatecolorList(){
		var cList = new Array();
		var flClear = false;
		for( var i=0; i<colorList.length; i++ ){
			cList[colorList[i]] = true;
		}
		for( var i=0; i<eList.length; i++ ){
			var e = eList[i]
			if(e.et==0)cList[downcast(e).type] = false;
			if(e.et==Cs.E_EYE)cList[downcast(e).color] = false;
		}
		for( var i=0; i<colorList.length; i++ ){
			if( cList[colorList[i]] ){
				//cList.splice(i,1)
				flColorKill = true;
				colorList.splice(i,1)
				i--;
				flClear = true;
			}
		}
		if( flClear){
			if( colorList.length > 0 ){
				clearNext();
			}else{
				base.onLevelClear();
			}
		}
	}
	
	function getColor(){
		return colorList[Std.random(colorList.length)]
	}

	function clearNext(){
		for( var i=0; i<nextLimit; i++){
			getNext();
			updateNextList();
		}
		nextPiece = null;
		
	}	

	// IMP
	function addImp(x,y,level){
		var imp = new sp.pe.Imp();
		imp.init();
		imp.setLevel(level)
		imp.birth(dm.empty( DP_PEOPLE ));
		imp.x = x //game.width*0.5
		imp.y = y //game.height*0.5
		imp.update();
		/*
		imp.game = game;
		imp.setSkin( game.dm.attach( "imp", Game.DP_PEOPLE) );
		imp.addToList(game.pList)
		imp.addToList(game.impList)
		*/
		
		return imp;
	}

	
	
	// EVALUATION

	function getGridModel():Array<Array<ModelUnit>> {
		var list = new Array();
		for( var x=0; x<xMax; x++ ){
			list[x] = new Array();
			for( var y=0; y<yMax; y++ ){
				var e = grid[x][y]
				if(e.et == 0 ){
					var token:sp.el.Token = downcast(e)
					if( token.flGroupable ){
						list[x][y]  = { t:token.type, g:null, s:token.special };
					}
				}
			}			
		}
		return list;
	};
	
	function evalGridModel(list){
		var gList = new Array();
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var e = list[x][y]
				if(e!=null){
					if(e.g == null ){
						var a = [e];
						e.g = a;
						gList.push(a);
					}
					var dir = [{x:1,y:0},{x:0,y:1}]
					for( var i=0; i<dir.length; i++ ){				// CHECK LES 2 SUIVANTS
						var d = dir[i]
						var se = list[x+d.x][y+d.y]
						if( se.t == e.t ){					// CHECK SAME TYPE 
							if(se.g != null ){
								for(var n=0; n<gList.length; n++ ){
									if( gList[n] == se.g ){
										gList.splice(n,1);
										break;
									}
								}
								var ogList = new Array();
								for(var n=0; n<se.g.length; n++ ) ogList[n] = se.g[n];
								
								for(var n=0; n<ogList.length;n++){
									var gre = ogList[n];
									e.g.push(gre);
									gre.g = e.g;
								}
								
								
							}else{
								e.g.push(se);
								se.g = e.g;
							}
						}
					}
				}
			}
		}
		
		return {gList:gList,list:list}
		
		/* TRACE EVAL RESULT
		Log.clear();
		Manager.log("evalGridMode ("+gList.length+") ")
		var str = ""
		for( var i=0; i<gList.length; i++ ){
				str+=gList[i].length+"/"
		}
		Manager.log(str)
		//*/
	}
	
	function getGroupModelScore(gList){
		var score = 0; 
		//var dbg = ""
		for( var i=0; i<gList.length; i++ ){
			var tr = 0;
			
			for( var n=0; n<gList[i].length; n++ ){

				if(gList[i][n].s == 0 )tr++;
	
			}
			if( tr >= groupMax ){
				score += tr*50
			}else{
				score += 0//tr*0.10	//10
			}
			//dbg += gList[i].length+";"
		}
		//Manager.log(">"+dbg)
		return score
	}
	
	
	//
	function setPos(e:sp.Element,x:float,y:float){
		e.x = getX(x)
		e.y = getY(y)
		e.update();
	}
	
	
	function kill(){
		while(sList.length>0){
			sList.pop().dispel()
		}
		this.removeMovieClip();
	}
	
	
	// IS
	function isFree(x,y){
		return grid[x][y] == null && x>=0 && x<xMax && y>=0 && y<yMax
	}
	
	function isIn(x,y,m){
		return x>m+marginLeft && y>m+marginUp && x<width-m && y<height-m
	}
	
	//
	function updateNextList(){
		while( nextList.length < nextLimit ){
			
			
			var sn = int( Math.min( Math.max( 1, shapeNum + shapeNumInc ), 6 ) )
			
			var shape = null
			if( sn <= 4 ){
				var cat = shapeList[sn];
				shape = cat[Std.random(cat.length)];
			}else{
				shape = getBigShape(sn)
			}
				
			var list = base.newPieceList(shape);
			nextList.push(list);
		}
	}
	

	
	function getBigShape(n){
		
		var list = [{x:0,y:0}]

		do{
			var x = Std.random(5)-2
			var y = Std.random(5)-2	
			
			var flValide = false;
			
			for( var i=0; i<list.length; i++ ){
				var p = list[i]
				var dif = Math.abs(p.x-x) + Math.abs(p.y-y)
				if( dif == 0){
					flValide = false;
					break
				}
				if( dif == 1 )flValide = true;
			}

			if( flValide )list.push({x:x,y:y});
			
		}while( list.length < n )

		
		return list
	}
	
	//GET
	
	function getNext():Array<ElementInfo>{	// Recursive
		var ei = nextList.shift()
		base.onNextRemove()
		return ei;
	}

	function getX(gx){
		return marginLeft + gx*ts
	}
	
	function getY(gy){
		return marginUp + gy*ts
	}	

	function genElement(et:int,x:int,y:int,n:int):sp.Element{

		var el = null;
		
		switch(et){
			case Cs.E_TOKEN:	// TOKEN
				var e = new sp.el.Token();
				el = upcast(e)
				break;
				
			case Cs.E_ITEM: // 
				var e = new sp.el.Item();
				el = upcast(e)
				break;
			case Cs.E_STONE:
				var e = new sp.el.Stone();
				el = upcast(e)
				break;
			case Cs.E_CELL:
				var e = new sp.el.ImpCell();
				el = upcast(e)
				break;
			case Cs.E_BOMB:
				var e = new sp.el.Bomb();
				el = upcast(e)
				break;
			case Cs.E_FIREBALL:
				var e = new sp.el.FireBall();
				el = upcast(e)
				break;
			case Cs.E_EYE:
				var e = new sp.el.Eye();
				el = upcast(e)
				break;					

		};
		
		el.game = this;
		el.px = x;
		el.py = y;
		el.init();
		
		switch(et){
			case Cs.E_TOKEN:
				var e = downcast(el)
				e.setType(getColor())
				if( n != null ){
					e.setSpecial(n);
				}
				break;
			case Cs.E_ITEM:
				var e = downcast(el)
				e.setType(n)
				break;
			case Cs.E_STONE:
				var e = downcast(el)
				e.setLife(n)
				break;
			case Cs.E_CELL:
				var e = downcast(el)
				e.setLevel(n)
				break;
			case Cs.E_BOMB:
				var e = downcast(el)
				break;
			case Cs.E_FIREBALL:
				var e = downcast(el)
			case Cs.E_EYE:
				var e = downcast(el)				
				break;
		};

		return el
	}

	function getHeightMax(){
		var ym = yMax
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				if( grid[x][y] != null ){
					ym = int(Math.min(y,ym))
					break;
				}
			}
		}
		return ym;
	}

	function getEmptyPos(){
		var x = null;
		var y = null;
		while(true){
			x = Std.random(xMax)
			y = Std.random(yMax)
			if( grid[x][y] == null ){
				break;
			}
		}
		return {x:x,y:y}
	}

	function getCoefFull(){
		var score = 0
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				if( grid[x][y] != null ){
					score += 1
				}				
			}
		}
		return score/(xMax*yMax)
	}
	
	
//{
};




















