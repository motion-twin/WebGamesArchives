package iso;

import flash.display.MovieClip;

private typedef HelperMc = { >MovieClip, _sub:MovieClip }

class Helper extends Iso {
	var mc			: HelperMc;
	var anim		: String;
	var defaultPos	: {cx:Int, cy:Int, dir:Int};
	var type		: Common.Helper;
	var hotspot		: {x:Int, y:Int};
	var active		: Bool;
	
	public function new(h:Common.Helper) {
		super();
		type = h;
		
		active = false;
		fl_static = false;
		speed = 0.15;
		minSpeed*=0.5;
		setShadow(true);
		setPos(Const.EXIT.x-3, Const.EXIT.y+12);
		defaultPos = { cx:Const.EXIT.x+1, cy:Const.EXIT.y, dir:1 }
		glowOver = true;
		hotspot = {x:0, y:12}
	}
	
	public function arrival() {
		man.cm.create({
			setPos(Const.EXIT.x-3, Const.EXIT.y-12);
			gotoXY(Const.EXIT.x-2, Const.EXIT.y) > end("helperMove");
			fl_visible = false;
			100>>man.openDoor();
			300;
			setPos(Const.EXIT.x, Const.EXIT.y);
			fl_visible = true;
			100;
			300>>man.closeDoor();
			gotoXY(defaultPos.cx, defaultPos.cy) > end("helperMove");
			setAnim();
			updateDir(defaultPos.dir, 0);
			active = true;
		});
	}
	
	public function leave() {
		cancelPath();
		active = false;
		man.cm.create({
			goto(Const.EXIT) > end("helperMove");
			fl_visible = false;
			300;
			setPos(Const.EXIT.x-2, Const.EXIT.y);
			fl_visible = true;
			300;
			gotoXY(cx, cy+8) > end("helperMove");
			fl_visible = false;
		});
	}
	
	function init(hmc:HelperMc) {
		if( mc!=null )
			mc.parent.removeChild(mc);
		mc = hmc;
		sprite.addChild(mc);
		mc.y+=23;
		mc.scaleX = -1;
		setAnim("walk");
		var data = Common.getHelperData(type);
		var tip = Tx.HelperTip({_name:data.name, _desc:data.desc});
		setAmbiantDesc(hotspot.x, hotspot.y, 11, tip);
	}
	
	function cellEmpty(x,y) {
		return !man.getPathCollision(man.tpf, x, y);
	}
	
	public override function goto(pt, ?speedMul=1.0) {
		while( pt.x>0 && !cellEmpty(pt.x, pt.y) )
			pt.x--;
		while( pt.x<Const.RWID && !cellEmpty(pt.x, pt.y) )
			pt.x++;
		trace(pt.x+","+pt.y+" "+cellEmpty(pt.x,pt.y));
		setAnim("walk");
		super.goto(pt, speedMul);
	}
	
	override function onArrive() {
		super.onArrive();
		setAnim("stand");
		man.cm.signal("helperMove");
	}
	
	public function moving() {
		return anim!="stand";
	}
	
	override function getInCasePos() {
		return man.teacher.getInCasePosExtern(cx,cy);
	}
	
	override function updateDir(dx,dy) {
		super.updateDir(dx,dy);
		if( anim=="walk" && (dx<0 || dy<0) )
			setAnim("back");
		if( anim=="back" && (dx>0 || dy>0) )
			setAnim("walk");
	}
	
	public function setAnim(?k="stand") {
		mc.gotoAndStop(k);
		anim = k;
		try {
			var smc : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
			smc.stop();
		}catch(e:Dynamic) {}
	}
	
}

