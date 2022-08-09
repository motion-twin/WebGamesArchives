package world.ent;
import Protocole;
import mt.bumdum9.Lib;



class Statue extends world.Ent {//}
	
	public var id:Int;
	public var base:pix.Element;
	
	public  function new(island, sq, id) {
		this.id = id;
		type = EOther;
		super(island, sq);
		block = true;
		
		base = new pix.Element();
		base.drawFrame(Gfx.world.get("statue"),0.5,0.85);
		addChild(base);
		
	}
	
	

	override function trigSide() {
		World.me.setControl(true);
		if( !World.me.sendReady() ) return true;
		
		World.me.send(_SavePos(id));
		new mt.fx.Flash(World.me.screen);
		var col = Col.getRainbow(id / Data.STATUE_MAX);
		var str = Lang.rep( Lang.BLESS, Lang.col(Lang.GODS[id],Col.getWeb(col)) );
		world.Inter.me.setWarning(str,0xFFFFFF);
		
		return true;
	}
	
	override function isTrig() {
		return true;
	}
	
	
	override function getProtectValue() {
		return 0;
	}
	
	
//{
}








