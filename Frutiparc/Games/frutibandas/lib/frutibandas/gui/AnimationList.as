// 
// $Id: AnimationList.as,v 1.1 2004/02/10 18:27:30  Exp $
//

import frutibandas.gui.Animable;

/**
 * Serialized animation list.
 *
 * Animations pushed to this list will be played in a serialized way, one after
 * the other.
 *
 * This object may be pushed into an AnimationController or in another 
 * AnimationList to chain an order animations.
 */
class frutibandas.gui.AnimationList implements Animable
{
    private var list        : Array;
    
    public function AnimationList()
    // {{{
    {
        this.list = new Array();
    }
    // }}}
    
    public function push( animatedObject:Animable ) : Void 
    // {{{
    {
        this.list.push(animatedObject);
    }
    // }}}

    public function update() : Boolean
    // {{{
    {
        if (this.list.length > 0) {
            var anim = this.list[0];
            if (!anim.update()) {
                this.list.shift(); 
            }
        }
        return (this.list.length > 0);
    }
    // }}}
    
    public function toString() : String
    // {{{
    {
        var result : String = "AnimationList["+this.list.length+"]\n";
        for (var i=0; i<this.list.length; i++) {
            result += this.list[i].toString() + "\n";
        }
        return result;
    }
    // }}}
}

//EOF
