import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Plasma;

enum Msg {
	Init(a:Array<Array<Int>>);
	Shoot(a:Int,power:Int,Pos:Array<Array<Float>>);
}
enum Step{
	Play;
	Wait;
	View;
}

class Game implements MMGame<Msg> {//}

	static public var DP_BG = 0;
	static public var DP_SHADOW = 1;
	static public var  DP_BOARD = 2;
	static public var DP_BALL = 3;
	static public var DP_PARTS = 8;

	public var flMain:Bool;
	public var flGameOver:Bool;
	public var currentColor:Int;
	public var passiveColor:Int;
	var gameOverTimer:Float;
	var tmc:Float;
	var angle:Float;
	var power:Float;
	var checkTimer:Float;
	var loop:Int;

	public var colors:Array<Int>;
	public var scores:Array<Int>;

	var step:Step;
	var hero:Ball;
	public var phys:Physics<Ball>;
	public var bg:flash.MovieClip;
	public var mcShadow:flash.MovieClip;
	public var mcArrow:flash.MovieClip;
	public var plasma:Plasma;

	//public var mainUpdate:Void->Void;
	static public var me:Game;
	public var root:flash.MovieClip;
	public var dm : mt.DepthManager;
	public var sdm : mt.DepthManager;

	function new( mc : flash.MovieClip ) {

		haxe.Log.setColor(0xFFFFFF);

		me = this;
		root = mc;
		dm = new mt.DepthManager(mc);
		MMApi.lockMessages(false);

		flGameOver = false;
		colors = [0x00BB00,0x8800CC];
		scores = [0,0];

	}

	// INIT
	function initDecor(){
		bg = dm.attach("bg",DP_BG);

		mcShadow = dm.empty(DP_SHADOW);
		mcShadow.blendMode = "normal";
		mcShadow._alpha = 40;
		sdm = new mt.DepthManager(mcShadow);

		var board =  dm.attach("mcBoard",DP_BOARD);
		//board._alpha = 50;

		// PLASMA
		/*
		plasma = new Plasma(dm.empty(DP_PARTS),Cs.mcw,Cs.mch,0.5);
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 4;
		fl.blurY = 4;
		plasma.filters.push(fl);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,-10,-20,-5,-10);
		plasma.root.blendMode = "add";
		*/


	}
	function initPhys(a:Array<Array<Int>>){

			var m = 0;
			var m2 = 14;

			phys = new Physics<Ball>(0.97,1.1,{ xMin : m, yMin : m, xMax : 300-m, yMax : 300-m2 });
			var i = 0;
			for( p in a ){
				var ball = new Ball();
				ball.x = p[0];
				ball.y = p[1];
				phys.objs.push(ball);

				var color = 0;
				if( i==0 ){
					color = 3;
					hero = ball;
				}else if( i<=Cs.HANDICAP ){
					color = 2;
				}

				ball.setColor( color );
				i++;
			}
			for( b in phys.objs )b.update();
	}

	// LOOP
	public function main() {
		//MMApi.print(phys.getEnergy());

		if(flGameOver){
			if(gameOverTimer==null)gameOverTimer = 50;
			gameOverTimer -= mt.Timer.tmod;
			if(gameOverTimer<=0){
				flGameOver = false;
				MMApi.gameOver();
			}

		}


		switch(step){
			case Play : updatePlay();
			case View : updateView();
			default:
		}

		var list = Sprite.spriteList.copy();
		for( sp in list )sp.update();

		//plasma.update();


	}

	// PLAY
	function initPlay(){

		step = Play;

		if( MMApi.hasControl() && !MMApi.isReconnecting() ){
			initInterface();
		}





	}
	function initInterface(){
		bg.onRelease = shoot;
		bg.onReleaseOutside = shoot;
		bg.useHandCursor = true;



		mcArrow = dm.attach("mcArrow",DP_BALL);
		mcArrow._x = hero.x;
		mcArrow._y = hero.y;
		Game.me.dm.over(Game.me.hero.root);

		Filt.glow(mcArrow,10,2,colors[currentColor-1]);
		mcArrow.blendMode = "add";

		var mc = Game.me.hero.root;
		mc.blendMode = "add";
		Filt.glow(mc,10,2,colors[currentColor-1]);


	}
	function removeInterface(){
		mcArrow.removeMovieClip();
		Reflect.deleteField(bg,"onRelease");
		bg.useHandCursor = false;
		Game.me.hero.root.filters = [];
		Game.me.hero.root.blendMode = "normal";
	}

	function updatePlay(){

		var dx = hero.root._xmouse;
		var dy = hero.root._ymouse;
		angle = Math.atan2( dy, dx );
		power = Math.min(Math.sqrt(dx*dx+dy*dy)/100,1);

		mcArrow._xscale = power*100;
		mcArrow._rotation = angle/0.0174;


	}
	function shoot(){
		removeInterface();
		var angle = Std.int(angle*10000);
		var power = Std.int(power*10000);

		var pos = [];
		for(o in phys.objs )pos.push([o.x,o.y]);

		MMApi.endTurn(Shoot(angle,power,pos));
	}
	function shootBall(angle:Float,power:Float){


		power *= 26;
		hero.dx = Math.cos(angle)*power;
		hero.dy = Math.sin(angle)*power;

		phys.start();
		step = View;
		tmc = 0;
		loop = 0;

		MMApi.lockMessages(true);

	}

	// VIEW
	function updateView(){

		tmc += mt.Timer.tmod;


		//
		while(tmc>=1){
			tmc--;
			loop++;
			phys.update(1);
			for( b in phys.objs )b.update();
			var e = phys.getEnergy();
			if( e < 0.5 ){
				phys.stopAll();
				step = Wait;
				MMApi.lockMessages(false);
				break;
			}
		}



	}
	function newTurn(){





		var cc = currentColor;
		currentColor = passiveColor;
		passiveColor = cc;

		//Filt.glow(hero.root,10,2,colors[currentColor-1]);
		//Col.setColor( hero.root,colors[currentColor-1], -50 );

		if(MMApi.isMyTurn()){
			initPlay();
		}




	}

	// SCORE
	public function incScore(n){

		// SCORE BALL
		var sens = n*2-1;
		var mc = dm.attach( "mcScoreBall", DP_BOARD );
		var mid = Cs.mcw*0.5;
		mc._x = mid + (mid-(10+scores[n]*10))*sens;
		mc._y = Cs.mch-7;
		mc._visible = MMApi.isReconnecting();
		Col.setColor(mc.smc,colors[n],-180);
		Filt.glow(mc,2,4,0x384D69);



		//
		scores[n]++;

		//
		if( scores[n] == Cs.BALL_VICTORY ){
			if( flMain ){
				MMApi.victory(n==0);
			}else{
				MMApi.victory(n==1);
			}
			flGameOver = true;
		}

		return mc;
	}


	// PROTOCOLE
	public function initialize() {
		var a = [];
		var m = Ball.RAY+10;
		for( i in 0...Cs.BALL_MAX ){
			var x,y;
			while(true){
				var flBreak = true;
				x = m+Std.random(Cs.mcw-2*m);
				y = m+Std.random(Cs.mcw-(2*m+8));
				for( p in a ){
					var dx = p[0]-x;
					var dy = p[1]-y;
					if( Math.sqrt(dx*dx+dy*dy) < Ball.RAY*2 ){
						flBreak = false;
						break;
					}
				}
				if(flBreak)break;
			}
			a.push([x,y]);
		}
		return Init(a);
	}
	public function onVictory(v) {
	}
	public function onReconnectDone() {

		//trace("reconnectDone! ("+(step==Play)+";"+(MMApi.hasControl())+")");
		if( step==Play && MMApi.hasControl() ){

			initInterface();
		}
	}
	public function onTurnDone() {
		if(step!=null)newTurn();

	}


	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
			case Init(a):

				initDecor();

				// OPP
				flMain = mine;
				if(flMain) MMApi.setColors( colors[0], colors[1] ); else MMApi.setColors( colors[1], colors[0] );

				// PHYS
				initPhys(a);

				currentColor = 1;
				passiveColor = 2;

				if(flMain){
					initPlay();
				}
				//Filt.glow(hero.root,10,2,colors[currentColor-1]);
				//Col.setColor( hero.root,colors[currentColor-1], -50 );

			case Shoot(angle,power,pos):

				/*
				haxe.Log.clear();
				trace("checkSum:"+checkSum);
				if(step==Wait)trace("step:Wait");
				else if(step==Play)trace("step:Wait");
				else trace("step:Other");
				var ics = getCheckSum();
				var dif= Math.abs(checkSum - ics);
				if(  dif > 0.000000000001 )trace("ERROR interne:"+dif);
				*/

				var i = 0;
				var dif = 0.0;
				for(o in phys.objs){
					var p = pos[i];
					o.x = p[0];
					o.y = p[1];
					i++;
					dif+=Math.abs(p[0]-o.x)+Math.abs(p[1]-o.y);
					if(dif>2){
						//Filt.blur(root,20,20);
						Col.setColor(root,0xFF0000,-100);
					}
				};
				if(dif>0){
					haxe.Log.clear();
					trace("DIF:"+dif);
				}


				shootBall(angle/10000,power/10000);
		}
	}

	// DEBUG
	public function getCheckSum(){
		var checkSum:Float = 0;
		for( o in phys.objs )checkSum += o.x+o.y;
		checkSum = Std.int(checkSum*10000);
		return checkSum;
	}




//{
}
