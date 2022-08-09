//
// $Id: BoardMask.as,v 1.5 2004/03/11 11:35:19  Exp $
//

import frutibandas.Main;
import frutibandas.Coordinate;
import frutibandas.gui.Board;

class frutibandas.gui.BoardMask extends MovieClip
{
    private var requiresUpdate : Boolean = true;

    public static function New( board:frutibandas.gui.Board ) : BoardMask
    { //{{{
        var depth  : Number    = board.getNextHighestDepth();
        var result : BoardMask = BoardMask( board.attachMovie("mcBoardMask", "BoardMask_"+depth, depth) );
        return result;
    } //}}}

    public function boardModified() : Void 
    { //{{{
        this.requiresUpdate = true;
    } //}}}

    public function update() : Void
    { //{{{
        if (!requiresUpdate) return;
        requiresUpdate = false;
        
        this.clear();
        
        var board : frutibandas.Board = Main.game.getBoard();
        var size  : Number            = Main.game.getBoard().getSize();
        
        for (var line=0; line<size; line++) {
            var height : Number = Board.SlotSize;
            for (var column=0; column<size; column++) {
                var slot : Number = board.getElement(new Coordinate(column, line));
                if (slot != frutibandas.Board.DESTROYED && slot != frutibandas.Board.TRAPPED) {
                    this.beginFill(0x0000FF);
                    var x = column*Board.SlotSize;
                    var y = line*Board.SlotSize;
                    this.moveTo( x, y );
                    this.lineTo( x + Board.SlotSize, y );
                    this.lineTo( x + Board.SlotSize, y + height );
                    this.lineTo( x, y + height );
                    this.lineTo( x, y );
                    this.endFill();
                }
            }
        }
    } //}}}
}

//EOF
