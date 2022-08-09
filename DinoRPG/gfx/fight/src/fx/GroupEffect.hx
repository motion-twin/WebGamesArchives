package fx;

import mt.bumdum.Lib;

class GroupEffect extends State {

	var step:Int;
	var ldec:Float;
	var caster:Fighter;
	var list:Array<{t : Fighter, life : Int}>;

	public function new( f, list:Array<{t : Fighter, life : Int}> ) {
		super();
		caster = f;
		this.list = list.copy();
		step = 0;
	}

	function nextStep() {
		step++;
		coef = 0;
	}

	// FX
	function updateAura(type,?base:flash.MovieClip,?coef) {
		if(coef == null) coef = this.coef;
		if(base == null) base = caster.root;

		switch(type) {
			case 0:
				var c = 1+(1+Math.random())*coef;
				base.filters = [];
				Filt.glow( base, 2, 	c*4, 	0xFFFFFF );
				Filt.glow( base, c*2, 	c*1.5, 	0xFFCC00 );
				Filt.glow( base, c*10, 	c, 	0xFF0000 );
			case 1:
				var c = 1+(1+Math.random())*coef;
				base.filters = [];
				Filt.glow( base, 2, 	c*4, 	0xFFFFFF );
				Filt.glow( base, c*2, 	c*1.5, 	0xFFFF00 );
				Filt.glow( base, c*10, 	c, 	0x66FF00 );
			case 2:
				var c = 1+(1+Math.random())*coef;
				base.filters = [];
				Filt.glow( base, 2, 	c*4, 	0xFFFFFF );
				Filt.glow( base, c*2, 	c*1.5, 	0x00FFFF );
				Filt.glow( base, c*10, 	c, 	0x0000FF );
			case 3:
				var c = 1+(1+Math.random())*coef;
				base.filters = [];
				Filt.glow( base, 2, 	c*4, 	0xFFFFFF );
				Filt.glow( base, c*2, 	c*1.5, 	0xFFFF00 );
				Filt.glow( base, c*10, 	c, 	0xFFFF00);
			case 4:
				var c = 1+(1+Math.random())*coef;
				base.filters = [];
				Filt.glow( base, 2, 	c*4, 	0xFFFFFF );
				Filt.glow( base, c*2, 	c*1.5, 	0xCCFFFF );
				Filt.glow( base, c*10, 	c, 	0x22FFFF );
		}
	}
	
	function genRayConcentrate() {
		var mc = caster.bdm.attach("mcRayConcentrate",Fighter.DP_BACK);
		mc._y = -caster.height*0.5;
		mc._rotation = Math.random()*360;
		return mc;
	}

	//TOOLS
	function damageAll(?fxt) {
		for ( o in list )
			if(  o.life != null )
				o.t.damages(o.life,20,fxt);
	}
	
	function goto(tx,ty) {
		caster.saveCurrentCoords();
		var dist = caster.getDist({x:tx,y:ty});
		spc =  caster.runSpeed / dist ;
		caster.moveTo(tx,ty);
	}

	function levit(c:Float,height) {
		if( ldec == null ) ldec = 0;
		ldec = (ldec+24)%628;
		var cc = ( 1-Math.cos(c*3.14))*0.5;
		caster.z = Math.sin(ldec*0.01)*2 - cc*height;
	}
}

