// 
// $Id: MoveCursor.as,v 1.6 2004/02/25 11:40:21  Exp $
//
import grapiz.gui.Token;
import grapiz.gui.Board;

class grapiz.gui.MoveCursor extends MovieClip
{
    public static var LINK_NAME : String = "mcMoveCursor";

    private var movingToken : Token;
    private var originToken : Token;
    private var board       : Board;
    
    public static function New( board:Board ) : MoveCursor
    { // {{{
        var depth  : Number     = board.getNextHighestDepth();
        var result : MoveCursor = MoveCursor( board.attachMovie(LINK_NAME, LINK_NAME+depth, depth) );
        result.board = board;
        return result;
    } // }}}

    public function onPress() : Void
    { // {{{
        this.stopDrag();
        this._visible = false;
        var target = eval(this._droptarget);
        if (target == this.originToken) {
            // target is origin, move cancelled
            this.originToken._alpha = 100;
        }
        else if (target instanceof Token) {
            // target is a token, search if eatable
            var valid : Boolean = false;
            var moves : Array = this.board.getCurrentAvailableMoves();
            for (var i=0; i<moves.length; i++) {
                if (moves[i] == undefined) {
                    break;
                }
                if (target.getCoordinate().equals( moves[i].getCoordinate() )) {
                    grapiz.Main.game.moveRequest(
                        grapiz.Convert.getLogicCoordinate(this.originToken.getCoordinate()),
                        moves[i].getMoveDirection() 
                    );
                    valid = true;
                    break;
                }
            }
            if (!valid) {
                this.originToken._alpha = 100;
            }
        }
        else if (target instanceof grapiz.gui.AvailableSlot) {
            // target is an available move slot
            grapiz.Main.game.moveRequest(
                grapiz.Convert.getLogicCoordinate(this.originToken.getCoordinate()),
                target.getMoveDirection() 
            );
        }
        else {
            // not slot nor target
            this.originToken._alpha = 100;
        }
        this.board.hideAvailableMoves();
        this.removeMovieClip();
    } // }}}

    public function setOriginToken( t:Token ) : Void
    { // {{{
        this.originToken = t;
        this.originToken._alpha = 50;
        this.setPosition( t.getCoordinate() );
        var d : Number = this.getNextHighestDepth();
        this.movingToken = Token( this.attachMovie(Token.LINK_NAME, "AT_"+d, d));
        this.movingToken.setTeam( this.originToken.getTeam() );
    } // }}}

    public function setPosition( c:grapiz.gui.Coordinate ) : Void
    { // {{{
        this._x = c.x;
        this._y = c.y;
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

    private function MoveCursor()
    { // {{{
        this.originToken = null;
        this.movingToken = null;
    } // }}}
}

//EOF
