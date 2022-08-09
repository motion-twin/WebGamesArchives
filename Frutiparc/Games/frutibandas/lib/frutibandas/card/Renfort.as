// 
// $Id: Renfort.as,v 1.4 2004/02/16 17:42:20  Exp $
//

import frutibandas.Main;
import frutibandas.Card;
import frutibandas.Game;
import frutibandas.Direction;
import frutibandas.Coordinate;

class frutibandas.card.Renfort extends Card
{
    public function Renfort()
    {
        super();
        this.id   = Card.RENFORT;
        this.name = "Renfort";
    }

    public function execute( game:Game, team:Number, co:Coordinate, d:Direction ) : Void
    {
        var xsum = co.x;
        var ysum = co.y;
        
        Main.gameUI.board.onMoveBegin();
        
        var c : Coordinate = new Coordinate();
        if (xsum > 10000) {
            c.x  = Math.floor(xsum / 10000) -1;
            c.y  = Math.floor(ysum / 10000) -1;
            xsum = xsum - (c.x+1) * 10000;
            ysum = ysum - (c.y+1) * 10000;
            this.createReenforcementAt(game, team, c);
        }
        if (xsum > 100) {
            c.x  = Math.floor(xsum / 100) -1;
            c.y  = Math.floor(ysum / 100) -1;
            xsum = xsum - (c.x+1) * 100;
            ysum = ysum - (c.y+1) * 100;
            this.createReenforcementAt(game, team, c);
        }
        if (xsum > 0) {
            c.x = xsum -1;
            c.y = ysum -1;
            this.createReenforcementAt(game, team, c);
        }

        Main.gameUI.board.onMoveDone();
    }

    private function createReenforcementAt(game:Game, team:Number, c:Coordinate)
    {
        Main.game.board.setElement(c, team);
        Main.game.board.incTeamCounter(team);

        var sprite = Main.gameUI.board.createSpriteView(c, team);
        Main.getAnimControl().push( new frutibandas.gui.options.Renfort(sprite, c, team), Main.ANIM_PRIO_CARD );
    }
}

//EOF
