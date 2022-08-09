import mt.bumdum.Lib;
import mt.bumdum.Trick;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Plasma;

enum Msg {
	Init(a:Array<Array<Int>>,seed:Int);
	Card(type:Int,power:Int,x:Int,y:Int);
}
enum Step{
	Play;
	Wait;
	View;
	GameOver;
}


class Game implements MMGame<Msg> {//}


	static public var DP_BG = 0;
	static public var DP_CARDS = 2;
	static public var DP_PARTS = 3;

	var flVictory:Bool;
	var flMain:Bool;
	var pid:Int;
	var cid:Int;
	var playCount:Int;

	var handCoef:Float;
	var coef:Float;
	var selection:Card;

	var step:Step;
	public var grid:Array<Array<Card>>;
	public var hand:Array<Card>;

	public var buts:Array<flash.MovieClip>;

	public var bg:flash.MovieClip;
	static public var me:Game;
	public var root:flash.MovieClip;
	public var dm : mt.DepthManager;


	function new( mc : flash.MovieClip ) {

		haxe.Log.setColor(0xFFFFFF);

		me = this;
		root = mc;
		dm = new mt.DepthManager(mc);
		bg = dm.attach("mcBg",DP_BG);
		MMApi.lockMessages(false);

	}


	// LOOP
	public function main() {

		//haxe.Log.clear();

		switch(step){
			case Play : updatePlay();
			case View : updateView();
			case GameOver : updateGameOver();
			default:
		}


		updateSprites();
		updateHandAnim();

	}
	function updateSprites(){
		var a = mt.bumdum.Sprite.spriteList.copy();
		for( sp in a )sp.update();
	}

	function initPlay(){
		if( playCount == Cs.CARD_MAX*2 ){
			initGameOver();
			return;
		}

		if( MMApi.hasControl() && !MMApi.isReconnecting() && MMApi.isMyTurn() ){
			step = Play;
			initInterface();
			updateInfos(0);
		}else{
			step  = Wait;
		}


	}
	function initInterface(){
		for( c in hand )c.active();
	}

	function updatePlay(){

		if(selection!=null){
			selection.fxSpark();
		}

	}

	public function selectCard(c:Card){
		c.rout();
		selection = c;
		updateInfos(1);
		for( b in buts )b._visible = true;
	}
	public function selectSlot(x,y){
		for( c in hand )c.unactive();
		for( b in buts )b._visible = false;
		MMApi.endTurn( Card(selection.type,selection.power,x,y) );
		removeSlotSelection();
	}
	/*
	function cancelCard(){
		removeSlotSelection();
		for( c in hand )c.active();
	}
	*/

	function removeSlotSelection(){
		for( c in hand )c.rout();
		selection = null;
		Trick.butKill(bg);
		for( b in buts )b._visible = false;
	}

	// VIEW
	function playCard(card:Card,x,y){
		selection = card;
		if( MMApi.isReconnecting() ){
			card.insertInGrid(x,y);
			ativeCard();
			return;
		}

		MMApi.lockMessages(true);
		step = View;
		coef = 0;
		card.goto(x,y);
		card.insertInGrid(x,y);
	}
	function updateView(){

		coef = Math.min(coef+0.1*mt.Timer.tmod,1);
		selection.updatePos(coef);
		if( coef == 1 ){
			ativeCard();
			MMApi.lockMessages(false);

		}
	}
	function ativeCard(){
		playCount++;
		step = Wait;
		selection.convert();
		selection = null;
		updateInfos();

	}


	// BOARD
	function initBoard(){
		grid = [];
		buts = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				var mc = dm.attach("mcBut",DP_BG);
				mc._x = Cs.getX(x);
				mc._y = Cs.getY(y);
				buts.push(mc);
				mc._visible = false;
				if(MMApi.hasControl()){
					mc.smc.onPress = callback(selectSlot,x,y);
				}
			}
		}

		// BOARD
		var mc = dm.attach("mcBoard",DP_BG);
		mc._y = Cs.mch;
		mc.gotoAndStop(pid+1);

		// BUTS


	}

	// HAND
	function launchHandAnim(){
		handCoef = 0.0;
		var ma = 15.0;
		var ec = (Cs.mcw-(hand.length*Cs.CARD_WIDTH+2*ma)) / (hand.length-1) ;
		ec = Math.min( ec, 16 );

		ma = ( Cs.mcw - ( hand.length*Cs.CARD_WIDTH + (hand.length-1)*ec ))*0.5;

		var id = 0;
		for( c in hand ){



			c.gotoHandPos( ma+(Cs.CARD_WIDTH+ec)*id );
			id++;
		}
	}
	function updateHandAnim(){
		handCoef = Math.min(handCoef+mt.Timer.tmod*0.1,1);

		var coef = 0.5-Math.cos(handCoef*3.14)*0.5;

		for( c in hand ){

			c.updatePos(coef);
		}


	}

	// BUTTONS
	public function removeBut(x,y){
		buts[x*Cs.YMAX+y].removeMovieClip();
	}
	public function getBut(x,y){
		return buts[x*Cs.YMAX+y];
	}

	// GAMEOVER
	function initGameOver(){
		MMApi.victory(flVictory);
		step = GameOver;
		coef = 0;
	}
	function updateGameOver(){
		coef += 0.02*mt.Timer.tmod;

		if( coef >= 1 ){
			MMApi.gameOver();
		}
	}

	// PROTOCOLE
	public function initialize() {
		var list = [];
		var types = [];
		for( i in 0...3 )list.push([]);

		for( i in 0...Cs.CARD_MAX  )types.insert(Std.random(types.length+1),i%3);



		for( i in 0...Cs.CARD_MAX ){
			var type = types[i];
			for( a in list ){
				type = (type+1)%3;
				a.push(type);
			}
		}

		return Init(list,Std.random(100000));
	}
	public function onVictory(v) {
	}
	public function onReconnectDone() {
		initPlay();
	}
	public function onTurnDone() {
		initPlay();
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
			case Init(a,n):
				flMain = mine;
				if( flMain) MMApi.setColors( Cs.COLORS[0], Cs.COLORS[1] ); else MMApi.setColors( Cs.COLORS[1], Cs.COLORS[0] );
				pid = flMain?0:1;
				cid = 1;
				playCount = 0;

				initBoard();

				// GEN BOARD CARDS
				var seed = new mt.Rand(n);
				var pos = [];
				for( x in 0...Cs.XMAX )for( y in 0...Cs.YMAX )	pos.push({x:x,y:y});
				var power = 0;


				for( n in a[0] ){
					var index = seed.random(pos.length);
					var p = pos[index];
					pos.splice(index,1);
					var color = ( power == 5 )?1:2;
					var card = new Card(n,color,power);
					card.insertInGrid(p.x,p.y);
					power++;
				}

				// GEN HAND CARDS
				hand = [];
				var power = 0;
				for( n in a[pid+1] ){
					var card = new Card(n,pid,power);
					var m = 4;
					card.root._x = m;
					card.root._y = Cs.HAND_Y;
					power++;
					hand.push(card);
					if( !MMApi.hasControl() )card.hide();
				}
				launchHandAnim();
				updateInfos();
				initPlay();

			case Card(type,power,x,y):

				step = View;


				var card = null;
				if( mine ){
					card = getCard( type, power );
					hand.remove(card);
					launchHandAnim();
					if( !MMApi.hasControl() )card.applySkin();
				}else{
					card = new Card(type, 1-pid , power);
					card.root._x = Cs.mcw*0.5 - Cs.CARD_WIDTH*0.5;
					card.root._y = -Cs.CARD_HEIGHT;
				}



				playCard(card,x,y);






		}
	}

	function getCard(type, power){
		for( c in hand ){
			if( c.type == type && c.power == power ) return c;
		}
		trace("CARD NOT FOUND!!!");
		return null;
	}

	// INFOS
	public function updateInfos(?phase){
		var str = "";

		var myCount = 0.0;
		var oppCount = 0.0;

		var myBonus = 0;
		var oppBonus = 0;


		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var card = grid[x][y];
				if( card.color == pid ){
					myCount++;
					myBonus += card.power+1;
				}
				if( card.color == 1-pid ){
					oppCount++;
					oppBonus += card.power+1;
				}



			}
		}

		if( myCount != null && oppCount != null ){
			str += "<div class=\"score0\">"+myCount+" ("+myBonus+")</div>";
			str += "<div class=\"score1\">"+oppCount+" ("+oppBonus+")</div>";
		}


		if( step==Play ){
			switch(phase){
				case 0 :	str += "<p>Choisissez une carte élément.</p>";
				case 1 :	str += "<p>Placez la carte sur le plateau.</p>";
				default :
			}

		}

		flVictory = null;
		myCount += myBonus*0.01;
		oppCount += oppBonus*0.01;
		if( myCount != oppCount )flVictory = myCount > oppCount;


		MMApi.setInfos(str);
	}


	// PLAY
	// MMApi.hasControl();
	// MMApi.isReconnecting()
	// MMApi.victory(true/false);
	// newTurn();




//{
}
