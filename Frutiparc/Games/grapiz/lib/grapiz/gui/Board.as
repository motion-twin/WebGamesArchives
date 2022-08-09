//
// $Id: Board.as,v 1.8 2004/03/12 12:05:22  Exp $
//

import grapiz.Main;
import grapiz.gui.Coordinate;

class grapiz.gui.Board extends MovieClip
{
    public static var LINK_NAME       : String = "mcBoard";
   
    public static var AVAILABLE_DEPTH : Number = 0;
    public static var EXPLOSION_DEPTH : Number = 7;
    public static var TOKENS_DEPTH    : Number = 8;

    private var editSlots : Array;
    private var tokens : Array;
    private var moves  : Array;
    
    /** Static constructor. */
    public static function New( parent : MovieClip ) : Board 
    { // {{{
        var depth : Number = parent.getNextHighestDepth();
        var mc    : MovieClip = parent.attachMovie("mcBoard", "mcBoard_"+depth, depth);
        return Board( mc );
    } // }}}

    public function hideAvailableMoves() : Void
    { // {{{
        for (var i=0; i<this.moves.length; i++) {
            if (this.moves[i]) {
                this.moves[i].destroy();
                this.moves[i] = null;
            }
        }
    } // }}}
    
    public function showAvailableMoves( token : grapiz.gui.Token ) : Void
    { // {{{
        var coordinate : grapiz.gui.Coordinate = new grapiz.gui.Coordinate( token._x, token._y );
        var logicCoord : grapiz.Coordinate     = grapiz.Convert.getLogicCoordinate( coordinate );
        var list : Array = grapiz.Main.game.getBoard().availableMoves( logicCoord );
        for (var i=0; i<list.length; i++) {
            var move : grapiz.AvailableMove = list[i];
            this.moves[i] = grapiz.gui.AvailableSlot.New(this, AVAILABLE_DEPTH+i);
            this.moves[i].setPosition( grapiz.Convert.getGuiCoordinate( move.target ) );
            this.moves[i].setMoveDirection( move.direction );
            this.moves[i].show();
        }
    } // }}}

    public function showEditionSlots() : Void
    {
        this.editSlots = new Array();
        var pos : Array = grapiz.Convert.getGuiPositions();
        for (var i=0; i<pos.length; i++) {
            var c = pos[i];
            var s = grapiz.gui.EditSlot.New( this, c );
            editSlots.push(s);
        }
    }

    public function getEditionSlots() : Array { 
        return editSlots; 
    }
    
    public function getCurrentAvailableMoves() : Array
    { // {{{
        return this.moves;
    } // }}}
    
    public function show() : Void 
    { // {{{
        for (var i=0; i<this.tokens.length; i++) {
            this.tokens[i].show();
        }
        this._visible = true;
    } // }}}

    public function playExplosionAt( c:Coordinate ) : Void
    { //{{{
        var anim = this.attachMovie("blow", "Blow", EXPLOSION_DEPTH);
        anim._x = c.x;
        anim._y = c.y;
        anim.play();        
    } //}}}
    
    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------
    
    private function Board() 
    { // {{{
        this.moves  = new Array();
        this.tokens = new Array();
        this.createTokens();
        this.gotoAndStop( grapiz.Main.game.getBoard().getSize() );
    } // }}}

    private function createTokens() : Void
    { // {{{
        var board : grapiz.Board = grapiz.Main.game.getBoard();
        var tokenList : Array    = board.getTokens();
        for (var i=0; i<tokenList.length; i++) {
            var token : grapiz.Token = tokenList[i];
            if (token != undefined) {
                this.tokens.push( this.createToken(token) );
            }
        }
    } // }}}

    private function createToken( token : grapiz.Token ) : grapiz.gui.Token
    { // {{{
        var guiToken : grapiz.gui.Token;
        var target   : grapiz.gui.Coordinate = grapiz.Convert.getGuiCoordinate( token.getCoordinate() );
        guiToken = grapiz.gui.Token.New(this, token.getTeam());
        guiToken.setPosition( target );
        token.setListener( guiToken );
        return guiToken;
    } // }}}
}

//EOF
