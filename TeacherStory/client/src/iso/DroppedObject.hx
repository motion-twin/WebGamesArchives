package iso;

import Iso;
import Common;

class DroppedObject extends Iso {
	public static var ALL	: List<DroppedObject> = new List();
	var object		: InvObject;
	var oid			: Int;
	
	public function new(x:Int,y:Int, o:InvObject, id:Int, color:Int) {
		super();
		
		oid = id;
		cx = x;
		cy = y;
		object = o;
		xr = 0.8;
		yr = 0.3;
		
		var s = man.tiles.getSprite("droppedObject");
		s.y = 15;
		s.filters = [ mt.deepnight.Color.getColorizeMatrixFilter(color, 1,0) ];
		sprite.addChild( s );
		
		setClick(0,23, 7, Tx.PickUp, function() {
			man.sendAction(TAction.Grab, [AT_Num(oid)]);
		});
	}
	
	
	public static function get(oid:Int) {
		for(o in ALL)
			if( o.oid==oid )
				return o;
		return null;
	}
	
	
	public function getObjectName() {
		return switch( object ) {
			case IvItem(c) : Common.getCItemData(c).name;
			case IvObject(o) : Common.getObjectData(o,[]).name;
		}
	}
	
	
	public override function register() {
		super.register();
		ALL.add(this);
	}
	
	public override function destroy() {
		super.destroy();
		ALL.remove(this);
	}
	
	
	public override function update() {
		super.update();
		if( fl_visible && man.time%2==0 )
			man.fx.objectShine(this, 0xFFDF00);
	}
}
