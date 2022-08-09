package ac ;

import Fighter.Mode ;
import Fight;

class Start extends State {

	public function new(fxt) {
		super();
	}

	override function init(){
	}

	public override function update() {
		super.update();
		if( Scene.me.endLoading() ){
			Main.me.flDisplay = true;
			for( f in Main.me.fighters )f.slot.root._visible = f.isDino;
			end();
		}
	}
}