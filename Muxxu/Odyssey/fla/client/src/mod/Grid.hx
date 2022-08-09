package mod;
import Protocole;
import mt.bumdum9.Lib;
import mt.deepnight.Interface;
using mt.bumdum9.MBut;
import mt.bumdum9.Rush;

private typedef GameState = {
	grid:Array<Bool>,
	heroes:Array<{xp:Int, gh:HeroGhost}>,
	days:Int,
	fights:Int,
	books:Int,
	shrines:Int,
}

private typedef Reward = {
	type:RewardType,
	loc:Int,
}
enum RewardType {
	FRIEND(type:HeroType);
	BOOK;
	SHRINE;
	EXIT;
	NOTHING;
}

#if dev//}

class Grid extends SP {//}

	public static var AUTO_LAUNCH  = false;
	
	public static var FORCE_RESET  = false;
	public static var LATE_GAME  = false;
	public static var START_HEROES = [Torkish];
	public static var START_XP = 12; // 30;
	public static var BENCHMARK_LVL = 4; // 30;
	
	public static var TEST_MONSTER:MonsterType = null;
	public static var TEST_ACTION:ActionType = AC_INTIMIDATE;//
	
	public static var XMAX = 10;
	public static var YMAX = 10;
	public static var MAX = 100;
	public static var BH = 16;
	
	public static var REWARDS = [
		{ type:FRIEND(Celeide), 	loc:12  },
		{ type:FRIEND(Espiroth), 	loc:60  },
		{ type:EXIT, 				loc:MAX-1  },
	];
	
	public static var XP_COEF = 1;
	public static var DIF_MAX = 20;
	
	public var data:GameState;
	var so:flash.net.SharedObject;
	
	var map:SP;
	var squares:Array<mt.pix.Element>;
	var heroes:Array<HeroSlot>;
	
	var menu:Interface;
	var footer:Interface;
	var butEvents:Array<mt.deepnight.SuperMovie.EventData>;
	
	var fieldTop:TF;
	var fieldHint:TF;
	
	var game:Game;
	
	public static var me:Grid;
	
	public function new() {
		super();
		me = this;
		flash.Lib.current.addChildAt(this,0);
		
		butEvents = [];
		heroes = [];
		
		initRewards();
		
		// INIT GRID
		initGrid();
		
		// FIELD TOP
		fieldTop = Cs.getField(0xFFFFFF);
		fieldTop.x = 3;
		fieldTop.width = Cs.mcw;
		addChild(fieldTop);
		
		// FIELD HINT
		fieldHint = Cs.getField(0xFFFFFF,8,"nokia",-1);
		fieldHint.multiline = fieldHint.wordWrap = true;
		fieldHint.x = 3;
		fieldHint.y = 240;
		fieldHint.width = Cs.mcw;
		fieldHint.height = Cs.mch>>1;
		//fieldHint.scaleX = fieldHint.scaleY = 2;
		addChild(fieldHint);
		
		// SAVE
		so = flash.net.SharedObject.getLocal("grid2");
		var raw = so.data.raw;
		if ( raw == null || FORCE_RESET ) 	reset();
		
		// LOAD
		load();
	
		// INIT
		init();
		maj();
		// BG
		graphics.beginFill(0);
		graphics.drawRect(0, 0, Cs.mcw,Cs.mch );
				
		// MENU
		var mc = new MC();
		mc.x = Cs.mcw - 120;
		mc.y = Cs.mch - 20;
		addChild(mc);
		footer = new Interface(mc, Cs.mcw, 40);
		footer.autoButtonWidth = true;
		var me = this;
		footer.addButton("new game", function() { me.reset(); me.superMaj(); } );
		//footer.addButton("benchmark", function() { me.benchmark(); } );
		
		//
		var mc = new MC();
		mc.x = 4;
		mc.y = 160 + BH + 4;
		addChild(mc);
		menu = new Interface(mc, Cs.mcw, 40);
		
		//
		displayMenu();
		displayStats();
		
		//
		/*
		var mm = new mt.bumdum9.MathMusic();
		var cuicui = function(t) 	return t * ( t >> 8 | t >> 4) & t >> 2;
		//var cuicui = function(t) 	return t * ( t>>48 | t>>17 | t >> 2 | t >> 3) & 63 & t >> 2;
		var cuicui = function(t) 	return t >> 1 | t>>8;
		var cuicui = function(t) 	return t >> 8 | t>>1;
		var cuicui = function(t) 	return (t & 640 | t >> 2) * (92 | t * 3 >> 7 | t >> 2) | t >> 8;
		mm.play(cuicui);
		*/
		//
		if ( AUTO_LAUNCH ) {
			nextDay();
			select(1);
		}
	}
	
	// MENU
	function displayMenu() {
		menu.reset();
		menu.autoButtonWidth = true;
		menu.addButton("next day", nextDay );
		if( data.heroes.length > 1 )	menu.addButton("swap heroes", swapPos );
	}
		
	// COMMANDS
	public function nextDay() {
		data.days++;
		for ( o in data.heroes ) Gameplay.initHeroState(o.gh);
		save();
		superMaj();
	}
	public function swapPos() {
		var sign = "";
		for ( o in data.heroes ) sign += o.gh.type;
		
		while (true) {
			Arr.shuffle(data.heroes);
			var sign2 = "";
			for ( o in data.heroes ) sign2 += o.gh.type;
			if (sign != sign2) break;
		}
		
		superMaj();
		
	}
	
	public function select(id) {
		
		var a = [];
		for ( h in heroes ) if ( h.alive ) a.push(h.ghost);


		game = new Game( Cs.getGameInit(a,getOpponents(id)) );
		flash.Lib.current.addChildAt(game,0);
		visible = false;
		
		game.onFinish = callback( endGame, id );
		game.initMask();
		/*
		data.grid[id] = true;
		save();
		maj();
		*/
	}
	public function endGame(id:Int , edata:GameClose) {
	
		visible = true;
		game.kill();
		if ( edata._w ) {
			conquer(id);
		}else {
			for ( h in heroes ) h.ghost.state.grid = 0;
		}

		data.fights++;
		save();
		superMaj();
	}
	function conquer(id) {
		
		
		// XP
		var tot = getSquareDif(id) * XP_COEF;
		var xp = Math.ceil( tot / data.heroes.length );
		for ( o in data.heroes ) {
			var oldLevel = Gameplay.getLevel(o.xp);
			o.xp += xp;
			if ( oldLevel < Gameplay.getLevel(o.xp) ) {
				Main.log(HTML.col("LEVEL-UP : " + o.gh.type,0x880000 ));
				Gameplay.initHeroState(o.gh);
			}
		}
		
		// REWARD
		if( !data.grid[id] ){
			var rew = getReward(id);
			
			switch(rew) {
				case FRIEND(ht) :	addHero(ht);
				case EXIT:			initEndSequence();
				case SHRINE :		data.shrines++;
				case BOOK :			data.books++;
				case NOTHING :
			}
			
		}
		
		// MARK
		data.grid[id] = true;
		
		//
		save();
		
	}
		
	// GAMEPLAY
	function getOpponents(id) {
		//trace("getOpp");
		if ( TEST_MONSTER != null )  return [TEST_MONSTER];
		
		var px = Std.int(id / YMAX);
		var py = id % YMAX;
		var baseDif = getSquareDif(id);
		if ( baseDif < 1 ) baseDif = 1;
		var dif = baseDif*10;
		
		//if ( baseDif == 1 ) return [WOOLY_BLOB];
		
		//var a = [WOOLY_BLOB, SNAKE, BULOT, PANTHER, LOST_SOUL, GOLEM];
		
		var monsters = getMonsters();
		
		var seed = new mt.Rand(42);
		seed.initSeed(px + 20, py);
		var opp = [];
		while ( dif > 0 ) {
			var mon = monsters[seed.random(monsters.length)];
			
			//if ( mon.lvl > 5 && (dif -mon.lvl < 0 || mon.lvl*2 > baseDif) ) continue;
			if (dif -mon.lvl < -5) continue;
			opp.push(mon.id);
			dif -= mon.lvl;
			
		}
		
		return opp;
		
	}
	function getMonsters(?lvl) {
		var a = [];
		var cons = Type.getEnumConstructs(MonsterType);
		for ( str in cons ) a.push(Type.createEnum(MonsterType, str));
		var monsters = [];
		for ( id in a ) {
			var data = Monster.DATA[Type.enumIndex(id)];
			if ( lvl != null && data.lvl != lvl ) continue;
			monsters.push( data  );
		}
		return monsters;
	}
	
	function getSquareDif(id) {
		var p = coord(id);
		var n = Std.int( (p.x + p.y) * DIF_MAX / (XMAX + YMAX) );
		if ( n == 0 ) n = 1;
		return n;
	}
	static inline function coord(id) {
		return { x:Std.int(id / YMAX), y:id % YMAX };
	}
	
	// MAJ
	public function maj() {
	
		displayGrid();
		fieldTop.text = "Days : " + data.days + "      Fights : " + data.fights;// +"      Books : " + data.books + "      Shrines : " + data.shrines;
		
	}
	public function superMaj() {
		init();
		displayMenu();
		maj();
	}
	
	// GRID
	function initGrid() {
		if ( map != null ) removeChild(map);
		var ec =  BH;
		squares = [];
		map = new SP();
		addChild(map);
		for ( x in 0...XMAX ) {
			for ( y in 0...YMAX ) {
				var el = new mt.pix.Element();
				el.setAlign(0, 0);
				el.x = x * ec;
				el.y = y * ec;
				map.addChild(el);
				squares.push(el);
			}
		}
		map.x = 4;
		map.y = 14;
		
	}
	function displayGrid() {
		
		
		var ready = false;
		for ( h in heroes ) if ( h.alive ) ready = true;
		
		

		for ( id in 0...MAX) {
			var el = squares[id];
			var state = data.grid[id];
			var fr = 1;
			el.removeEvents();
			Col.setColor(el, 0, 0);
			if ( state == true ) {
				fr = 0;
				
				if( ready ){
					Col.setColor(el, 0xAAFF44);
					el.makeBut( callback(select, id));
				}else {
					Col.setColor(el, 0xFF0000);
				}
								
			}else {
				
				var rew = getReward(id);
				if ( rew != NOTHING ) {
					fr = 2 + Type.enumIndex(rew);
				}
	
				
				if ( reach(id) ) {
					if( ready ){
						Col.setColor(el, 0xAAFF44);
						el.makeBut( callback(select, id));
					}else {
						Col.setColor(el, 0xFF0000);
					}
						
				}
				
				
			}
			el.goto(fr, "grid_test");
			
			//

			
		}
		
	}
	function getNei(id) {
	
		var a = [YMAX, 1, -YMAX, -1];
		var b = [];
		for ( inc in a ) {
			if ( id % YMAX == 0 && inc == -1 ) continue;
			if ( id % YMAX == YMAX-1 && inc == 1 ) continue;
			var nid = id + inc;
			if ( nid >= 0 && nid < MAX ) b.push(nid);
		}
		return b;
	}
	function reach(id) {
		var a = getNei(id);
		
		for ( nid in a ) if ( data.grid[nid] == true ) return true;
		return false;
	}
	function getReward(id) {
		for ( rew in REWARDS ) if ( rew.loc == id ) return rew.type;
		return NOTHING;
	}
		
	//  INIT
	function init() {
		
		// CLEAN
		for ( sl in heroes ) sl.kill();
		heroes = [];
		
		// HEROES
		for ( o in data.heroes ) initHero(o.gh,o.xp);
		
		
		
	}
	function initHero(gh:HeroGhost,xp) {
				
		var slot = new HeroSlot(gh,xp);
		slot.x = 180;
		slot.y = BH+heroes.length*(slot.height+10);
		addChild(slot);
		heroes.push(slot);
		
		//
	}
	function addHero(type:HeroType) {
		var gh = Data.getGhost(type);
		Gameplay.initHeroState(gh);
		data.heroes.push({gh:gh,xp:START_XP});
	}
	
	
	// HINT
	public function displayHint(str) {
	
		
		fieldHint.htmlText = str;

		
		
		
		
		
	}
	public function hideHint() {
		displayHint("");
	}
	
	// BENCHMARK
	/*
	public function benchmark() {
		
		var a = [];
		for ( h in heroes ) if ( h.alive ) a.push(h.ghost);
		
		var b = getMonsters(BENCHMARK_LVL);
		var opp = [];
		for ( data in b ) opp.push(data.id);
		Arr.shuffle(opp);

		game = new Game( a, opp );
		flash.Lib.current.addChildAt(game,0);
		visible = false;
		
		game.initMask();
		var me = this;
		game.onFinish = function(fl) {
			me.visible = true;
			me.game.kill();
		}
		
	}
	*/
	
	// SAVE
	public function reset() {
		Main.log("reset game");
		data = { grid:[true], heroes:[], days:0, fights:0, books:0, shrines:0, };
		for( h in START_HEROES ) addHero(h);
		if ( LATE_GAME ) {
			var lim = 7;
			for ( x in 0...lim ) {
				for ( y in 0...lim ) {
					conquer(getSquareId(x, y));
				}
			}
		}
		
		
		save();
		load();
	}
	public function load() {
		data = haxe.Unserializer.run( so.data.raw);
		
		
		
		
		//
		maj();
	}
	public function save() {
		so.data.raw = haxe.Serializer.run(data);
		so.flush();
	}
		
	//
	public function initRewards() {
		//var rnd = Std.random(1000);
		//Main.log(""+rnd);
		//var seed = new mt.Rand(rnd);	//42 - 790 - 634
		var seed = new mt.Rand(898);
		var free = [];
		for ( id in 0...MAX ) free.push(id);
		for ( rew in REWARDS ) free.remove(rew.loc);
		
		Arr.shuffle(free,seed);
		
		var a = [10,72,18,54];
		for( n in a ){
			free.remove(n);
			free.push(n);
		}
		
		for ( i in 0...Gameplay.MAX_KNOWLEDGE )
			REWARDS.push( { type:BOOK, loc:free.pop() } );
			
		for ( i in 0...Gameplay.MAX_AWAKENING )
			REWARDS.push( { type:SHRINE, loc:free.pop() } );

		
	}
	
	//
	function getSquareId(x,y) {
		return x * YMAX + y;
	}
	
	// ENDING
	public function initEndSequence() {
		Main.log("CONGRATULATION!");
	}
	
	// STATS
	function displayStats() {
		
		Main.log( "XP_COEF : x" + XP_COEF);
		
		//
		var sum = 0;
		for (  id in 0...MAX ) sum += getSquareDif(id) * XP_COEF;
		Main.log( "--- total: " + sum + " xp ---" );
		for ( i in 1...5 ) 	Main.log("> "+ i + "x chars lvl." + Gameplay.getLevel(Std.int(sum/i)) );
		Main.log("--------------------");
	}
	
	//
	function getSlot(gh) {
		for ( sl in heroes ) if ( sl.ghost == gh ) return sl;
		return null;
	}
	
	//

	
//{
}



class ButSkill extends SP {

	public var field:TF;
	public function new(sk) {
		super();
		var sid = Type.enumIndex(sk);
		var dat = Data.SKILLS[sid];
		field = Cs.getField(0xAAAACC, 8, "nokia");
		field.text = dat.name;
		addChild(field);
		
		var str = dat.desc + "<br/>Prix : " + dat.price;
		mt.bumdum9.Hint.me.addItem( this, str );
		onOut(Grid.me.hideHint);
		
	}
	
}
class ButAction extends SP {

	public var field:TF;
	public function new(str:String, action:Void->Void,  help="???" ) {
		super();
		field = Cs.getField(0xCC00CC, 8, "nokia");
		field.text = str;
		addChild(field);
		
		//var str = dat.desc + "<br/>Prix : " + dat.price;
		//onOver(callback(Grid.me.displayHint, help ));
		//onOut(Grid.me.hideHint);
		
		mt.bumdum9.Hint.me.addItem( this, help );
		
		onClick(action);
		
	}
	
}

class HeroSlot extends SP{
	
	public var alive:Bool;
	var free:Int;
	
	var skills:Array<ButSkill>;
	
	public var ghost:HeroGhost;
	var title:TF;
	
	
	public function new(gh,xp) {
		ghost = gh;
		super();
		var data = Hero.DATA[Type.enumIndex(gh.type)];
		

		// VARS
		var lvl = Gameplay.getLevel(xp);
		var cur = xp - Gameplay.getXp(lvl);
		var next = Gameplay.getXp(lvl + 1);
		
		var spent = 0;
		var have = [];
		for ( sk in gh.skills ) {
			var sid = Type.enumIndex(sk);
			var dat = Data.SKILLS[sid];
			spent += dat.price;
			have[sid] = true;
		}
		free = lvl - spent;

		//var sum = 0;
		//for ( b in gh.grid ) if ( b != null ) sum++;
		alive = gh.state.grid > 0;
		
		// ENERGY
		var barSize = 32;
		for( i in 0...2 ){
			var dim = Gameplay.getGridSize(ghost);

			var bar = new RBar(barSize, 8,[0xFF0000,0xFFCC00][i]);
			bar.x += (barSize + 4)*i;
			bar.y = 12;
			var str = "";
			var coef = 0.0;
			switch( i ) {
				case 0 :
					coef = gh.state.grid/(dim.width*dim.height);
					str = "grille : "+Math.ceil(coef*100)+"%";
				case 1 :
					coef = cur / next;
					str = cur + "/" + next + " pts d'experience";
			}


			mt.bumdum9.Hint.me.addItem(bar, str);
			bar.display(coef);
			
			addChild(bar);
		}
		
		
		//
		var lineSpace = 10;
		var lineWidth = 150;
		
		// TITLE
		title = Cs.getField(0xFFFFFF, 8, "nokia");
		title.x = -2;
		title.width = 500;
		addChild(title);
		if ( !alive ) title.textColor = 0xFF0000;
		var str = Std.string(data.id)+" ";
		if ( free > 0 ) str += col("( "+free+" pts a répartir )",0xFF00FF);
		title.htmlText = str;// + "   xp : " + cur + "/" + next + "     free : " + free;
		
		// CARACS
		/*
		var f = Cs.getField(0xFFFFFF, 8, "nokia");
		f.x = barSize*2 + 6;
		f.y = 10;
		f.width = 500;
		addChild(f);
		var tcolor = 0x88CC88;
		var str = col("Connaissances : ",tcolor) + ghost.knowledge + col("      Eveil : ",tcolor) + ghost.awakening; // + "   xp : " + cur + "/" + next + "     free : " + free;
		if ( free > 0 ) str += col("      Compétenteces : ",tcolor)+free+" pt(s) ";
		f.htmlText = str;
		*/

		
		// CURSOR
		var cx =  -2;
		var cy =  2 * lineSpace;
		
		// CARACS
		for ( i in 0...2 ) {
			var f = Cs.getField(0xFFFFFF, 8, "nokia");
			f.x = cx;
			f.y = cy;
			f.width = 500;
			addChild(f);
			f.htmlText = col(["Conaissances", "Eveil"][i] + " : ",0x88CC88) + [ghost.knowledge, ghost.awakening][i];
			cy += lineSpace;
		}
		
		
		// SKILL
		var id = 0;
		var lineMax = 3;

		skills = [];
		for ( sk in data.skills ) {
			
			var sid = Type.enumIndex(sk);
			var dat = Data.SKILLS[sid];
			
			var but = new ButSkill(sk);
			addChild(but);
			but.x = cx+Std.int( id / lineMax)*lineWidth;
			but.y = cy + (id % lineMax)* lineSpace;
			if ( !have[sid] ) {
				but.field.textColor = 0x444444;
				if ( free >= dat.price ) but.onClick(callback(buySkill,sk));
			}
			
			skills.push(but);
			id++;
		}
		cy += lineSpace * lineMax;
		

		
		// STUDY
		if ( Grid.me.data.books > 0 && gh.knowledge < Gameplay.MAX_KNOWLEDGE ) {
		//if (  gh.knowledge < Gameplay.MAX_KNOWLEDGE ) {
			var but = new ButAction("Etudier", study, "Rajouter un point de connaissance a " + Std.string(data.id) );
			but.x = cx;
			but.y = cy;
			addChild(but);
			cx += lineWidth;
		}
		
		// PRAY
		if ( Grid.me.data.shrines > 0 && gh.awakening < Gameplay.MAX_AWAKENING/Gameplay.MAX_HERO ) {
			var but = new ButAction("Prier", pray, "Rajouter un point d'eveil a " + Std.string(data.id) );
			but.x = cx;
			but.y = cy;
			addChild(but);
		}
		
	}
	
	public function buySkill(sk:SkillType) {
		ghost.skills.push(sk);
		Grid.me.save();
		Grid.me.superMaj();
	}
	
	public function study() {
		ghost.knowledge++;
		Grid.me.data.books--;
		Grid.me.save();
		Grid.me.superMaj();
	}
	public function pray() {
		ghost.awakening++;
		Grid.me.data.shrines--;
		Grid.me.save();
		Grid.me.superMaj();
	}
	
	public function kill() {
		parent.removeChild(this);
		for ( but in skills ) but.removeEvents();
	}

	
	// FORMAT
	public function col(str, color:Int) {
		//return str;
		return "<font color='" + Col.getWeb(color) + "'>"+str+"</font>";
	}


}

//{
#end

