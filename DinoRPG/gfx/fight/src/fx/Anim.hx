package fx;

import mt.bumdum.Lib;

class Anim extends State {
	var caster:Fighter;
	var link:String;
	
	public function new( f, link ) {
		super();
		this.link = link;
		caster = f;
		addActor(f);
	}

	override function init() {
		caster.playAnim( link );
		end();
	}
}
