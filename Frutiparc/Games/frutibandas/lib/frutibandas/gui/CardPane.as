// 
// $Id: CardPane.as,v 1.6 2004/05/17 16:12:42  Exp $
//

import frutibandas.Main;
import frutibandas.gui.PlayerInfo;
import frutibandas.gui.CardSlot;

/**
 * Manage graphically the player card list.
 *
 * Usage:
 *
 *     var cardPane : CardPane = CardPane.New( playerInfoMC );
 *     cardPane.push( frutibandas.Card.DESORDRE );
 *     cardPane.push( frutibandas.Card.SOLO );
 *      ...
 *     cardPane.remove( frutibandas.Card.DESORDRE );
 *      ...
 *     cardPane.clear();
 */
class frutibandas.gui.CardPane
{
    private var visible    : Boolean;
    private var playerPane : PlayerInfo;
    private var slots      : Array;
   
    /**
     * Static constructor.
     *
     * Create a new CardPane on parent player info.
     */
    public static function New( playerInfo:PlayerInfo ) : CardPane    
    { 
        var result : CardPane = new CardPane(playerInfo);
        return result;
    } 

    /** 
     * Toggle cards visibility. 
     */
    public function setVisible( bool:Boolean ) : Void
    { 
        this.visible = bool;
    } 
    
    /** 
     * Remove all slots in this pane. 
     */
    public function clear() : Void 
    { 
        for (var i=0; i<this.slots.length; i++) {
            var slot : CardSlot = this.slots[i];
            if (slot.cardId != null) {
                slot.vanish();
            }
            slot.cardId = null;
        }
    } 

    /** 
     * Remove first card matching specified id from pane. 
     */
    public function remove( cardID:Number ) : Void 
    { 
        var slot : CardSlot = this.findSlot(cardID);
        slot.cardId = null;
        Main.pushAnimation(new frutibandas.gui.AnimCardDisapear(slot), Main.ANIM_PRIO_DEL_CARD);
    } 
   
    /** 
     * Make specified card appear in first empty slot. 
     */
    public function pushAnimated( cardID:Number ) : Void
    { 
        var slot : CardSlot = this.findSlot(null);
        slot.cardId = cardID;
        Main.pushAnimation(new frutibandas.gui.AnimCardApear(slot, visible), Main.ANIM_PRIO_APP_CARD);
    } 
    
    /** 
     * Add a card to this pane. 
     */
    public function push( cardID:Number ) : Void 
    { 
        var slot : CardSlot = this.findSlot(null);
        if (visible) {
            slot.cardId = cardID;
            slot.setCard(cardID);
        }
        else {
            slot.cardId = cardID;
            slot.hide();
        }
    } 

    /** 
     * Specified card is played, turn/highlight it then remove it. 
     */
    public function play( cardID:Number ) : Void
    { 
        var slot : CardSlot = this.findSlot(cardID);

        if (slot == null) {
            return;
        }
        
        if (visible == false) {
            slot.turned();
        }
        
        slot.cardId = null;
        Main.pushAnimation(new frutibandas.gui.AnimCardDisapear(slot), Main.ANIM_PRIO_CARD_PLAY)
    } 
    
    
    // ----------------------------------------------------------------------
    // PRIVATES 
    // ----------------------------------------------------------------------

    /** 
     * Constructor. 
     */
    private function CardPane( playerPane:PlayerInfo)
    { 
        this.playerPane = playerPane;
        this.slots      = new Array();
        this.visible    = false;
        this.createSlots();
    } 

    private function createSlots() : Void
    { 
        var csWidth  : Number = CardSlot.WIDTH;
        var csHeight : Number = CardSlot.HEIGHT;
        var padding  : Number = (this.playerPane._width - (2 * PlayerInfo.CARD_MARGIN) - (2 * csWidth)) / 3;
            
        for (var i=0; i<8; i++) {
            var col  = i % 2;
            var line = Math.floor( i / 2 );
            var slot : CardSlot = CardSlot( this.playerPane.attachMovie("mcCardSlot", "CardSlot_"+i, this.playerPane.getNextHighestDepth()) );
            slot._x = PlayerInfo.CARD_MARGIN + padding + ( col * csWidth ) + ( col * padding );
            slot._y = PlayerInfo.CARD_SLOT_Y + PlayerInfo.CARD_SPACING + (line * csHeight);
            slot.cardId = null;
            slot.interfacePlayer = this.playerPane;
            this.slots.push(slot);
        }
    } 

    private function findSlot( cardID:Number ) : CardSlot
    { 
        for (var i=0; i<this.slots.length; i++) {
            var slot : CardSlot = this.slots[i];
            if (slot.cardId == cardID) {
                return slot;
            }
        }
        return null;
    } 
}

//EOF
