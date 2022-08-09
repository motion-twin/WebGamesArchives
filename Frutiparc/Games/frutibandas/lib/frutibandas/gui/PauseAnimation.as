// 
// $Id: PauseAnimation.as,v 1.1 2004/02/10 18:27:30  Exp $
//

import frutibandas.gui.Animable;

/**
 *
 */
class frutibandas.gui.PauseAnimation implements Animable
{
    private static var DEFAULT_PAUSE = 20;
    
    private var step       : Number;

    public function PauseAnimation()
    {
        this.step        = DEFAULT_PAUSE;
    }

    public function update() : Boolean
    {
        this.step--;
        return (this.step > 0);
    }

    public function toString() : String
    {
        return "PauseAnimation";
    }
}

//EOF
