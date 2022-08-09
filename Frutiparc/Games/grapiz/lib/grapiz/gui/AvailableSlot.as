// 
// $Id: AvailableSlot.as,v 1.5 2004/02/25 11:40:21  Exp $
//

import grapiz.Direction;
import grapiz.gui.Board;

/**
 * Da macross shield movieclip.
 *
 * Appears on slots the player can move the current selected token onto.
 */
class grapiz.gui.AvailableSlot extends MovieClip 
{
    public static var LINK_NAME : String = "mcAvailableSlot";

    private var direction : grapiz.Direction;
    
    /** Static constructor. */
    public static function New( board:Board, idx:Number) : AvailableSlot
    { // {{{
        return AvailableSlot( board.attachMovie(LINK_NAME, LINK_NAME+idx, idx) );
    } // }}}

    public function setPosition( c:grapiz.gui.Coordinate ) : Void
    { // {{{
        this._x = c.x;
        this._y = c.y;
    } // }}}

    public function getCoordinate() : grapiz.gui.Coordinate
    { // {{{
        return new grapiz.gui.Coordinate(this._x, this._y);
    } // }}}

    public function setMoveDirection( d:grapiz.Direction ) : Void
    { // {{{
        this.direction = d;
    } // }}}

    public function getMoveDirection() : grapiz.Direction
    { // {{{
        return this.direction;
    } // }}}
    
    public function show() : Void
    { // {{{
        this._visible = true;
    } // }}}

    public function destroy() : Void
    { // {{{
        this._visible = false;
        this.removeMovieClip();
    } // }}}

    
    // ----------------------------------------------------------------------
    // Callbacks
    // ----------------------------------------------------------------------
    
    public function onPress() : Void
    { // {{{
        trace("AvailableSlot on press");
    } // }}}

    
    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------
    
    private function AvailableSlot() 
    { // {{{
    } // }}}

}

//EOF
