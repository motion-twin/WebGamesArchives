// 
// $Id: Celerite.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

/**
 * The player will be able to move twice.
 */
class frutibandas.card.Celerite extends Card
{
    public function Celerite()
    {
        super();
        this.id   = Card.CELERITE;
        this.name = "Celerite";
    }

    public function execute(game:Game, team:Number, c:Coordinate, d:Direction) : Void
    {
    }
}

//EOF
