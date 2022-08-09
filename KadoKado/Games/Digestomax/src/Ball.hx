import mt.bumdum.Lib;
import Protocol;

class Ball {//}

	public var flIce:Bool;
	public var flFruit:Bool;

	public var gid:Int;
	public var color:Int;
	public var fallAmount:Int;

	public var px:Int;
	public var py:Int;

	public var fc:Float;

	public var coef:Float;
	public var spc:Float;


	public var root:flash.MovieClip;
	public var skin:flash.MovieClip;
	public var dm:mt.DepthManager;

	public var mcArrow:flash.MovieClip;


	public function new(x,y,?col){

		root = Game.me.dm.empty(Game.DP_BALLS);
		Game.me.dm.over(Game.me.hero.root);

		dm = new mt.DepthManager(root);
		skin = dm.attach("mcBall",0);

		Game.me.balls.push(this);
		setPos(x,y);
		setColor(col);

	}

	public function setPos(x,y){
		px = x;
		py = y;
		insertInGrid();
		display(px,py);
	}
	public function display(x,y){
		root._x = Cs.getX(x);
		root._y = Cs.getY(y);
	}
	public function setColor(?col){

		if(col==null){
			col = Std.random(Cs.COLOR_MAX);

			if(Game.me.lvl>1){
				// FLASH
				if( Std.random(40*Game.me.lvl) == 0 )	col += 10;

				//GULP
				if( Std.random(100) == 0 )	col = 5;

				// STOMACH
				var lim = Game.me.hero.stomachSize+Game.me.bonusStomach;
				var sc = Std.int( Math.pow((lim-2)*1.5,3) );
				if( lim<12 && Std.random(sc)==0 ){
					Game.me.bonusStomach++;
					col = 4;
				}
			}
		}
		flFruit = col<20;
		color = col;
		var fr = color+1;
		skin.gotoAndStop(fr);
		//skin.smc.gotoAndStop(fr);
	}


	// GRID
	public function move(dx,dy){
		removeFromGrid();
		px += dx;
		py += dy;
		insertInGrid();
		//Game.me.checkEmpty(px-dx,py-dy);
	}
	public function insertInGrid(){

		Game.me.grid[px][py] = this;
		//if(flFruit)trace("insertFruit in ["+px+","+py+"]");
	}
	public function removeFromGrid(){
		#if prod
		if( Game.me.grid[px][py] == null ) trace("ERROR: removeFromGrid("+px+","+py+")");
		#end
		Game.me.grid[px][py] = null;
		//if(flFruit)trace("removeFruit in ["+px+","+py+"]");
	}

	//


	// BASIC


	// FALL

	/*
	public function initFall(){
		if(action!=null)return;
		move(0,1);
		setAction(fall);
		coef = -0.2;
		spc = 0.2;

	}
	public function fall(){
		coef += spc;
		display(px,py+Math.max(0,coef)-1);
		if(coef>=1){
			//trace("test["+px+","+(py+1)+"]"+Game.me.grid[px][py+1] );
			if( Game.me.grid[px][py+1]!=null || Cs.isOut(px,py+1) ){
				display(px,py);
				setAction(null);
				endFall();
			}else{
				coef-=1;
				move(0,1);
				Game.me.checkEmpty(px,py-1);
			}
		}
	}
	public function endFall(){

	}

	*/

	// KILL
	/*
	public function crunch(id){
		var score = Cs.SCORE_FRUIT[id];
		KKApi.addScore(score);
		var p = Game.me.newScore( Cs.getX(px), Cs.getY(py-0.5), KKApi.val(score) );
		Col.setPercentColor( p.root.smc.smc, 70, [0xFF0000,0x88FF00,0xFF8800,0x4400FF][color] );
		kill();
	}
	*/
	public function explode(){

		// PART
		var cr = 3;
		var max = 6;
		for( i in 0...max ){

			var p = new mt.bumdum.Phys( Game.me.dm.attach("partFruit",Game.DP_FX) );
			var a = (i+Math.random())/max*6.28;
			var sp = 0.5+Math.random()*3;
			p.vx =  Math.cos(a)*sp;
			p.vy =  Math.sin(a)*sp;
			p.x = root._x + p.vx*cr;
			p.y = root._y + p.vy*cr;
			p.vr = (Math.random()*2-1)*15;
			p.fr = 0.97;
			p.weight = 0.1+Math.random()*0.1;
			p.timer = 10 + Math.random()*20;
			p.frict = 0.99;
			p.fadeType = 0;
			p.root._rotation = a/0.0174 + 180;
			p.root.gotoAndStop(color+1);
			p.root.smc.gotoAndStop(Std.random(p.root.smc._totalframes)+1);
			p.updatePos();
		}

		// LIGHT
		var cr = 3;
		for( i in 0...3 ){
			var p = new mt.bumdum.Phys( Game.me.dm.attach("partLight",Game.DP_FX) );
			var a = Math.random()*6.28;
			var sp = Math.random()*4;
			p.vx =  Math.cos(a)*sp;
			p.vy =  Math.sin(a)*sp;
			p.x = root._x + p.vx*cr;
			p.y = root._y + p.vy*cr;
			p.timer = 10 + Math.random()*10;
			p.frict = 0.9;
			p.fadeType = 0;
			p.updatePos();
			p.root._alpha = 50;
			p.root.blendMode = "add";
		}

		//


		kill();
	}
	function kill(){
		removeFromGrid();
		Game.me.balls.remove(this);
		root.removeMovieClip();
	}


	// DEBUG
	function tracePos(str){
		trace(str+" : ["+px+","+py+"] " );
	}


	// CERVORACE
	// VORACE
	// VORAX
	// DEVORAS
	// PIOULIMIK
	// GOULU
	// GLOUTON
	// DIGESTION
	// INGESTION
	// NUTRITION

	// PRODIGESTION
	// HARDIGESTION
	// PARADIGESTION
	// RHAPSODIGESTION
	// GASTRIK
	// INDIGEST

	// DIGESTIVAL
	// DIGESTOMAX


/*ù

Pioupiou est prisonnier d'un verger sauvage maudit.
Pour se sauver Il doit regrouper les fruit qui l'entoure grâce à sa prodigieuse capacité digestive.
Attention cependant aux indigestions !


#KEYS

$$key(left) $$key(right) : se déplacer.
$$key(left) $$key(right) $$key(up) $$key(down) : avaler un fruit voisin.
$$key(up) : expulser les fruits hors de votre estomac.

En avalant et recrachant les fruits, regroupez pour les faire disparaitre.
Au premier niveau, 2 fruits cotes-à-cotes disparaissent.
Au second niveau, 3 fruits cotes-à-cotes disparaissent.

Attention votre estomac à une capacité limité, si vous avalez plus de 6 fruit, vous recevrez une pénalité de temps.

Pour passer au tableau suivant pioupiou ne doit laisser aucun fruit.




*/


//{
}











