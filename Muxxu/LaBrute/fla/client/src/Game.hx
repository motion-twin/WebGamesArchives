import flash.Key;
import mt.bumdum.Lib;
import mt.bumdum.Bmp;
import mt.bumdum.Phys;
import Data;

typedef DataInit = {
	list:Array<_Action>
}
typedef TextField = {
	>flash.MovieClip,
	field:flash.TextField
}

enum Step {
	Load;
	Play;
	Pause;
	GameOver;
	Test;
}


class Game {//}

	public static var FL_TEST = false;

	public static var DP_BG = 			0 ;
	public static var DP_SHADE = 		3 ;
	public static var DP_FIGHTERS = 	4 ;
	public static var DP_PARTS = 		6 ;
	public static var DP_INTER = 		8 ;

	public var bg : flash.MovieClip ;
	public var root : flash.MovieClip ;
	public var dm:mt.DepthManager;
	public static var me : Game ;

	var history:Array<_Action>;
	public var states:Array<{update:Void->Void}>;
	public var fighters:Array<Fighter>;
	public var cadavers:Array<Fighter>;
	public var current:State;
	public var inters:Array<Array<InterGlad>>;
	public var gtimer:Int;
	var mcHint:TextField;

	public var step : Step ;
	public var timer : Float ;
	public var shake : Float ;

	public var data:ClientData;
	public var action:Void->Void;

	// test
	public var testCount:Int;
	public var tests:Array<Array<Array<Int>>>;
	public static var TEST_DATA = [Lang.PERMANENTS,Lang.WEAPONS,Lang.SUPERS,Lang.FOLLOWERS];

	//debug
	public var dinoData : String ;

	public function new(mc : flash.MovieClip) {

		haxe.Log.setColor(0xFFFFFF);

		root = mc;
		me = this;
		dm = new mt.DepthManager(mc);

		gtimer = 0;
		states = [];
		fighters = [];
		cadavers = [];

		inters = [[],[]];

		Lang.setLang(Reflect.field(flash.Lib._root,"lang"));

		buildHistory();
		if( history.length == 0 ) return;
		initDecor();
		playNext();

		//
		//trace(root._url);
	}
	public function buildHistory(){

		history = [];

		data = Codec.getData("data");
		if( data._end == null && data._seed == 123 ) {
			if( FL_TEST ) initTestMode() else demo();
			return;
		}

		var arena = new Arena(data._seed);
		for( g in data._glads )
			arena.addGladiator( g._s, g._t, g._gfx, g._lvl, g._bits, g._n );
		if( data._p0 != null )
			arena.setTeamProperty(0,data._p0);
		if( data._p1 != null )
			arena.setTeamProperty(1,data._p1);
		arena.fight();
		history = arena.history;
	}


	function demo() {
		data = {
			_seed:0,
			_glads:[],
			_mini:"../../www/swf/mini_perso.swf",
			_end:"javascript:()",
			_arena:1,
			_p0:null,
			_p1:null,
		}

		var combatSeed = 247853263;

		var skin1 = "40;39;31;18;54;56;19;50;59;6;51;54;7;40;26;0";
		var skin2 = "0;4;3;2;51;82;19;19;15;11;21;82;81;80;88;";

		var level = 3;
		var lvl_0 = 7;
		var lvl_1 = 4;

		var a = Permanent(INCREVABLE);
		var b = Permanent(VANDALISM);
		var c = Followers(BEAR);
		var d = Weapons(HAMMER);
		var fs = [ Gladiator.getSample([a],level,1100), Gladiator.getSample([d],level,550) ];
		//fs[0] = Std.random(9999);
		//fs[0] = 12;
		//var fs = [Std.random(9999),Std.random(9999)];
		//var fs = [2936,3344];
		//var fs = [Std.random(9999),8451];
		//var fs = [86,32];
		// 8451 = 2x chien
		//var fs = [32,9];
		//var fs  = [669,Std.random(1000)];
		var fs = [ 27850761, 46740557 ];
		//lvl_0 = 2;
		//lvl_1 = 5;

		//*
		var skins = [];
		for( i in 0...2 ){
			var sd = new mt.Rand(fs[i]);
			var str = "";
			var max = 18;
			for( n in 0...max ){
				if(n==1)str+="0;";
				str += sd.random(100)+"";
				if(n<max-1)str+=";";
			}
			skins.push(str);
		}
		//*/
		//var skins  = [skin1,skin2];

		var arena = new Arena(combatSeed);

		/*
		var bits = haxe.io.Bytes.alloc(Math.ceil(level/8));
		for( i in 0...bits.length )
			bits.set(i,Std.random(256));

		*/

		var n = haxe.io.Bytes.alloc(1);
		n.set(0,1);
		arena.addGladiator( fs[0], 0, skins[0], lvl_0, haxe.io.Bytes.alloc(1), "Futunax"  );	// CASSE 5
		arena.addGladiator( fs[1], 1, skins[1], lvl_1, n, "Wallis"  );	// DOG 101 111

		var prop = {
			_poi:false,
			_sab:false,
			//_st:{id:666,skin:"40;39;31;18;54;56;19;50;59;6;51;54;7;40;26;0",lvl:20,levels:null},
			_st:null,
		}
		arena.setTeamProperty(0,prop);
		arena.fight();
		history = arena.history;
	}

	public function initDecor(){
		bg = dm.attach("mcArena",DP_BG);
		var aid = data._arena;
		if(aid==null)aid = 0;

		bg.gotoAndStop(aid+1);
	}

	// UPDATE
	public function update() {

		gtimer++;
		mt.Timer.update();

		/*
		if( flash.Key.isDown(flash.Key.SPACE) ){
			mt.Timer.tmod = 10;
		}

		*/



		//updateSprites();
		updateStates();
		updateHint();
		switch(step){
			case Load:
			case Play:
			case Pause:
			case GameOver:
			case Test:			updateTest();
		}
		if( action != null) action();

		updateSprites();

		if(shake!=null){
			root._y = shake;
			shake *= -0.75;
			if(Math.abs(shake)<1){
				shake = null;
				root._y = 0;
			}
		}
	}

	// PLAYER
	function playNext(){
		//trace("---");
		if( history.length == 0 ){

			initGameOver();
			return;
		}

		step = Play;
		var ac = history.shift();

		//trace("["+history.length+"]playNext : "+ac);

		switch(ac){
			case AddFighter( id, team, skin, lvl, bits, name, inter ):

				var f = new Fighter(id,team,skin,inter);
				var gl = new Gladiator(id,name);
				gl.setLevels(lvl,bits);
				f.setGladiator(gl);
				var st = new st.ComeIn(f);

			case AddFollower( id, team, ft):

				var f = new Fighter(id,team,"");
				var gl = new Gladiator(id,"",ft);
				f.setGladiator(gl);
				var st = new st.ComeIn(f);

			case Attack(aid,tid,damages,sab,dis,disShield,disAtt):	new st.Attack(aid,tid,damages,sab,dis,disShield,disAtt);

			case Leave(fid): 								new st.Leave(fid);
			case ThrowAttack(aid,tid,damages):				new st.ThrowAttack(aid,tid,damages);
			case Steal(aid,tid):							new st.Steal(aid,tid);
			case Grab(aid,tid,damages):						new st.Grab(aid,tid,damages);
			case Bomb(fid,damages):							new st.Bomb(fid,damages);
			case Medecine(fid,life):						new st.Medecine(fid,life);
			case Status(fid,sid,flag):						new st.Status(fid,sid,flag);
			case Net(aid,tid):								new st.Net(aid,tid);
			case MoveTo(aid,did,dcx): 						new st.Move(aid,did,dcx);
			case MoveBack(aid): 							new st.Move(aid);
			case Weapon(fid,wid,sab): 						new st.Weapon(fid,wid,sab);
			case Trash(fid): 								new st.Trash(fid);
			case Death(fid):								new st.Death(fid); //new st.Death(fid);
			case EndFight(team):							new st.EndFight(team);
			case Escape(fid,a):								new st.Escape(fid,a);
			case Hypno(aid,a):								new st.Hypno(aid,a);
			case Downpour(aid,a,dmg):						new st.Downpour(aid,a,dmg);

			case FxResistDamage(fid):					new st.Fx(fid,0);
			case Eat(fid,heal,cid):						new st.Eat(fid,heal,cid);
			case Poison(fid,damage):					new st.Poison(fid,damage);


		}








	}
	public function endCurrentState(){

		current = null;
		playNext();
	}

	// GAMEOVER
	function initGameOver(){
		step = GameOver;
	}
	function updateGameOver(){

	}

	// SPRITES
	function updateSprites(){
		var list = mt.bumdum.Sprite.spriteList.copy();
		var list2 = Sprite.spriteList.copy();

		var f = function(a:Sprite,b:Sprite){
			if(a.y<b.y)return -1;
			return 1;
		}
		list2.sort(f);

		for( sp in list )sp.update();
		for( sp in list2 )sp.update();

	}
	function updateStates(){
		var list = states.copy();
		for( st in list )st.update();

	}

	// INTER
	public function addInterGlad(team){
		var m = 4;
		var mc = dm.attach("mcInterGlad",DP_INTER);
		mc._x = m + (Cs.mcw-2*m)*team;
		mc._y = m + inters[team].length*64;
		mc._xscale = -100 * (team*2-1);



		var inter = new InterGlad(mc);
		inters[team].push(inter);
		states.push( cast inter);

		return inter;
	}

	// TOOLS
	public function getFighter(id){
		for( f in fighters )if(f.id==id)return f;
		return null;
	}
	public function getCadaver(id){
		for( f in cadavers )if(f.id==id)return f;
		return null;
	}

	// ACTION
	public function setPause(p : Float) {
		step = Pause;

	}

	// TOOLS
	public function isFree(x:Float,y:Float,?me:Fighter){
		for( f in fighters ){
			if( f != me ){
				var dx = f.x - x;
				var dy = f.y - y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if( dist < 35 ) return false;
			}
		}
		return true;
	}
	public function getFreePos(side){

		for( i in 0...200 ){
			var ma = 40;
			var x = ma+Math.random()*(Cs.mcw*0.5-(ma+15));
			var y = Math.random()*Cs.HEIGHT;
			if( side == 0 ) 	x  = Cs.mcw*0.5 - x;
			else 				x  = Cs.mcw*0.5 + x;

			if( isFree(x,y) ) return {x:x,y:y};

		}

		return { x: Cs.mcw*0.5 + (side*2-1)*60, y:Cs.HEIGHT*0.5 };


	}

	// HINTS
	public function setHint(mc:flash.MovieClip,str,?w){
		mc.onRollOver = callback(displayHint,str,w);
		mc.onDragOver = mc.onRollOver;
		mc.onRollOut = removeHint;
		mc.onDragOut = removeHint;
	}
	public function displayHint(str,?w){
		if(mcHint==null){
			mcHint = cast dm.attach("mcHint",DP_INTER);
			if(w!=null)mcHint.field._width = w;
			mcHint.field.htmlText = str;
			mcHint.field._height = mcHint.field.textHeight+5;
			mcHint.smc._xscale = mcHint.field._width+5;
			mcHint.smc._yscale = mcHint.field._height+5;
			updateHint();
		}

	}
	function updateHint(){
		var m = 15;
		var lx = Cs.mcw-(mcHint._width+5);
		mcHint._x = root._xmouse + m ;
		if(mcHint._x>lx)mcHint._x = lx;
		mcHint._y = root._ymouse + m ;
	}
	public function removeHint(){
		mcHint.removeMovieClip();
		mcHint = null;
	}

	// FX
	public function fxHab(name:String,x=0.0,y=0.0){
		var mc = dm.attach("fxHab",DP_PARTS);
		cast(mc)._txt = name.toUpperCase();
		mc._x = x;
		mc._y = y;
	}

	// TEST - STATS
	function initTestMode(){

		tests = [[],[],[],[],[],[]];
		step = Test;
		testCount = 0;



		for( i in 0...5 ){
			var max = TEST_DATA[i].length;
			if(i==4)max = 4;
			for( n in 0...max )tests[i][n] = [0,0];
		}

		/*

		var pmax = Lang.PERMANENTS.length;
		var perms = [];
		for( i in 0...pmax )perms[i] = [0,0];

		var wmax = Lang.WEAPONS.length;
		var weaps = [];
		for( i in 0...wmax )weaps[i] = [0,0];

		var smax = Lang.SUPERS.length;
		var supers = [];
		for( i in 0...smax )supers[i] = [0,0];

		var fmax = Lang.FOLLOWERS.length;
		var fols = [];
		for( i in 0...fmax )fols[i] = [0,0];
		*/



	}
	function updateTest(){


		var amax = 10;

		var nmin = 30;
		var nmax = 35;

		haxe.Log.clear();
		haxe.Log.trace(testCount,null);



		/*
		var str = "--- Test sur "+amax+" combats ---\n";
		str += "--- Brutes de niveau 0 a "+nmax+" ---\n";
		str+"\n";
		*/

		for( n in 0...amax ){
			testCount++;
			var arena = new Arena(Std.random(1000));
			var lvl = nmin+Std.random(nmax-nmin);

			arena.addGladiator( Std.random(1000), 0, "", lvl, null, "Wallis"  );
			arena.addGladiator( Std.random(1000), 1, "", lvl, null,"Futuna"  );
			arena.fight();


			for( glad in arena.glads ){

				if(glad.gl.fol == null && glad.timeLimit == null ){


					var n = 0;
					if( glad.team==arena.teamWin )n = 1;

					// CARACS
					for( id in glad.gl.bonus ){
						switch(id){
							case Permanent(pid):		tests[0][ Type.enumIndex(pid) ][n]++;
							case Weapons(wid):			tests[1][ Type.enumIndex(wid) ][n]++;
							case Super(sid):			tests[2][ Type.enumIndex(sid) ][n]++;
							case Followers(fid):		tests[3][ Type.enumIndex(fid) ][n]++;
							default:
						}
					}

					var a = [glad.gl.force,glad.gl.agility,glad.gl.speed,glad.gl.lifeMax];
					for( i in 0...4 ){
						tests[4][i][n] += a[i];
					}

					var bl = glad.gl.bonus.length;
					if( tests[5][bl] == null ) tests[5][bl] = [0,0];
					tests[5][bl][n]++;

					//tests[5][0][n] += glad.gl.bonus.length;

				}

			}

		}


		var o:flash.KeyListener = { onKeyDown : printTests, onKeyUp:null };
		Key.addListener(o);

	}
	function printTests(){

		var str = "";
		//str += "---"+tests[4].length+"\n";

		for( i in 0...6 ){

			switch(i){
				case 0,1,2,3,4:
					var a = tests[i];
					var n = 0;
					for( a2 in a ){
						var tot = a2[0]+a2[1];
						var c = a2[1]/tot;
						var prc = Math.round(c*10000)/100;

						var name = TEST_DATA[i][n];
						if(i==4) name = Lang.CARACS[n];

						var base = "["+tot+"]"+name+" :";
						while( base.length < 26 ) base += " ";
						str+= base +" "+prc+"% \n";
						n++;
					}
					str+="\n";

				case 5 :
					str+="\n";
					str+="Repartitions bonus : \n";
					for( n in 0...tests[5].length ){
						var a = tests[5][n];
						var tot = a[0]+a[1];
						var prc = Std.int( a[1]/tot*100 );

						var s = n+"/ ";
						s += "["+tot+"]";
						while( s.length < 13 ) s+=" ";
						str+= s+"win "+prc+"%\n";
					}

					/*
					for ( n in 0...2 ){
						var val = Std.int( tests[i][0][n]/testCount *10)/10;
						str += " bonus moyens "+["perdant","gagant"][n]+" : "+val+"\n";
					}
					*/


			}
		}



		flash.System.setClipboard(str);

	}


	// Mort pendant sequence d'attaque
	// arme part lors du show + reparer armes
	// RETOUR ANIM APRES LAND
	// fonctionnement de l'armure
	// fonctionnement du shield

	// REMI
	// ANIMAUX - ANIM FILET
	// ANIM "launch" = LANCEE MAIN FRONT
	// VU Anim d'un gars avec les mains blanches

	// NEW ANIM
	// HURLE

	// SANG SUEUR ARENE POUSSIERE
	// COGNER, pulveriser, frapper, piler, rosser, battre, taper, tamponner, brutaliser
	// chataigne, beigne torgnole, baffe, volée, pain

	/*

	- Adeptes de la torgnole, poètes de la baffe, distributeurs de e-pains et autres mangeurs de chataignes, l'arène de www.labrute.fr vient d'ouvrir ses portes !
	Soyez les premiers a pulvériser vos adversaires lors de combats epiques, faites evoluer votre brute dans la sueur et le sang, bravez des bêtes sauvages malodorantes et quittez victorieux l'enfer poussiereux de l'arène pour rejoindre votre cellule.



	et enfin, lorsque le genoux de votre adversaire touchera le sol,
	extirpez vous de la poussière de l'arène, harassé, tremablant, mais  vainqueur !



	Partagez votre passion pour la brutalité dans la sueur et le sang
	-Parce que donner et prendre des coups c'est quand même plus drole deriere un écran : www.labrute.

Adeptes de la torgnole, poètes de la baffe, distributeurs de e-pains et autres mangeurs de chataignes, l'arène de <strong><a href="http://www.labrute.fr" target="_blank">www.labrute.fr</a></strong> vient d'ouvrir ses portes !
Soyez les premiers a pulvériser vos adversaires lors de combats epiques, faites evoluer votre brute dans la sueur et le sang, bravez des bêtes sauvages malodorantes et quittez victorieux l'enfer poussiereux de l'arène pour rejoindre votre cellule !


// venez sur bumdum.labrute.fr, pour chaque clic je rend une baffe !

	*/

//{
}
