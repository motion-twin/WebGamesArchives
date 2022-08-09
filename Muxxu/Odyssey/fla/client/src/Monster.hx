import Protocole;
import mt.bumdum9.Lib;


class Monster extends Ent{//}
	
	public static var DATA = mt.data.Mods.parseODS( "client.ods", "monsters", DataMonster );
	
	public var life:mt.flash.Volatile<Int>;
	public var summonSickness:Bool;
	
	public var sequenceId:Int;
	public var firstChain:Array<ActionType>;
	public var sequence:Array<ActionType>;
	public var data:DataMonster;
	public var skills:Array<SkillType>;
	public var bonus_atk:mt.flash.Volatile<Int>;
	public var investment:Int;
	
	var lifeLossDisplay:Int;
	
	public var pan:inter.MonsterBox;
	public var sbar:inter.SequenceBar;

	
	public function new(game, id:MonsterType) {
		super(game);

		data = DATA[Type.enumIndex(id)];
		skills = data.skills.copy();
		
		summonSickness = true;
		sequenceId = 0;
		life = getLifeMax();
		armor = data.armor;
		firstChain = [];
		bonus_atk = 0;
		
		lifeLossDisplay = 0;
		
		sequence = data.sequence.copy();
		
		// DEV
		#if dev
		if ( mod.Grid.TEST_ACTION != null ) sequence.unshift(mod.Grid.TEST_ACTION);
		#end
		
		// STATUS
		for ( st in data.status ) addStatus(st);
		
		//
		pan = new inter.MonsterBox(this);
		game.dm.add(pan, Game.DP_FRONT);
		pan.maj();
		
		sbar = new inter.SequenceBar(this);
		game.dm.add(sbar, Game.DP_FRONT);
		sbar.maj();
		
		//
		folk = new Folk();
		folk.setMonster(id);
		folk.getStandPos = getStandPos;
		folk.x = Cs.mcw + 50;
		
		
	}
	
	public function update() {

		
		if( lifeLossDisplay != 0 ){
			var pos = folk.getCenter(0.5,1);
			new fx.Life(lifeLossDisplay, pos.x, pos.y);
			lifeLossDisplay = 0;
		}
	}

	//
	public override function onUpkeep() {
		super.onUpkeep();
		
		var poison = numStatus(STA_POISON);
		if( poison > 0 ) incLife( -poison);
		
		pan.maj();

	}
	
	
	
	// PLAY
	public function getNextAction() {
		var act:ActionType = null;
		if ( firstChain.length > 0 ) {
			act = firstChain.shift();
		}else {
			act = sequence[sequenceId];
			sequenceId = (sequenceId + 1) % sequence.length;
		}
		return act;
	}
	public function getNextActionData() {
		var act:ActionType = null;
		if ( firstChain.length > 0 ) 	act = firstChain[0];
		else							act = sequence[sequenceId];
		return Data.ACTIONS[Type.enumIndex(act)];
	}
	
	
	// HIT
	public override function hit(dam:Damage) {
		
		// WAKE UP
		while ( firstChain[0] == AC_SLEEP ) firstChain.shift();
		
		//
		return super.hit(dam);
		
	}
	
	// DAMAGE TYPE
	public override function applyDamageEffects(dam:Damage) {
		super.applyDamageEffects(dam);
		for ( dt in dam.types ) {
			switch(dt) {
				case ICE(n) :	freeze(n);
				default :
			}
		}
	}
	public override function applyDamage(dam:Damage) {
		
		if( dam.value > 0 ){
			for ( dt in dam.types ) {
				switch(dt) {
					
					case STUN :
						for (  i in 0...2 ) firstChain.unshift(AC_WAIT);
						
					case SKILL_KILLER(sk) :
						skills.remove(sk);
						
					default :
						
				}
			}
		}
		
		return -incLife(-dam.value);
	}
	public override function getArmorType() {
		return data.armorType;
	}

	public override function regenerate(n) {
		incLife(n);
	}
	
	// LIFE
	public function incLife(inc) {
		//if ( inc == 0 ) throw("whoho");
		life += inc;
		
		var max = getLifeMax();
		if ( life > max ) life = max;
		if ( life < 0 ) life = 0;
		
		lifeLossDisplay += inc;
		//var pos = folk.getCenter(0.5,1);
		//new fx.Life(inc,pos.x, pos.y);
	
		return inc;
	}
	public function getLifeMax() {
		return data.life;
	}
	
	//
	public override function getAttack() {
		var atk = data.atk + bonus_atk;
		if ( haveStatus(STA_BLIND) ) atk--;
		if ( atk < 0 ) atk = 0;
		return atk;
	}
	public function getArmor() {
		return armor;
	}
	public override function incArmor(n) {
		
		if ( n < 0 && armor > 0 ) {
			var counter = pan.counters[1];
			new mt.fx.Shake(counter.icon, 7,0);
			var max = 8;
			for ( i in 0...max ) {
				var mc = new FxTriangle();
				var p = new mt.fx.Part(mc);
				
				p.setPos(pan.x+counter.x+2,pan.y+counter.y+8);
				p.fadeType = 2;
				p.timer = 10 + Std.random(10);
				p.vx = 1+(Math.random() * 2 - 1) * 2;
				p.vy = -(0.5 + Math.random() * 2);
				p.weight = 0.05 + Math.random() * 0.1;
				p.frict = 0.98;
				p.twist(12, 0.98);
				p.setScale(0.25 + Math.random() * 0.25);
				Filt.glow(p.root, 10, 1, 0xFFFFFF);
				p.root.blendMode = flash.display.BlendMode.ADD;
				Game.me.dm.add(p.root, Game.DP_FX);
			}
		}
		super.incArmor(n);
	}
	
	// FX
	public override function fxHit() {
		var e = new mt.fx.Flash(pan, 0.3, 0xFF0000);
		e.maj();
		//new mt.fx.Shake(pan, 16, 0, 0.6);
		folk.play("hit",true);

		
	}
	public override function fxAbsorb() {
		if( getArmorType() != 1 ) new mt.fx.Flash(folk, 0.2);
		pan.fxArmor();
		
	}
		
	public override function fxDodge() {
		folk.play("dodge", null, true);
	}
	
	public override function majInter() {
		pan.maj();
		sbar.maj();
	}
	
	// SHORTCUT
	public function freeze(pow) {
		for ( i in 0...pow ) firstChain.unshift(AC_FREEZE);
		majInter();
		

	}
	public function isHalfLife() {
		return life <= data.life >> 1;
	}
	public function willRiposte(damage:Damage) {
		return have(COUNTER_ATTACK)
			&& life > 0
			&& isActive()
			&& Lambda.has(damage.types, PHYSICAL)
			&& !Lambda.has(damage.types, PROJECTILE)
			&& !damage.source.have(STEADY_STRIKE)
			&& !Lambda.has(damage.types, STEALTH);
	}
	public function isActive() {
		var data = getNextActionData();
		return data.id != AC_FREEZE && data.id != AC_SLEEP;
	}
	public function getRandomBallType() {
		return data.balls[Std.random(data.balls.length)];
	}
	
	public function removeActions(ac:ActionType) {
		
		var id = 0;
		for ( a in sequence ) {
			if ( a == ac ) sequence[id] = AC_WAIT;
			id++;
		}
		this.majInter();
	}
	
	// OVERRIDE
	public override function have(sk:SkillType) {
		for ( s in skills ) if (s == sk ) return true;
		return false;
	}
	public override function getSkills() {
		return skills.copy();
	}

	
	public override function getStandPos() {
		return Scene.MONSTER_POS;
	}
	
	
	// KILL
	public function kill() {
		game.monster = null;
		pan.parent.removeChild(pan);
		sbar.parent.removeChild(sbar);
		//
		Main.log(data.name + " rune cost : " + investment +"/"+Gameplay.getAverageRuneLoss(data.lvl));
	}
	
	
//{
}