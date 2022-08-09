// 
// $Id: Confiscation.as,v 1.6 2004/03/11 11:35:19  Exp $
//

import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

/**
 * If the oponent play a card this card will be confiscated.
 */
class frutibandas.card.Confiscation extends Card
{
    public function Confiscation()
    {
        super();
        this.id   = Card.CONFISCATION;
        this.name = "Confiscation";
    }

    public function execute(game:Game, team:Number, c:Coordinate, d:Direction, p:Number) : Void
    {
        if ( hiden || p == undefined || isNaN(p) ) {
            // we play the confiscation card which is hidden from oponent
            frutibandas.Main.debug("Confiscation.execute() p:undefined it means that we played the card" );
        }
        else {
            // the confiscation card is now visible
            frutibandas.Main.gameUI.onCardConfiscated(team, p);
        }
    }
}

//EOF
