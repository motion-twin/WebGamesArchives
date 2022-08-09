// 
// $Id: AnimCardTurn.as,v 1.1 2004/02/10 18:27:30  Exp $
//

import frutibandas.gui.CardSlot;
import frutibandas.gui.Animable;

public class frutibandas.gui.AnimCardTurn implements Animable
{
    private static var ANIM_STEPS = 5;

    private var step : Number;
    private var card : CardSlot;
    
    public function AnimCardTurn(card:CardSlot)
    {
        this.step = ANIM_STEPS;
        this.card = card;
    }

    public function update() : Boolean
    {
        return false;
    }
}

//EOF
