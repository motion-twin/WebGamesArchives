//
// $Id: KeyboardController.as,v 1.2 2004/03/12 12:05:22  Exp $
//

class grapiz.gui.KeyboardController 
{
    private var key : Number;
    
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
        key = Key.getCode();
    }
}
//EOF
