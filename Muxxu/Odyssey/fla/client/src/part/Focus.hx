package part;
import Protocole;
import mt.bumdum9.Lib;



class Focus extends mt.fx.Arrow<SP> {//}
	
	public static var ALL:Array<part.Focus> = [];

	public var trg: { x:Float, y:Float };
	public var onImpact:Void->Void;
	
	var anLim:Float;
	var anCoef:Float;
	
	public function new(mc:SP) {

		super(mc);
		Scene.me.dm.add(mc, Scene.DP_FX);
		
		//
		asp = 0;
		aspFrict = 0.95;
		anLim = 0.2;
		anCoef = 0.1;
		ALL.push(this);
	
	}

	// UPDATE
	override function update() {
		super.update();
		if ( trg != null ) seek();
		
	}
	function seek() {

		var dx = trg.x - x;
		var dy = trg.y - y;
		var da = Num.hMod(Math.atan2(dy, dx) - an, 3.14);
		an += Num.mm( -anLim, da * anCoef, anLim);
		aspAcc = (1 - Math.min(Math.abs(da), 0.75));
		
		if ( Math.sqrt(dx * dx + dy * dy) < 8 ) impact();
		
		aspFrict -= 0.005;

	}
	
	public function setFolkTarget(f:Folk, ray, asp) {
		trg = f.getCenter();
	
		var a = Math.random() * 6.28;
		setPos(trg.x  +Math.cos(a) * ray, trg.y  +Math.sin(a) * ray);
		
		this.asp = asp;
		an = a + 90;

		
	}
	


	//
	function impact() {
		if ( onImpact != null ) onImpact();
		ALL.remove(this);
		kill();
	}
	
	
	
//{
}