package actor;
import mt.Timer;

using Ex;
import Protocol;
/**
 * ...
 * @author de
 */

class Drone extends ItemActor
{
	var height : Float;
	var nextMoveTimer : Float; 
	
	public static inline var TickLen =  2;
	
	public function new(g : Grid, id :_ItemDesc) 
	{
		super( g, id);
		
		height = 2;
		nextMoveTimer = TickLen;
		
		var fr = grid.randomFree();
		if ( fr != null)
		{
			var grP = fr.getGridPos();
			setPos( grP.x, grP.y );
			update();
		}
	}

	public override function update()
	{
		super.update();
		
		var p = pos.toGrid();
		setPos3( p.x, p.y , height + Math.sin( mt.Timer.oldTime * 0.001 * 3 ) * 0.3 );
		
		nextMoveTimer -= Timer.deltaT;
		
		if ( nextMoveTimer <= 0)
		{
			var possD = [];
			
			var t = new V2I(); 
			for ( i in Dirs.LIST)
			{	
				t.x = p.x + i.x;
				t.y = p.y + i.y;
				if ( grid.isPathable( t.x, t.y ) )
					possD.pushBack( t.clone() );
			}
				
			var fin = possD.random();
			
			if ( fin != null)
			{
				//if ( fin.x < p.x || fin.y < p.y )
				te.setup.frame = 0;
				//else te.setup.frame = 1;
					
				te.el.goto( te.setup.frame, te.setup.index );
				
				new fx.Tween<Float>( 0.575, p.x, fin.x, function(v) setPos3( v,pos.toGridF().y,pos3.z ) ).interp( MathEx.lerp );
				new fx.Tween<Float>( 0.575, p.y, fin.y, function(v) setPos3( pos.toGridF().x,v,pos3.z ) ).interp( MathEx.lerp );
			}
				
			nextMoveTimer = TickLen + Dice.rollF( -0.5, 0.5);
		}
	}
	
}


