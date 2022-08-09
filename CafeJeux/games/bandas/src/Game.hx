import Common;
import Anim;

typedef Miette = {> flash.MovieClip,
	size : Float,
	dx : Float,
	dy : Float,
	vit : Float
}


class Game implements MMGame<Msg> {
	public static function opposite( t : Team ){
		if( t == Bananas ) return Orange
		else return Bananas;
	}

	public var dmanagerBoard : mt.DepthManager;
	public var dmanager : mt.DepthManager;
	public var dmanagerPower : mt.DepthManager;
	public var grid : Array<Array<Cell>>;
	public var anim : List<Anim>;
	public var freeAnim : List<Anim>;

	public var cards : Array<Card>;
	public var myCards : Array<Card>;
	public var oppCards : Array<Card>;
	public var partsUp : Array<Miette>;
	public var partsDown : Array<Miette>;
	public var partsLeft : Array<Miette>;
	public var partsRight : Array<Miette>;
	/*
	public var onde1 : flash.MovieClip;
	public var onde2 : flash.MovieClip;
	public var onde3 : flash.MovieClip;
	public var onde4 : flash.MovieClip;
	*/

	public var effect : {
		celerite: Card, // != null si le joueur actuel est en train de jouer la carte celerite
		confiscation: {myCard: Bool,card: Card}, //
		desordre: {card: Card}, // défini si le prochain mouvement du joueur est à inversé
		oppDesordre: Bool, // défini si l'adversaire aura son prochain coup inversé
		hideDesordre: {card: Card}, // défini si le joueur qu'on voit lance le coup mais qu'on ne doit pas le voir
		charge: Bool, // vrai si le joueur double son prochain coup
		solo: {x: Int,y: Int, mine: Bool}, // != null si activé
		oneUsed: Bool // true si une carte a déjà été utilisée ce tour
	};

	public var myTeam(default,null) : Team;
	var checkDone : Bool;

	var ctrl : {> flash.MovieClip,
		up : flash.MovieClip,
		down : flash.MovieClip,
		left : flash.MovieClip,
		right : flash.MovieClip
	};
	var myCount : Int;
	var oppCount : Int;
	public var justSendMove : Bool;
	var winner : Team;
	var victorySent : Bool;
	var initReceived : Bool;
	var ignoreMyTurn : Bool;
	var afterEndAnim : Void -> Void;

	public var min_x(default,null) : Int;
	public var max_x(default,null) : Int;
	public var min_y(default,null) : Int;
	public var max_y(default,null) : Int;

	//public var mc : flash.MovieClip;


	public var choosingCard : Card;
	public var noMoveTurn : Int;
	public var moveCount : Int;

	function new( mc : flash.MovieClip ) {
		//this.mc = mc;
		min_x = min_y = 0;
		max_x = max_y = Const.SIZE - 1;
		justSendMove = false;
		anim = new List();
		freeAnim = new List();
		//cards = new Array();
		myCards = new Array();
		oppCards = new Array();
		partsUp = new Array();
		partsDown = new Array();
		partsLeft = new Array();
		partsRight = new Array();
		effect = {celerite: null,confiscation: null,desordre: null,charge: null,solo: null,oppDesordre: false,oneUsed: false,hideDesordre: null};

		var mcg = mc.createEmptyMovieClip("mcg",5);
		dmanagerPower = new mt.DepthManager(mc.createEmptyMovieClip("mcp",6));

		dmanager = new mt.DepthManager(mcg);
		dmanager.attach("bg",Const.PLAN_BG);
		dmanagerBoard = new mt.DepthManager(dmanager.empty(Const.PLAN_BOARD));
		dmanagerBoard.getMC().cacheAsBitmap = true;

		noMoveTurn = 0;
		initReceived = false;
		victorySent = false;
		ignoreMyTurn = false;

		// when ready
		MMApi.lockMessages(false);
	}

	public function fruit(link,x,y,?plan:Int) {
		if( plan == null ) plan = Const.PLAN_FRUIT;
		var mc = dmanager.attach(link,plan);
		if( y != null ) {
			mc._x = x;
			mc._y = y;
			//dmanager.ysort(Const.PLAN_FRUIT);
		}
		return mc;
	}

	/*
	public function onde(link,x,y) {
		var mc = dmanager.attach(link,Const.PLAN_BOARD);
		if( y != null ) {
			mc._x = x;
			mc._y = y;
			dmanager.ysort(Const.PLAN_BOARD);
		}
		return mc;
	}
	*/

	public function initialize() {
		var team = Std.random(2) == 0;
		var grid = new Array();
		var count0 = 0;
		var count1 = 0;
		for( i in 0...Const.SIZE ){
			grid[i] = new Array();
			for( j in 0...Const.SIZE ){
				var t =
				if( count0 >= Const.START_FRUIT || count1 >= Const.START_FRUIT ){
					count0 >= Const.START_FRUIT;
				}else{
					Std.random(2) == 0;
				}
				if( !t ) count0++ else count1++;
				grid[i][j] = t;
			}
		}

		var c = new Array();
		for( i in 0...Const.START_CARD ){
			c.push( Card.random() );
		}
		return Init(team,grid,c);
	}

	public function displayBoard(){
		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				grid[i][j].display();
				grid[i][j].fruit.display();
			}
		}

		if( MMApi.hasControl() ){
			ctrl = cast dmanager.attach("controls",Const.PLAN_CONTROLS);
		}
	}

	function startControl(){
		if( !MMApi.hasControl() ) return;

		var me = this;
		ctrl.left.onRelease = function() { me.doMove(Left); }
		ctrl.right.onRelease = function() { me.doMove(Right); }
		ctrl.up.onRelease = function() { me.doMove(Up); }
		ctrl.down.onRelease = function() { me.doMove(Down); }
		ctrl.gotoAndStop(1);
	}

	function stopControl(){
		if( !MMApi.hasControl() ) return;

		Reflect.deleteField(ctrl.left,"onRelease");
		Reflect.deleteField(ctrl.right,"onRelease");
		Reflect.deleteField(ctrl.up,"onRelease");
		Reflect.deleteField(ctrl.down,"onRelease");
		ctrl.gotoAndStop(2);
	}

	public function displayCards(){
		if( cards.length > 0 ){
			var i = 0;
			for( c in cards ){
				c.pos = i++;
				c.display();
			}
			displayInfos();

		}else{
			for( c in myCards ) c.display();
			for( c in oppCards ) c.display();
		}
	}

	public function cardMyTurn(){
		for( c in myCards ) c.myTurn();
	}

	public function cardEndMyTurn(){
		for( c in myCards ) c.endMyTurn();
	}

	public function main() {
		/*
		var dir = if(flash.Key.isDown(flash.Key.UP)) Up;
			else if(flash.Key.isDown(flash.Key.DOWN)) Down;
			else if(flash.Key.isDown(flash.Key.RIGHT)) Right;
			else if(flash.Key.isDown(flash.Key.LEFT)) Left;
			else null;

		if( dir != null )
			doMove(dir);
		*/

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					anim.remove( a );
				}
			}
			if( anim.length == 0 )
				onEndAnim();
		}
		if( freeAnim.length > 0 ){
			for( a in freeAnim ){
				if( a.play() ){
					freeAnim.remove( a );
				}
			}
		}

		if(partsUp.length >=1){
			movePart("Up");
		}
		if(partsDown.length >=1){
			movePart("Down");
		}
		if(partsLeft.length >=1){
			movePart("Left");
		}
		if(partsRight.length >=1){
			movePart("Right");
		}
	}

	function doMove(dir) {
		if( !MMApi.isMyTurn() || anim.length != 0 || cards.length != 0 || justSendMove )
			return;

		justSendMove = true;

		if( choosingCard != null )
			choosingCard.cleanRoll();

		if( effect.desordre != null ){
			MMApi.lockMessages(true);
			effect.desordre.card.displayPower(null);
			dir = switch(dir){
				case Up: Down;
				case Down: Up;
				case Left: Right;
				case Right: Left;
			}
		}
		
		if( effect.celerite != null ){
			var i = switch( dir ){ case Up: 1; case Down: 2; case Left: 3; case Right: 4; }
			MMApi.sendMessage(UseCard(effect.celerite.pos,i,null));
			effect.celerite = null;
		}else{
			stopControl();
			if( effect.charge == true ){
				effect.charge = null;
				MMApi.endTurn(DoubleMove(dir));
			}else{
				MMApi.endTurn(Move(dir));
			}
		}
	}

	public function onEndAnim(){
		//displayOnde();
		if( checkDone ){
			if( afterEndAnim != null ){
				var f = afterEndAnim;
				afterEndAnim = null;
				f();
			}else{
				MMApi.lockMessages(false);
			}
		}else{
			checkVictory();
			checkBorder();
			checkVictory();
			checkDone = true;
			if( anim.length == 0 ) onEndAnim();
		}
	}

	public function onTurnDone() {
		if( MMApi.isMyTurn() == null ) return;

		if( MMApi.isMyTurn() && ignoreMyTurn ){
			ignoreMyTurn = false;
			MMApi.endTurn();
			return;
		}

		if( MMApi.isMyTurn() )
			cardMyTurn();
		else
			cardEndMyTurn();

		effect.oneUsed = false;
		if( effect.confiscation != null ){
			if( effect.confiscation.myCard == MMApi.isMyTurn() ){
				effect.confiscation.card.logLose();
				effect.confiscation.card.remove();
				effect.confiscation = null;
			}
		}

		if( cards.length > 0 )
			displayCards();
		if( MMApi.isMyTurn() ) startControl() else stopControl();

		if( cards.length == 0 ){
			var t = if( MMApi.isMyTurn() ) myTeam else opposite(myTeam);

			for( i in 0...Const.SIZE ){
				for( j in 0...Const.SIZE ){
					var g = grid[i][j];
					if( g.fruit != null ){
						if( g.fruit.team == t )
							if( MMApi.isMyTurn() ) g.fruit.myTurn() else g.fruit.wakeUp();
						else
							g.fruit.endMyTurn();
					}
				}
			}
		}

		displayInfos();
	}

	public function checkVictory(){
		if( victorySent ) return;

		var bananasCount = 0;
		var orangeCount = 0;
		var bananasStoned = 0;
		var orangeStoned = 0;
		for( i in 0...Const.SIZE ){
			for( j in 0...Const.SIZE ){
				var g = grid[i][j];
				if( g.status == Used ){
					if( g.fruit.team == Bananas ){
						bananasCount++;
						if( g.fruit.stoned ) bananasStoned++;
					}else{
						orangeCount++;
						if( g.fruit.stoned ) orangeStoned++;
					}
				}
			}
		}

		if( myTeam == Bananas ){
			myCount = bananasCount;
			oppCount = orangeCount;
		}else{
			myCount = orangeCount;
			oppCount = bananasCount;
		}

		displayInfos();

		if( bananasCount == 0 && orangeCount == 0 ){
			victory( null );
		}else if( bananasCount == 0 ){
			victory( myTeam != Bananas );
		}else if( orangeCount == 0 ){
			victory( myTeam != Orange );
		}else if( bananasCount == bananasStoned && orangeCount == orangeStoned ){
			victory( null );
		}
	}

	function displayInfos(){
		if( MMApi.isReconnecting() ) return;
		if( cards == null ) return;

		if( cards.length > 0 ){
			if( MMApi.isMyTurn() && MMApi.hasControl() ){
				MMApi.setInfos("<p>Choisissez un biscuit.</p>");
			}else{
				MMApi.setInfos("<p></p>");
			}
		}else{
			var s = "<div class=\"score0\">"+myCount+"</div><div class=\"score1\">"+oppCount+"</div>";
			if( MMApi.isMyTurn() && MMApi.hasControl() ){
				MMApi.setInfos(s+"<p>Choisissez une direction.</p>");
			}else{
				MMApi.setInfos(s+"<p></p>");
			}
		}
	}

	function victory( mine : Bool ){
		if( victorySent ) return;
		victorySent = true;
		MMApi.victory( mine );
		winner = if( mine ) myTeam else opposite(myTeam);
	}

	public function checkBorder(){
		if( winner != null ) return;

		var changed = false;

		var used : Bool;
		// check top border
		do{
			used = false;
			for( x in 0...Const.SIZE ){
				var g = grid[min_y][x];
				if( g.status == Used && !g.fruit.stoned ){
					used = true;
					break;
				}
			}
			if( !used ){
				for( x in 0...Const.SIZE ) grid[min_y][x].destroy();
				min_y++;
				genPart(min_x * (Const.CSIZE) + Const.BASEX - 5,min_y * (Const.CSIZE) + Const.BASEY - Const.CSIZE/3,(max_x-min_x)*Const.CSIZE + 15,"Up");
				changed = true;
			}
		}while( !used );

		// check bottom border
		do {
			used = false;
			for( x in 0...Const.SIZE ){
				var g = grid[max_y][x];
				if( g.status == Used && !g.fruit.stoned ){
					used = true;
					break;
				}
			}
			if( !used ){
				for( x in 0...Const.SIZE ) grid[max_y][x].destroy();
				max_y--;
				genPart(min_x * (Const.CSIZE) + Const.BASEX - 5,max_y * (Const.CSIZE) + Const.BASEY + Const.CSIZE/2,(max_x-min_x)*Const.CSIZE + Const.CSIZE - 15,"Down");
				changed = true;
			}
		}while( !used );

		// check left border
		do {
			used = false;
			for( y in 0...Const.SIZE ){
				var g = grid[y][min_x];
				if( g.status == Used && !g.fruit.stoned ){
					used = true;
					break;
				}
			}
			if( !used ){
				for( y in 0...Const.SIZE ) grid[y][min_x].destroy();
				min_x++;
				genPart(min_x * (Const.CSIZE) + Const.BASEX - 14,min_y * (Const.CSIZE) + Const.BASEY,(max_y-min_y)*Const.CSIZE + Const.CSIZE - 15,"Left");
				changed = true;
			}
		}while( !used );

		// check right border
		do {
			used = false;
			for( y in 0...Const.SIZE ){
				var g = grid[y][max_x];
				if( g.status == Used && !g.fruit.stoned ){
					used = true;
					break;
				}
			}
			if( !used ){
				for( y in 0...Const.SIZE ) grid[y][max_x].destroy();
				max_x--;
				genPart(max_x * (Const.CSIZE) + Const.BASEX + 14,min_y * (Const.CSIZE) + Const.BASEY,(max_y-min_y)*Const.CSIZE + Const.CSIZE - 15,"Right");
				changed = true;
			}
		}while( !used );

		if( changed ){
			//displayOnde();
		}
	}

	public function onVictory( mine : Bool ){
		MMApi.gameOver();
	}

	public function onReconnectDone(){
		if( MMApi.isMyTurn() ) startControl() else stopControl();
		displayInfos();
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		if( victorySent ) return;
		switch( msg ) {
		case Init(team,g,c):
			if( initReceived ){
				trace("Init received twice");
				return;
			}
			initReceived = true;
			myTeam = if( (mine || team) && !(mine && team) ) Bananas else Orange;
			grid = new Array();
			for( i in 0...Const.SIZE ){
				grid[i] = new Array();
				for( j in 0...Const.SIZE ){
					grid[i][j] = new Cell(this,if(g[i][j]) Bananas else Orange, j, i );
				}
			}
			cards = new Array();
			for( t in c ){
				cards.push( new Card(true,this,t,cards.length,null) );
			}
			if( MMApi.isMyTurn() != null ) displayCards();
			myCount = Std.int((Const.SIZE*Const.SIZE) / 2);
			oppCount = myCount;
		case Move(d):
			moveCount = 0;
			justSendMove = false;
			MMApi.lockMessages(true);
			var t = if(mine) myTeam else opposite(myTeam);

			if( effect.oppDesordre && !mine ){
				effect.oppDesordre = false;
				for( i in 0...Const.SIZE ){
				for( j in 0...Const.SIZE ){
					var g = grid[i][j];
					if( g.fruit != null ) g.fruit.cleanStars();
				}
				}
			}

			if( mine && effect.charge != null ){
				effect.charge = null;
			}

			if( effect.desordre != null && mine ){
				effect.desordre.card.remove();
				effect.desordre = null;
			}

			if( effect.hideDesordre != null && !mine ){
				var lCard = effect.hideDesordre.card;
				var me = this;
				lCard.displayPower(function(){ lCard.remove(); me.onMessage(mine,Move(d)); });
				effect.hideDesordre = null;
				return;
			}

			for( r in grid ) for( g in r ) if( g.fruit != null ) g.fruit.endMyTurn();

			if( effect.solo != null ){
				if( effect.solo.mine != mine ) throw "Solo can't apply on other player.";
				grid[effect.solo.y][effect.solo.x].move( d, t );
				effect.solo = null;
			}else{
				switch( d ){
					case Up: for( i in 0...Const.SIZE ) for( j in 0...Const.SIZE ) grid[i][j].move( d, t );
					case Down:
						var i = Const.SIZE;
						while( i >= 0 ){
							for( j in 0...Const.SIZE ) grid[i][j].move( d, t );
							i--;
						}
					case Left: for( i in 0...Const.SIZE ) for( j in 0...Const.SIZE ) grid[i][j].move( d, t );
					case Right:
						for( i in 0...Const.SIZE ){
							var j = Const.SIZE;
							while( j >= 0 ){
								grid[i][j].move( d, t );
								j--;
							}
						}
				}
			}
			checkDone = false;
			if( anim.length == 0 ){
				onEndAnim();
			}

			if( moveCount == 0 ){
				noMoveTurn++;
			}else{
				noMoveTurn = 0;
			}

			if( noMoveTurn >= 4 ){	
				victory( null );
			}

		case TakeCard(p):
			var c = cards.splice(p,1)[0];
			var t = c.type;
			c.remove();
			if( mine ){
				myCards.push(new Card(false,this,t,myCards.length,true));
			}else{
				oppCards.push(new Card(false,this,t,oppCards.length,false));
			}
			displayCards();
			if( cards.length == 0 ){
				if( !mine ) ignoreMyTurn = true;
				if( myTeam == Bananas ){
					if( MMApi.hasControl() ) MMApi.logMessage("Vous jouez les cerises.");
					MMApi.setColors( 0xFF0000, 0xFFFFFF );
				}else{
					if( MMApi.hasControl() ) MMApi.logMessage("Vous jouez les meringues.");
					MMApi.setColors( 0xFFFFFF, 0xFF0000 );
				}
				
				displayBoard();
				onTurnDone();
			}

		case UseCard(c,x,y):
			justSendMove = false;
			MMApi.lockMessages(true);
			if( mine ){
				effect.oneUsed = true;
				for( card in myCards )
					card.endMyTurn();
			}
			if( effect.confiscation != null ){
				effect.confiscation.card.remove();
				var card = if( mine ) myCards[c] else oppCards[c];
				card.pos = effect.confiscation.card.pos;
				card.mine = !card.mine;
				card.displayPowerLose();
				if( mine ) oppCards[card.pos] = card;
				else myCards[card.pos] = card;
				card.display(!mine);
				if( card.mine ) card.endMyTurn();
				effect.confiscation = null;
			}else{
				if( mine ) myCards[c].onUse( mine, x, y );
				else oppCards[c].onUse( mine, x, y );
			}
			checkDone = false;
		case DoubleMove(d):
			onMessage(mine,Move(d));
			var me = this;
			if( anim.length == 0 )
				onMessage(mine,Move(d));
			else
				afterEndAnim = function(){
					if( me.victorySent )
						MMApi.lockMessages(false);
					else
						me.onMessage(mine,Move(d));
				}
		}
	}
		public function genPart(x : Float,y : Float,length,sens) {

			if(sens == "Up"){
				for(i in 0...Const.PARTNUM){
					var part:Miette = cast dmanager.attach("miettePart",Const.PLAN_PART);
					part._x = x + Std.random(length);
					part._y = y;
					part.vit = Std.random(5)/10 + 0.3;
					part._rotation = Std.random(90);
					part._xscale = Std.random(80)+20;
					part._yscale = part._xscale;
					part.gotoAndStop(""+(Std.random(part._totalframes)+1));
					partsUp.push(part);
				}
			}

			if(sens == "Down"){
				for(i in 0...Const.PARTNUM){
					var part:Miette = cast dmanager.attach("miettePart",Const.PLAN_PART);
					part._x = x + Std.random(length);
					part._y = y;
					part.vit = Std.random(5)/10 + 0.3;
					part._rotation = Std.random(90);
					part._xscale = Std.random(80)+20;
					part._yscale = part._xscale;
					part.gotoAndStop(""+(Std.random(part._totalframes)+1));
					partsDown.push(part);
				}
			}
			if(sens == "Left"){
				for(i in 0...Const.PARTNUM){
					var part:Miette = cast dmanager.attach("miettePart",Const.PLAN_PART);
					part._x = x;
					part._y = y + Std.random(length);
					part.vit = Std.random(5)/10 + 0.3;
					part._rotation = Std.random(90);
					part._xscale = Std.random(80)+20;
					part._yscale = part._xscale;
					part.gotoAndStop(""+(Std.random(part._totalframes)+1));
					partsLeft.push(part);
				}
			}
			if(sens == "Right"){
				for(i in 0...Const.PARTNUM){
					var part:Miette = cast dmanager.attach("miettePart",Const.PLAN_PART);
					part._x = x;
					part._y = y + Std.random(length);
					part.vit = Std.random(5)/10 + 0.3;
					part._rotation = Std.random(90);
					part._xscale = Std.random(80)+20;
					part._yscale = part._xscale;
					part.gotoAndStop(""+(Std.random(part._totalframes)+1));
					partsRight.push(part);
				}
			}

		}

		public function movePart(sens){
			if(sens == "Up"){
				for( i in 0...Const.PARTNUM ){
					var p = partsUp[i];
					p._y -= p.vit;
					p._xscale -= 0.7 + Std.random(10) / 10;
					p._yscale = p._xscale;
					if( p._xscale <=1 ) {
						p.removeMovieClip();
						partsUp.splice(i--,1);
					}
				}
			}
			if(sens == "Down"){
				for( i in 0...Const.PARTNUM ){
					var p = partsDown[i];
					p._y += p.vit;
					p._xscale -= 0.7 + Std.random(10) / 10;
					p._yscale = p._xscale;
					if( p._xscale <=1 ) {
						p.removeMovieClip();
						partsDown.splice(i--,1);
					}

				}
			}
			if(sens == "Left"){
				for( i in 0...Const.PARTNUM ){
					var p = partsLeft[i];
					p._x -= p.vit;
					p._xscale -= 0.7 + Std.random(10) / 10;
					p._yscale = p._xscale;
					if( p._xscale <=1 ) {
						p.removeMovieClip();
						partsLeft.splice(i--,1);
					}

				}
			}
			if(sens == "Right"){
				for( i in 0...Const.PARTNUM ){
					var p = partsRight[i];
					p._x += p.vit;
					p._xscale -= 0.7 + Std.random(10) / 10;
					p._yscale = p._xscale;
					if( p._xscale <=1 ) {
						p.removeMovieClip();
						partsRight.splice(i--,1);
					}

				}
			}
		}

/*
		public function displayOnde(){
			// onde du haut
			onde1 = onde("onde",null,null);
			onde1.stop();
			// bas
			onde2 = onde("onde",null,null);
			onde2.stop();
			// gauche
			onde3 = onde("ondeV",null,null);
			onde3.stop();
			// droite
			onde4 = onde("ondeV",null,null);
			onde4.stop();

			// haut
			onde1._y = min_y * (Const.CSIZE) + Const.BASEY / 1.4;
			onde1._x = min_x * (Const.CSIZE) + Const.BASEX -5;
			onde1._xscale = 100 * (max_x + 1 - min_x)/ Const.SIZE;

			// bas
			onde2._y = (max_y + 1) * (Const.CSIZE) + Const.BASEY / 1.4;
			onde2._x = min_x * (Const.CSIZE) + Const.BASEX -5;
			onde2._xscale = 100 * (max_x + 1 - min_x)/ Const.SIZE;

			// gauche
			onde3._x = min_x * (Const.CSIZE) + Const.BASEX;
			onde3._y = (min_y + 1) * (Const.CSIZE);
			onde3._yscale = 100 * (max_y + 1 - min_y)/ Const.SIZE;

			// droite
			onde4._x = (max_x +1 ) * (Const.CSIZE) + Const.BASEX;
			onde4._y = (min_y + 1) * (Const.CSIZE);
			onde4._yscale = 100 * (max_y + 1 - min_y)/ Const.SIZE;
				
			freeAnim.add( new AnimFadeRemove(onde1,8,12) );
			freeAnim.add( new AnimFadeRemove(onde2,8,12) );
			freeAnim.add( new AnimFadeRemove(onde3,8,12) );
			freeAnim.add( new AnimFadeRemove(onde4,8,12) );
		}

*/

}
