class Game {//}

	static var FL_DEBUG = false;

	static var STAND_ALONE = true;
	static var PLASMA_QUALITY = 0.25;

	static var DP_BG = 0
	static var DP_CONSOLE = 1
	static var DP_GROUND = 2
	static var DP_DECK = 3
	static var DP_CARD = 4
	static var DP_INTERFACE = 6
	static var DP_PAILLETTE = 7
	static var DP_PART = 8
	static var DP_FRONT = 9
	static var DP_HINT = 10
	static var DP_LOG = 12

	var flSecondFrame:bool;
	var flClick:bool;
	var flLog:bool;
	var flPause:bool;
	var flNoob:bool;
	var flPenguin:bool;
	var speed:float;
	var step:int;
	var roundId:int;
	var currentInfoSlot:int;
	var mainPlayerId :int;

	var sList:Array<Sprite>
	var partList:Array<Part>

	var rawData:String;
	var logText:String;
	var playerList:Array<Player>
	var actionList:Array< { name:String, list:Array<Action>, id:int } >
	var cardList:Array<Card>

	var startUrl:String;
	var endUrl:String;
	var viewUrl:String;
	var addUrl:String;

	var infoSlots:Array<{>MovieClip,field:TextField,bg:MovieClip}>

	var imgUrl:String;

	var dm:DepthManager;
	var cdm:DepthManager;
	var bg:MovieClip;
	var root:MovieClip;
	var map:MovieClip;
	var mcFader:MovieClip;
	var mcLog:{>MovieClip,field:TextField};
	var mcConsole:{>MovieClip,field:TextField};

	var mcPlasma:{>MovieClip,bmp:flash.display.BitmapData, fader:Array<Array<float>>, ftimer:float}
	var mcPaillette:{>MovieClip,dm:DepthManager}
	var mcGameover:{>MovieClip,field:TextField,but:Button,illus:MovieClip,card:Card}
	var mcHint:{>MovieClip,flFade:bool,field:TextField,sx:int,sy:int,bg:MovieClip,pic:MovieClip}
	var mcMsg:{>MovieClip,field:TextField,timer:float,decal:float,cards:Array<MovieClip>}
	var mcCards:MovieClip;
	var playBut:{>MovieClip,but:Button,up:Button,down:Button,arrow:MovieClip};

	var slv:LoadVars;
	var kl:{ onKeyDown:void->void, onKeyUp:void->void }
	var ml:{ onMouseDown : void -> void, onMouseUp : void -> void, onMouseMove : void -> void,onMouseWheel : float -> void }

	var victory:Array<int>

	//var mcBoussole:{>MovieClip,vr:float,ta:float}
	var pid:String;

	var waitClick:void->void;
	var cardInfoTrg:Card;
	var fight:DataFight;
	var round:DataRound;
	var c:Card;

	function new(mc) {
		Std.cast(System.security).allowDomain("*");
		/*
		Std.cast(System.security).allowInsecureDomain("*");

		Std.cast(System.security).allowDomain("www.dinocard.net");
		Std.cast(System.security).allowDomain("data.dinocard.net");
		Std.cast(System.security).allowInsecureDomain("www.dinocard.net");
		Std.cast(System.security).allowInsecureDomain("data.dinocard.net");
		//*/
		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;

		var url : String = "" ;
		//var imgUrl = "" ;
		var seed = null ;

		var dialog = downcast(Std.getRoot()).$dm ;
		var inf = downcast(Std.getRoot()).$info ;




		if(inf==null ){
			seed = 123 //p1 1227
			seed = 114 //p1 1227
			seed = 151;
			seed = 120887357;

			var pc = new PersistCodec() ;

			//var params = {$p1 :"$generate".substring(1), $p2 :1217, $r : 2, $o :4, $s : seed, $d : null } ;
			var params = {$p1 :20, $p2 :21, $r : 2, $o :4, $s : seed, $d : null } ;		//20	//
			startUrl = "http://dev.dinocard/duel/data?p=" + pc.encode(params) ;
			Log.trace("startUrl " +startUrl );
			//startUrl = "http://www.dinocard.net/duel/data?p=" + pc.encode(params) ;
			imgUrl = "http://data.dinocard.net/gfx/card/artwork/"
			//viewUrl = "http://www.frutiparc.com/"
		} else {
			var infos = new PersistCodec().decode(inf) ;
			imgUrl = infos.$imgUrl ;
			seed = infos.$seed ;
			pid = infos.$pack1+";"+infos.$pack2
			endUrl = infos.$endUrl ;
			startUrl = infos.$url ;
			viewUrl = infos.$viewUrl ;
			addUrl = infos.$addUrl ;
			flNoob = infos.$noob
			mainPlayerId = infos.$side ;

		}
		if(flNoob==null)flNoob = true;
		flPenguin = root.blendMode == null

		flPause = false;
		///

		sList = new Array();
		partList = new Array();
		//
		bg = dm.attach("mcBg",DP_BG)
		bg.stop();


		flLog = false;
		logText = ""
		//
		speed = 0.1

		//
		initConsole();

		initKeyListener();
		initMouseListener();
		initStep(0)

		//
		initPlasma();
		//


	}

	function initConsole(){
		if(flPenguin)return;
		mcConsole = downcast(dm.attach("mcConsole",DP_CONSOLE))
		mcConsole._y = Cs.mch
		mcConsole.field.text = ""
	}
	function initInterface(){
		/*
		mcBoussole = downcast(dm.attach("mcBoussole",DP_GROUND))
		mcBoussole._x = Cs.mcw
		mcBoussole._y = Cs.mch*0.5
		mcBoussole._rotation = -180
		mcBoussole.vr = 0;
		mcBoussole.ta = -180;
		*/

		//
		infoSlots =[]
		var dt = ["Début du round "+(roundId+1),"Tour de "+fight.$player1.$name,"Tour de "+fight.$player2.$name,"Combat!"]
		for( var i=0; i<dt.length; i++ ){
			var txt = dt[i]
			var mc = downcast(dm.attach("mcSlotInfo",DP_INTERFACE))
			mc._x = Cs.mcw-140
			mc._y = Cs.mch+i*15
			mc.bg.stop();
			mc.field.text = dt[i]
			infoSlots.push(mc)
		}
		lightSlot(0)

		// PLAY BUT

		var mc = downcast(dm.attach("mcPlayBut",DP_INTERFACE))
		mc._x = 394
		mc._y = Cs.mch
		playBut = mc
		playBut.up.onPress = callback(this,scrollText,-1)
		playBut.down.onPress = callback(this,scrollText,1)


		//
		mcCards = dm.empty(DP_CARD)
		cdm = new DepthManager(mcCards);
		//mcCards.cacheAsBitmap = true;

	}
	function lightSlot(n){

		if(currentInfoSlot !=null )unlightSlot(currentInfoSlot);
		currentInfoSlot = n;
		var mc = infoSlots[n]
		mc.bg.gotoAndStop("2");
		mc.field.textColor = 0xE6EBFF

		var a = [[0,0],[1,0],[0,1],[2,2]][n]

		for( var i=0; i<playerList.length; i++ )playerList[i].setIcon(a[i]);

	}
	function unlightSlot(n){
		var mc = infoSlots[n]
		mc.bg.gotoAndStop("1");
		mc.field.textColor = 0x011565
	}

	function initStep(n:int){
		step = n
		switch(step){
			case 0: // LOAD INFO
				Cs.log("Chargement des données...",4)
				slv = new LoadVars();
				slv.sendAndLoad( startUrl, slv, "_self" );
				slv.onData = callback(this,onDataLoaded)
				//
				roundId = 0
				victory = [0,0]
				break;
			case 1: // BUILD
				Cs.logText = ""
				initInterface()


				cardList = new Array();

				// INFOS
				Card.INFOS =		fight.$elements.$cards
				Card.INST = 		fight.$elements.$instances
				Card.CAPACITIES =	fight.$elements.$capacities
				/*
				//############## DEV
				Cs.log( "seed : " + fight.$roundMax, 3)
				*/
				// PLAYER
				var a  = [fight.$player1,fight.$player2]
				playerList = new Array();
				for( var i=0; i<2; i++ ){
					if(mainPlayerId==null && i==0)mainPlayerId = a[i].$id;
					var p = new Player(a[i]);
					playerList.push(p)
					p.flHero = (p.dside==1);
				}

				// FX
				for( var i=0; i<10; i++ ){
					var p = newPart("mcStone")
					p.x = Player.MARGIN+Math.random()*(Cs.mcw-Player.MARGIN)
					p.y = Cs.mch*0.5 + Math.random()*3
					p.weight = 0.1+Math.random()*0.2
					p.fadeType = 0
					p.timer = 10+Math.random()*35
					p.setScale(60+p.weight*100)
					p.vr = (Math.random()*2-1)*5
					p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
				}

				//
				downcast(bg).mcHelp._visible = flNoob;
				//
				initStep(2)

				break;

			case 10: //
				Cs.log("Décompression des données.",4)
				break;

			case 11:
				bg.play();
				downcast(bg).obj = this;

				break;

			case 2: // LAUNCH ROUND
				round = fight.$rounds[roundId]
				actionList = new Array();


				var list = []

				/// PHASES
				for( var i=0; i<round.$phases.length; i++ ){
					actionList.push({name:"Phase "+(i+1)+" :",list:[],id:100+i})
					var phase = round.$phases[i]

					// TURN
					var tList =  [phase.$turn1,phase.$turn2]
					for( var b=0; b<tList.length; b++ ){
						list = new Array();

						var turn = tList[b]
						var turnPhaseList = [ turn.$upkeep, turn.$actions, turn.$end ]
						for( var k=0; k<turnPhaseList.length; k++){
							var al = turnPhaseList[k]
							for( var v=0; v<al.length; v++){
								addAction(al[v],list)
							}
						}
						actionList.push({name:"Tour de "+playerList[b].data.$name,list:list,id:b+1})
					}

					// COMBAT
					list = new Array();
					for( var b=0; b<phase.$combat.length; b++ ){
						//list.push( getAction(phase.$combat[b]) );
						addAction(phase.$combat[b],list)
					}
					if(list.length>0)actionList.push({name:"Combat:",list:list,id:3});
				}
				if(!flPause)togglePause();
				break;

			case 3: // END ROUND
				for( var i=0; i<cardList.length; i++){
					var card = cardList[i]
					card.endTimer = (card.x + card.y)*0.05
				}
				for( var i=0; i<playerList.length; i++){
					var pl = playerList[i];
					pl.introStep = 2;

					switch(fight.$winner){
						case 0:
							pl.setMood(0);
							setFlashMessage("MATCH NUL!",pl.side,null);
							break;
						case i+1:
							pl.setMood(4);
							victory[pl.side]++;
							setFlashMessage("VICTOIRE!",pl.side,null);
							break;
						default:
							pl.setMood(1);
							setFlashMessage("DEFAITE!",pl.side,null);
							break;

					}
					/*

					if(life>0 && op.life<=0){
						setMood(4);
						Cs.game.victory[int((side+1)*0.5)]++;
						Cs.game.setFlashMessage("VICTOIRE!",side,null)
					}else if(life<=0 && op.life>0){
						setMood(1);
						Cs.game.setFlashMessage("DEFAITE!",side,null)
					}else{
						setMood(0);
						Cs.game.setFlashMessage("MATCH NUL!",side,null)
					}
					*/
					//playerList[i].setEndMood();
				}




				while(infoSlots.length>0)infoSlots.pop().removeMovieClip();
				break;

			case 5: // RESTART
				break;

			case 8: // GAMEOVER
				//initGameOverScreen();
				var lv = new LoadVars();
				lv.send(endUrl,"_self",null);
				break;

		}
	}

	//
	function main() {
		//Log.print(fight.$winner)
		speed = 0.15
		if(Key.isDown(107) || Key.isDown(Key.SHIFT) || Key.isDown(83) )speed = 1//0.34; //0.34;
		if(Key.isDown(109))speed = 0.02;
		switch(step){
			case 0: // LOADING
				/*
				Log.print(slv.getBytesTotal())
				var lb = slv.getBytesLoaded()
				var tb = slv.getBytesTotal()
				Cs.logText = ""
				Cs.log("Chargement des données... "+(lb/tb)*100+"%",4)
				*/
			case 1: // START
				moveSprites();
				break;
			case 2: // ROUNDS
				if(!flPause)playAction();
				moveSprites();
				updatePlasma();
				//updateBoussole();
				for( var i=0; i<playerList.length; i++ )playerList[i].update();
				break;

			case 3: // ENDS
				moveSprites();
				for( var i=0; i<playerList.length; i++ ){
					var pl = playerList[i]
					pl.update();

				}
				if(cardList.length==0){
					restart();
				}

				break;
			case 5: //
				bg.prevFrame();
				if(bg._currentframe==1){
					endRound();
				}
				break;
			case 10:
				if(flSecondFrame){
					fight = new PersistCodec().decode(rawData)
					//Cs.log(rawData,1000)
					/*
					var pl1 = fight.$player1
					var pl2 = fight.$player2
					var pl1s = fight.$player1.$side
					var pl2s = fight.$player2.$side
					//fight.$player1 = pl2
					//fight.$player2 = pl1
					fight.$player1.$side = pl2s
					fight.$player2.$side = pl1s
					//*/
					initStep(11)
				}else{
					flSecondFrame = true;
				}
				break;

		}

		if(mcHint!=null)updateHint();
		if(mcMsg!=null)updateFlashMessage()
	}

	/*
	function updateBoussole(){
		var mc = mcBoussole
		var dr = Cs.hMod(mc.ta - mc._rotation, 180)
		var lim = 10
		mc.vr += Cs.mm(-lim,dr*0.15,lim)
		mc._rotation += mc.vr
		mc.vr *= Math.pow(0.6,Timer.tmod)
		//Log.print(mc)
	}
	*/

	function playAction(){
		//Log.print(actionList[0].name)
		if( actionList[0].list.length == 0 ){
			actionList.shift();
			if( actionList.length == 0 ){
				initStep(3);
				return;
			}else{
				var id = actionList[0].id
				switch(id){
					case 1:
					case 2:
					case 3:
						lightSlot(id)
						break;
					default:
						var mc = infoSlots[0]
						mc.field.text = "Round "+(roundId+1)+" - Phase "+(id-100)
						break;
				}

				Cs.log( Cs.getColFont( Cs.getBold("--- "+actionList[0].name+" ---"), "#006600"  ), 5 );
				//mcBoussole.ta = actionList[0].angle;
				//Log.trace(">"+actionList[0].angle)
			}
		}

		actionList[0].list[0].update();


	}
	function moveSprites(){
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}
	}

	//
	function newPart(link){
		var p = new Part(dm.attach(link,DP_PART))
		return p;
	}

	// GET
	function addAction(data,list:Array<Action>){
		var ac = getAction(data)
		ac.parentList = list;
		list.push(ac)
		//Cs.game.actionList[0].list
	}
	function getAction(data):Action{

		var ac:Action = null;
		switch(data.$type){
			case 0:  return new ac.Damages(data);
			case 1:  return new ac.DinozState(data);
			case 2:  return new ac.Life(data);
			case 3:  return new ac.Pool(data);
			case 4:  return new ac.Graveyard(data);
			case 5:  return new ac.Rail(data);
			case 6:  return new ac.Obj(data);
			case 7:  return new ac.Enchant(data);
			case 8:  return new ac.Pick(data);
			case 9:  return new ac.Effect(data);
			case 10: return new ac.Duel(data);
			case 11: return new ac.End(data);
			case 12: return new ac.Shuffle(data);
			case 13: return new ac.Dialog(data);
		}
		Log.trace("action inconnue :"+data.$type);
		return null;
	}
	function getPlayer(id){
		for( var i=0; i<playerList.length; i++ ){
			if(playerList[i].data.$id==id)return playerList[i];
		}
		//Log.trace("player["+id+"] not found!")
		return null;
	}

	// PLASMA
	function initPlasma(){
		mcPlasma = downcast(dm.empty(DP_PAILLETTE))
		mcPlasma.bmp = new flash.display.BitmapData(int(Cs.mcw*PLASMA_QUALITY),int(Cs.mch*PLASMA_QUALITY),true,0x00000000);
		mcPlasma.attachBitmap(mcPlasma.bmp,0);
		mcPlasma._xscale = 100/PLASMA_QUALITY;
		mcPlasma._yscale = 100/PLASMA_QUALITY;

		mcPaillette = downcast(dm.empty(DP_PAILLETTE))
		mcPaillette.dm = new DepthManager(mcPaillette)

	}
	function setPlasmaFader(a){
		mcPlasma.fader = a
		if(a==null){
			mcPlasma.bmp.fillRect(mcPlasma.bmp.rectangle,0x00000000)
			mcPlasma.ftimer = null
		}else{
			mcPlasma.ftimer = 100
		}
	}
	function updatePlasma(){
		//Log.print("fader:"+mcPlasma.fader.length)
		for( var i=0; i<mcPlasma.fader.length; i++ ){
			var a = mcPlasma.fader[i]
			switch(a[0]){
				case 0:
					plasmaDraw(mcPaillette)
				case 1:
					var bfl = new flash.filters.BlurFilter()
					bfl.blurX = a[1]
					bfl.blurY = a[1]
					mcPlasma.bmp.applyFilter(mcPlasma.bmp, mcPlasma.bmp.rectangle, new flash.geom.Point(0,0), bfl );
					break;
				case 2:
					var ct = new flash.geom.ColorTransform(a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8], )
					mcPlasma.bmp.colorTransform( mcPlasma.bmp.rectangle, ct );
					break;
				case 3:
					mcPlasma.bmp.scroll(int(a[1]),int(a[2]))
					break;
				case 4:
					var fl = new flash.filters.GlowFilter()
					fl.blurX = a[1]
					fl.blurY = a[1]
					fl.strength = a[2]
					fl.color = a[3]
					mcPlasma.bmp.applyFilter(mcPlasma.bmp, mcPlasma.bmp.rectangle, new flash.geom.Point(0,0), fl );
					break;
			}
		}
		if(mcPlasma.ftimer!=null){
			//Log.print("ftimer:"+mcPlasma.ftimer)
			mcPlasma.ftimer -= Timer.tmod
			if(mcPlasma.ftimer<0){
				Cs.game.mcPlasma.blendMode = BlendMode.NORMAL
				setPlasmaFader(null)
			}
		}



	}
	function plasmaDraw(mc){

		var bmp = mcPlasma.bmp


		var m = new flash.geom.Matrix();
		m.scale((mc._xscale/100*PLASMA_QUALITY), (mc._yscale/100)*PLASMA_QUALITY)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x*PLASMA_QUALITY,mc._y*PLASMA_QUALITY)

		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0)
		var b = mc.blendMode

		bmp.draw( mc, m, ct, b, null, false )
		//*/
	}

	function plasmaBlur(b){
		var bfl = new flash.filters.BlurFilter()
		bfl.blurX = b
		bfl.blurY = b
		mcPlasma.bmp.applyFilter(mcPlasma.bmp, mcPlasma.bmp.rectangle, new flash.geom.Point(0,0), bfl );
	}
	function plasmaColorTransform(cr,cg,cb,ca,nr,ng,nb,na){

	}

	function resetPlasma(){
		mcPlasma.fader = []
		mcPlasma.bmp.fillRect(mcPlasma.bmp.rectangle,0x00000000)
	}
	function fadeBg(prc){
		mcPlasma.bmp.fillRect(mcPlasma.bmp.rectangle,Cs.objToCol32({r:0,g:0,b:0,a:int(prc*2.55)}))
	}

	// FADER
	function setFader(n){
		mcFader = dm.attach("mcFader",DP_FRONT)
		mcFader.useHandCursor = false;
		mcFader._alpha = n
	}
	function removeFader(){
		mcFader.onPress = null;
		mcFader.gotoAndPlay("fadeOut")//removeMovieClip();
	}

	// LOADING
	function onDataLoaded(data){
		Cs.logText = ""
		Cs.log("Chargement des données... 100%",4)
		rawData = data
		initStep(10)

	}

	// KEYS
	function initKeyListener(){
		kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}
	function onKeyPress(){

		var n = Key.getCode();


		if(n>=96 && n<107 ){


		}
		if(n>=49 && n<52 ){
		}
		if(n>=52 && n<55 ){

		}

		switch(n){
			case 80:
				break;
			case Key.ENTER:
			case Key.SPACE:
				if(flPause){
					togglePause();
				}
				break;
			case 107: // +
				break;
			case 109: // -
				break;
			case 84: // T
				Log.clear();
				break;
			case Key.ESCAPE:
				break;
			case 82: // R
				if(flPause && FL_DEBUG )initStep(3);
				break;
			case 66: //B
				Cs.log(fight.$seed+";"+pid,3)
				break;
			case 222: // ²
				//toggleLog();
				break;
		}


	}
	function onKeyRelease(){

	}

	// MOUSE
	function initMouseListener(){

		ml = {
			onMouseDown:callback(this,onMousePress),
			onMouseUp:callback(this,onMouseRelease),
			onMouseWheel:null,
			onMouseMove:null
		}
		Mouse.addListener(ml)
	}
	function onMousePress(){
		//if(waitClick!=null)waitClick();
		flClick = true;
		/*
		for( var i=0; i<playerList.length; i++ ){
			var pl = playerList[i];
			if(pl.introStep!=null)return;
		}
		if(root._ymouse<Cs.mch){
			if(flPause){
				togglePause();
				if(cardInfoTrg != null){
					cardInfoTrg.hideInfo();
					cardInfoTrg = null;
				}
			}
		}
		*/
	}
	function onMouseRelease(){
		flClick = false
	}

	// PAUSE
	function togglePause(){

		flPause = !flPause;
		if(flPause){
			playBut.gotoAndStop("2")
			if(!flNoob)playBut.arrow.stop();
			playBut.but.onPress = callback(this,togglePause)
		}else{
			playBut.gotoAndStop("1")
			for( var i=0; i<playerList.length; i++ ) playerList[i].faster();
			mcMsg.timer = 0
		}
		flClick = false;
	}

	// HINT
	function makeHint(mc,str,sx,sy){

		//str = "Yeaaaaaaaaaaaaaah !!! J'ai plein de super truc a dire youpi !!! blablablabal balablablabla bla balbal balb lab lablabal"
		mc.useHandCursor = false;
		var over = mc.onRollOver
		var out = mc.onRollOut
		mc.onRollOver = callback(this,showHint,str,sx,sy,over)
		mc.onRollOut = callback(this,hideHint,out)
		mc.onDragOut = mc.onRollOut

		downcast(mc).orover = over;
		downcast(mc).orout = out;

	}
	function removeHint(mc){
		mc.onRollOver = null//downcast(mc).orover
		mc.onRollOut = null//downcast(mc).orout
		mc.onDragOut = null//downcast(mc).orout
		mc.useHandCursor = false;


	}
	function showHint(str,sx,sy,f){
		var flPlace = false
		if( mcHint == null ){
			mcHint = downcast(dm.attach("mcHint",DP_HINT))
			flPlace = true
		}
		mcHint._alpha = 100;
		mcHint.flFade = false;
		mcHint.sx = sx
		mcHint.sy = sy
		mcHint.field._width = 160
		mcHint.field.multiline = false;
		mcHint.field.htmlText = str

		mcHint.field._width = mcHint.field.textWidth+6
		mcHint.field._height = mcHint.field.textHeight+8
		mcHint.bg._xscale = mcHint.field.textWidth+10;
		mcHint.bg._yscale = mcHint.field.textHeight+8;


		if(flPlace){
			var hp = getHintPos();
			mcHint._x = hp.x
			mcHint._y = hp.y
		}

		// GLOW ZZZZ
		Cs.glow(mcHint,2,255,0xFFFFFF)
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 6;
		fl.blurY = 6;
		fl.color = 0x000000;
		fl.strength = 0.8;
		var a = mcHint.filters
		a.push(fl)
		mcHint.filters = a

		//
		f();

	}
	function hideHint(f){
		//mcHint.flFade = true;
		mcHint.removeMovieClip();
		mcHint = null;
		f();
	}
	function updateHint(){
		if(mcHint.flFade){
			mcHint._alpha -= 20*Timer.tmod;
			if( mcHint._alpha < 10 ){
				mcHint.removeMovieClip();
				mcHint = null;
			}
		}

		var hp = getHintPos();
		var c = 0.3
		mcHint._x += (hp.x-mcHint._x)*c;
		mcHint._y += (hp.y-mcHint._y)*c;


		var ins = 10

		mcHint.pic._x = ins-hp.sx*(mcHint.bg._xscale-2*ins);
		mcHint.pic._y = ins-hp.sy*(mcHint.bg._yscale-2*ins);

		var dx = root._xmouse - (mcHint._x+mcHint.pic._x)
		var dy = root._ymouse - (mcHint._y+mcHint.pic._y)

		mcHint.pic._xscale = Math.sqrt(dx*dx+dy*dy)-10
		mcHint.pic._rotation = Math.atan2(dy,dx)/0.0174


	}
	function getHintPos(){
		//
		var m = 2;
		var mx = 20
		var my = 20
		//
		var sx = mcHint.sx
		var ftx = root._xmouse + sx*mcHint.bg._xscale
		var mm = m+mx
		if( ftx<mm || ftx+mcHint.bg._xscale > Cs.mcw-mm ){
			sx++;
			if(sx == 1)sx=-1;
		}
		var sy = mcHint.sy
		var fty = root._ymouse + sy*mcHint.bg._yscale
		mm = m+my
		if( fty<mm || fty+mcHint.bg._yscale > Cs.mch-mm ){
			sy++;
			if(sy == 1)sy=-1;
		}




		var tx = root._xmouse + mx + sx*(mcHint.bg._xscale+mx*2)
		var ty = root._ymouse + my + sy*(mcHint.bg._yscale+my*2)
		return {x:tx,y:ty,sx:sx,sy:sy}
	}

	//
	function scrollText(sens){
		mcConsole.field.scroll += sens;
	}

	// FLASH MESSAGE
	function setFlashMessage(msg,side,cards){
		if(side!=1 || !flNoob )return;
		if(mcMsg==null)mcMsg = downcast(dm.attach("mcFlashMessage",DP_PART));
		mcMsg._alpha = 100
		mcMsg.field.text = msg
		mcMsg.timer = 80
		mcMsg.decal = 0
		mcMsg.cards = cards
		mcMsg._x = Cs.mcw
		mcMsg._y = Cs.mch-20
		Cs.glow(mcMsg,4,50,0xFF0000)
		mcMsg._visible = false;
	}
	function displayFlashMessage(){
		if( mcMsg !=null )mcMsg._visible = true;
	}
	function updateFlashMessage(){
		if(!mcMsg._visible)return;
		mcMsg.timer-=Timer.tmod;
		mcMsg.decal = (mcMsg.decal+53*Timer.tmod)%628
		var prc = 70+Math.cos(mcMsg.decal/100)*30
		var a = mcMsg.cards
		Cs.setPercentColor(mcMsg,prc,0xFFFFFF)
		if(mcMsg.timer<10){
			mcMsg._alpha = mcMsg.timer*10
			if(mcMsg.timer<0){
				mcMsg.removeMovieClip();
				mcMsg = null
				prc = 0
			}
		}

		for( var i=0; i<a.length; i++ ){
			Cs.setPercentColor(a[i],prc,0xFFFFFF)
		}
	}

	// RESTART
	function restart(){
		for( var i=0; i<playerList.length; i++ ){
			playerList[i].kill();
		}
		initStep(5)

	}
	function endRound(){
		roundId++
		if(roundId<fight.$rounds.length){
			initStep(11)
		}else{
			initStep(8)
		}
	}
	function endPress(n:int){
		switch(n){
			case 0:
				mcGameover.card.kill();
				mcGameover.removeMovieClip()

				roundId = 0;
				initStep(11);
				break;
			case 1:
				Cs.log("redirection vers: "+endUrl, 3)
				var lv = new LoadVars();
				lv.send(endUrl,"_self",null);
				break;
		}
	}
	function initGameOverScreen(){
		mcGameover = downcast(dm.attach("mcGameOver",DP_INTERFACE))
		var gdm = new DepthManager(mcGameover)
		var base = 348
		if( fight.$newCard == null ){
			mcGameover.gotoAndStop("1")
			for( var i=0; i<2; i++ ){
				var sens = i*2-1
				var mc = downcast(gdm.attach("mcBouille",2));
				mc._yscale = 200;
				mc._xscale = -sens*mc._yscale;
				mc._x = Cs.mcw*0.5 + sens*160;
				mc._y = 140;
				Cs.loadAvatar(mc);
				var p = playerList[i]
				mc.cl = p.data.$avatar.duplicate();
				mc.cl[1] = ((i+1)==fight.$winner)?4:3;

			}
			base = 300
		}else{
			mcGameover.gotoAndStop("2")
			var card = new Card(null)
			card.setData(fight.$newCard);
			card.x = Cs.mcw*0.5
			card.y = 210
			card.setScale(200)
			card.toggleShadow();
			card.instantFlipIn();
			card.updatePos();
			mcGameover.card = card
		}

		//
		var a = ["revoir la partie","retour au menu"]
		for( var i=0; i<a.length; i++ ){
			var mc = downcast(gdm.attach("mcEndBut",0))
			mc._x = 145
			mc._y = 348 +i*18
			mc.but.onPress = callback(this,endPress,i)
			mc.field.text = a[i]
		}
	}

	// DEBUG
	function toggleLog(){
		flLog = !flLog

		if(flLog){
			mcLog = downcast(dm.attach("mcLog",DP_LOG))
			mcLog.field.text = Cs.logText
		}else{
			mcLog.removeMovieClip();
		}
	}




//{
}

