import Protocol;
import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Lib;


typedef McText = {>flash.MovieClip,field:flash.TextField};

enum MonsterStep{
	MAttack;
	MMove;
	MEnd;

}
enum Step {
	Shop;
	Event;
	Play;
	Work;
	GameOver;
}

class Game {//}

	public static var DP_ITEMS = 	4;
	public static var DP_INTER = 	3;
	public static var DP_FADER = 	2;
	public static var DP_MAP = 	1;
	public static var DP_BG = 	0;

	public var flShoot:Bool;
	public var flMove:Bool;
	public var flQueue:Bool;
	public var flMute:Bool;

	public var event:Event;
	public var step:Step;
	public var endStep:Int;
	public var next:MonsterStep;

	public var floors:Array<Floor>;
	public var cfl:Floor;

	public var coef:Float;
	public var did:Int;

	public var bx:mt.flash.Volatile<Int>;
	public var by:mt.flash.Volatile<Int>;

	public var bagSize:mt.flash.Volatile<Int>;
	public var food:mt.flash.Volatile<Int>;
	public var gold:mt.flash.Volatile<Int>;
	public var lureGold:mt.flash.Volatile<Int>;
	public var shuriken:mt.flash.Volatile<Int>;
	public var weaponId:mt.flash.Volatile<Int>;
	public var armorId:mt.flash.Volatile<Int>;
	public var huntMax:Int;

	public var inventory:mt.flash.PArray<Int>;

	public var flhColor:Int;
	public var flh:Float;

	var logCoef:Float;

	public var hero:ent.Hero;
	public var work:Array<Ent>;
	public var active:Array<Ent>;
	public var allies:Array<Ent>;
	public var logs:Array<McText>;



	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var mcInter:{
		>flash.MovieClip,
		barLife:flash.MovieClip,
		shuriken:flash.MovieClip,
		fieldLife:flash.TextField,
		fieldFood:flash.TextField,
		fieldGold:flash.TextField,
		fieldShuriken:flash.TextField
	};

	public var mcLog:{>flash.MovieClip,dm:mt.DepthManager,timer:Float};


	static public var me:Game;


	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = dm.attach("mcBg",DP_BG);
		did = 351;
		did = Std.random(012000);


		huntMax = 10;

		bagSize = 3;
		food = 250;
		gold = 0;
		lureGold = 0;
		shuriken = 3;
		armorId = 0;
		weaponId = 0;

		allies = [];
		inventory = new mt.flash.PArray();
		work = [];
		logs = [];

		initInter();


		displayFood();
		displayGold();
		displayShuriken();
		displayItems();

		enterDungeon();




	}

	// UPDATE
	public function update(){

		switch(step){
			case Play : updatePlay();
			case Work : updateWork();
			case Event : event.update();
			case GameOver : updateGameOver();
			default:
		}
		if(flh!=null)updateFlash();
		if(logCoef!=null )updateLog();
		if(mcLog._alpha>0  )updateLogAlpha();

		if( inventory.cheat || lureGold!=gold  )KKApi.flagCheater();

		updateSprites();

	}

	// DUNGEON
	public function enterDungeon(){
		floors = [];
		hero = new ent.Hero();
		hero.x = Std.int(Cs.XMAX*0.5);
		hero.y = Std.int(Cs.YMAX*0.5);
		loadFloor(0);
		step = Play;

	}
	public function loadFloor(id){
		cfl.hide();
		cfl = getFloor(id);
		cfl.show();
		hero.setFloor(cfl);
		hero.setPos(hero.x,hero.y);
		bx = hero.x;
		by = hero.y;
		hero.display();
		cfl.scroll(hero);


		/*
		if(cfl!=null)cleanMap();

		genFloor(n);
		initMap();

		hero.setPos(Std.int(Cs.XMAX*0.5),Std.int(Cs.YMAX*0.5));

		updateScroll();
		*/


	}
	public function getFloor(id){
		var fl = floors[id];
		if( fl == null ){
			fl = new Floor(id);
			floors[id] = fl;
			if(id>0)Cs.probaLevelUp();
		}

		return fl;
	}


	// CHECK
	public function initEvents(){
		checkEvents();
	}
	public function checkEvents(){

		if(hero.life<=0){
			initGameOver();
			return;
		}


		if(flMove){
			if( hero.sq.type == STAIR_UP )		new ev.Floor(1);
			else if( hero.sq.type == STAIR_DOWN )	new ev.Floor(-1);
			var sq = hero.sq;
			if(  sq.itemId != null ){
				pickUp(sq.itemId,sq);
			}

		}
		if( allies.length > 0 ){
			var sq = cfl.grid[bx][by];
			if( sq.ent == null ){
				var ent = allies.pop();
				ent.setFloor(cfl);
				ent.setPos(bx,by);
				ent.display();
			}
		}


		flMove = false;
		if(event==null){
			if(food==0){
				log(["Vous avez tres faim !","Il faut trouver de la nourriture !","Vous avez besoin de manger !","La faim vous terrasse"][Std.random(4)]);
				hero.hurt(1);
			}
			if(hero.life<=0)	initGameOver();
			else			initPlay();
		}

	}

	// PLAY
	public function initPlay(){
		step =Play;
		hero.setFuturAction(null);
		displayItems(true);

	}
	public function updatePlay(){
		if( flash.Key.isDown(flash.Key.RIGHT) )	move(0);
		else if( flash.Key.isDown(flash.Key.DOWN) )	move(1);
		else if( flash.Key.isDown(flash.Key.LEFT) )	move(2);
		else if( flash.Key.isDown(flash.Key.UP) )	move(3);
		else if( flash.Key.isDown(flash.Key.SPACE) )	shoot();
		else flShoot = true;
	}

	public function move(dir:Int){
		var d = Cs.DIR[dir];
		var sq = cfl.grid[hero.sq.x+d[0]][hero.sq.y+d[1]];
		if( sq.isHeroFree() ){
			flMove = true;
			hero.setFuturAction( Goto(dir) );
			gogogo();
		}else if( sq.ent!=null ){
			if(sq.ent.flBad){
				hero.setFuturAction( Attack(dir) );
				gogogo();
			}else if( sq.ent.flGood){
				flMove = true;
				hero.setFuturAction( Goto(dir) );
				var ally:ent.Bad = cast (sq.ent);
				ally.swapDir = (dir+2)%4;
				ally.first();

				gogogo();
			}else if( sq.ent.flTrader ){
				new ev.Trader();
			}

		}
	}

	public function shoot(){
		if(!flShoot || shuriken<=0 )return;
		flShoot = false;
		var trg = hero.getNearestBad(2,7);

		if( trg!= null ){
			incShuriken(-1);
			var ev = new ev.Shoot(hero,trg,1+Std.random(3));
			if(hero.flFire){
				ev.dmg++;
				Filt.glow( ev.shot,2,4,0xFFFF00 );
				Filt.glow( ev.shot,4,2,0xFFCC00 );
			};
			//var ev = new ev.Shoot(hero,trg,0);
		}else{
			log("Aucun monstre a portée de tir !");
		}

	}


	// WORK
	function updateWork(){

		coef = Math.min( coef+Cs.SPEED, 1);
		if(flQueue){
			work[0].update(coef);
			if(coef==1){
				coef = 0;
			}
		}else{
			var list = work.copy();
			for( e in list )e.update(coef);
		}

		if(work.length==0){
			if(next!=null)	nextTurn();
			else 		initEvents();
		}

		cfl.scroll(hero);
	}

	// NEXT TURN
	public function gogogo(){
		Game.me.hero.first();
		displayItems();
		if(food>0){
			food--;
			displayFood();
		}

		next = MAttack;
		coef = 0;
		step = Work;
		active = [];
		for( e in cfl.ents ){
			active.push(e);
		}
		nextTurn();

	}
	function nextTurn(){
		coef = 0;
		switch(next){
			case MAttack:
				var list = active.copy();
				for( e in list )e.checkAttack();
				flQueue = true;
				next = MMove;
				if( work.length == 0 )nextTurn();
			case MMove:

				var list = active.copy();
				for( e in list )e.checkMove();
				flQueue = false;
				next = MEnd;
			case MEnd:
				initEvents();
		}

	}

	// ITEM
	public function pickUp(id,?sq){
		//var id = sq.itemId;
		sq.removeItem();
		//hero.sq.fxGem( Col.objToCol(Col.getRainbow()) );
		switch(id){
			case 1 : incGold(1);
			case 2 : incGold(2+Std.random(8));
			case 3 : incGold(10+Std.random(15));
			case 4 : incGold(50+Std.random(50));
			case 5 : setArmor(1);				Lang.take(id);
			case 6 : setArmor(2);				Lang.take(id);
			case 7 : setWeapon(1);				Lang.take(id);
			case 8 : setWeapon(2);				Lang.take(id);
			case 9 : incFood(50);				Lang.take(id);
			case 10 : incFood(100);				Lang.take(id);
			case 11 : incShuriken(3);
			case 12 : incShuriken(10);
			case 13 : bagSize = 5; displayItems();		Lang.take(id);
			case 21 : gem(id-21);
			case 22 : gem(id-21);
			case 23 : gem(id-21);
			default : take(id);
		}

		//sq.fxLight();
	}
	function take(id){
		switch(id){
			default :
				Lang.take(id);
				inventory.push(id);
				if( inventory.length>bagSize )dropItem(inventory.shift());
				displayItems();
				hero.buildCaracs();

		}

	}
	function useItem(n){
		var id = inventory[n];


		switch(id){
			case 14:  // POTION
				hero.incLife(8);

			case 15: // BIG POTION
				hero.lifeMax += 2;
				hero.incLife(100);

			case 16: // GRAPPIN
				var fl = getFloor(cfl.id+1);
				var sq = fl.grid[hero.x][hero.y];
				if( sq.isHeroFree() ){
					new ev.Floor(1);
				}else{
					log("Vous ne parvenez pas a accrocher votre grappin !");
					return;
				}

			case 17: // TALISMAN
				var list = [];
				for( bad in cfl.bads )if( bad.flUndead )list.push(bad);
				if(list.length==0){
					log("Il n'y a aucun mort-vivant dans cette zone.");
					return;
				}else{
					log("Vous utilisez votre talisman contre les mort-vivants.");
					fxFlash(0xFFFFFF);
					for( b in list ){
						b.bhMove = BCoward;
						b.bhAtt = BRandom(0.1);
					}
				}

			case 18 : log("il augmente d'un point vos dégats."); 			return;
			case 19 : log("il augmente vos chance d'esquive");			return;
			case 20 : log("il augmente votre agilité."); 				return;
			case 24 : log("C'est une patte d'ours blanc porte-bonheur"); 		return;
			case 25 : // SCROLL FIRE

				var list = hero.getNearBads(1);
				if( list.length == 0 ){
					log("Il n'y a aucun ennemis proches de vous.");
					return;
				}else{
					for(ent in list){
						ent.sq.fxFlame();
						ent.die();
					}
				}

			case 26 : // SCROLL ICE
				var trg = hero.getNearestBad(1,7);
				if(trg==null){
					log("Il n'y a aucun ennemis proches de vous.");
					return;
				}else{
					var ev = new ev.Shoot(hero,trg,0);
					ev.shot.gotoAndStop(2);
					ev.bhl = [1];
				}

			case 27 : // BOMB
				var ev = new ev.Bomb();

			case 28 : // OREILLER
				if( hero.life>=hero.lifeMax ) 	log("Vous êtes déja en pleine forme !!");
				else if( food<15 ) 		log("Vous avez trop faim pour dormir...");
				else {
					var flOk = true;
					var list = [];
					var ray = 7;
					for( dx in 0...ray*2+1 ){
						for( dy in 0...ray*2+1 ){
							var x = hero.x + dx - ray;
							var y = hero.y + dy - ray;
							if( cfl.grid[x][y].ent.flBad ){
								flOk = false;
								break;
							}
						}
					}
					if(!flOk){
						log("Trop de monstres : c'est pas le moment de dormir !");
					}else{
						hero.sq.fxSleep();
						log("Vous vous endormez pendant une heure...");
						incFood(-10);
						hero.incLife(1);
					}
				}
				return;

			case 29: // TELEPORT
				var ev = new ev.Teleport();

			case 30: // CHAOS

				var list = Game.me.hero.getNearBads(6);
				fxFlash(0x8800FF);
				if( list.length > 0 ){
					for( b in list )b.setChaos();
				}else{
					log("Il n'y a aucun ennemis proches dans les environs.");
					return;
				}

			case 31: // OURS
				var list = hero.getNearFreeList();
				if( list.length>0 ){
					var sq = list[Std.random(list.length)];
					invoke(20,sq);
				}else{
					log("Il n'y a pas assez d'espace autour de vous !");
					return;
				}
			case 32: // DOG
				var list = hero.getNearFreeList();
				if( list.length>0 ){
					var sq = list[Std.random(list.length)];
					invoke(21,sq);
				}else{
					log("Il n'y a pas assez d'espace autour de vous !");
					return;
				}

			case 33: // BRACELET
				log("Ce bracelet multiplie votre force par deux !");	return;

			case 34: // ZIPPO
				log("Il permet d'enflammer vos shuriken !");


			default:
				log("sans effets...");
				return;
		}

		inventory.splice(n,1);
		displayItems(event==null);

	}

	function gem(id){

		Lang.take(21+id);
		hero.sq.fxGem(Cs.COLOR_GEM[id]);

		var sc = Cs.SCORE_GEM[id];
		KKApi.addScore(sc);
		hero.sq.fxScore(KKApi.val(sc));

	}

	public function invoke(id,sq){
		var bad = new ent.Bad(id);
		bad.setFloor(cfl);
		bad.setPos(sq.x,sq.y);
		bad.display();
		sq.fxGem(0xFFAA00);
		sq.fxGem(0xFF0000);
	}

	function dropItem(itemId){
		hero.sq.addItem(itemId);
		hero.sq.showItem();
	}
	function incGold(inc){
		if(inc==1)log("Vous rammassez 1 pièce d'or !"  );
		if(inc>1)log("Vous rammassez "+inc+" pièces d'or !"  );
		gold += inc;
		lureGold += inc;
		displayGold();
	}
	function incFood(inc){
		food += inc;
		if(food<0)food = 0;
		displayFood();
	}
	function incShuriken(inc){
		if(inc>0)log("Vous rammassez "+inc+" shurikens !"  );
		shuriken += inc;
		displayShuriken();
	}


	function setArmor(aid){
		var id = null;
		if(armorId==1)	id = 5;
		if(armorId==2)	id = 6;
		if(id!=null)	dropItem(id);
		armorId = aid;
		hero.buildCaracs();
		hero.display();

	}
	function setWeapon(wid){

		var id = null;
		if(weaponId==1)	id = 7;
		if(weaponId==2)	id = 8;
		if(id!=null)	dropItem(id);


		weaponId = wid;
		hero.buildCaracs();
		hero.display();

	}


	// INTER
	function initInter(){
		mcInter = cast dm.attach("mcInter",DP_INTER);
	}
	public function displayLife(){
		var coef = hero.life / hero.lifeMax;
		mcInter.barLife._xscale = coef*100;

		//var col = Col.objToCol(Col.getRainbow(coef));
		var col = 0x00FF00;
		if( coef<1 )		col = 0x44DD00;
		if( coef<=0.5 )		col = 0xFFCC00;
		if( coef<=0.25 )	col = 0xFF0000;

		Col.setColor( mcInter.barLife,col  );

		mcInter.fieldLife.text = hero.life+"/"+hero.lifeMax;


	}
	public function displayFood(){
		mcInter.fieldFood.text = food+"";
	}
	public function displayGold(){
		mcInter.fieldGold.text = lureGold+"";
	}
	public function displayShuriken(){
		mcInter.fieldShuriken.text = shuriken+"";
		mcInter.shuriken.gotoAndStop(hero.flFire?2:1);
	}

	public function displayItems(?flAction){
		//mcInter.fieldGold.text = gold+"";
		dm.clear(DP_ITEMS);
		for( i in 0...bagSize ){
			var slot =  dm.attach("mcSlot",DP_ITEMS);
			slot._x = Cs.mcw-(bagSize-i)*28;
			slot._y = 3;
			var id = inventory[i];
			if( id!=null ){
				var mc = dm.attach("mcItem",DP_ITEMS);
				mc._x = slot._x;
				mc._y = slot._y;
				mc.gotoAndStop(id+1);
				if(flAction){
					slot.onPress = callback(useItem,i);
					slot.onRollOver = callback(rovItem,mc);
					slot.onDragOver = callback(rovItem,mc);
					slot.onRollOut = callback(rouItem,mc);
					slot.onDragOut = callback(rouItem,mc);
					KKApi.registerButton(slot);
				}
			}
		};
	}


	public function rovItem(mc:flash.MovieClip){
		mc.blendMode = "add";

	}
	public function rouItem(mc:flash.MovieClip){
		mc.blendMode = "normal";
	}


	// GameOver
	public function initGameOver(){
		step = GameOver;
		endStep = 0;
		coef = 0;
		log("Vous êtes mort !");

	}
	public function updateGameOver(){
		switch(endStep){
			case 0:
				coef = Math.min(coef+0.1,1);
				if( coef == 1 ){
					endStep++;
					if(gold>0){
						var a = KKApi.val(Cs.SCORE_GOLD);
						log("Bonus Or "+gold+" x"+a+" = "+(a*gold)+"pts");
					}
				}
			case 1:
				if( gold > 0 ){
					incGold(-1);
					KKApi.addScore(Cs.SCORE_GOLD);
				}else{
					endStep++;
					if(food>0){
						var a = KKApi.val(Cs.SCORE_FOOD);
						log("Bonus Nourriture "+food+" x"+a+" = "+(a*food)+"pts");
					}

				}
			case 2:
				if( food > 0 ){
					for( i in 0...5 ){
						incFood(-1);
						KKApi.addScore(Cs.SCORE_FOOD);
						if(food==0)break;
					}

				}else{
					endStep++;
					KKApi.gameOver({});
				}

		}

	}


	// FX
	public function updateFlash(){
		var prc = flh;
		flh *= 0.6;
		if( flh<0.1 ){
			flh = null;
			prc = 0;
		}
		Col.setPercentColor(root,prc,flhColor);
	}
	public function fxFlash(col){
		flhColor = col;
		flh = 100;
	}

	// LOG
	public function log(str){
		if(flMute)return;
		if(mcLog==null){
			mcLog = cast dm.empty(DP_INTER);
			mcLog.dm = new mt.DepthManager(mcLog);
		}

		var mc:McText = cast mcLog.dm.attach("mcLog",DP_INTER);
		mc.field.text = str;
		mc._y = Cs.mch;
		Filt.glow(mc,2,4,0);
		logs.unshift(mc);
		logCoef = 0;

		mcLog.timer = 60;
		mcLog._alpha = 100;

	}
	public function updateLog(){
		logCoef = Math.min(logCoef+0.2,1);

		var lim = 5;
		var ec = 12;
		for( i in 0...logs.length ){
			var mc = logs[i];
			mc._y = Cs.mch-((i+logCoef)*ec+5);
			mc._alpha = 100 - ((i+logCoef-1)/(lim-1))*100;
		}

		if(logCoef==1){
			while( logs.length >= lim )logs.pop().removeMovieClip();
			logCoef = null;
		}

	}
	public function updateLogAlpha(){
		if(mcLog.timer>0)mcLog.timer--;
		else mcLog._alpha -=10;
		if(mcLog._alpha<=0){
			while(logs.length>0)logs.pop().removeMovieClip();
		}

	}


	//
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}




//{
}


// MSG MARCHAND QUAND PLUS DE PLACE
// SCEAU MORT VIVANT





// FADE DU LOG





// ** MECANISME DE JEU **
// PORTES ( CLE OU ENFONCE )
// PIEGE QUI FAIT TOMBER LE JOUEUR & l'etag precedent

// CAPE INVISIBLE
// BUCHE / FAUX MUR : Permet de bloquer des ennemis



// BUG


// ** TODO **
// SYSTEM DE GARDE ROOM
// SYSTEM DE DIF ROOM


























