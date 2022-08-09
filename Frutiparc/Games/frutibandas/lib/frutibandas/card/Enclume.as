// 
// $Id: Enclume.as,v 1.5 2004/02/16 17:42:20  Exp $
//

import frutibandas.Main;
import frutibandas.Card;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Enclume extends Card
{
    public function Enclume()
    {
        this.id   = Card.ENCLUME;
        this.name = "Enclume";
        this.requiresTarget = true;
    }

    public function execute(game:frutibandas.Game, team:Number, c:Coordinate, d:Direction) : Void
    {
        var sprite    = Main.gameUI.board.getSpriteAt(c);
        var animation = new frutibandas.gui.options.Enclume(c, sprite);

        game.getBoard().destroy(c);
        game.getBoard().removeEmptyBorders();
        Main.getAnimControl().push(animation, Main.ANIM_PRIO_CARD);
    }
}

//EOF
