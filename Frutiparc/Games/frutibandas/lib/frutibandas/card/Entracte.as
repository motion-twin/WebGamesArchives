// 
// $Id: Entracte.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Entracte extends Card
{
    public function Entracte()
    {
        super();
        this.id   = Card.ENTRACTE;
        this.name = "Entracte";
    }

    public function execute( game:Game, team:Number, c:Coordinate, d:Direction ) : Void
    {}
}

//EOF
