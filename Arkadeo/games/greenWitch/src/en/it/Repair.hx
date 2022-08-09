package en.it;

class Repair extends en.Item {
	public function new(x,y) {
		super(x,y);

		sprite.swap("icon",0);
		sprite.setCenter(0.5,0.5);
		pickDist = 25;
	}
	
	override private function onPickUp() {
		super.onPickUp();
		for(d in en.Door.ALL)
			d.repair();
		fx.pop(xx,yy, Lang.DoorsRepaired);
		S.BANK.item05().play();
	}
}
