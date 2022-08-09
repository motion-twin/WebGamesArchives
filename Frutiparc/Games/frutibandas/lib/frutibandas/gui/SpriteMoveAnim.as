// 
// $Id: SpriteMoveAnim.as,v 1.1 2004/02/10 18:27:30  Exp $
//

import frutibandas.Main;
import frutibandas.Direction;
import frutibandas.Coordinate;

import frutibandas.gui.Animable;
import frutibandas.gui.Sprite;

class frutibandas.gui.SpriteMoveAnim implements Animable
{
    public static var MOVE   : Number = 1;
    public static var PUSHED : Number = 2;
    public static var FALL   : Number = 3;
    
    private static var ANIM_STEPS       : Number = 5;
    private static var WAIT_BEFORE_FALL : Number = 10;
    
    private var moveType    : Number;
    private var moveAnim    : String;
    private var sprite      : Sprite;
    private var origin      : Coordinate;
    private var direction   : Direction;
    private var target      : Coordinate;
    private var started     : Boolean;
    private var wait        : Number;
    private var step        : Number;

    public function SpriteMoveAnim(sprite:Sprite, origin:Coordinate, d:Direction, t:Number)
    {
        this.moveAnim = "";
        this.sprite = sprite;
        this.origin = origin;
        this.direction = d;
        this.target    = origin.copy();
        this.target.move(d);
        this.started     = false;
        if (t == FALL) {
            this.step    = 0;
            this.wait    = WAIT_BEFORE_FALL;
        }
        else {
            this.wait = random(3);
            this.step = ANIM_STEPS;
        }
        this.moveType    = t;
        this.target = Main.gameUI.board.getBandasRealCoordinate(this.target);
    }

    private function prepare() : Void
    {
        var d = this.direction.toNumber();
        if ( d == 3 ) {
            this.sprite._xscale = -100;
            d = 1;
        }
        else {
            this.sprite._xscale = 100;
        }
        this.sprite.x = this.target.x;
        this.sprite.y = this.target.y;
                
        switch (this.moveType) {
            case MOVE:
                this.moveAnim = "jump"+d;
                break;
            case PUSHED:
                this.moveAnim = "push"+d;
                break;
            case FALL:
                this.moveAnim = "fall";
                this.sprite._x = this.target.x;
                this.sprite._y = this.target.y;
                break;
        }
    }

    public function update() : Boolean
    {
        if (this.wait > 0) {
            this.wait--;
            return true;
        }
        else if (this.wait == 0) {
            this.prepare();
            this.sprite.fruit.gotoAndPlay(this.moveAnim);
            this.wait = -1;
            return true;
        }
        else {
            this.step--;
            return (this.step > 0);
        }
    }

    public function toString() : String
    {
        return "SpriteMoveAnim";
    }
}

//EOF
