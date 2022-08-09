class Shot extends Phys {

	var ray:float;
	var deadLine:float;
	var sShot:float;
	var sType:int;

	var badShot:bool;
	var bounce:bool;

	var flDead:bool;


	function new(mc,type){
		badShot = false;
		bounce = false;
		flDead = false;
		deadLine = -ray+3;
		sType = type;
		
		// HERO single shot
		if (type == 0) {
			super(Cs.game.dm.attach("mcSpike",2));
			ray = 4 ;
			sShot = 5;
			vy = 0;
			vx = 0;
			vr = 0;
			/*
			var flt = new flash.filters.GlowFilter();
			flt.color = 0x99F9DC//0x3333FF;
			flt.alpha = 0.5;
			flt.blurX = 8;
			flt.blurY = 12;
			flt.strength = 2;
			root.filters = [flt];
			*/
		}

		// OCTOPUSSY shot
		if (type == 2) {
			super(Cs.game.dm.attach("mcShootOcto",2));
			ray = 4 ;
			sShot = 5;
			vy = 0;
			vx = 0;
			vr = 0;
			badShot = true;
			/*
			var flt = new flash.filters.GlowFilter();
			flt.color = 0x50519E;
			flt.alpha = 0.5;
			flt.blurX = 5;
			flt.blurY = 10;
			flt.strength = 1;
			root.filters = [flt];
			*/
		}
		
		// Bomber shot
		if (type == 3) {
			super(Cs.game.dm.attach("mcShootBomber",2));
			ray = 4 ;
			sShot = 3
			;
			vy = 0;
			vx = 0;
			vr = 0;
			badShot = true;
		}
		
		// Oyster shot
		if (type == 4) {
			super(Cs.game.dm.attach("mcShootPearl",2));
			ray = 4 ;
			sShot = 1;
			vy = 0;
			vx = 0;
			vr = 0;
			badShot = true;
			
		}		
		
		// Boss shot
		if (type == 5) {
			super(Cs.game.dm.attach("mcShootPearl",2));
			ray = 8 ;
			sShot = 8;
			vy = 0;
			vx = 0;
			vr = 0;
			badShot = true;
			root._xscale = 200;
			vr = 20;
		}	

		Cs.game.shotList.push(this)
		deadLine = -ray+3;
	}

	function update () {
		super.update()
		if (sType == 4) {
			sShot = sShot + (0.07*sShot);
			vy = sShot;
		}
		checkShot();
		isKilling();
		reflect();
	}

function isKilling(){
	// Enemy Shot
	if (badShot) {
		var hero = Cs.game.hero ;
		var xmin = hero.x - hero.hWidth;
		var xmax = hero.x + hero.hWidth;
		var ymin = hero.y - hero.hHeight;
		var ymax = hero.y + hero.hHeight;
		if 	(( y >= ymin) &&( y <= ymax )) {
			if 	(( x >= xmin) &&( x <= xmax ))  {
				Cs.game.hero.shooted(this);
				return;
			}
		}
	}else {
		// Hero Shot
		if (!flDead){
			for (var i = 0; i < Cs.game.monsterList.length ; i++) {
				var monster = Cs.game.monsterList[i] ;
				var xmin = monster.x - monster.ray;
				var xmax = monster.x + monster.ray;
				var ymin = monster.y - monster.ray;
				var ymax = monster.y + monster.ray;

				if 	(( y >= ymin) &&( y <= ymax )) {
					if 	(( x >= xmin) &&( x <= xmax ))  {
						
						if (!Cs.game.monsterList[i].flDeath){
							Cs.game.monsterList[i].shooted();
							}
						
						if ((Cs.game.monsterList[i].mType == 4) && Cs.game.monsterList[i].isClosed ) {
							reBound();
						}
						else {
							kill();
							return;
						}
					}
				}
			}
		}
	}
}

function reflect() {
	if((x>300)||(x<0)) {
		root._rotation = -root._rotation;
		vx = -vx ;
	}
}

function reBound(){
	root.gotoAndPlay("dead");
	vx =  Math.random()*10;
	vy = Math.random()*-vy;
	flDead = true;
}


function checkShot() {
	if ( (y<-10) || ( y > 310 ) ) kill();
}

function kill(){
	Cs.game.shotList.remove(this)
	super.kill();
}

}