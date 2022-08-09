// 
// $Id: Vachette.as,v 1.3 2004/03/01 14:06:30  Exp $
//

import frutibandas.Main;
import frutibandas.Direction;
import frutibandas.Coordinate;

import frutibandas.gui.Animable;
import frutibandas.gui.Board;
import frutibandas.gui.Sprite;
import frutibandas.gui.SpriteFlyAnimation;

/**
 * Manage the vachette option effect.
 *
 * This animation 
 *  - draws the mcVachette movie clip
 *  - draws puf movie clips behind the vachette
 *  - make collided sprites fly in the air and disapear.
 */
class frutibandas.gui.options.Vachette implements Animable
{
    private static var SYMBOL_COW : String = "mcVachette";
    private static var SYMBOL_PUF : String = "mcSmoke";

    private static var COW_SPEED    : Number = 4;
    private static var PUF_INTERVAL : Number = 8;
    
    private var startCoord : Coordinate;
    private var cowMovie   : MovieClip;
    private var step       : Number;
    private var sprites    : Array;
    private var nextPuf    : Number;
    private var pufDepth   : Number;
    private var subAnimations : Array;
    private var moveCompleted : Boolean;
    private var direction     : Direction;
    private var nextThrow     : Number;
    private var endY          : Number;

    public var flCompleted : Boolean;
    
    public function Vachette( c:Coordinate )
    {
        this.direction     = Direction.Right;
        this.nextThrow     = 0;
        this.moveCompleted = false;
        this.flCompleted = false;
        this.startCoord = c;
        
        var depth : Number = Board.EFFECTS_BOT_DEPTH + 100;
        this.cowMovie      = Main.gameUI.board.attachMovie(SYMBOL_COW, SYMBOL_COW+depth, depth);

        var realC : Coordinate = Main.gameUI.board.getBandasRealCoordinate(c);
        this.cowMovie._x = realC.x;
        this.cowMovie._y = Main.game.getBoard().getMinY() * (frutibandas.gui.Board.SlotSize);

        this.sprites = new Array();
        this.subAnimations = new Array();

        this.endY = frutibandas.gui.Board.SlotSize * (Main.game.getBoard().getMaxY() +1);
    }

    public function update() : Boolean
    {
        this.updatePuf();
        this.updatePos();
        this.updateSubAnimations();
        this.updateState();
        return !this.flCompleted;
    }

    private function updateState() : Void
    {
        this.flCompleted = (this.moveCompleted && (this.subAnimations.length == 0));
    }

    private function updatePos() : Void
    {
        this.cowMovie._y += COW_SPEED;
        if ((this.cowMovie._y) > this.nextThrow) {
            this.nextThrow = this.nextThrow + frutibandas.gui.Board.SlotSize;
            var sprite : Sprite = Sprite( this.sprites.shift() );
            if (sprite != null && sprite != undefined) {
                var depth : Number = Board.EFFECTS_TOP_DEPTH + 10 - this.sprites.length;
                this.direction = this.direction.oposite();
                var anim  : SpriteFlyAnimation = new SpriteFlyAnimation(sprite, depth, direction);
                this.subAnimations.push(anim);
            }
        }
        if (this.cowMovie._y >= this.endY) {
            this.moveCompleted = true;
            this.cowMovie.removeMovieClip();
        }
    }
    
    private function updatePuf() : Void
    {
        this.nextPuf--;
        if (this.nextPuf <= 0) {
            this.nextPuf = PUF_INTERVAL + Math.random(6);
            
            var depth = this.getNextPufDepth();
            var puf   = Main.gameUI.board.attachMovie(SYMBOL_PUF, SYMBOL_PUF+depth, depth);
            puf._x = this.cowMovie._x + Math.random(5);
            puf._y = this.cowMovie._y - 5;
        }
    }

    private function updateSubAnimations() : Void
    {
        if (this.subAnimations.length > 0) {
            for (var i=0; i<this.subAnimations.length; i++) {
                var anim : SpriteFlyAnimation = this.subAnimations[i];
                if (!anim.update()) {
                    subAnimations.splice(i, 1);
                }
            }
        }
    }

    public function addCollisionStep( s:Sprite ) : Void
    {
        this.sprites.push(s);
    }

    private function getNextPufDepth() : Number
    {
        this.pufDepth++;
        if (this.pufDepth >= 50) {
            this.pufDepth = 0;
        }
        return this.pufDepth + Board.EFFECTS_BOT_DEPTH;
    }
}

//EOF

