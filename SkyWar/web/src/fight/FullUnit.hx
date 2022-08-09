package fight;
import Datas;

class FullUnit {
	public var unit : db.Unit;
	public var logic : ShipLogic;
	public var isAttacker : Bool;
	public var hasInit : Bool;
	public var hasColonization : Bool;
	public var hasStealth : Bool;
	public var hasSentinelle : Bool;
	public var hasScout : Bool;
	public var hasCorosive : Bool;
	public var hasPack : Bool;
	public var hasRepartition : Bool;
	public var bomb : Int;
	public var raid : Int;
	public var multi : Int;
	public var aura : ShipCapacity;
	public var damageFactor : Float;
	public var fleetTarget : Int;

	public function new( u:db.Unit, ?isAttacker=false, userTechnos:List<_Tec> ){
		this.isAttacker = isAttacker;
		this.unit = u;
		this.logic = u.getLogic().applyUserTechnos(userTechnos);
		this.hasInit = false;
		this.hasColonization = false;
		this.hasStealth = false;
		this.hasSentinelle = false;
		this.hasScout = false;
		this.hasCorosive = false;
		this.hasPack = false;
		this.hasRepartition = false;
		this.bomb = this.raid = this.fleetTarget = 0;
		this.multi = 1;
		this.damageFactor = 1.0;
		this.aura = null;
		for (c in logic.capacities){
			switch (c){
				case Init: this.hasInit = true;
				case Bomb(n): this.bomb += n;
				case Raid(n): this.raid = n;
				case Multi(n): this.multi = n;
				case Colonization: this.hasColonization = true;
				case Stealth:  this.hasStealth = true;
				case Sentinelle: this.hasSentinelle = true;
				case Scout: this.hasScout = true;
				case Regeneration:
				case Corrosive: this.hasCorosive = true;
				case Repartition: this.hasRepartition = true;
				case Pack: this.hasPack = true;
				case Aura(x): this.aura = x;
				case FleetTarget(v): this.fleetTarget = v;
			}
		}
	}
}
