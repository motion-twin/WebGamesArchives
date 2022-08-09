import mt.bumdum.Lib;




class Generator extends Rel {//}
	

	public var px:Int;
	public var py:Int;
	public var type:Int;
	

	
	
	public function new(mc:flash.MovieClip,t){
		super(mc);
		Game.me.generators.push(this);
		type = t;
		setScale(Game.me.size);
		relPoint = Game.me.selector;
		Col.setColor(root.smc,Game.COLOR[type]);
		root.smc.blendMode = "add";
		root.stop();
	}
		
	//
	public function update(){
		super.update();
	}
	

	public function light(){
		root.gotoAndStop(2);
		root.smc.blendMode = "add";
		Col.setColor(root.smc,Game.COLOR[type]);
	}	

	public function unlight(){
		root.gotoAndStop(1);
		root.smc.blendMode = "add";
		Col.setColor(root.smc,Game.COLOR[type]);
	}	
	
	//
	public function setPos(nx,ny){
		px = nx;
		py = ny;
		x = px*Game.me.size; 
		y = py*Game.me.size; 
	}
	
	public function kill(){
		Game.me.generators.remove(this);	
		super.kill();
	}
	
	

//{
}
















