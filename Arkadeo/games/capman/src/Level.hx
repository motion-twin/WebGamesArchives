import mt.bumdum9.Lib;
import Protocol;

@:build(mt.kiroukou.macros.IntInliner.create([
	DP_BG,
	DP_WALLS,
	DP_GROUND,
	DP_ENTS,
	DP_FX,
	DP_SCORE,
	DP_PLASMA
]))
class Level extends SP {
	public  var dm:mt.DepthManager;
	public static var me:Level;
	
	public var bg:SP;
	public var shade:SP;
	public var walls:SP;

	public function new() {
		super();
		me = this;
		dm = new mt.DepthManager(this);
		// BG
		bg = new SP();
		dm.add(bg, DP_BG);
		bg.graphics.beginFill(0x120618);
		bg.graphics.drawRect(0, 0, Cs.WIDTH, Cs.HEIGHT);
		
		shade = new SP();
		dm.add(shade, DP_GROUND);
		shade.alpha = 0.5;
		shade.blendMode = flash.display.BlendMode.LAYER;
		
		walls = new SP();
		dm.add(walls, DP_WALLS);
	}
	
	public function kill() {
		parent.removeChild(this);
	}
}
