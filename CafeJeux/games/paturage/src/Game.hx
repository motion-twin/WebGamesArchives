import mt.bumdum.Lib;
import mt.bumdum.Trick;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Plasma;

enum Msg {
	Init(n:Int);
	Spawn(x:Int,y:Int);
	Move(x:Int,y:Int,dir:Int);
}
enum Step{
	Play;
	Wait;
	Summon;
	View;
	GameOver;
}

typedef Square = { >flash.MovieClip, herb:Int, sheep:Sheep, dm:mt.DepthManager, x:Int, y:Int };

class Game implements MMGame<Msg> {//}


	static public var DP_BG = 	0;
	static public var DP_SQUARES = 	2;
	static public var DP_SHADE = 	3;
	static public var DP_SHEEPS = 	4;
	static public var DP_PARTS = 	5;

	var flDoubleSheep:Bool;
	var flBonusMove:Bool;
	var flFirstTurn:Bool;
	var flVictory:Bool;
	var flMain:Bool;
	var cid:Int;
	var pid:Int;
	var move:Int;

	var step:Step;
	var coef:Float;
	var shake:Float;

	var myScore:Int;
	var oppScore:Int;
	var maxScore:Int;
	var moveMax:Int;

	//public var grid:Array<Array<Square>>;
	public var squares:Array<Square>;
	public var sheeps:Array<Sheep>;
	public var elements:Array<flash.MovieClip>;

	var sheep:Sheep;
	var ghost:flash.MovieClip;
	var ghost2:flash.MovieClip;
	var secondSheep:Square;

	public var bg:flash.MovieClip;
	static public var me:Game;
	public var root:flash.MovieClip;
	public var dm : mt.DepthManager;
	public var sdm : mt.DepthManager;


	function new( mc : flash.MovieClip ) {
		Cs.init();
		haxe.Log.setColor(0xFFFFFF);
		me = this;
		root = mc;
		dm = new mt.DepthManager(mc);
		bg = dm.attach("mcBg",DP_BG);

		elements = [];

		MMApi.lockMessages(false);



	}


	// LOOP
	public function main() {

		switch(step){
			case Play : updatePlay();
			case View : updateMove();
			case Summon : updateSpawn();
			case GameOver : updateGameOver();
			default:
		}

		updateSprites();
		updateShake();
		updateElements();

	}
	function updateSprites(){
		var a = mt.bumdum.Sprite.spriteList.copy();
		for( sp in a )sp.update();
	}

	// PLAY
	function initPlay(?flNewTurn){

		if( flNewTurn ){
			for( sh in sheeps ){
				if(sh.pid==cid){
					var sq = getSq(sh.x,sh.y);
					eat(sq);
				}
			}
		}

		// CHECK END

		var sum = 0;
		for(sq in squares )sum += sq.herb;
		if( sum == 0 ){
			initGameOver();
			return;
		}



		if( move==null &&  MMApi.isMyTurn() ){
			move = 0;
			moveMax = 3;
			if( !flMain &&  flBonusMove )moveMax+=2;
		}

		// INFOS
		updateInfos();


		if( MMApi.hasControl() && !MMApi.isReconnecting() && MMApi.isMyTurn() ){
			flFirstTurn = false;
			step = Play;
			initInterface();
			if(sheep!=null){
				selectSheep( getSq(sheep.x,sheep.y) );
			}

		}else{
			step  = Wait;
		}


	}
	function updatePlay(){

	}

	// INTERFACE
	function initInterface(){

		for( sq in squares ){
			if( move <= 0 && sq.sheep == null )	Trick.butAction(sq,callback(summonSheep,sq),callback(showSummon,sq),callback(hideSummon,sq));
			if( sq.sheep.pid == pid )		Trick.butAction(sq,callback(clickSheep,sq),callback(showSelect,sq),callback(hideSelect,sq));

		}

	}
	function removeInterface(){
		for( sq in squares ){
			Col.setColor(sq,0,0);
			Trick.butKill(sq);
		}
	}

	// INTER SUMMON
	function summonSheep(sq){
		if(flDoubleSheep){
			if( secondSheep==null ){
				ghost.removeMovieClip();
				return;
			}
			flDoubleSheep = false;
			MMApi.sendMessage(Spawn(secondSheep.x,secondSheep.y));
			secondSheep = null;
			ghost2.removeMovieClip();
		}
		MMApi.endTurn(Spawn(sq.x,sq.y));
		ghost.removeMovieClip();
		removeInterface();
	}
	function showSummon(sq:Square){
		ghost = newGhost(sq);
		if(flDoubleSheep){
			var dx = sq._xmouse - Cs.SIZE*0.5;
			var dy = sq._ymouse - Cs.SIZE*0.5;

			var dir = null;
			if( Math.abs(dx) > Math.abs(dy) )	dir = dx>0?0:2;
			else					dir = dy>0?1:3;

			var d = Cs.DIR[dir];
			var nsq = getSq( sq.x+d[0], sq.y+d[1] );
			secondSheep = null;
			if(nsq.sheep==null){
				ghost2 = newGhost(nsq);
				secondSheep = nsq;
			}

		}
	}
	function hideSummon(sq:Square){
		ghost.removeMovieClip();
		ghost2.removeMovieClip();
	}
	function newGhost(sq:Square){
		var mc = sq.dm.attach("mcSheep",0);
		mc._x = Cs.SIZE*0.5;
		mc._y = Cs.SIZE*0.5;
		mc._alpha = 50;
		mc.gotoAndStop(pid+1);
		mc.smc.stop();
		return mc;
	}

	// INTER SELECT
	function clickSheep(sq:Square){
		hideSelect(sq);
		removeInterface();
		if( sq.sheep == sheep ){
			sheep = null;
			initInterface();
		}else{
			selectSheep(sq);
		}
	}
	function selectSheep(sq:Square){
		sheep = sq.sheep;
		// DEPLACEMENT
		for( dir in 0...4 ){
			var d = Cs.DIR[dir];
			var nx = sq.x+d[0];
			var ny = sq.y+d[1];
			var nsq = getSq(nx,ny);
			if( nsq.sheep == null ){
				Col.setColor(nsq,0,20);
				Trick.butAction(nsq,callback(moveSheep,sq,dir),callback(showMove,nsq),callback(hideMove,nsq));
			}
		}

		// CANCEL
		for( sh in sheeps ){
			var sq = getSq(sh.x,sh.y);
			if( sq.sheep.pid == pid )Trick.butAction(sq,callback(clickSheep,sq),callback(showSelect,sq),callback(hideSelect,sq));
		}

	}
	function showSelect(sq){
		Col.setColor(sq.sheep.root,0,20);
		Filt.glow(sq.sheep.root,10,1,0xFFFFFF);
	}
	function hideSelect(sq){
		Col.setColor(sq.sheep.root,0,0);
		sq.sheep.root.filters = [];
	}

	// INTER MOVE
	function moveSheep(sq,dir){
		var msg = Move(sq.x,sq.y,dir);
		removeInterface();
		move++;
		flBonusMove = false;
		if( move < moveMax)	MMApi.sendMessage(msg);
		else			MMApi.endTurn(msg);
	}
	function showMove(sq){
		Col.setColor(sq,0,60);

	}
	function hideMove(sq){
		Col.setColor(sq,0,30);
	}

	// SPAWN
	function spawnSheep(x,y,id){

		var sheep = new Sheep(x,y,id);
		if( !MMApi.isReconnecting() ){
			sheep.fxLand();
			MMApi.lockMessages(true);
			step = Summon;
			coef = 0;
		}else{
			dig(x,y);
		}

	}
	function updateSpawn(){
		coef = Math.min(coef+0.1*mt.Timer.tmod,1);
		if(coef==1){

			step = Wait;
			MMApi.lockMessages(false);
		}
	}

	function dig(x,y){
		var sq = getSq(x,y);
		sq.herb = 0;
		sq.gotoAndStop(1+Cs.HERB_MAX-sq.herb);
	}

	// MOVE
	function initMove(sheep:Sheep, dir){
		MMApi.lockMessages(true);
		sheep.move(dir);
		coef = 0;
		step = View;

	}
	function updateMove(){
		coef = Math.min(coef+0.08*mt.Timer.tmod,1);
		if(coef==1){
			sheep.endAnim();
			eat(getSq(sheep.x,sheep.y));

			if( move<moveMax && MMApi.isMyTurn() ){

			}else{
				sheep = null;
				move = null;
				step = Wait;
			}
			initPlay();
			MMApi.lockMessages(false);
		}
	}
	function eat(sq:Square){
		if(sq.herb>0){
			sq.herb--;
			sq.gotoAndStop(1+Cs.HERB_MAX-sq.herb);
			if(pid == sq.sheep.pid )	myScore++;
			else				oppScore++;
			updateInfos();
			sq.sheep.graze();

			var p = new mt.bumdum.Phys(dm.attach("fxScore",DP_PARTS));
			p.x = sq.sheep.root._x;
			p.y = sq.sheep.root._y - Cs.SIZE*0.5;
			p.vy = -0.25;
			p.timer = 40;
			cast (p.root)._value = "+"+1;


		}
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

	// BOARD
	function initBoard(n){
		squares = [];
		var seed = new mt.Rand(n);
		for( x in 0...Cs.GSIZE ){
			for( y in 0...Cs.GSIZE ){
				var mc:Square = cast Game.me.dm.attach("mcSquare",DP_SQUARES);
				mc.herb = 1+seed.random(Cs.HERB_MAX);
				mc.dm = new mt.DepthManager(mc);
				mc._x = Cs.getX(x);
				mc._y = Cs.getY(y);
				mc.x = x;
				mc.y = y;
				mc.gotoAndStop(Cs.HERB_MAX+1-mc.herb);
				squares[x*Cs.GSIZE+y] = mc;
			}
		}

		maxScore = 0;
		for( sq in squares )maxScore+=sq.herb;

		// SHADE
		var mcShade = dm.empty(DP_SHADE);
		mcShade.blendMode = "layer";
		mcShade._alpha = 20;
		sdm = new mt.DepthManager(mcShade);

	}

	// ELEMENTS
	function updateElements(){
		var f = function(a:flash.MovieClip,b:flash.MovieClip){
			if(a._y <b._y)return -1;
			return 1;
		}
		elements.sort(f);
		var a = elements.copy();
		for( mc in a )dm.over(mc);
	}

	// FX
	public function fxShake(px:Int,py:Int){

		var x = Cs.getX(px+0.5);
		var y = Cs.getY(py+0.5);

		root._y = 70;
		var max = 32;
		var cr = 3;
		for( i in 0...max ){
			var a = i/max * 6.28;
			var speed = 0.5+Math.random()*2;
			var ca = Math.cos(a)*speed;
			var sa = Math.sin(a)*speed;
			var vz = -(4+Math.random()*10);

			var p = new Part(dm.attach("partDirt",DP_SHEEPS));
			p.x = x + ca*cr;
			p.y = y + sa*cr;
			p.z = vz*cr;
			p.vx = ca - Math.random()*4;
			p.vy = sa;
			p.vz = vz;
			p.zw = (0.5+Math.random()*0.5);
			p.timer = 10+Math.random()*60;
			p.bounceFrict = 0.6;
			p.ray = 4;
			p.dropShadow();
			p.updatePos();
			p.fadeType = 0;

			p.frict = 0.95;
			p.setScale(50+Math.random()*100);

		}


		for( i in 0...6 ){
			var p = new mt.bumdum.Phys( dm.attach("mcDust",DP_PARTS) );
			p.x = x + ( Math.random()*2-1 )*20;
			p.y = y ;
			p.weight = -(0.05+Math.random()*0.3);
			p.vr = (Math.random()*2-1)*18;
			p.root._rotation = Math.random()*360;
			p.fr = 0.95;
			p.frict = 0.92;
			p.vx = -Math.random()*14;

			p.updatePos();
			p.timer = 10+Math.random()*20;
		}

		// VIRE HERB
		dig(px,py);

	}
	function updateShake(){
		if(root._y==0)return;
		root._y = -root._y*0.5;
		if(Math.abs(root._y)< 1)root._y = 0;

	}

	// PROTOCOLE
	public function initialize() {

		return Init(Std.random(10000));
	}
	public function onVictory(v) {

	}
	public function onReconnectDone() {
		initPlay();
	}
	public function onTurnDone() {
		if(flMain==null)return;

		cid = 1-cid;
		initPlay(true);
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
			case Init(n):
				flMain = mine;
				if( flMain) MMApi.setColors( Cs.COLORS[0], Cs.COLORS[1] ); else MMApi.setColors( Cs.COLORS[1], Cs.COLORS[0] );
				sheeps = [];

				pid = flMain?0:1;
				//flDoubleSheep = !flMain;
				flBonusMove = !flMain;

				cid = 0;
				myScore = 0;
				oppScore = 0;
				updateInfos();

				initBoard(n);
				flFirstTurn = true;

				/*
				var startPos = [[1,1],[3,1],[3,3],[1,3]];
				for( i in 0...4 ){
					var p = startPos[i];
					var sheep = new Sheep( p[0], p[1], i%2 );
				}
				*/


				initPlay();

			case Spawn(x,y):
				spawnSheep(x,y,mine?pid:(1-pid) );

			case Move(x,y,dir):
				sheep = getSq(x,y).sheep;
				initMove( sheep, dir );

		}
	}

	// GET
	public function getSq(x,y){
		if( x<0 || x>=Cs.GSIZE || y<0 || y>=Cs.GSIZE ) return null;
		return squares[x*Cs.GSIZE+y];

	}

	// INFOS
	public function updateInfos(){
		var str = "";

		str += "<div class=\"score0\">"+myScore+"</div>";
		str += "<div class=\"score1\">"+oppScore+"</div>";

		if( MMApi.isMyTurn() && MMApi.hasControl()  ){

			//str+="<p>move("+move+")</p>";
			if(flFirstTurn){
				if( flDoubleSheep ){
					str +="<p>Placez vos deux premiers moutons</p>";
				}else{
					str +="<p>Placez votre premier mouton</p>";
				}
			}else if( move==0 ){
				str +="<p>Placez un nouveau mouton.</p>";
				str +="<p>DÈplacez un mouton.</p>";
			}else{
				var n = moveMax-move;
				var s = "";
				if(n>1)s="s";
				str +="<p>DÈplacez un mouton<br/>il vous reste "+n+" mouvement"+s+"</p>";
			}
		}


		flVictory = null;
		if(myScore!=oppScore)flVictory = myScore > oppScore;

		MMApi.setInfos(str);
		//MMApi.setInfos("<p>Choisissez votre point de d√©part.</p>")


	}


	// ENLEVER LE SPAWN SUR CHIFFRE NEGATIF



//{
}





























