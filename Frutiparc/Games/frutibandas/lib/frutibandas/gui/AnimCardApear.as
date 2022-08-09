// 
// $Id: AnimCardApear.as,v 1.1 2004/02/12 17:59:18  Exp $
//

import frutibandas.gui.Animable;
import frutibandas.gui.CardSlot;

class frutibandas.gui.AnimCardApear implements Animable
{
    private static var ANIM_STEP = 20;
    
    private var card : CardSlot;
    private var step : Number;
    private var visible : Boolean;
    
    public function AnimCardApear( card:CardSlot, visible:Boolean ) 
    {
        this.step = ANIM_STEP;
        this.card = card;
        this.visible = visible;
    }

    public function update() : Boolean
    {
        if (this.step == ANIM_STEP) {
            if (this.visible) this.card.setCard( this.card.cardId );
            else              this.card.hide();
        }
        this.step--;
        if (this.step <= 0) {
            return false;
        }
        return true;
    }
}

//EOF
