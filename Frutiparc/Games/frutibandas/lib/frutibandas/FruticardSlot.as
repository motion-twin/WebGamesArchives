// 
// $Id: FruticardSlot.as,v 1.4 2004/05/06 11:10:42  Exp $
//

import frusion.client.FrusionClient;
import frutibandas.Main;

class frutibandas.FruticardSlot 
{
    private static var IDX_VICTORY : Number = 0;
    private static var IDX_DEFEAT   : Number = 1;
    private static var IDX_DRAW    : Number = 2;
    private var client      : FrusionClient;
    
    public var $linit : Boolean; // set to true when the league score is modified
    public var $f : Array; // free rooms stats
    public var $l : Array; // league rooms stats
    public var $c : Array; // challenge rooms stats
    public var $ls: Array; // league scores

    public function FruticardSlot( fclient:FrusionClient )
    {
        this.client = fclient;
        var deser : Object = this.client.frutiCard.slots[0];
        
        $linit = false;
        
        if (deser.$linit) $linit = true;
        if (deser.$f  != undefined)  $f = deser.$f;  else $f  = [0,0,0];
        if (deser.$l  != undefined)  $l = deser.$l;  else $l  = [0,0,0];
        if (deser.$c  != undefined)  $c = deser.$c;  else $c  = [0,0,0];
        if (deser.$ls != undefined) $ls = deser.$ls; else $ls = [0,0,0];
     
        // TODO convert deser.$ls[1] to something different than undefined

        Main.debug( this.toString() );
    }
    
    public function newVictory( mode:Number ) : Void
    {
        increment(mode, IDX_VICTORY);
    }
    
    public function newDefeat( mode:Number ) : Void
    {
        increment(mode, IDX_DEFEAT);
    }
    
    public function newDraw( mode:Number ) : Void
    {
        increment(mode, IDX_DRAW);
    }

    public function setLeagueScore( score:Number ) : Void
    {
        $ls[0] = score;                                    // actual score
        if (!$linit || $ls[1] > score) $ls[1] = score; // min score
        if (!$linit || $ls[2] < score) $ls[2] = score; // max score
        $linit = true;
        save();
    }

    private function increment( mode:Number, index:Number ) : Void
    {
        switch (mode) {
            case 0:
                $f[index]++;
                break;
                
            case 1:
                return; // challenge mode does not save its value anymore
                // $c[index]++;
                // break;
                
            case 2:
                $l[index]++;
                break;
                
            default:
                // Main.debug("FruticardSlot::increment() unknown mode "+mode);
                break;
        }
        save();
    }

    private function save() : Void
    {
        var o : Object = new Object();
        o.$linit = $linit;
        o.$f = $f;
        o.$c = $c;
        o.$l = $l;
        o.$ls = $ls;

        Main.debug( this.toString() );
        
        this.client.frutiCard.updateSlot(0, o);
    }

    public function toString() : String
    {
        var result : String = "";
        result += "FrutiCard slot : \n";
        result += "  + free wins="  + $f[0]  + " defeats=" + $f[1]  + " draws=" + $f[2]  + "\n";
        result += "  + chal wins="  + $c[0]  + " defeats=" + $c[1]  + " draws=" + $c[2]  + "\n";
        result += "  + leag wins="  + $l[0]  + " defeats=" + $l[1]  + " draws=" + $l[2]  + "\n";
        result += "  + leag score=" + $ls[0] + " min="     + $ls[1] + " max="   + $ls[2] + "\n";
        return result;
    }
}

//eof
