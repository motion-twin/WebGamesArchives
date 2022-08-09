// 
// $Id: Petrification.as,v 1.5 2004/02/16 17:42:20  Exp $
//

import frutibandas.Card;

import frutibandas.Main;
import frutibandas.Game;
import frutibandas.Board;
import frutibandas.Direction;
import frutibandas.Coordinate;

import frutibandas.gui.options.Stone;

class frutibandas.card.Petrification extends Card
{
    public function Petrification()
    {
        super();
        this.id   = Card.PETRIFICATION;
        this.name = "Petrification";
        this.requiresTarget = true;
        this.targetSprite   = true;
    }

    public function execute(game:Game, team:Number, c:Coordinate, d:Direction) : Void
    {
        var board   : Board  = game.getBoard();
        var element : Number = board.getElement(c);
        if (element > Board.FREE) {
            var anim : Stone = new Stone(c);
            
            board.setElement(c, Board.ROCK);
            board.decTeamCounter(element);

            board.removeEmptyBorders();
            Main.getAnimControl().push( anim, Main.ANIM_PRIO_CARD );
        }
    }
}

//EOF
