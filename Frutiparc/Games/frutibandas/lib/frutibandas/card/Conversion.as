// 
// $Id: Conversion.as,v 1.5 2004/02/16 17:42:20  Exp $
//

import frutibandas.Main;
import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

/**
 * Change the team of a sprite.
 */
class frutibandas.card.Conversion extends Card
{
    public function Conversion()
    {
        this.id   = Card.CONVERSION;
        this.name = "Conversion";
        this.requiresTarget = true;
        this.targetSprite   = true;
    }

    public function execute(game:Game, team:Number, c:Coordinate, d:Direction) : Void
    {
        var board  : frutibandas.Board = game.getBoard();
        var sprite : Number            = board.getElement(c);

        if (sprite > frutibandas.Board.FREE) {
            
            board.decTeamCounter(sprite);
            board.incTeamCounter(1-sprite);
            board.setElement(c, 1-sprite);

            var anim : frutibandas.gui.options.Conversion;
            anim = new frutibandas.gui.options.Conversion(c, 1-sprite);

            Main.gameUI.board.onSpriteConverted(c, 1-sprite);

            Main.getAnimControl().push( anim, Main.ANIM_PRIO_CARD );
        }
    }
}

//EOF
