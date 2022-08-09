// 
// $Id: EditSlot.as,v 1.1 2004/05/07 15:10:19  Exp $
//

import grapiz.gui.*;

class grapiz.gui.EditSlot extends MovieClip
{
    public static var LINK_NAME : String = "mcEditSlot";

    private var coordinate : Coordinate;
    private var team       : Number;
    private var token      : Token;
    private var board      : Board;
    

    
    public static function New( board:Board, c:Coordinate ) : EditSlot
    {//{{{
        var depth = board.getNextHighestDepth();
        var mc    = board.attachMovie(LINK_NAME, LINK_NAME+depth, depth);
        var slot  = EditSlot( mc );
        slot.team = -1;
        slot.setBoard( board );
        slot.setCoordinate( c );
        slot.show();
        return slot;
    }//}}}

    public function getCoordinate() : Coordinate
    {//{{{
        return coordinate;
    }//}}}
    
    public function setCoordinate( c:Coordinate ) : Void
    {//{{{
        coordinate = c;
        _x = c.x;
        _y = c.y;
    }//}}}

    public function getTeam() : Number
    {//{{{
        return team;
    }//}}}

    public function show() : Void
    {//{{{
        token = Token.New( this.board, team );
        token.setPosition( this.coordinate );
        token._visible = false;
        token.setEditSlot( this );
    }//}}}

    public function toggleTeam() : Void
    {//{{{
        team = grapiz.Main.editTeam;
        if (team == -1) {
            token._visible = false;
        }
        else {
            token._visible = true;
            token.setTeam( team );
        }
    }//}}}

    public function onRelease() : Void
    {//{{{
        toggleTeam();
    }//}}}

    
    // ----------------------------------------------------------------------
    // Private methods
    // ----------------------------------------------------------------------
    
    private function EditSlot()
    {//{{{
        team = -1;
    }//}}}

    private function setBoard( b:Board ) : Void
    {//{{{
        board = b;
    }//}}}
}
//EOF
