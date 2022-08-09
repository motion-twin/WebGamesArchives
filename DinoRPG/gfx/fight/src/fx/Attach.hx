package fx;

import mt.bumdum.Lib;

class Attach extends State {

	var caster:Fighter;
	var link:String;
	
	public function new( f, link) {
		super();
		this.link = link;
		this.caster = f;
		addActor(f);
	}

	override function init(){
		var mc = caster.bdm.attach(link, 10);
		mc._y = -caster.height * 0.5;
		end();
	}
}
