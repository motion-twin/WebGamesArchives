package en.it;

class Heal extends en.Item {
	public function new(x,y) {
		super(x,y);
		
		if( game.isLeague() )
			duration = 30*40;
		
		sprite.swap("icon", 2);
		sprite.setCenter(0.5, 0.5);
	}
	
	override private function onPickUp() {
		super.onPickUp();
		game.hero.heal(3);
		S.BANK.heal01().play();
	}
}