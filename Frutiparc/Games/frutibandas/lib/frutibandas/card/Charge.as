// 
// $Id: Charge.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;

import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

/**
 * The player's next move will be duplicated.
 */
class frutibandas.card.Charge extends Card
{
    public function Charge()
    {
        super();
        this.id   = Card.CHARGE;
        this.name = "Charge";
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void 
    {
    }
}

//EOF
