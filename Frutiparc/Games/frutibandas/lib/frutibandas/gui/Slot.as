//
// Copyright (c) 2004 Motion-Twin
//
// $Id: Slot.as,v 1.8 2004/02/25 13:03:59  Exp $
//

import frutibandas.Main;
import frutibandas.Coordinate;
import frutibandas.gui.Board;
import frutibandas.gui.Animable;

/**
 * Slot representation.
 */
class frutibandas.gui.Slot extends MovieClip implements Animable
{
    public static var symbolName : String = "mcSquare";
    public static var animLength : Number = 8;

    private var animStep    : Number;
    private var running     : Boolean;

    /** Static constructor. */
    public static function New( board:Board, c:Coordinate, depth:Number ) : Slot
    { // {{{
        if (depth == undefined) {
            depth = board.getNextHighestDepth();
        }
        var slot  : Slot = Slot( board.attachMovie(symbolName, symbolName+depth, depth) );
        var guiCoordinate : Coordinate = board.getBandasRealCoordinate(c);
        slot._x = guiCoordinate.x;
        slot._y = guiCoordinate.y;
        slot.stop();
        return slot;
    } // }}}

    public function start() : Void
    { // {{{
        this.running     = true;
        this.animStep    = animLength;
        this.gotoAndPlay("destroy");
    } // }}}
    
    public function update() : Boolean
    { // {{{
        if (!running) this.start();
        
        this.animStep--;
        if (this.animStep <= 0) {
            return false;
        }
        return true;
    } // }}}
    
    public function toString() : String
    { // {{{
        return "Slot";
    } // }}}

    
    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------

    private function Slot()
    { // {{{
        this.animStep = animLength;
    } // }}}
}

