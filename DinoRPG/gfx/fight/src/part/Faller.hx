package part;
import mt.bumdum.Lib;


class Faller extends Part{

	public var flBurst:Bool;
	public var flFall:Bool;

	public function new(mc){
		super(mc);
		flFall = true;
	}

	public override function update(){
		super.update();
		if( flFall && z == 0 ){
			vx = 0;
			vy = 0;
			vz = 0;
			weight = 0;
			if(root.smc!=null)root.smc.stop();
			if(flBurst){
				root._rotation = 0;
				root.gotoAndPlay("burst");
			}
			flFall = false;
		}

	}
}