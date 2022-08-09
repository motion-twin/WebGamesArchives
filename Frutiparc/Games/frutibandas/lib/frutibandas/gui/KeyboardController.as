//
// $Id: KeyboardController.as,v 1.11 2004/05/06 11:10:42  Exp $
//

class frutibandas.gui.KeyboardController 
{
    private var key   : Number;
    
    public function KeyboardController()
    {
        key   = -1;
        Key.addListener(this);
    }

    public function hasKey() : Boolean
    {
        return key != -1;
    }

    public function nextKey() : Number
    {
        var result : Number = key;
        key = -1;
        return result;
    }

    public function onKeyUp() 
    {}

    public function onKeyDown()
    {
        if (!frutibandas.Main.pause) { 
            key = Key.getCode();
        }
        else {
            frutibandas.Main.debug("pause, key ignored");
        }
    }
}

//EOF
