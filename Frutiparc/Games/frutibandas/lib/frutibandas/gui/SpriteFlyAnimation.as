// 
// $Id
//

import frutibandas.Direction;
import frutibandas.gui.Sprite;

class frutibandas.gui.SpriteFlyAnimation
{
    private var steps     : Number;
    
    private var sprite    : Sprite;
    private var depth     : Number;

    private var xModifier : Number;
    private var yModifier : Number;
    private var speed     : Number;
    
    public function SpriteFlyAnimation( sprite:Sprite, depth:Number, direction:Direction )
    {
        this.depth  = depth;
        this.sprite = sprite;
        this.steps  = 10;
        if (direction == Direction.Left) {
            this.xModifier = -1;
            this.yModifier =  1;
        }
        if (direction == Direction.Right) {
            this.xModifier =  1;
            this.yModifier =  1;
        }
        this.speed = 8;
        this.sprite.swapDepths(depth);
        this.sprite.playFly(direction);
    }
    
    public function update() : Boolean
    {
        this.steps--;
        if (this.steps <= 0) {
            this.sprite.kill();
            return false;
        }
        this.sprite._xscale *= 1.1;
        this.sprite._yscale *= 1.1;
        this.sprite._x += this.speed * this.xModifier;
        this.sprite._y += this.speed * this.yModifier;
        return true;
    }
}

//EOF
