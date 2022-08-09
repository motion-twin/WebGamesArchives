import mt.bumdum.Lib;
import Protocol;

class Piou extends Ball {//}

	public static var STOMACH_MODE 		= 2;


	public var fallCoef:Float;
	public var eatUpWait:Int;
	public var sens:Int;
	public var frame:Int;
	public var stomachSize:mt.flash.Volatile<Int>;

	public var ox:Float;

	public var action:Void->Void;
	public var stomach:mt.flash.PArray<Int>;



	public function new(x,y){
		super(x,y,20);
		ox = 0;
		frame = 0;
		stomach = new mt.flash.PArray();
		stomachSize = 6;
		skin.smc.stop();
		Reflect.setField(skin.smc,"$big",false);

	}


	public function init(){
		Reflect.setField(skin.smc,"$big",stomach.length);

		if(stomach.length>stomachSize){
			explode();
		}else{
			Game.me.checkEnd();
		}

		//Reflect.setField(skin,"$big",stomach.length>0);

		//Reflect.setField(skin.smc.smc,"$big",stomach.length>0);


		//setAction(control);


		/*
		if(!Game.me.checkEnd()){
			setAction(control);
		}
		*/

	}

	public function update(){
		action();
	}
	public function control(){
		var flFall = Game.me.fallList.length>0;

		if( flash.Key.isDown( flash.Key.LEFT ) )		walk(-1);
		else if( flash.Key.isDown( flash.Key.RIGHT ) )		walk(1);
		else if( flash.Key.isDown( flash.Key.DOWN ) && !flFall )		dig();
		else if( flash.Key.isDown( flash.Key.UP ) && !flFall )		initEatUp(true);
		else if( flash.Key.isDown( flash.Key.SPACE ) && !flFall )	initEatUp(false);

		// RECAL
		/*
		var dx = ox>0?1:-1;
		var next = Game.me.grid[px+dx][py];
		if( next!=null ){
			ox*=0.5;
			display(px+ox,py);
		}
		*/


	}


	// CLIMB
	public function walk(sens){


		setSens(sens);
		ox += sens*0.15;

		var flAnim = true;

		if( ox*sens > 0 ){

			if(Game.me.fallList.length==0){

				var next = Game.me.grid[px+sens][py];
				if( Cs.isOut(px+sens,py) ){
					ox = 0;
				}
				if( next.flFruit ){
					if( canEat() )eat(sens,next);
					else ox = 0;
				}
				if( Math.abs(ox) >= 0.5 ){
					ox -= sens;
					move(sens,0);
					Game.me.initFall();
				};
			}else{
				flAnim = false;
				ox = 0;
			}


		}

		display( px+ox, py );

		if( skin.smc._currentframe<10 && flAnim){
			frame = (frame+1)%8;
			skin.smc.gotoAndStop(frame+1);
		}


	}


	// STOMACH
	public function feed(fruit:Ball){



		switch(fruit.color){
			case 4 :
				Game.me.fxFlash(0xFF88FF);
				incStomach(1);

			case 5 :
				Game.me.fxFlash(0x00FFFF);

				if(stomach.length>0){
					var sc = KKApi.cmult(Cs.SCORE_FRUIT,KKApi.const(2*stomach.length));
					KKApi.addScore(sc);
					var p  = Game.me.newScore( fruit.root._x, fruit.root._y, KKApi.val(sc), 0x0000FF );
					p.vy = -3;
					stomach = new mt.flash.PArray();
					Game.me.displayStomach();
				}


			default:
				if(fruit.color>=10){
					var id = fruit.color-10;
					Game.me.fxFlash(Cs.FRUIT_COLOR[id]);
					Game.me.explodeAll(id);
					var sc = Cs.getScore(Game.me.work.length);
					var p  = Game.me.newScore( fruit.root._x, fruit.root._y, KKApi.val(sc), Cs.FRUIT_COLOR[id] );
				}else{

					if( stomach.length<stomachSize ){
						stomach.unshift(fruit.color);
					}else{
						Game.me.fxFlash(0xFF0000);
						Game.me.upc = Math.min(Game.me.upc+0.1,1);
					}
				}


		}



		fruit.kill();
		// UPDATE STOMACH
		Game.me.displayStomach();


	}

	// EAT
	public function dig(){

		var next = Game.me.grid[px][py+1];

		if( !next.flFruit || !canEat() )return;


		if(Math.abs(ox)>0.1){
			ox*=0.5;
			display(px+ox,py);
			return;
		}


		action = anim;
		coef = 0;
		spc = 0.12;

		skin.smc.gotoAndPlay("dig");
		skin.smc.smc.gotoAndStop(next.color+1);
		skin.smc.smc._xscale = sens*100;

		// KILL
		feed(next);

		// MOVE
		move(0,1);
		ox = 0;
		display(px,py);
		Game.me.initFall();

		//Game.me.checkEmpty(px,py-1);


	}
	public function eat(sens,next:Ball){

		feed(next);
		ox = 0;
		move(sens,0);

		action = anim;
		coef = 0;
		spc = 0.16;
		skin.smc.gotoAndPlay("swallow");
		skin.smc.smc.gotoAndStop(next.color+1);
		skin.smc.smc._xscale = sens*100;


		display(px,py);
		Game.me.initFall();

	}

	public function initEatUp(flBoth){
		if(Game.me.fallList.length>0 || py == 0 )return;

		if(Math.abs(ox)>0.1){
			ox*=0.5;
			display(px+ox,py);
			return;
		}


		var next = Game.me.grid[px][py-1];
		if( !next.flFruit ){
			initPoop();
			return;
		}

		if( !canEat() || !flBoth )return;


		Reflect.setField(skin.smc,"_fruit",next.color+1);
		Reflect.setField(skin.smc,"_sens",sens);


		eatUpWait = 4;
		skin.smc.gotoAndPlay("initEatUp");


		setAction(updateInitEatUp);

		ox = 0;
		display(px,py);

	}
	public function updateInitEatUp(){

		if( eatUpWait-- == 0 )startEatUp();
	}

	public function startEatUp(){
		var next = Game.me.grid[px][py-1];
		Reflect.setField(skin.smc,"_fruit",next.color+1);
		skin.smc.gotoAndPlay("eatUp");
		feed(next);
		eatUpWait = 6;
		setAction(eatUp);
		Game.me.initFall();

	}
	public function eatUp(){
		//trace("A"+eatUpWait);
		if( eatUpWait-- == 0 ){
			if( flash.Key.isDown( flash.Key.UP ) && Game.me.grid[px][py-1].flFruit && canEat() ){
				startEatUp();
			}else{
				eatUpWait = null;
				skin.smc.gotoAndPlay("endEatUp");
				init();
			}

		}
	}

	// STOMACH
	public function incStomach(inc){
		stomachSize += inc;
		while( stomach.length > stomachSize )stomach.pop();
		Game.me.displayJauge();
		Game.me.displayStomach();

	}

	// POOP
	public function initPoop(){
		if(stomach.length==0 || py<=0 )return;
		setAction(poop);

	}
	public function poop(){

		move(0,-1);
		display(px,py);

		var color = stomach.pop();
		var ball = new Ball(px,py+1);
		ball.setColor(color);
		Game.me.displayStomach();


		skin.gotoAndStop(1);
		skin.gotoAndStop(21);
		Reflect.setField(skin.smc,"$big",stomach.length);
		skin.smc.gotoAndPlay("windUp");

		if(stomach.length==0 || py<=0){
			Game.me.checkCombo();
			skin.smc.play();
			init();
			//root.smc.gotoAndStop(1);
			//init();
		}


	}

	//
	public function canEat(){
		return true;
		return stomach.length<stomachSize;
	}
	//
	public function anim(){
		coef += spc;
		if(coef>=1){
			skin.smc.gotoAndStop(1);
			init();
		}
	}
	public function setSens(n){
		sens = n;
		root._xscale = sens*100;
	}

	public function setAction(f){
		action = f;
	}

	public function explode(){
		var mc = Game.me.dm.attach( "piouExplode", Game.DP_PIOU );
		mc._x = root._x;
		mc._y = root._y;
		setAction(null);
		//Game.me.initGameOver();
		//KKApi.gameOver({});
		kill();
	}


	#if prod
	public function insertInGrid(){
		super.insertInGrid();
		//trace("pioupiou["+px+","+py+"]");
	}
	#end
//{
}











