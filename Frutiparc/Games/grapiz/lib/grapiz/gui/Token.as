//
// $Id: Token.as,v 1.8 2004/04/05 17:24:27  Exp $
//

import grapiz.Main;
import grapiz.gui.EditSlot;

class grapiz.gui.Token extends MovieClip implements grapiz.TokenListener
{
    public static var LINK_NAME   : String = "mcToken";

    private var board    : grapiz.gui.Board;
    private var team     : Number;
    private var editSlot : grapiz.gui.EditSlot
    

    /** Static constructor. */
    public static function New( board : grapiz.gui.Board, team : Number ) : Token
    { // {{{
        var mcName : String = LINK_NAME;
        var depth  : Number = board.getNextHighestDepth() + grapiz.gui.Board.TOKENS_DEPTH;
        var token  : Token  = Token( board.attachMovie(mcName, mcName + "_" + depth, depth) );
        token.board = board;
        token.setTeam(team);
        return token;
    } // }}}
    
    public function getTeam() : Number 
    { // {{{
        return this.team;
    } // }}}

    public function getCoordinate() : grapiz.gui.Coordinate
    { // {{{
        return new grapiz.gui.Coordinate( this._x, this._y );
    } // }}}

    public function onMove( token:grapiz.Token, direction:grapiz.Direction, steps:Number ) : Void 
    { // {{{
        var c : grapiz.gui.Coordinate = new grapiz.gui.Coordinate(this._x, this._y);
        c.move(direction, steps);
       
        Main.animation = new grapiz.gui.TokenAnim(this, c, steps);
        Main.debug("animation is ="+Main.animation);
        this.swapDepths( this._parent.getNextHighestDepth() );
        this._alpha = 100;
    } // }}}

    public function onDestroyed() : Void
    { // {{{
        Main.animation.setTokenToDestroy(this);
    } // }}}
    
    public function setPosition( c : grapiz.gui.Coordinate ) : Void
    { // {{{
        this._x = c.x;
        this._y = c.y;
    } // }}}

    public function onPress() : Void
    { // {{{
        if (this.editSlot) {
            this.editSlot.toggleTeam();
            return;
        }
        if (this.team != Main.game.getTeam() 
            || this.team != Main.game.getCurrentTurn() 
            || Main.inputLock
        ) {
            return;
        }
        var moveCursor : grapiz.gui.MoveCursor;
        moveCursor = grapiz.gui.MoveCursor.New( this.board );
        moveCursor.setOriginToken(this);
        moveCursor.show();
        moveCursor.startDrag(true);
        this.board.showAvailableMoves(this);
    } // }}}

    public function show() : Void
    { // {{{
        this._visible = true;
    } // }}}

    public function setTeam( t:Number ) : Void
    { // {{{
        this.team = t;
        this.gotoAndStop(t+1);
    } // }}}

    public function setEditSlot( slot:EditSlot ) : Void 
    {//{{{
        editSlot = slot;
    }//}}}
    
    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------

    private function Token()
    { // {{{
        this.team = undefined;
    } // }}}
}

//EOF

