package elem ;

/**
 * ...
 * @author Tipyx
 */
class Grip extends h2d.Sprite
{
	public var cX				: Int;
	
	public var isActivated		: Bool;
	
	var hs						: mt.deepnight.slb.HSprite;

	public function new(newX:Int) {
		super();
		
		this.cX = newX;
		
		isActivated = true;
		
		hs = Settings.SLB_TAUPI.h_get("gripIdle");
		hs.filter = true;
		hs.scaleY = -1;
		hs.setCenterRatio(0.5, 0.5);
		hs.scaleX = 0.4;
		hs.scaleY = -0.4;
		this.addChild(hs);
		
		var inter = new h2d.Interactive(Settings.SIZE, Settings.SIZE);
		inter.scaleX = inter.scaleY = 0.4;
		inter.setPos(-Std.int(Settings.SIZE / 4), -Std.int(Settings.SIZE / 4));
		//inter.backgroundColor = 0xFF800000;
		//inter.alpha = 0.5;
		inter.onClick = function(e) {
			isActivated = !isActivated;
			hs.alpha = isActivated ? 1 : 0.1;
		}
		this.addChild(inter);
	}
	
	public function enable() {
		isActivated = true;
		hs.alpha = 1;
	}
	
	public function disable() {
		isActivated = false;
		hs.alpha = 0.1;
	}
}