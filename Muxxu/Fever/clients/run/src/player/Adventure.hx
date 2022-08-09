package player;
import Protocole;
import mt.bumdum9.Lib;

typedef AdvInterBar = { bg:pix.Element, dm:mt.DepthManager };
typedef Contender = { sprite:pix.Sprite, life:Int, hearts:Array<pix.Element>, lifeMax:Int };

class Adventure extends Player {//}
	
	public static var MARGIN = 18;

	public var endFxId:Int;
	var ingame:Bool;
	var win:Bool;
	var useMask:Bool;
	
	var bars:Array<AdvInterBar>;
	var data:MonsterData;

	var hero:Contender;
	var mon:Contender;
	
	var timeBar:Array<pix.Element>;
	var used:Array<_GameBonus>;
	var step:Int;
	var timer:Int;
	var cid:Int;
	var gameList:Array<Int>;
	var action:Void->Void;
	var wait:Void->Void;

	//var special: { heroLife:Int, doll:Bool, mask:Bool, book:Bool, windmill:Bool,   };
	
	public function new(data, seedNum) {
		super();
		#if dev
		if( Cs.FORCE_MONSTER != null )  data = Data.DATA._monsters[Cs.FORCE_MONSTER];
		#end
		
		useMask = false;

		this.data = data;
		gameList = getMonsterGameList(data, seedNum);
		cid = -1;
		endFxId = 0;
		ingame = false;
		initInter();
		used = [];
		
		//
		launch();
		//

		//
		Keyb.init();
		Keyb.actions[67] = callback( useBonus, Cheese);
		Keyb.actions[86] = useJoker;
		Keyb.actions[66] = callback( useBonus, Knife);
		
		#if dev
		var me = this;
		Keyb.actions[109] = function () { me.incHeroLife(-(me.hero.life-1)); }				// -
		Keyb.actions[107] = function () { me.incMonsterLife(-(me.mon.life-1)); }		// +
		#end
	
		
	}
	function launch() {
		
		var startDif = data._tempStart * 0.01;
		if( have(Cocktail) ) startDif -= 0.1;
		if( startDif < 0 ) startDif = 0;
		setDif(startDif);
		jumpTo();
	}


	function getHeart() {
		var el = new pix.Element();
		el.drawFrame(Gfx.inter.get(1,"heart"));
		el.y = 4;
		el.tabIndex = 1;
		bars[1].dm.add(el, 2);
		return el;
	}
	
	// UPDATE
	override function update(?e:Dynamic) {
		super.update(e);
		if( action != null ) action();

	}
	
	// CALLBACK
	override function onSetWin(win) {
		this.win = win;
		if( win ) {
			
			var damage = 1;
			var fork =  have(Fork) && Std.random(10) == 0;
			if( fork ) damage++;
			incMonsterLife( -damage);
			
			// HERO ANIM
			var normal = Gfx.hero.getAnim("hero_front");
			if( fork ){
				var anim = Gfx.hero.getAnim("hero_fork");
				hero.sprite.setAnims([anim, normal]);
			}else {
				var jump = Gfx.hero.getAnim("hero_happy_jump");
				hero.sprite.setAnims([jump, jump, jump, normal]);
			}
		
		}else {
			
			var damage = data._atk;
			if( have(MagicRing) && damage > 1 ) damage--;
			
			if( data._id == 9 )		endFxId = world.Loader.me.have(Mirror)?2:1;
			else					incHeroLife( -damage);
		}
	
		
	}
	override function endGame() {
		ingame = false;
		hideCornerIcon();
		
		if( mon.life <= 0 || endFxId == 2 )			endPlayer(true);
		else if(hero.life <= 0 || endFxId == 1 )	endPlayer(false);
		
		if( win || !have(Windmill) ) setDif(dif + data._tempInc * 0.01);
		jumpTo();

	}
	
	// END PLAYER
	function endPlayer(success) {
		
		Keyb.clean();
		action = null;
		World.me.send(_GameResult(success, used ));
		World.me.victory = success;
		
		var mfx:mt.fx.Fx = null;
		switch(endFxId) {
			
			case 0 :
				if( success )	 	mfx = new fx.FadeStarOut(this);
				else 				mfx = new fx.GameOver(this);
				
			case 1, 2:				mfx = new fx.Medusa(this);
			
		}
		
	}
	
	// OV
	override function newGame(id) {
		super.newGame(id);
		game.y = MARGIN;
	}
	public function initGame() {
		dm.add(game, Player.DP_GAME);
		action = updatePlay;
		ingame = true;
		game.active = true;
		
		// GRIMOIRE
		if( have(Book) && game.id == World.me.params.noEntry ) initNoEntry();
		
		// HOURGLASS
		if( have(Hourglass) &&  Data.DATA._games[game.id]._type == 1 ) {
			game.gameTime = Std.int( game.gameTime*1.25 );
			game.gameTimeMax = game.gameTime;
			diplayCornerIcon(Gfx.inter.get(16,"items"));
		}
	}
	function updatePlay() {
		game.update();
		setTimeBar(game.gameTime / game.gameTimeMax);
	}
		
	// JUMPER
	function jumpTo() {
		var old = game;
		
		newGame(getNextGameId());
		initJumper(old);
		if( old != null ) old.kill();
	}
	function initJumper(?from:Game) {
		var fromId = Std.random(Game.MAX);
		if( from != null ) fromId = from.id;
		var jumper = new Jumper(fromId, game.id, this);
		
		if( from == null ) 	jumper.coef = 0.5;
		else				Jumper.drawGame(from);
		
		Jumper.drawGame(game);
		
		action = jumper.update;
		jumper.update();
	}
	
	// JOKER
	var slider:flash.display.Bitmap;
	function useJoker() {

		if( !ingame || game.win != null ) return;
		if( have(Voodoo_Mask) && !useMask ) {
			useMask = true;
			sideSlide("voodoo_mask");
		}else if( haveBonus(Leaf) ){
			
			spendBonus(Leaf);
			sideSlide();
		}

		
		
	}
	function endJoker() {
		slider.parent.removeChild(slider);
		slider.bitmapData.dispose();
		slider = null;
		initGame();
	}
	
	// SEQUENCE
	function useBonus(b) {
		if( ingame || !haveBonus(b) || wait != null ) return;
		if( b == Cheese && hero.life == hero.lifeMax ) return;
		
		spendBonus(b);
	
		
		wait = action;
		step = 0;
		timer = 0;
		switch(b) {
			case Cheese :	action = updateCheese;
			case Knife :	action = updateKnife;
			default :
		}
	}
	function updateCheese() {
		timer++;
		switch(step) {
			case 0:
				hero.sprite.setAnims([Gfx.hero.getAnim("hero_cheese"), Gfx.hero.getAnim("hero_front")]);
				step++;
			case 1:
				if( timer > 40 ) {
					step++;
					timer = 0;
					hero.life = hero.lifeMax;
					majHearts(hero);
				}
			case 2 :
				if( timer++ > 10 ) {
					action = wait;
					wait = null;
				}
				
			
		}
	}
	function updateKnife() {
		timer++;
		switch(step) {
			case 0:
				hero.sprite.setAnims([Gfx.hero.getAnim("hero_knife"), Gfx.hero.getAnim("hero_front")]);
				step++;
			case 1:
				if( timer == 20 ){
					var knife = new pix.Element();
					knife.drawFrame(Gfx.fx.get("knife"));
					bars[1].dm.add(knife, 5);
					knife.x = hero.sprite.x+8;
					knife.y = hero.sprite.y;
					
					var fx = new mt.fx.Tween(knife,mon.sprite.x-4,mon.sprite.y,0.05);
					fx.onFinish = callback(stab, knife, false);
					
					step++;
				}
				
			
		}
	}
	function stab(knife:pix.Element,backfire) {
		
		if( !backfire && data._id == 11) {
			var fx = new mt.fx.Tween(knife, hero.sprite.x + 4, hero.sprite.y, 0.05);
			fx.onFinish = callback(stab, knife, true);
			knife.scaleX = -1;
			mon.sprite.setAnims(Gfx.monsters.getAnims([data._anim+"_repel",data._anim]));
			//mon.sprite.setAnim(Gfx.monsters.getAnim(data._anim+"_repel"));
			return;
		}
		
		var trg = mon;
		if( backfire ) trg = hero;
		
		knife.drawFrame(Gfx.fx.get(1, "knife"));
		if(knife.parent != null ) knife.parent.removeChild(knife);
		trg.sprite.addChild(knife);
		knife.x -= trg.sprite.x;
		knife.y -= trg.sprite.y;
		
		if( backfire )	incHeroLife( -1);
		else			incMonsterLife( -1);
		
		new mt.fx.Vanish(knife, 15);

		if( mon.life <= 0 ) {
			endPlayer(true);
			
		}else if ( hero.life <= 0 ) {
			endPlayer(false);
			
		}else {
			action = wait;
			wait = null;
		}
		
		
	}
	
	// SPECIAL
	/*
	function stoneHero() {
		var el = new pix.Element();
		el.drawFrame(Gfx.hero.get(1, "hero_hurt"));
		el.x = hero.sprite.x;
		el.y = hero.sprite.y;
		bars[1].dm.add(el, 2);
		new mt.fx.Blink( el, 40, 4 , 4 );
		
		hero.sprite.anim.goto(0);
		hero.sprite.anim.play(0);
		hero.stoned = true;
		
	}
	*/
	
	// SIDE SLIDE
	function sideSlide(?illus:String) {
		
		ingame = false;
		action = null;
		
		// DOLL
		var psh = 0;
		var speed = 0.1;
		if( illus != null ) {
			psh = Cs.mcw;
			speed = 0.025;
		}
		
		// SLIDER
		slider = new flash.display.Bitmap();
		slider.bitmapData = new flash.display.BitmapData(Cs.mcw * 2 + psh, Cs.mch, false, 0);
		var rect = new flash.geom.Rectangle(0, 0, Cs.mcw, Cs.mch);
		slider.bitmapData.draw(game,null,null,null,rect);
		slider.y = MARGIN;
		game.kill();
		
		newGame(getNextGameId());
		var m = new flash.geom.Matrix();
		m.translate(Cs.mcw+psh, 0);
		rect.x += Cs.mcw+psh;
		slider.bitmapData.draw(game, m, null, null, rect);
		
		//
		if( illus != null ) {
			var e = new pix.Element();
			e.drawFrame(Gfx.illus.get(illus),0,0);
			var m = new MX();
			m.scale(8, 8);
			m.translate(Cs.mcw, 0);
			slider.bitmapData.draw(e, m);
		}
		
		
		// SLIDE
		var fx = new mt.fx.Tween(slider, -(Cs.mcw+psh), MARGIN,speed);
		fx.curveInOut();
		fx.onFinish = endJoker;
		dm.add(slider, Player.DP_GAME);
			
	}
	
	// ICON
	var cornerIcon:pix.Element;
	function diplayCornerIcon(fr) {
		if( cornerIcon == null ){
			cornerIcon = new pix.Element();
			cornerIcon.y = MARGIN ;
			cornerIcon.scaleX = cornerIcon.scaleY = 2;
			Filt.glow(cornerIcon, 4, 200, 0);
			dm.add(cornerIcon, Player.DP_INTER);
		}
		cornerIcon.visible = true;
		cornerIcon.drawFrame(fr,0,0);
		
	}
	function hideCornerIcon() {
		if( cornerIcon == null ) return;
		cornerIcon.visible = false;
	}
	
	
	
	// GRIMOIRE
	function initNoEntry() {
		var mc = new McNoEntryAnim();
		game.addChild(mc);
		mc.x = Cs.mcw * 0.5;
		mc.y = Cs.mch * 0.5;
		timer = 0;
		action = majNoEntry;
	}
	function majNoEntry() {
		if( timer++ == 12 ) sideSlide();
	}

	
	//
	function getNextGameId() {
		cid = (cid + 1) % gameList.length;
		return gameList[cid];
	}
	
	// INTER
	static var TIMEBAR_LENGTH = 97;
	var counters:Array<flash.text.TextField>;
	var temp:flash.text.TextField;
	var iconTemp:pix.Element;
	
	function initInter() {
		// BAR
		bars = [];
		for( i in 0...2 ) {
			var bar = new pix.Element();
			bar.y = i * (Cs.mcrh - MARGIN);
			bar.drawFrame(Gfx.inter.get(i, "bar"), 0, 0);
			bar.scaleX = bar.scaleY = 2;
			dm.add(bar, Player.DP_INTER);
			bars.push( { bg:bar, dm:new mt.DepthManager(bar) } );
			bar.mouseEnabled  = false;
			bar.mouseChildren  = false;
		}
		
		// TIME BAR
		timeBar = [];
		var bgt = new pix.Element();
		bars[0].dm.add(bgt, 1);
		bgt.drawFrame(Gfx.inter.get("bg_timebar"), 0, 0);
		bgt.x = 30;
		bgt.width = TIMEBAR_LENGTH;
		
		for( i in 0...3  ) {
			var el = new pix.Element();
			bars[0].dm.add(el,1);
			el.drawFrame(Gfx.inter.get([0,1,0][i],"timebar"),0,0);
			el.x = 30+i;
			el.y = 1;
			timeBar.push(el);
		}
		setTimeBar(1);
		
		// COUNTERS
		counters = [];
		var x = 0;
		for( i in 0...4 ) {
			var ico = new pix.Element();
			ico.drawFrame(Gfx.inter.get(i,"adv_icons"),0,0);
			bars[0].dm.add(ico, 1);
			ico.x = x;
			x += 9;
			
			var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			bars[0].dm.add(f, 1);
			f.x = x;
			f.y = -2;
			f.text = "0";
			f.filters = [ new flash.filters.GlowFilter(0x550000,1,4,4,100)];
			f.height = 10;
			f.width = 16;
			f.selectable = false;
			x += 15;
			
			if( i == 0 ) {
				temp = f;
				temp.width = 20;
				iconTemp = new pix.Element();
				iconTemp.drawFrame(Gfx.inter.get("icon_temp"),0,0);
				bars[0].dm.add(iconTemp, 1);
				iconTemp.y = 0;
				x += 105;
			}else {
				counters.push(f);
			}
		}
		majCounters();
		/*
		temp = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		bars[0].dm.add(temp, 1);
		temp.x = 11;
		temp.y = -2;
		temp.text = "25°";
		temp.filters = [ new flash.filters.GlowFilter(0x550000,1,4,4,100)];
		temp.height = 10;
		temp.width = 20;
		temp.selectable = false;
		
		iconTemp = new pix.Element();
		iconTemp.drawFrame(Gfx.inter.get("icon_temp"),0,0);
		bars[0].dm.add(iconTemp, 1);
		iconTemp.y = 0;
		*/
		
		
		// HEROES
		var monLifeMax = data._life;
		if( have(Voodoo_Doll) ) monLifeMax--;
		
		var limit = 18 - monLifeMax;
		var hl = getHeroLife();
		if( hl > limit ) hl = limit;
		
		hero = getContender(-1,hl);
		mon = getContender(1,monLifeMax);
		hero.sprite.setAnim(Gfx.hero.getAnim("hero_front"));
		mon.sprite.setAnim(Gfx.monsters.getAnim(data._anim));
		mon.sprite.y += data._oy + 4;
		
		incMonsterLife(0);
		incHeroLife(0);
		
		
	}
	function getContender(side, lifeMax) {
		
		var sp = new pix.Sprite();
		bars[1].dm.add(sp, 1);
		sp.x = 9;
		sp.y = 1;
		if( side == 1 ) sp.x = Cs.mcw*0.5 - sp.x;
		
		var con:Contender = { sprite:sp, life:lifeMax, hearts:[], lifeMax:lifeMax};
	
		for( i in 0...lifeMax) {
			var h = getHeart();
			h.x = 21 + i * 9;
			con.hearts.push(h);
			if( side == 1 ) h.x = Cs.mcw*0.5 - h.x;
		}

		return con;
	}
	
	function incMonsterLife(inc) {
		mon.life += inc;
		if( mon.life < 0 ) mon.life = 0;
		majHearts(mon);
		if( inc < 0 ) fxDamageMonster();
	}
	function incHeroLife(inc) {
		hero.life += inc;
		if( hero.life < 0 ) hero.life = 0;
		majHearts(hero);
		
		if( inc < 0 ) {
			hero.sprite.setAnims([Gfx.hero.getAnim("hero_hurt"),Gfx.hero.getAnim("hero_front")]);
			new mt.fx.Shake( hero.sprite, 4, 0, 0.8 );
		}
	}
		
	function majHearts(con:Contender) {
		var id = 0;
		for( el in con.hearts  ) {
			var k = (id < con.life)?0:1;
			if( el.tabIndex == 0 && k == 1 ) {
				var sp = new pix.Sprite();
				sp.setAnim(Gfx.inter.getAnim("heart_explode"));
				bars[1].dm.add(sp,2);
				sp.x = el.x;
				sp.y = el.y;
				sp.anim.onFinish = sp.kill;
			}
			el.tabIndex = k;
			el.drawFrame(Gfx.inter.get(k, "heart"));
			id++;
		}
	}
	function setTimeBar(c:Float) {
		
		c = Num.mm(0, c, 1);
		var ww = TIMEBAR_LENGTH*c;
		
		var mid = timeBar[1];
		mid.width = ww;
		
		var top = timeBar[2];
		top.x = 30 + ww;
		
		
		
	}
	
	function setDif(n:Float) {
		if( n > data._tempMax*0.01 ) n = data._tempMax*0.01;
		Player.me.dif = n;
		temp.text = Std.int(Player.me.dif * 100) + "°";
		//temp.width = temp.textWidth + 4;
		iconTemp.x = temp.x + temp.textWidth + 3;
	}
	
	function majCounters() {
		if( world.Loader.me == null ) return;
		var inv = world.Loader.me.data._inv;
		for( i in 0...3) {
			var n = [inv._knife, inv._cheese, inv._leaf ][i];
			if( n > 99 ) n = 99;
			var str = Std.string(n);
			while( str.length == 1 ) str = "0" + str;
			counters[i].text = str;
		}
	}
	
	//
	function fxDamageMonster() {
		mon.sprite.setAnims([Gfx.monsters.getAnim(data._anim + "_hurt"),Gfx.monsters.getAnim(data._anim)]);
		new mt.fx.Shake( mon.sprite, 4, 0, 0.8 );
	}
	
	
	// WORLD LINK
	function have(it) {
		if( World.me == null ) return false;
		return world.Loader.me.have(it);
	}
	function getHeroLife() {
		if( World.me == null ) return 12;
		return world.Loader.me.getLifeMax();
	}
	function haveBonus(n:_GameBonus) {
		#if dev
		return true;
		#end
		if( World.me == null ) return true;
		var inv = world.Loader.me.data._inv;
		switch(n) {
			case Leaf :			return inv._leaf > 0;
			case Cheese :		return inv._cheese > 0;
			case Knife :		return inv._knife > 0;
			default : 			return false;
		}
	}
	function spendBonus(b:_GameBonus) {
		if( world.Loader.me == null ) return;
		used.push(b);
		world.Loader.me.incGameBonus(b, -1);
		majCounters();
	}
	

	//
	static public function getMonsterGameList(data:MonsterData,k:Int,?max=32) {
		var gameList = [];
		var seed = new mt.Rand(k);
		
		// FAM
		var a = data._gameFam.split(",");
		for( str in a ) {
			var id = Std.parseInt(str);
			for( g in Data.DATA._games) if( g._acc == id ) gameList.push(g);
		}
		
		// SPECIFIC
		var a = data._gameSpecial.split(",");
		for( str in a ) gameList.push( Data.DATA._games[Std.parseInt(str)] );
		
		// SUM
		var weightSum = 0;
		for( g in gameList ) weightSum += g._weight;
		
		// LIST
		var a = [];
		for( i in 0...48 ) {
			var rnd = seed.random(weightSum);
			var sum = 0;
			var id = 0;
			for( g in gameList ) {
				sum += g._weight;
				if( sum > rnd ) {
					a.push(g._id);
					break;
				}
			}
		}
		
		// REMOVE DOUBLE
		var b = [];
		var prec = -1;
		for( id in a ) {
			if( prec != id ) b.push(id);
			prec = id;
		}
		
		//
		return b;

	}
	
		
	
//{
}









