package iso;

import Iso;
import Common;

class Item extends Iso {
	public var type		: ItemType;
	public var data		: Null<ItemData>;
	public var flip		: Bool;
	
	public function new(s, t:ItemType) {
		super(s);
		type = t;
		flip = false;
	}
	

	public static function getSprite(t:ItemType) {
		return Manager.ME.tiles.getSprite( switch(t) {
			case ITable	: "table";
			case IDesktop: "table";
		});
	}
}
