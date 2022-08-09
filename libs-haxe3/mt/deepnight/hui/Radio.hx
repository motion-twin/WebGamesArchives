package mt.deepnight.hui;

import mt.deepnight.Color;

class Radio extends Check {
	var needAutoSelect			: Bool;
	public static var STYLE = {
		var s = new Style();
		s.bg = None;
		s.bgOutline = None;
		s.checkType = Outline(0xFFFFFF,1);
		s.padding = 0;
		s;
	}

	public function new(p, label:String, ?selected=false, cb:Bool->Void) {
		super(p, label, selected==true, cb);

		style = new Style(Component.BASE_STYLE,this);
		style.copyValues(STYLE);

		if( selected ) {
			select();
			needAutoSelect = false;
		}
		else {
			unselect();
			needAutoSelect = true;
		}
	}

	override function onButtonClick(_) {
		select();
	}

	override function select() {
		super.select();
		for(c in getNeightbours())
			c.unselect();
	}

	override function unselect() {
		super.unselect();
	}

	function hasSelectedNeighbour() {
		for(c in getNeightbours())
			if( c.isSelected() )
				return true;
		return false;
	}

	function getNeightbours() : Array<Radio> {
		if( parent!=null )
			return cast parent.children.filter( function(c) return c!=this && cast Type.getClass(c)== cast Type.getClass(this) );
		else
			return [];
	}

	override function update() {
		super.update();

		if( needAutoSelect && !hasSelectedNeighbour() )
			select();
		needAutoSelect = false;
	}
}