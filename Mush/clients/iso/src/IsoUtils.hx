package ;

import Types;

/**
 * ...
 * @author de
 */

class IsoUtils
{
	
	public static function getGizmo() : flash.display.MovieClip
	{
		var gizmoX = new flash.display.Sprite();
		var gizmoY = new flash.display.Sprite();
		var gizmoZ = new flash.display.Sprite();
		
		gizmoX.graphics.moveTo(0, 0);
		gizmoY.graphics.moveTo(0, 0);
		gizmoZ.graphics.moveTo(0, 0);
		
		gizmoX.graphics.lineStyle( 2, 0xFF0000 );
		gizmoY.graphics.lineStyle( 2, 0x00FF00 );
		gizmoZ.graphics.lineStyle( 2, 0x0000FF );
		
		var tgtX = new V2DIso().add2( 1, 0);
		gizmoX.graphics.lineTo( tgtX.x, tgtX.y);
		
		var tgtY = new V2DIso().add2( 0, 1);
		gizmoY.graphics.lineTo( tgtY.x, tgtY.y);
		
		gizmoZ.graphics.lineTo( 0,  - V2DIso.R * 0.5);
		
		var mc = new flash.display.MovieClip();
		mc.visible = true;
		
		mc.addChild( gizmoX );
	    mc.addChild( gizmoY );
		mc.addChild( gizmoZ );
		return mc;
	}
	
	public static function teCopy( te : TileEntry ) : TileEntry
	{
		var nu : TileEntry = { setup: Reflect.copy(te.setup),el: cast new ElementEx() };
		Data.setup( nu.el, nu.setup.sheet, nu.setup.frame, nu.setup.index );
		nu.el.x = te.el.x;
		nu.el.y = te.el.y;
		return nu;
	}
}