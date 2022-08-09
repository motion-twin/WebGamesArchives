// 
// $Id: Desordre.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Coordinate;
import frutibandas.Direction;

class frutibandas.card.Desordre extends Card
{
    public function Desordre()
    {
        super();
        this.id   = Card.DESORDRE;
        this.name = "Desordre";
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    {}
}

//EOF
