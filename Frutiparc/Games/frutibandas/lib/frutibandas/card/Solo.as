// 
// $Id: Solo.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Solo extends Card
{
    public function Solo()
    {
        super();
        this.id   = Card.SOLO;
        this.name = "Solo";
        this.requiresTarget = true;
        this.targetTeam     = true;
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    {
        game.setNextSolo(team, c);
    }
}

//EOF
