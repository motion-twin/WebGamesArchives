// 
// $Id: CardPool.as,v 1.4 2004/05/06 11:10:42  Exp $
//

class frutibandas.CardPool
{
    private var cards : Array;
    
    public function CardPool( xmlAttribute:String )
    {
        this.cards = new Array();
        var list : Array = xmlAttribute.split(":");
        for (var i=0; i<list.length; i++) {
            this.cards.push( parseInt(list[i]) );
        }
    }

    public function remove( cardID:Number ) : Void
    {
        for (var i=0; i<this.cards.length; i++) {
            if (this.cards[i] == cardID) {
                this.cards.splice(i, 1);
                return;
            }
        }
        // throw new Error("Card "+cardID+" not found in CardPool");
    }

    public function getIdOf( index:Number ) : Number
    {
        return this.cards[index];
    }

    public function size() : Number
    {
        return this.cards.length;
    }

    public function toString() : String
    {
        var result : String = "CardPool[ ";
        for (var i=0; i<this.cards.length; i++) {
            result += this.cards[i] + " ";
        }
        result += "]";
        return result;
    }
}

//EOF
