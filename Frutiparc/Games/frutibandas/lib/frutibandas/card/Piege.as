// 
// $Id: Piege.as,v 1.6 2004/03/11 11:35:19  Exp $
//

import frutibandas.Main;
import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Board;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Piege extends Card
{
    public function Piege()
    {
        super();
        this.id   = Card.PIEGE;
        this.name = "Piege";
        this.requiresTarget = true;
        this.targetFreeSlot = true;
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    {
        if (Main.game.board.getElement(c) != Board.DESTROYED && hiden) {
            Main.game.board.setTrapped(c);
        }
        else {
            Main.game.board.destroy(c);
        }
    }  
}

//EOF
