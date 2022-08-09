import Protocol;
import mt.bumdum.Lib;
import Floor;



class Ent {//}

	var flDamage:Bool;
	var flDeath:Bool;
	var flDoubleDamage:Bool;

	public var flFreeze:Bool;
	public var flBad:Bool;
	public var flGood:Bool;
	public var flTrader:Bool;

	public var x:mt.flash.Volatile<Int>;
	public var y:mt.flash.Volatile<Int>;

	public var direction:mt.flash.Volatile<Int>;

	public var damageMin:mt.flash.Volatile<Int>;
	public var damageMax:mt.flash.Volatile<Int>;
	public var armor:mt.flash.Volatile<Int>;
	public var lifeMax:mt.flash.Volatile<Int>;
	public var life:mt.flash.Volatile<Int>;

	public var agility:mt.flash.Volatile<Int>;
	public var dodge:mt.flash.Volatile<Int>;
	public var damage:mt.flash.Volatile<Int>;
	public var coef:Float;

	public var strikeId:Int;

	public var floor:Floor;
	public var sq:Square;

	public var action:Action;


	public var root:flash.MovieClip;
	public var anim:flash.MovieClip;


	public function new(){
		damageMin = 1;
		damageMax = 1;
		armor = 0;
		agility = 3;
		dodge = 4;
		lifeMax = 3;

	}
	public function init(){
		life = lifeMax;
		setDirection(1);
	}

	public function setFloor(fl){
		if(floor!=null)floor.ents.remove(this);
		floor = fl;
		if(this==Game.me.hero)	floor.ents.unshift(this);
		else 			floor.ents.push(this);
	}


	public function first(){
		floor.ents.remove(this);
		floor.ents.unshift(this);
	}

	// CHECK
	public function checkAttack(){


	}
	public function checkMove(){


	}

	// ACTION
	public function setAction(ac){
		action = ac;
		if( ac!=null ){
			Game.me.work.push(this);
			Game.me.active.remove(this);
		}else{
			Game.me.work.remove(this);
		}

		switch(action){
			case Goto(dir):		initMove(dir);
			case Attack(dir):	initAttack(dir);
		}
	}
	public function update(coef){
		if(flDeath){
			setAction(null);
			return;
		}
		switch(action){
			case Goto(dir):		move(dir,coef);
			case Attack(dir):	attack(dir,coef);
		}
	}

	/*

	public function attack(dir){
		// ent
		var d = Cs.DIR[dir];
		trg = floor.grid[sq.x+d[0]][sq.y+d[1]].ent;
		adir = dir;
		flDamage = false;
		Game.me.attackers.push(this);
	}


	// ANIMS
	public function initMove(){
		if(mdir==null)return;

		var d = Cs.DIR[mdir];
		var next = floor.grid[sq.x+d[0]][sq.y+d[1]];
		setSquare(next);
		if(mdir==1){
			display();
			root._y -= Cs.CS;
		}
	}
	*/
	// MOVE
	function initMove(di){
		if(di==null)return;
		var d = Cs.DIR[di];
		var next = floor.grid[sq.x+d[0]][sq.y+d[1]];
		setSquare(next);
		if(di==1){
			display();
			root._y -= Cs.CS;
		}

		if( getHeroDist()<=Game.me.huntMax )floor.buildTracks();


		setDirection(di);


	}
	function move(di,coef:Float){
		if(di==null)return;
		var c = coef;
		if( di ==1 )c = coef-1;
		var d = Cs.DIR[di];
		root._x = c*d[0]*Cs.CS;
		root._y = c*d[1]*Cs.CS;

		var fr = anim._currentframe;
		if( fr ==  anim._totalframes ) fr = 1;
		else fr++;
		anim.gotoAndStop( fr );

		if(coef==1){
			display();
			x = sq.x;
			y = sq.y;
			setAction(null);
		}
	}

	// ATTACK
	function initAttack(di){
		setDirection(di);

	}
	function attack(di:Int,coef:Float){

		var d = Cs.DIR[di];
		var trg = floor.grid[sq.x+d[0]][sq.y+d[1]].ent;

		if(!flDamage){
			flDamage = true;

			// DODGE
			var c = agility / trg.dodge;
			damage = null;
			if( Math.random()< c ){
				damage = getDamage();
				damage -= trg.armor;
				if( damage < 0 )damage = 0;
			}

			trg.fxDamage(damage);
			if( damage!=null ){
				trg.fxStrike(strikeId,di);
				trg.hurt(damage);
			}

			if( Game.me.hero == this ){
				if( damage > 0 )	Game.me.log("Vous infligez "+damage+" dégat(s) à "+trg.getName()+"." );
				else if( damage == 0 )	Game.me.log(trg.getName()+" encaisse votre attaque sans broncher." );
				else			Game.me.log(trg.getName()+" évite votre coups." );
			}
			if( Game.me.hero == trg ){
				if( damage > 0 )	Game.me.log(getName()+" vous inflige "+damage+" dégat(s)." );
				else if( damage == 0 )	Game.me.log(getName()+" ne parvient pas a vous blesser." );
				else			Game.me.log("Vous esquivez l'attaque de "+getName()+"." );
			}

		}

		var c = Math.max(1-coef*1.5,0);
		var d = Cs.DIR[di];

		var cx = 12;
		var cy = 16;

		var dc = 4;
		root.smc._x = cx+c*d[0]*dc;
		root.smc._y = cy+c*d[1]*dc;


		if(damage>0){
			var sens = trg.root.smc._x>cx?-1:1;
			trg.root.smc._x = cx+c*6*sens;
			Col.setPercentColor(trg.root.smc,(1-coef)*100,0xFF0000);
		}else{
			//var n = Math.sin(coef*3.14);
			//trg.root.smc._x = cx+n*d[0]*16;
			//trg.root.smc._y = cy+n*d[1]*16;
		}

		if(coef==1){
			flDamage = false;
			setAction(null);
		}

	}

	//
	public function freeze(){
		flFreeze = true;
		display();
	}

	//
	public function hurt(n){
		if(n==null)return;
		life -= n;
		if(n>0 && Game.me.hero == this ){
			Game.me.fxFlash(0xFF0000);
		}
		if(life<=0){
			life = 0;
			die();
		}
	}
	public function fxDamage(n:Int){

		//var mc = new mt.DepthManager(root).attach("mcLoss",Square.DP_FX);
		var mc = floor.dm.attach("mcLoss",Square.DP_FX);

		mc._x = (x+0.5)*Cs.CS;//*0.5;
		var b = root.getBounds(root);
		mc._y = (y+0.5)*Cs.CS + b.yMin;
		var str = n+"";
		var col = 0xFF0000;
		if(n==null){
			col = 0;
			str = "miss";
		}

		Reflect.setField(mc,"_loss",str);
		Filt.glow(mc,2,4,col);
	}
	public function fxStrike(id,di){
		if(id==null)return;
		var mc = sq.dm.attach("mcStrike",Square.DP_FX);
		mc.gotoAndStop(id+1);
		mc._x = Cs.CS*0.5;
		mc._y = Cs.CS*0.5;
		//if( di!=0 )mc._xscale*=-1;
		mc._rotation = di*90;

	}


	public function getDamage(){
		var dmg = damageMin+Std.random(1+damageMax-damageMin);
		if(flDoubleDamage)dmg*=2;
		return dmg;
	}


	public function die(){
		flDeath = true;
		kill();
	}


	public function setPos(x,y){
		this.x = x;
		this.y = y;
		setSquare(floor.grid[x][y]);
	}
	public function setSquare(square){
		if(sq.ent==this)sq.ent = null;
		sq = square;
		sq.ent = this;
	}

	// DISPLAY / ATTACH
	public function display(){
		if(root!=null)root.removeMovieClip();
		attach();
		root.smc.smc.gotoAndStop(direction+1);
		if( flFreeze ){
			Filt.grey(root,1,0,{r:0,g:150,b:210});
		}

	}
	function attach(){
		root = sq.dm.attach("mcEnt",Square.DP_ACTOR);
	}
	function setDirection(di){
		direction = di;
		root.smc.smc.gotoAndStop(direction+1);
		anim = root.smc.smc.smc;
	}


	// TOOLS
	public function getHeroDist(){
		var dx = Math.abs(sq.x-Game.me.hero.sq.x);
		var dy = Math.abs(sq.y-Game.me.hero.sq.y);
		return dx+dy;
	}
	public function getNearBads(ray){
		var list:Array<ent.Bad> = [];
		for( dx in 0...ray*2+1 ){
			for( dy in 0...ray*2+1 ){
				var x = x+dx-ray;
				var y = y+dy-ray;
				var ent = floor.grid[x][y].ent;
				if( ent.flBad )list.push( cast ent);
			}
		}
		return list;
	}
	public function getNearestBad(min,max){
		var trg:Ent = null;
		var dmax = 99;
		for( d in Cs.DIR ){
			for( i in 1...max ){
				var x = x + i*d[0];
				var y = y + i*d[1];
				var sq = floor.grid[x][y];
				if( !sq.isGround() || ( i<min && sq.ent.flBad )  )break;
				if( ( i<dmax || (sq.ent.flBad && trg.flBad!=true )) && sq.ent !=null && sq.ent.flGood!=true ){
					trg = sq.ent;
					dmax = i;
					//trace("="+sq.ent);
					break;
				}
				if(i==dmax)break;
			}
		}
		return trg;

	}

	public function getNearFreeList(){
		var list = [];
		var ray = 1;
		for( dx in 0...ray*2+1 ){
			for( dy in 0...ray*2+1 ){
				var x = x+dx-ray;
				var y = y+dy-ray;
				var sq = floor.grid[x][y];
				if( sq.ent==null && sq.isGround() )list.push(sq);
				//if( ent.flBad )list.push( cast ent);
			}
		}
		return list;
	}


	// TEXT
	public function getName(){
		return "no name";
	}

	// KILL
	public function kill(){
		Game.me.active.remove(this);
		root.removeMovieClip();
		floor.ents.remove(this);
		sq.ent = null;
	}


	//


//{
}

