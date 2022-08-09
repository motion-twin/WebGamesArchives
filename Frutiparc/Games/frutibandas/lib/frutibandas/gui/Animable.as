// 
// $Id: Animable.as,v 1.1 2004/02/10 18:27:30  Exp $
//

interface frutibandas.gui.Animable
{
    /**
     * Animable objects must return 'false' in this method to be 
     * unregistered from the animation process.
     *
     * This method is called on each frame so Animable can process their 
     * animation.
     */
    public function update() : Boolean;
}

//EOF
