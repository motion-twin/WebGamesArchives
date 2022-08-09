// 
// $Id: AnimCardDisapear.as,v 1.1 2004/02/10 18:27:30  Exp $
//

import frutibandas.gui.CardSlot;
import frutibandas.gui.Animable;

class frutibandas.gui.AnimCardDisapear implements Animable
{
    private static var ANIM_WAIT = 20;

    private var wait    : Number;
    private var card    : CardSlot;
    
    public function AnimCardDisapear(card:CardSlot)
    {
        this.wait = 0;
        this.card = card;
    }
    
    public function update() : Boolean
    {
        this.wait++;
        if (this.wait >= ANIM_WAIT) {
            this.card.vanish();
            return false;
        }
        return true;
    }
}

//EOF
