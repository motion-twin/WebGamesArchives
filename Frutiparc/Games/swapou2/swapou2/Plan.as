class swapou2.Plan {

	private var mc : MovieClip;
	private var depth : Number;

	function Plan( mc : MovieClip ) {
		this.mc = mc;
		this.depth = 0;
	}

	function attach( name : String ) : MovieClip {
		return Std.attachMC(mc,name,depth++);		
	}

	function empty() : MovieClip {
		return Std.createEmptyMC(mc,depth++);
	}

}
