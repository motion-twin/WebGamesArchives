// 
// $Id: Vachette.as,v 1.6 2004/02/16 17:42:20  Exp $
//

import frutibandas.Main;
import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Board;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Vachette extends Card
{
    public function Vachette()
    {
        super();
        this.id             = Card.VACHETTE;
        this.name           = "Vachette";
        this.requiresTarget = true;
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    {
        c.y = 0;

        var anim = new frutibandas.gui.options.Vachette(c);
        
        // push each collided sprites to the vachette sprite collision list
        var board : frutibandas.Board = Main.game.getBoard();
        while (c.y < board.getSize()) {
            var element : Number = board.getElement(c);
            if (element > Board.FREE) {
                board.decTeamCounter(element);
            }
            board.setElement(c, Board.FREE);
            anim.addCollisionStep( Main.gameUI.board.getSpriteAt(c) );
            c.y++;
        }
        
        // clean up removed borders
        Main.getAnimControl().push(anim, Main.ANIM_PRIO_CARD);
        board.removeEmptyBorders();
    }
}

//EOF
