import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Color;
import mt.deepnight.slb.BSprite;

class Hud {
	var mode				: Mode;
	public var wrapper		: Sprite;

	var credits				: Array<BSprite>;
	#if debug
	var debug				: flash.text.TextField;
	#end
	var phaseOn				: BSprite;
	var phaseOff			: BSprite;

	public function new() {
		mode = Mode.ME;
		credits = [];

		wrapper = new Sprite();
		mode.dm.add(wrapper, Const.DP_INTERF);

		#if debug
		debug = mode.createField("--", 0xFF79FF, false);
		wrapper.addChild(debug);
		debug.width = 50;
		debug.height = 70;
		debug.wordWrap = false;
		debug.x = Const.WID-debug.width;
		debug.y = Const.HEI-debug.height;
		#end

		phaseOff = mode.tiles.get("icon_phantom", 0);
		wrapper.addChild(phaseOff);
		phaseOff.alpha = 0.6;

		phaseOn = mode.tiles.get("icon_phantom", 2);
		wrapper.addChild(phaseOn);

		phaseOff.x = phaseOn.x = Const.WID - 40;
	}

	public function refresh() {
		if( mode.hero==null )
			return;

		for(s in credits)
			s.destroy();

		for(i in 0...mode.hero.credits) {
			var s = mode.tiles.get("heart", 0);
			wrapper.addChild(s);
			s.setCenter(0,0);
			s.x = 5 + i*(s.width+1);
			s.y = 5;
			credits.push(s);
		}
	}

	public function loseCreditFx() {
		if( credits.length==0 )
			return;

		var s = credits[credits.length-1];
		mode.fx.creditLoss(s.x+s.width*0.5, s.y+s.height*0.5);
	}


	public function update() {
		#if debug
		var a = [];
		a.push("diff="+mode.diff);
		if( mode.isLeague() )
			a.push("mobs="+mode.asLeague().getMaxMobs());
		a.push("skill="+mode.skill);
		a.push("perf="+api.AKApi.getPerf());
		debug.text = a.join("\n");
		#end

		var t = mode.hero.cd.get("phaseLock");
		phaseOff.visible = t>0;
		if( t>0 ) {
			phaseOn.setFrame(1);
			var f = 1 - (t/Const.PHASE_CD);
			var h = Std.int(28*f);
			var r = new flash.geom.Rectangle(0, 6+28-h, phaseOff.width, h);
			phaseOn.scrollRect = r;
			phaseOn.alpha = 0.7;
			phaseOn.y = phaseOff.y + phaseOff.height - h - 6;
		}
		else {
			phaseOn.y = phaseOff.y;
			phaseOn.scrollRect = null;
			phaseOn.alpha = 1;
			phaseOn.setFrame(2);
		}
	}
}

