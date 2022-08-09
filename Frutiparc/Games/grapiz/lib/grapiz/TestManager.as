//
// $Id: TestManager.as,v 1.4 2004/03/04 18:23:50  Exp $
//

import grapiz.Main;

/**
 * This class is used to simulate a grapiz.Manager when the game is ran in
 * debug mode. 
 */
class grapiz.TestManager extends grapiz.Manager
{
    public function TestManager() 
    {}
    
    public function quit() 
    { 
        trace("grapiz.TestManager.quit() called"); 
    }
    
    public function debugMessage(msg:String) 
    { 
        trace(msg); 
    }

    public function move(c:grapiz.Coordinate, d:grapiz.Direction)
    {
        Main.game.move(c.x, c.y, d.toNumber());
        var turn = (Main.game.getCurrentTurn() + 1) % Main.game.getNumberOfTeams();
        Main.game.turn( turn );
        Main.game.setTeam( Main.game.getCurrentTurn() );
        // trace(Main.game.getBoard());
    }
}

//EOF
