package ent;
import Protocol;





class Hero extends Ent{//}


	public var skin:{ >flash.MovieClip, weapon:flash.MovieClip, armor:flash.MovieClip };
	public var futurAction:Action;

	public var flFire:Bool;
	public var luck:Int;

	public function new(){
		super();
		flGood = true;
		flBad = false;
		Game.me.hero = this;
		lifeMax = 12;
		buildCaracs();
		init();
		//strikeId = 1;
	}
	override function init(){
		super.init();
		Game.me.displayLife();
	}

	// CARACS
	public function buildCaracs(){
		flDoubleDamage = false;
		damageMin = 1;
		damageMax = 2;

		armor = 0;
		luck = 0;

		agility = 3;
		dodge = 4;


		// WEAPON
		switch(Game.me.weaponId){
			case 1:	// COUTEAU
				damageMax = 3;
			case 2: // KATANA
				damageMax = 5;
		}

		strikeId = Game.me.weaponId;

		// ARMOR
		switch(Game.me.armorId){
			case 1:	// LEATHER
				armor = 1;
				dodge -= 1;
			case 2 : // METAL
				armor = 2;
				agility -= 1;
				dodge -= 2;
		}

		for(id in Game.me.inventory){
			switch(id){
				case 18 : // AMULETTE ROUGE
					damageMin++;
					damageMax++;

				case 19 : // AMULETTE VERTE
					dodge++;

				case 20 : // AMULETTE BLEUE
					agility += 2;

				case 24 : // PORTE BONHEUR
					luck += 5;

				case 33 : // DEGATS !!
					flDoubleDamage = true;

				case 34 : // ZIPPO !!
					flFire = true;
				default:
			}
		}

		if(life>lifeMax)life = lifeMax;
		Game.me.displayLife();
		Game.me.displayShuriken();

		//



	}
	override function display(){
		super.display();
		skin.stop();
		paint();
	}

	//
	override function attach(){
		//trace("attach!");
		root = sq.dm.attach("mcHero",Square.DP_ACTOR);
		skin = cast root.smc.smc.smc;
		skin.stop();
	}
	public function paint(){
		skin.weapon.gotoAndStop(Game.me.weaponId+1);
		skin.armor.gotoAndStop(Game.me.armorId+1);
	}
	override function setDirection(di){
		//trace("setDir!");
		super.setDirection(di);
		skin = cast root.smc.smc.smc;
		paint();
		skin.stop();
	}

	override function checkMove(){
		switch(futurAction){
			case Goto(di): setAction(futurAction);
			default:
		}
	}
	override function checkAttack(){
		switch(futurAction){
			case Attack(di): setAction(futurAction);
			default:
		}
	}


	public function incLife(n){
		var d = lifeMax - life;
		if( n>d ) n = d;
		life += n;
		Game.me.displayLife();
		Game.me.log("Vous guérissez "+n+" blessure(s).");
	}
	public function setFuturAction(ac){
		futurAction = ac;
	}
	override function hurt(n){
		super.hurt(n);
		Game.me.displayLife();
	}

	override function kill(){
		sq.fxLight();
		root.smc.smc.gotoAndPlay("die");
		root = null;
		super.kill();
	}

	/*
	public function die(){
		super.die();
		Game.me.initGameOver();
	}
	*/

//{
}














