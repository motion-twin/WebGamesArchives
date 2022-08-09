// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: BoardListener.as,v 1.9 2004/03/11 11:35:19  Exp $
// 
import frutibandas.Coordinate;
import frutibandas.Direction;

/**
 * Receive board events.
 */
interface frutibandas.BoardListener 
{
    /**
     * Called whenever a slot is destroyed.
     */
    function onSlotDestroyed( coordinate:Coordinate ) : Void;
    function onSlotTrapped( coordinate:Coordinate ) : Void;
    function onTrapDiscovered( coordinate:Coordinate ) : Void;

    function onMoveBegin( d:Direction ) : Void;
    function onSpriteMove( c:Coordinate, d:Direction, pushed:Boolean ) : Void;
    function onMoveDone() : Void;
}

