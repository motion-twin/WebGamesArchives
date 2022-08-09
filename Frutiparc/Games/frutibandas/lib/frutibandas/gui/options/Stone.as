// 
// $Id: Stone.as,v 1.2 2004/02/10 18:26:52  Exp $
//

import frutibandas.Main;
import frutibandas.Coordinate;

import frutibandas.gui.Animable;
import frutibandas.gui.Sprite;

/**
 * Manage the stonification (animation) of a sprite.
 */
class frutibandas.gui.options.Stone implements Animable
{
    private static var ANIM_LENGTH = 16;
    
    private var running : Boolean;
    private var sprite  : Sprite;
    private var coord   : Coordinate;
    private var step    : Number;

    public function Stone( c:Coordinate ) 
    {
        this.sprite  = Main.gameUI.board.getSpriteAt(c);
        this.coord   = c;
        this.step    = ANIM_LENGTH;
        this.running = false;
    }
    
    public function update() : Boolean
    {
        if (!running) {
            sprite.petrify();
            running = true;
        }
        this.step--;
        return (this.step > 0);
    }
}

//EOF
