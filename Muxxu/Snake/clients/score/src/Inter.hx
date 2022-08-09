import Protocole;
import mt.bumdum9.Lib;

class Inter {//}
	public static var WIDTH = 440;
	public static var HEIGHT = 210;
	
	public static var MARGIN = 110;
	public static var TAB_H = 10;
	
	public static var PAGE_MAX = 9;

	
	var players:Array<_PlayerScore>;
	var tabIndex:Int;
	var tabs:Array<ButText>;
	var scrollButs:Array<But>;
	var vigs:Array<Vig>;
	var page:Int;
	var groups:Array<ButText>;
	var root:flash.display.Sprite;
	var fxm:mt.fx.Manager;
	
	public var data:_HallOfFame;
	public static var me:Inter;
	
	public function new(data:_HallOfFame) {
		me = this;
		this.data = data;
		root = new flash.display.Sprite();
		Main.root.addChild(root);
		initBg();
		
		//
		fxm = new mt.fx.Manager();
		
		//
		tabIndex =  0;
		vigs = [];
		
		
		initTabs();
		
		initGroups(data._sections);
		initScrollButs();
	
		// AUTO SELECT;
		if( data._sections.length > 0 )select(data._sections[0],0);

	}
	
	// INIT
	function initBg() {
		
		// MARGIN
		root.graphics.beginFill(Gfx.col("green_1"));
		root.graphics.drawRect(0, 0, WIDTH, HEIGHT);
		
		root.graphics.beginFill(Gfx.col("green_0"));
		root.graphics.drawRect(0, 0, MARGIN, HEIGHT);
		
		root.graphics.beginFill( 0xFFFFFF );
		root.graphics.drawRect(MARGIN, 0, 1, HEIGHT);
		root.graphics.beginFill( Col.brighten(Gfx.col("green_2"),-50) );
		root.graphics.drawRect(MARGIN + 1, 0, 1, HEIGHT);
		
		// TABS
		var ma = MARGIN + 2;
		//root.graphics.beginFill(Gfx.col("green_2"));
		root.graphics.beginFill(Col.brighten(Gfx.col("green_2"),-40));
		root.graphics.drawRect(ma, 0, WIDTH-ma, TAB_H);
	}
	function initGroups(a:Array<_ScoreSection>) {
		
		var ec = Math.min((HEIGHT  / (a.length+1)), 20);
		var y = Std.int((HEIGHT - (ec * (a.length-1))) * 0.5);
		
		
		if( y > 30 ) y = 30;
		if( y < 7 ) y = 7;
		
		groups = [];
		var me = this;
		for( id in 0...a.length ) {
			var str = getSectionName(a[id]);
			var f = function() { me.select(a[id],id); };
			var but = new ButText(f,str);
			root.addChild(but);
			but.x = MARGIN*0.5;
			but.y = y;
			but.setSize(MARGIN, 12);
			but.textColors[0] = 0xCCFF88;
			but.bgColors = [ Gfx.col("green_0"),		Col.brighten( Gfx.col("green_0"), 30),		Gfx.col("green_0"),  Gfx.col("red_0")];
			but.hBordColors = [ null,null,null,0xFFFFFF];
			y += Std.int(ec);
			Main.buts.push(but);
			groups.push(but);
		}
	}
	function getSectionName(id:_ScoreSection) {
		switch(id) {
			case SS_FRIENDS :		return Lang.SECTION_FRIENDS; //"mes amis";
			case SS_ARCHIVE :		return Lang.SECTION_ARCHIVE; //"archive";
			case SS_TOP :			return Lang.SECTION_TOP; //"pantheon";
			case SS_RAINBOW : 		return Lang.SECTION_RAINBOW ;
			case SS_GROUP(str) :	return str;
			case SS_MY_DRAFT : 	return Lang.SECTION_DRAFT ;
			//case SS_LAST_DRAFT : 	return Lang.SECTION_LAST_DRAFT ; //### DEPRECATED
			case SS_DRAFT(id, n) : return Lang.TOURNAMENT+" "+ "ABCDEFGHIJKLMNOPQRSTUVWXYZ".charAt(n) ; //### TODO
		}
	}
	
	function initScrollButs() {
		var me = this;
		scrollButs = [];
		
		for( n in 0...2 ) {
			var sens = n * 2 - 1;
			for( i in 0...2 ) {
				var a  = [];
				for( k in 0...3 ) a.push( Gfx.bg.get(k, ["but_scroll", "but_scroll_fast"][i] ) );
				var but = new ButPix( function() { me.incPage((1 + i * 9) * sens); }, a );
				root.addChild(but);
				but.x = WIDTH - 22;
				but.y = TAB_H+(HEIGHT - TAB_H) * 0.5 + ( 59 + i * 31 ) * sens;
				but.scaleY = -sens;
				Main.buts.push(but);
				but.sleepAlpha = 0.5;
				but.setSleep(true);
				scrollButs.push(but);
			}
		}
	}

	// ACTION
	public var activeSection:_ScoreSection;
	function select(type,id) {
		cleanPage();
		for( g in groups ) g.setHighlight(false);
		groups[id].setHighlight(true);
		activeSection = type;
		

		if( !isTabable() ) for( tab in tabs ) 	tab.visible = false;
		

		if( Main.dev ){
			var me = this;
			haxe.Timer.delay( function() { me.receiveData(me.getRandomData()); }, 1000 );
		}else {
			var data : _ScoreCall = {_s : type } ;
			Codec.load(Main.domain + "/selScore", data, receiveData) ;
		}
	}
	function receiveData(data:_ScorePage) {
		players = data._list;
		tabMax = 1;
		for( o in data._list ) if( o._score.length > tabMax ) tabMax = o._score.length;
		displayScores(tabIndex);
	}
	//
	function isTabable() {
		switch(activeSection) {
			case SS_ARCHIVE, SS_TOP, SS_MY_DRAFT, SS_RAINBOW :
				return false;
			case SS_DRAFT(id, n) :					return false;
			default :								return true;
		}
	}
	
	// UPDATE
	public function update() {
		fxm.update();
	}
	

	// PAGE
	var tabMax:Int;
	function displayScores(tab:Int) {
		page = 0;
		
		// TABS
		tabIndex = tab;
		if( tabIndex >= tabMax ) tabIndex = tabMax - 1;
		switch(activeSection) {
			case SS_ARCHIVE :
				players.sort(sortPlayersByReplayId);
			case SS_TOP :
				players.sort(sortPlayersByScore);
			default :
				players.sort(sortPlayersByScore);
				gotoMe();
		}
		displayPage();
		
	}
	function gotoMe() {
		var id = 0;
		for( p in players ) {
			if( p._name == data._me ) break;
			id++;
		}
		page = Std.int(id / PAGE_MAX);
	}
	
	function sortPlayersByScore(a:_PlayerScore, b:_PlayerScore) {
		var na = a._score[tabIndex]._score;
		var nb = b._score[tabIndex]._score;
		if( na > nb ) 			return -1;
		else if( na == nb ) 	return 0;
		else					return 1;
	}
	function sortPlayersByReplayId(a:_PlayerScore, b:_PlayerScore) {
		var na = a._score[tabIndex]._replayId;
		var nb = b._score[tabIndex]._replayId;
		if( na > nb ) 			return -1;
		else if( na == nb ) 	return 0;
		else					return 1;
	}
	
	
	function displayPage() {
		cleanPage();
		var pageMax = Std.int((players.length-1) / PAGE_MAX);
		
		for( id in 0...PAGE_MAX ) {
			var k = page * PAGE_MAX + id;
			if( k >=  players.length ) break;
			var pl = players[k];
			var vig = new Vig(pl, tabIndex, k);
			vig.x = MARGIN + 4 ;
			vig.y = 12 + id * Vig.HEIGHT;
			vigs.push(vig);
			if( activeSection == SS_RAINBOW && k < 5 ) vig.setPrize(0);
		}
		
		
		// BUTS
		for( i in 0...4 ) scrollButs[i].setSleep( page == (i<2?0:pageMax) );
			
	}
	function incPage(inc) {
		page += inc;
		var pageMax = Std.int((players.length-1) / PAGE_MAX);
		if( page > pageMax ) page = pageMax;
		if( page < 0 ) page = 0;
		displayPage();
	}
	
	function cleanPage() {
		while(vigs.length > 0) vigs.pop().kill();
	}
	
	function initTabs() {
		tabs = [];
		var me = this;
		var ww = 100;
		for( id in 0...3 ) {
			var str = Lang.TIME_INTERVAL[id];
			var b = new ButText( function() { me.selectTab(id); }, str );
			b.x = MARGIN+2+(id+0.5)*ww;
			b.y = Std.int(TAB_H*0.5);
			b.setSize(ww, TAB_H);
			//b.sepColors = [ Col.brighten(Gfx.col("green_2"),-40),	Gfx.col("green_2"),		Col.brighten(Gfx.col("green_2"),-40)];
			b.bgColors = [ Gfx.col("green_2"), Gfx.col("green_1"), Gfx.col("green_2"), Gfx.col("green_1") ];
			b.textColors = [ Gfx.col("green_1"), Gfx.col("green_2"), Gfx.col("green_1"), 0xFFFFFF ];
			root.addChild(b);
			Main.buts.push(b);
			tabs.push(b);
		}
		tabs[tabIndex].setHighlight(true);
	}
	function selectTab(id) {
		var tab = tabs[id];
		for( t in tabs )t.setHighlight(false);
		tab.setHighlight(true);
		cleanPage();
		displayScores(id);
		
	}
	
	// DEBUG
	function getRandomPseudo() {
		
		var a = ["Dark", "White", "Snow", "Red","Deep","Black","Fried","Fun", "Kiki", "Lolo", "Mimi", "Nana", "Super", "Ultra", "Giga", "Extra", "Mega"];
		var b = ["Boss","Bison","Sangoku","Neo","Bouzig","Shiva","City","Hunter","Warrior","Saya","Surfer","Skater","Poutre","Blaster","Killer","Ninja","Shinobi","Kikou"];
		var c = ["du95", "2000", "33", "2010", "2009", "2008", "2007", "2006", "2004", "92", "93", "94"];
		
		var name = a[Std.random(a.length)] + b[Std.random(b.length)];
		if( Std.random(5) == 0 ) name += c[Std.random(c.length)];
		
		return name;
		
	}
	function getRandomData() {
	
			var data:_ScorePage = {	_list:[] };
			for( i in 0...64 ) {
				var o:_PlayerScore = {
					_name:getRandomPseudo(),
					_avatar:"hale.gif",
					_score:[],
				}
				
				var max = 3;
				if( activeSection == SS_ARCHIVE ) max = 1;
				
				for( i in 0...max ) {
					var data:_ScoreData = { _score:Std.random(1200) * 50,	_cards:[],	_replayId:Std.random(140000) };
					var max = 2;
					while ( max < 6 && Std.random(2) == 0 ) max++;
					
					var max = Data.getCardMax();
					
					for( k in 0...max ) data._cards.push( Snk.getEnum(_CardType,Std.random(max)) );
					o._score.push(data);
				}
				data._list.push(o);
			}
			data._list[Std.random(data._list.length)]._name = "Bumdum";
			return data;
	}
	
//{
}












