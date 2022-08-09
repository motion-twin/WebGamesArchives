import mt.bumdum9.Lib;
import Protocol;

/**
 * Bar displaying shoes
 */
class Inter {
	
	var bonus:EL;
	public var bonusKind(default, null):BonusKind;
	
	public function new() {
		bonus = new EL();
		bonus.visible = false;
		bonus.y = 10;
		api.AKApi.setStatusMC( bonus, "center" );
	}
	
	public function update() {
		//display bonus update timing
	}
	
	public function removeBonus() {
		bonus.visible = false;
		bonusKind = null;
	}
	
	public function setBonus( kind : BonusKind ) {
		switch( kind ) {
			case BK_Jump:	bonus.goto("shoe", 0.5, 0.2);
			case BK_Star:	bonus.goto("cap", 0.5, 0.2);
		}
		bonus.visible = true;
		bonusKind = kind;
	}
}
