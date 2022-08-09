// 
// $Id: TestManager.as,v 1.4 2004/03/12 18:11:41  Exp $
//

import frutibandas.Main;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.TestManager extends frutibandas.Manager
{
    public function TestManager()
    {}

    public function quit() 
    {
        frutibandas.Main.debug("frutibandas.TestManager.quit() called");
    }

    public function debugMessage(msg:String)
    {
        trace(msg);
    }

    public function chooseCard(id:Number)
    {
        var enterMovePhase : Boolean = false;
        if (Main.game.getPool().size() == 1) enterMovePhase = true;
        Main.game.cardSelected(Main.game.currentTeam, id, enterMovePhase);
        Main.game.turn(1-Main.game.currentTeam);
    }

    public function move(d:Direction) 
    {
        frutibandas.Main.debug("frutibandas.TestManager.move("+d+")");
        Main.game.move(Main.game.currentTeam, d);
    }
    
    public function playCard(id:Number, c:Coordinate, d:Direction)
    {
        frutibandas.Main.debug("frutibandas.TestManager.playCard("+id+", "+c+", "+d+")");
        Main.game.playCard(Main.game.currentTeam, id, c, d);
        Main.game.turn(1 - Main.game.currentTeam);
    }
    
    public function onCardPlayed(xml:XMLNode) : Void
    {
        frutibandas.Main.debug("onCardPlayed("+xml.toString()+")");
        var team : Number = parseInt( xml.attributes.e );
        var card : Number = parseInt( xml.attributes.c );
        var x    : Number = parseInt( xml.attributes.x );
        var y    : Number = parseInt( xml.attributes.y );
        var d    : Number = parseInt( xml.attributes.d );
        Main.game.playCard(team, card, new Coordinate(x,y), Direction.valueOf(d));
    }
    
    public function sendGame(msg:String)
    {
        Main.game.newMessage("dbg mode:", msg);
    }
}

//EOF
