package en.mob;

class Unlocker extends en.Mob {
	
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 30;
		
		coward = true;
		setSpeed(1.1);
		maxPathLen = 20;
		radius = 8;
		initLife(3);
		weight = 10;
		baseScore = 30;
		
		sprite.swap("unlocker");
		setShadow(true);
	}
	
	override function getLoot() { return api.AKApi.const(2); }
	override function getXp() { return api.AKApi.const(5); }
	
	override function moveAI() {
		if( cd.has("moveDecision") )
			return;
			
		// Joueur dans le coin ?
		if( roomId==hero.roomId || sightCheck(hero) ) {
			super.moveAI();
			return;
		}
		
		// Cherche une porte fermée
		var doors = en.Door.getDoors(roomId);
		var targets : Array<en.Door> = [];
		for(d in doors)
			if( d.isClosed() ) {
				if( d.inRoom(hero.roomId) || distance(d)<120 ) // proche, ou bien qui mène au joueur :)
					targets.insert(0, d);
				else
					targets.push(d);
			}
		
		if( targets.length>0 ) {
			fx.marker(targets[0].xx, targets[0].yy, 0x0080FF);
			if( gotoFreeCoord(targets[0].xx, targets[0].yy) ) {
				decisionCD(50);
				return;
			}
		}
		
		// Bah on se promène alors
		wander();
		decisionCD(30);
	}
	
	override private function onTouchDoor(d:en.Door) {
		if( d.isClosed() ) {
			cd.unset("moveDecision");
			d.forceOpen();
			fx.pop(d.xx,d.yy, Lang.DoorUnlocked, 0x7AE61A);
		}
	}
	
	override function update() {
		super.update();
		sprite.scaleX = dx>0 ? 1 : -1;
	}
}
