import Common;
import Anim;
import mt.bumdum.Lib;

typedef DescMC = {> flash.MovieClip, desc: flash.TextField, title: flash.TextField, card: flash.MovieClip}
typedef PowerMC = {> flash.MovieClip, t1: flash.MovieClip, t2: flash.MovieClip, b: flash.MovieClip }

enum TargetType {
	All;
	Both;
	Mine;
	Free;	
}



class Card {
	static var ANIM_POWER = {start: 1,end: 145};
	static var ENCLUME       = 0;
	static var CELERITE      = 1;
	static var CONFISCATION  = 2; //
	static var RENFORT       = 3;
	static var DESORDRE      = 4; //
	static var PETRIFICATION = 5;
	static var VACHETTE      = 6;
	static var CONVERSION    = 7;
	static var CHARGE        = 8;
	static var ENTRACTE      = 9;
	static var SOLO          = 10;
	static var PIEGE         = 11; //

	public static function random(){
		return Std.random(12);
	}

	static var NAMES = ["Enclume","Relais","Voleur de biscuit","Renforts","Désordre mental","Pétrification","Pelle à tarte","Conversion","Double charge","Sieste","Solo","Piège" ];
	static var DESC = [
		"L'enclume detruit la case ciblée et ce qui est dessus.",
		"Vous pouvez jouer 2 fois pendant un tour.",
		"Si votre adversaire joue un biscuit au prochain tour, annulez son effet et récupérez le biscuit.",
		"Place au hasard jusqu'à 3 alliés supplémentaires sur le gâteau.",
		"Le prochain mouvement de votre adversaire sera inversé.",
		"La cible se transforme en pierre.",
		"Faites voler toute la colonne choisie grâce à cet outil magique.",
		"La cible choisie change d'équipe.",
		"Votre prochain mouvement sera doublé.",
		"Vous passez votre tour.",
		"Seul l'aliment ciblé se déplacera ce tour.",
		"Posez un piège sur une case libre du gateau. La case se détruira si un aliment marche dessus."
	];

	//

	public var pos : Int;
	public var type : Int;
	var choice : Bool;
	var mc : flash.MovieClip;
	var game : Game;
	var used : Bool;
	public var mine : Bool;

	var mcDesc : DescMC;

	public function new( ch, g, t, p, m : Bool ){
		mine = m;
		choice = ch;
		game = g;
		type = t;
		pos = p;
		used = false;
	}

	public function display( ?m : Bool ){
		if( m == null ) m = mine;
		if( mc == null ) mc = game.dmanager.attach("card",Const.PLAN_CARD);

		if( choice ){
			var p = pos;
			mc._x = (p % 4) * 70 + 40;
			mc._y = Std.int(p / 4) * 90 + 50;
			if( !MMApi.isMyTurn() || !MMApi.hasControl() ){
				mc.gotoAndStop( 1 );
				mc.onRollOver = null;
				mc.onDragOut = null;
				mc.onRollOut = null;
				mc.onRelease = null;
			}else{
				mc.gotoAndStop( type + 10 );
				mc.onRollOver = onRollOver;
				mc.onDragOut = onRollOut;
				mc.onRollOut = onRollOut;
				mc.onRelease = choose;
			}
		}else{
			mc._xscale = mc._yscale = 50;
			//mc._x = if( mine ) 20 else 280;
			//mc._y = pos * 45 + 35;
			mc._x = if( m ) pos * 40 + 20 else (pos + 4.5) * 40 + 20;
			mc._y = 295;
			if( m && MMApi.hasControl() ){
				mc.gotoAndStop( type + 10 );
				mc.onRollOver = onRollOver;
				mc.onDragOut = onRollOut;
				mc.onRollOut = onRollOut;
				mc.onRelease = use;
			}else{
				mc.gotoAndStop( 1 );
				Reflect.deleteField(mc,"onRollOver");
				Reflect.deleteField(mc,"onDragOut");
				Reflect.deleteField(mc,"onRollOut");
				Reflect.deleteField(mc,"onRelease");
				mc._alpha = 100;
			}
		}

		hideDesc();
	}

	public function onRollOver(){
		if( !choice ){
			if( MMApi.isMyTurn() && !game.effect.oneUsed && game.choosingCard != this ){
				mc._xscale = mc._yscale = 65;
				mc._y = 280;
			}
		}else{
			mc._xscale = mc._yscale = 110;
		}
		displayDesc();
	}

	public function onRollOut(){
		if( !choice ){
			if( game.choosingCard != this ){
				mc._xscale = mc._yscale = 50;
				mc._y = 295;
			}
		}else{
			mc._xscale = mc._yscale = 100;
		}
		hideDesc();
	}

	function displayDesc(){
		hideDesc();
		
		if(choice){
			mcDesc = cast game.dmanager.attach("cardDesc",Const.PLAN_CARD_DESC);
			mcDesc._y = 200;
			mcDesc.card.gotoAndStop(type+10);
			mcDesc.title.text = NAMES[type];
			mcDesc.desc.text = DESC[type];
		}else{
			mcDesc = cast game.dmanager.attach("cardDesc",Const.PLAN_CARD_DESC);
			mcDesc._y = 0;
			mcDesc.card.gotoAndStop(type+10);
			mcDesc.title.text = NAMES[type];
			mcDesc.desc.text = DESC[type];
		}
	}

	function hideDesc(){
		if( mcDesc != null ){
			mcDesc.removeMovieClip();
			mcDesc = null;
		}
	}

	public function remove(){
		if( mc != null ){
			mc.removeMovieClip();
			mc = null;
		}
		hideDesc();
	}

	public function choose(){
		if( MMApi.isMyTurn() ){
			MMApi.endTurn(TakeCard(pos));
		}
	}

	public function displayPower( soe : Void -> Void ){
		var player = if( mine ) "$me" else "$other";

		game.dmanager.getMC().cacheAsBitmap = true;

		var p : PowerMC = cast game.dmanagerPower.attach("power", Const.PLAN_POWER);
		p.t1.gotoAndStop( type + 10 );
		p.t2.gotoAndStop( type + 10 );
		p.b.gotoAndStop( type + 10 );
		var me = this;

		var oe = function(){
			MMApi.logMessage(player+" utilise le biscuit "+NAMES[me.type]+".");
			p.removeMovieClip();
			me.game.dmanager.getMC().cacheAsBitmap = false;
			if( soe != null ) 
				soe();
			else
				MMApi.lockMessages( false );
		}

		game.anim.add( new AnimPlay(p,ANIM_POWER,0,oe) );
	}

	public function displayPowerLose(){
		var player = if( mine ) "$me" else "$other";

		game.dmanager.getMC().cacheAsBitmap = true;

		var p : PowerMC = cast game.dmanagerPower.attach("power_lose", Const.PLAN_POWER);
		p.t1.gotoAndStop( type + 10 );
		p.t2.gotoAndStop( type + 10 );
		p.b.gotoAndStop( type + 10 );
		var me = this;

		var oe = function(){
			MMApi.logMessage(player+" vole le biscuit "+NAMES[me.type]+".");
			p.removeMovieClip();
			me.game.dmanager.getMC().cacheAsBitmap = false;
			MMApi.lockMessages( false );
		}

		game.anim.add( new AnimPlay(p,ANIM_POWER,0,oe) );
	}

	public function logLose(){
		var player = if( mine ) "$me" else "$other";
		MMApi.logMessage(player+" a utilisé son biscuit "+NAMES[type]+" pour rien.");
	}

	public function endMyTurn(){
		if( MMApi.hasControl() )
			mc._alpha = 50;
	}

	public function myTurn(){
		if( MMApi.hasControl() )
			mc._alpha = 100;
	}

	public function use(){
		if( !MMApi.isMyTurn() ) return;
		if( used ) return;
		if( game.effect.oneUsed ) return;
		
		if( game.choosingCard == this ){
			cleanRoll();
			return;
		}
		if( game.choosingCard != null )
			game.choosingCard.cleanRoll();

		if( type == ENCLUME ){
			chooseTarget(TargetType.All);
		}else if( type == CONVERSION || type == PETRIFICATION ){
			chooseTarget(TargetType.Both);
		}else if( type == SOLO ){
			chooseTarget(TargetType.Mine);
		}else if( type == PIEGE ){
			chooseTarget(TargetType.Free);
		}else if( type == VACHETTE ){
			chooseVachette();
		}else if( type == RENFORT ){
			used = true;
			game.effect.oneUsed = true;
			game.cardEndMyTurn();
			MMApi.sendMessage(UseCard(pos,Std.random(1000),null));
		}else if (type == CELERITE && game.effect.confiscation == null ){
			used = true;
			game.effect.celerite = this;
			game.effect.oneUsed = true;
			game.cardEndMyTurn();
			remove();
			var t = game.myTeam;
			var me = this;
			displayPower(function(){
				for( r in me.game.grid ) for( c in r ) if( c.fruit != null && c.fruit.team == t ) c.fruit.spark();
			});
		}else{
			used = true;
			game.effect.oneUsed = true;
			game.cardEndMyTurn();
			if( type == ENTRACTE && game.effect.confiscation == null )	
				MMApi.endTurn(UseCard(pos,null,null));
			else
				MMApi.sendMessage(UseCard(pos,null,null));
		}
	}

	public function onUse( mine: Bool, x : Int, y : Int ){
		var me = this;
		switch( type ){
			case ENCLUME:
				remove();
				var g = game.grid[y][x];
				displayPower(function(){
					g.enclume();
				});
			case CELERITE:
				var d = switch( x ){ case 1: Up; case 2: Down; case 3: Left; case 4: Right; }
				var g = game;
				remove();
				if( !mine ){
					var t = Game.opposite(game.myTeam);
					displayPower(function(){
						for( r in me.game.grid ) for( c in r ) if( c.fruit != null && c.fruit.team == t ) c.fruit.spark();
						g.onMessage(mine,Move(d));
					});
				}else{
					g.onMessage(mine,Move(d));
				}
			case CONFISCATION:
				game.effect.confiscation = {myCard: mine,card: this};
				if( mine && MMApi.hasControl() ){
					remove();
					displayPower(null);
				}else{
					MMApi.lockMessages(false);
				}
			case RENFORT:
				remove();
				displayPower(function(){
					me.renfort(mine,x);
				});
			case DESORDRE:
				if( !mine ){
					game.effect.desordre = {card: this};
					MMApi.lockMessages(false);
				}else if( !MMApi.hasControl() ){
					game.effect.hideDesordre = {card: this};
					MMApi.lockMessages(false);
				}else{
					game.effect.oppDesordre = true;
					remove();
					displayPower(function(){	
						var t = Game.opposite(me.game.myTeam);
						for( r in me.game.grid ) for( c in r ){
							if( c.fruit != null && c.fruit.team == t ) c.fruit.stars();
						}
						MMApi.lockMessages(false);
					});
				}
			case PETRIFICATION:
				remove();
				displayPower(function(){
					me.game.grid[y][x].fruit.stone();
				});
			case VACHETTE:
				remove();
				displayPower(function(){
					me.vachette( x );
				});
			case CONVERSION:
				var f = game.grid[y][x].fruit;
				var mt = game.myTeam;
				remove();
				displayPower(function(){
					f.convert();
					if( MMApi.isMyTurn() ){
						if( f.team == mt ) f.myTurn(); else f.endMyTurn();
					}
				});
			case CHARGE:
				if( mine ) game.effect.charge = true;
				remove();
				var t = if( mine ) game.myTeam else Game.opposite(game.myTeam);
				displayPower(function(){
					for( r in me.game.grid ) for( c in r ) if( c.fruit != null && c.fruit.team == t ) c.fruit.spark();
				});
			case ENTRACTE:
				remove();
				displayPower(null);
				var t = if( mine ) game.myTeam else Game.opposite(game.myTeam);
				for( i in 0...Const.SIZE ){
					for( j in 0...Const.SIZE ){
						var g = game.grid[i][j];
						if( g.fruit != null && g.fruit.team == t ){
							g.fruit.sleep();
						}
					}
				}
			case SOLO:
				game.effect.solo = {x: x,y: y,mine: mine};
				if( mine ){
					for( r in game.grid ) for( c in r ){
						if( c.fruit != null && c.fruit.team == game.myTeam && (c.x != x || c.y != y) ) c.fruit.endMyTurn();
					}
				}
				remove();
				displayPower(null);
			case PIEGE:
				var g = game.grid[y][x];
				if( mine && MMApi.hasControl() ){
					remove();
					displayPower(function(){
						g.mine( true, me );
					});
				}else{
					g.mine( false, this );
					MMApi.lockMessages(false);
				}
		}
	}	

	public function glow(){
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 10;
		fl.blurY = 10;
		fl.color = 0xFFFFFF;
		fl.strength = 5;
		var a = mc.filters;
		a.push( fl );
		mc.filters = a;
	}

	public function killGlow(){
		var a = mc.filters;
		a.remove( a[0] );
		mc.filters = a;
	}

	public function chooseTarget( tt : TargetType ){
		game.choosingCard = this;
		glow();
		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				var g = game.grid[i][j];
				var ok = switch( tt ){
					case All:	 g.status != Destroy;
					case Mine: g.status == Used && g.fruit.team == game.myTeam;
					case Both: g.status == Used;
					case Free: g.status == Status.Free;
				}
				if( ok ){
					var me = this;
					g.chooseTarget( function(){
						me.game.effect.oneUsed = true;
						me.game.cardEndMyTurn();
						MMApi.sendMessage(UseCard(me.pos,g.x,g.y));
						me.cleanRoll();
					});
				}
			}
		}
	}

	public function chooseVachette(){
		game.choosingCard = this;
		glow();
		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				var g = game.grid[i][j];
				var me = this;
				g.chooseVachette( function(){	
					me.game.effect.oneUsed = true;
					me.game.cardEndMyTurn();
					MMApi.sendMessage(UseCard(me.pos,g.x,null));
					me.cleanRoll();
				});
			}
		}
	}

	public function cleanRoll(){	
		killGlow();
		if( game.choosingCard == this ){
			game.choosingCard = null;
			onRollOut();
		}

		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				game.grid[i][j].cleanRoll();
			}
		}
	}

	///
	function vachette( x ){
		var top = game.grid[game.min_y][x];
		var bottom = game.grid[game.max_y][x];
		
		var mcVachette = game.fruit("vachette",null,null,Const.PLAN_VACHETTE);
		var p = {end: {x: top.mc._x,y: -180.0},start: {x: bottom.mc._x,y: 300.0}};
		mcVachette.gotoAndStop(4);
		mcVachette._x = p.start.x;
		mcVachette._y = p.start.y;
		var dur = 55;
		var onEnd = function(){ mcVachette.removeMovieClip(); };
		game.anim.add( new AnimMove(mcVachette,p,dur,0,onEnd) );

		for( i in game.min_y...(game.max_y + 1) ){
			game.grid[i][x].vachette(Std.int(-i * 3.5 + 28));
		}
	}

	function renfort(mine,x){
		var free = new Array();
		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				var g = game.grid[i][j];
				if( g.status == Status.Free ){
					free.push(g);
				}
			}
		}
		for( i in 0...Const.RENFORT_FRUIT ){
			if( free.length == 0 ) break;
			var r = x % free.length;
			var g = free.splice(r,1)[0];
			g.addFruit( if( mine ) game.myTeam else Game.opposite(game.myTeam) );
		}
	}


}
