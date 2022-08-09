//
// $Id: Convert.as,v 1.6 2004/03/12 12:05:22  Exp $
//

import grapiz.Direction;

/**
 * Manage board to gui coordinate conversion.
 *
 * The prepare() method must be called once on game initialization when the
 * board is defined.
 */
class grapiz.Convert
{
    private static var logicPositions  : Array = null;
    private static var guiPositions    : Array = null;
    private static var boardLineLength : Number = 0;

    /** Convert a logic coordinate to a gui one. */
    public static function getGuiCoordinate( coord : grapiz.Coordinate ) : grapiz.gui.Coordinate
    { //{{{
        var i : Number = coordinateToIndex(coord);
        if (guiPositions[i] == undefined) {
            trace("grapiz.Convert.getGuiCoordinate() : unable to convert "+coord.toString());
            throw new Error("grapiz.Convert.getGuiCoordinate() : unable to convert "+coord.toString());
        }
        return guiPositions[i].copy();
    } //}}}

    /** Convert a gui coordinate to a logic one. */
    public static function getLogicCoordinate( coord : grapiz.gui.Coordinate ) : grapiz.Coordinate
    { //{{{
        var i : Number = guiCoordinateToIndex(coord);
        if (logicPositions[i] == undefined) {
            trace("grapiz.Convert.getLogicCoordinate() : unable to convert "+coord.toString());
            throw new Error("grapiz.Convert.getLogicCoordinate() : unable to convert "+coord.toString());
        }
        return logicPositions[i].copy();
    } //}}}

    /** Initialize translation between logic coordinates and graphic ones. */
    public static function prepare(board:grapiz.Board, guiCenterX:Number, guiCenterY:Number) : Void
    { //{{{
        if (board == undefined || board == null) {
            throw new Error("grapiz.Convert.prepare() : board parameter undefined");
        }
        if (guiCenterX == undefined) {
            throw new Error("grapiz.Convert.prepare() : guiCenterX undefined");
        }
        if (guiCenterY == undefined) {
            throw new Error("grapiz.Convert.prepare() : guiCenterY undefined");
        }

        guiPositions = new Array();
        logicPositions = new Array();
        boardLineLength = (board.getSize()*2)+1;
       
        var radius : Number = board.getSize();
        var guiOrigin : grapiz.gui.Coordinate = new grapiz.gui.Coordinate(guiCenterX, guiCenterY);        
        guiOrigin.move(Direction.North, radius);
        var guiCursor : grapiz.gui.Coordinate = guiOrigin.copy();
        
        var cursor : grapiz.Coordinate = new grapiz.Coordinate(0,0);
        while (cursor.x <= (radius*2)) {
            while (board.isValid(cursor)) {
                guiPositions  [    coordinateToIndex(cursor)    ] = guiCursor.copy();
                logicPositions[ guiCoordinateToIndex(guiCursor) ] = cursor.copy();
                guiCursor.move(Direction.SouthEast);
                cursor.move(Direction.SouthEast);
            }
            cursor.y = 0;
            cursor.x++;
            if (cursor.x > radius) {
                cursor.y = cursor.x - radius;
                guiOrigin.move(Direction.South);
            }
            else {
                guiOrigin.move(Direction.SouthWest);
            }
            guiCursor = guiOrigin.copy();
        }
    } //}}}

    public static function getGuiPositions() : Array { return guiPositions; }
    
    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------
    
    private static function guiCoordinateToIndex( coord: grapiz.gui.Coordinate ) : Number
    { //{{{
        // return (grapiz.Globals.Width * coord.x) + coord.y;
        return (700 * coord.x) + coord.y;
    } //}}}
    
    private static function coordinateToIndex( coord : grapiz.Coordinate ) : Number
    { //{{{
        return (boardLineLength * coord.x) + coord.y;
    } //}}}
}

//EOF

