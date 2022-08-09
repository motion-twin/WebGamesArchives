package mt.deepnight.mui;

import flash.display.Sprite;
import mt.deepnight.Color;

class Radio extends Check {
	var needAutoSelect			: Bool;
	

	public function new(p, label:String, ?selected=false, cb:Bool->Void) {
		super(p, label, selected==true, cb);
		
		if( selected ) {
			select();
			needAutoSelect = false;
		}
		else {
			unselect();
			needAutoSelect = true;
		}
		
		hideCheckBox();
	}

	override function onClick(e:flash.events.MouseEvent) {
		e.stopPropagation();
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
		
	override function renderCheck() {
		check.graphics.clear();
		if( hasState("selected") ) {
			check.graphics.beginFill( 0xffffff, 1 );
			check.graphics.drawCircle(Check.CHECK_WID*0.5, Check.CHECK_WID*0.5, Check.CHECK_WID*0.5);
		}
		else {
			check.graphics.beginFill( Color.brightnessInt(color, -0.2), 1 );
			check.graphics.lineStyle( 1, 0x0, 0.3);
			check.graphics.drawCircle(Check.CHECK_WID*0.5, Check.CHECK_WID*0.5, Check.CHECK_WID*0.5);
		}
		updateCheckFilters();
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