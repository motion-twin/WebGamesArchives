package part;
import Protocole;
import mt.bumdum9.Lib;



class Cloud extends mt.fx.Part<FxCloud> {//}
	


	public function new() {
	
		var mc = new FxCloud();		
		Scene.me.dm.add(mc, Scene.DP_FX);		
		
		
		super(mc);
		
		frict = 0.96;		
		frameKill();
		root.rotation = Std.random(360);
	}

	
	
	
//{
}