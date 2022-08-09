import Protocole;
import mt.bumdum9.Lib;

typedef StatusSlot = { sta:StatusType, turn:Int };

class Ent {//}
	
	public var alive:Bool;	// TODO
	public var armor:Int;
	
	//public var pan:inter.EntBox;
	
	public var status:Array<StatusSlot>;
	public var game:Game;
	
	public var folk:Folk;
	
	public function new(gm) {
		game = gm;
		status = [];
		alive = true;
	}
	
	// TURN
	public function onUpkeep() {
		// STATUS
		//for ( o in status.copy() ) if ( o.turn-- == 0 ) status.remove(o);
	}
	public function onEndTurn() {
		//
	}
	public function onPlayTurn() {
		// STATUS
		for ( o in status.copy() ) if ( --o.turn == 0 ) status.remove(o);
	}
	
	// HIT
	public function hit(dam:Damage) {
		

		var impact = dam.value > 0;
		
		// ARMOR
		if ( armor > 0 && dam.value > 0 && armorCollide(dam) ) 	applyArmor(dam);
		
		// IMPACT
		if( impact ) applyImpactEffects(dam);
		
		
		// DAMAGE EFFECT
		if ( dam.value > 0 ) applyDamageEffects(dam);
		
		// APPLY
		var n = applyDamage(dam);
		
		
		// FX
		if ( n > 0 )	fxHit();
		else			fxAbsorb();
		
		majInter();
		return n;
		
	}
	public function applyImpactEffects(dam:Damage) {
		
		var evasion = getArmorType() == 1;
		
		if ( haveStatus(STA_WEAK_POINT) ) incArmor(evasion?1:-1);
		
		for ( dt in dam.types ) {
			switch(dt) {
				case ACID :	if ( armor > 0 && !evasion ) incArmor( -1);
				default :
			}
		}
	}
	public function applyDamageEffects(dam:Damage) {
		for ( dt in dam.types ) {
			switch(dt) {
				case POISON :	addStatus(STA_POISON);
				default :
			}
		}
	}
	public function applyDamage(dam:Damage) {
		trace("no apply damage defined");
		
		
		
		return dam.value;
	}
	
	// REGENERATE
	public function regenerate(n) {
		
	}
	
	// ATTACK
	public function getAttack() {
		return 0;
	}
	
	// ARMOR
	public function getArmorType() {
		return 0;
	}
	public function armorCollide(dam) {
		var armorType = getArmorType();
		
		switch( armorType ) {
			case 0 : 	return Lambda.has(dam.types, PHYSICAL) && !Lambda.has(dam.types, PIERCE);
			case 1 : 	return !Lambda.has(dam.types, PROJECTILE);
			case 2 : 	return Lambda.has(dam.types, MAGIC);
			default :	return false;
		}
		
		
		
	}
	public function applyArmor(dam:Damage) {

		
		var absorb = 0;
		switch(getArmorType()) {
			case 0 : // CLASSIC
				absorb = armor;
				if ( Lambda.has(dam.types, LIGHT)  ) absorb <<= 1;
				if ( Lambda.has(dam.types, STEALTH) )	 absorb >>= 1;
				
			case 1 : // EVASION
				if ( dam.value > armor ) {
					fxDodge();
					absorb = dam.value;
				}
				
			case 2 : // MAGIC
				absorb = armor;
			
		}
		
		if ( absorb > dam.value ) absorb = dam.value;
		dam.value -= absorb;
			
		return absorb;
	}
	public function incArmor(n) {
		armor += n;
		if ( armor <= 0 ) resetArmor();
	}
	public function resetArmor() {
		armor = 0;
	}
			
	// STATUS
	public function addStatus(sta:StatusType, turn=-1) {
		if ( !Data.STATUS[Type.enumIndex(sta)].multi && haveStatus(sta) ) return;
		status.push( { sta:sta, turn:turn } );
	}
	public function removeStatus(sta) {
		for ( o in status ) {
			if ( o.sta == sta ) {
				status.remove(o);
				return true;
			}
		}
		return false;
		
	}
	public function numStatus(sta) {
		var n = 0;
		for ( o in status ) if ( o.sta == sta ) n++;
		return n;
	}
	public function haveStatus(sta) {
		for ( o in status ) if ( o.sta == sta ) return true;
		return false;
	}
	public function useStatus(sta) {
		for ( o in status ) {
			if ( o.sta == sta ) {
				status.remove(o);
				return true;
			}
		}
		return false;
	}
	
	/*
	public function tickStatus() {
		for ( o in status.copy() ) {
			var data = Data.STATUS[Type.enumIndex(o.sta)];
			if ( data.leak ) status.remove(o);
		}
	}
	*/
	
	public function removeAllNegativeStatus() {
		
		for ( o in status.copy() ) {
			var data = Data.STATUS[Type.enumIndex(o.sta)];
			if ( !data.boost ) removeStatus(o.sta);
		}

	}
		
	// INTER
	public function majInter() {
		
	}
	
	// SKILL
	public function have(sk:SkillType) {
		return false;
	}
	public function getSkills():Array<SkillType> {
		return [];
	}
	
	// FX
	public function fxHit() {
		
	}
	public function fxAbsorb() {
		
	}
	public function fxDodge() {
		
	}
	
	// SCENE
	public function getStandPos() {
		return Cs.mcw >> 1;
	}
	
	
//{
}





