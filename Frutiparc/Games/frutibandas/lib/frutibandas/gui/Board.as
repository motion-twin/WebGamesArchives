//
// Copyright (c) 2004 Motion-Twin
//
// $Id: Board.as,v 1.23 2004/06/24 11:43:43  Exp $
//
import frutibandas.Main;
import frutibandas.Coordinate;
import frutibandas.Direction;
import frutibandas.gui.Slot;
import frutibandas.gui.Sprite;

class frutibandas.gui.Board extends MovieClip implements frutibandas.BoardListener
{
    public static var SlotSize     : Number = 32;
    public static var BandasHeight : Number = -1;
    
    private var size           : Number;
    private var slots          : Array;
    private var bandas         : Array;
    private var sprites        : Array;

    private var width          : Number;
    private var counter        : Number;

    private static var BOARD_LINE_DEPTH     : Number =    0;
    private static var SLOT_DEPTH           : Number =  100;
    private static var SLOT_ANIM_DEPTH      : Number =  209;
    private static var BOARD_DEPTH          : Number =  210;
    private static var BOARD_MASK_DEPTH     : Number =  211;
    public  static var EFFECTS_BOT_DEPTH    : Number =  500;  // under sprites
    public  static var EFFECTS_TOP_DEPTH    : Number = 2000;  // over sprites

    private static var BANDAS_DEPTH : Number = 1000;

    private var slotsDepth  : Number;
    
    private var boardMask   : frutibandas.gui.BoardMask;
    private var boardLine   : MovieClip;
    private var modified    : Boolean;

    private var borderTop  : Number;
    private var borderLeft : Number;
    private var traps      : Array;

    private var moveAnimation        : frutibandas.gui.AnimationController;
    private var deleteSlotAnimations : frutibandas.gui.AnimationController;
    
    /* 
     * only logic data: a reference to frutibandas.Main.game.board 
     */
    private var board : frutibandas.Board;
    
    /** Static constructor. */
    public static function New( parent:frutibandas.gui.Game ) : Board
    { // {{{
        var result : Board;
        var depth  : Number = parent.getNextHighestDepth();
        result = Board( parent.attachMovie("mcBoard", "mcBoard@"+depth, depth) );
        return result;
    } // }}}

    public function toLogicCoordinate( guiCoord:Coordinate ) : Coordinate
    // {{{
    {
        if (guiCoord.x < this._x || guiCoord.x > (this._x + this.width)) 
            return null;
        if (guiCoord.y < this._y || guiCoord.y > (this._y + this.width))
            return null;

        var result : Coordinate = new Coordinate();
        result.x = Math.floor((guiCoord.x - this._x)/ SlotSize);
        result.y = Math.floor((guiCoord.y - this._y)/ SlotSize);
        return result;
    }
    // }}}
    
    public function getBandasRealCoordinate(c:Coordinate) : Coordinate 
    // {{{
    {
        var result : Coordinate = c.copy();
        result.x = this.borderLeft + (c.x * SlotSize) + (SlotSize/2); // + 5;
        result.y = this.borderTop  + (c.y * SlotSize) + (SlotSize/2); // - (BandasHeight - SlotSize) - 2;
        return result;
    }
    // }}}
    
    public function createSpriteView( c:Coordinate, team:Number ) : Sprite
    // {{{
    {
        var depth    : Number = getDepthOf(c);
        var libName  : String = "mcBandas";
        var mcBandas : Sprite;
        
        counter++;
        mcBandas = Sprite( this.attachMovie(libName, libName+"@"+depth, depth) );
        if (mcBandas == undefined || mcBandas == null) {
            trace("Error : mcBandas not attached");
        }
        BandasHeight = mcBandas._height;

        var realCoordinate : Coordinate = getBandasRealCoordinate(c);
        mcBandas._x   = realCoordinate.x;
        mcBandas._y   = realCoordinate.y;
        mcBandas.id   = depth;
        mcBandas.skin = Main.game.skins[team];
        mcBandas.team = team;
        mcBandas.init();

        // sprite.addListener(mcBandas);
        this.bandas.push(mcBandas);
        this.setSpriteAt(c, mcBandas);
        return mcBandas;
    }
    // }}}

    public function update() : Void
    // {{{
    {
        this.boardMask.update();
        this.updateBoardLine();
    }
    // }}}

    public function show() : Void
    // {{{
    {
        for (var i=0; i<this.slots.length; i++) {
            this.slots[i]._visible = true;
        }
        for (var i=0; i<this.bandas.length; i++) {
            this.bandas[i]._visible = true;
        }
        this._visible = true;
    }
    // }}}

    public function getSpriteAt( c:Coordinate ) : frutibandas.gui.Sprite
    {//{{{
        var index : Number = (c.y *this.size) + c.x;
        return Sprite( this.sprites[ index ] );
    }//}}}

    public function setSpriteAt( c:Coordinate, s:frutibandas.gui.Sprite ) : Void
    // {{{
    {
        var index : Number = (c.y *this.size) + c.x;
        if (c.y >= this.size || c.x >= this.size || c.x < 0 || c.y < 0) {
            return;
        }
        this.sprites[ index ] = s;
    }
    // }}}
    
    // 
    // METHODS RESERVED TO LOGIC BOARD
    //

    public function onSlotDestroyed(c:Coordinate) : Void
    {//{{{
        this.modified = true;
        boardMask.boardModified();
      
        var depth = SLOT_DEPTH + (c.y * size) + c.x;
        var slot : frutibandas.gui.Slot = frutibandas.gui.Slot.New(this, c, depth);
        this.deleteSlotAnimations.pushNextPriority(slot);
        
        var sprite : frutibandas.gui.Sprite = this.getSpriteAt(c);
        if (sprite != undefined && sprite != null) {
            Main.debug("set sprite at "+c);
            this.setSpriteAt(c, null);
            Main.debug("sprite.onDestroyed()");
            sprite.onDestroyed();
            Main.debug("pushNextPriority()");
            this.deleteSlotAnimations.pushNextPriority(sprite);
            Main.debug("done");
        }
    }//}}}

    public function onSlotTrapped( c:Coordinate ) : Void
    {//{{{
        this.modified = true;
        boardMask.boardModified();
        var depth = SLOT_DEPTH + (c.y * size) + c.x;
        var trap : frutibandas.gui.Trap = frutibandas.gui.Trap.New(this, c, depth);
        this.traps.push( trap );
    }//}}}
   
    public function onTrapDiscovered( c:Coordinate ) : Void
    {//{{{
        for (var i=0; i<traps.length; i++) {
            if (traps[i].getCoordinate().equals(c)) {
                traps[i].play();
                traps[i] = null;
            }
        }
    }//}}}
    
    public function onSpriteMove(c:Coordinate, d:Direction, pushed:Boolean) : Void 
    {//{{{
        var sprite : frutibandas.gui.Sprite = this.getSpriteAt(c);
        if (sprite == undefined || sprite == null || sprite == "") {
            throw new Error("Error: sprite at "+c+" undefined");
        }

        var dest   : Coordinate = c.copy();
        dest.move(d);
      
        var depth  : Number   = getDepthOf(dest);
        sprite.swapDepths( depth );
        
        var anim : frutibandas.gui.SpriteMoveAnim;
        if (pushed) 
             anim = new frutibandas.gui.SpriteMoveAnim(sprite, c, d, frutibandas.gui.SpriteMoveAnim.PUSHED);
        else
             anim = new frutibandas.gui.SpriteMoveAnim(sprite, c, d, frutibandas.gui.SpriteMoveAnim.MOVE);

        this.setSpriteAt(c, null);
        this.setSpriteAt(dest, sprite);

        var priority : Number;
        switch (d) {
            case Direction.Up: 
                priority = 9 - c.y;
                break;
            case Direction.Down:
                priority = c.y;
                break;
            case Direction.Left:
                priority = 9 - c.x;
                break;
            case Direction.Right:
                priority = c.x;
                break;
        }

        // moveAnimation.push( sprite, priority );
        moveAnimation.push( anim, priority );

        if (!this.board.isValid(dest) 
            || this.board.getElement(dest) == frutibandas.Board.DESTROYED
            || this.board.getElement(dest) == frutibandas.Board.TRAPPED) {
            var fallAnim = new frutibandas.gui.SpriteMoveAnim(sprite, c, d, frutibandas.gui.SpriteMoveAnim.FALL);
            moveAnimation.push( fallAnim, priority +1 );
        }
    }//}}}

    public function onMoveBegin( d:Direction ) : Void 
    // {{{
    {
        this.deleteSlotAnimations = new frutibandas.gui.AnimationController(10);
        this.moveAnimation        = new frutibandas.gui.AnimationController(10);
    }    
    // }}}

    public function onMoveDone() : Void
    // {{{
    {
        Main.getAnimControl().push(this.moveAnimation,        Main.ANIM_PRIO_MOVE);
        Main.getAnimControl().push(this.deleteSlotAnimations, Main.ANIM_PRIO_DEL_BORDER);
        Main.flushAnimation();
    }
    // }}}
    
    //
    // METHOD USED BY CARDS ACTIVATION
    // 

    public function onSpriteConverted( c:Coordinate, newTeam:Number ) : Void
    // {{{
    {
        trace("setting sprite team to "+newTeam+" at team coordinate "+c);
        var sprite : frutibandas.gui.Sprite = this.getSpriteAt(c);
        if (sprite != undefined && sprite != null) {
            sprite.setTeam( newTeam );
        }
        else {
            trace("No sprite at "+c);
        }
    }
    // }}}
    
    // 
    // PRIVATE METHODS
    //
    
    private function Board()
    // {{{
    {
        super();
        this.borderTop  = 0;
        this.borderLeft = 0;

        this.slotsDepth  =  100;

        this.traps = new Array();
        
        this.board = Main.game.board;
        this.board.setListener(this);
        this.size  = this.board.getSize();
        this.width = 0;
        
        this.slots   = new Array();
        this.bandas  = new Array();
        this.sprites = new Array();
       
        this.boardLine     = this.createEmptyMovieClip("BoardLine", BOARD_LINE_DEPTH);
        this.moveAnimation = new frutibandas.gui.AnimationController(10);
        this.modified      = true;

        this.counter       = 0;
        this.createSlots();
    }
    // }}}

    private function updateBoardLine() : Void
    { // {{{
        if (!this.modified) return;

        this.boardLine.clear();
        //this.boardLine.beginFill(0xff9b2d);
        this.boardLine.beginFill(0x8ba731);

        var board : frutibandas.Board = Main.game.getBoard();
        var size  : Number            = board.getSize();
        for (var line=0; line<size; line++) {
            for (var column=0; column<size; column++) {
                var coord  : Coordinate = new Coordinate(column, line);
                var bottom : Coordinate = new Coordinate(column, line+1);
                var slot : Number = board.getElement(coord);
                var next : Number = board.getElement(bottom);

                var slotEmpty = (slot == frutibandas.Board.DESTROYED || slot == frutibandas.Board.TRAPPED);
                // next line may fail
                var nextEmpty = (next == frutibandas.Board.DESTROYED || next == frutibandas.Board.TRAPPED);
                if (!slotEmpty && nextEmpty) {
                    var real : Coordinate = getBandasRealCoordinate(coord);
                    real.x -= Math.floor(Board.SlotSize / 2);
                    real.y += Math.floor(Board.SlotSize / 2);
                    this.boardLine.moveTo(real.x, real.y);
                    this.boardLine.lineTo(real.x + Board.SlotSize, real.y);
                    this.boardLine.lineTo(real.x + Board.SlotSize, real.y + 4);
                    this.boardLine.lineTo(real.x, real.y + 4);
                    this.boardLine.lineTo(real.x, real.y);
                }
            }
        }
        this.boardLine.endFill();
        this.modified = false;
    } // }}}

    private function createSlotView( c:Coordinate, slot:Number ) : Void
    { // {{{
        if (slot > frutibandas.Board.FREE) {
            this.createSpriteView( c, slot );
        }
    } // }}}

    private function createSlots() : Void
    { // {{{
        var depth = BOARD_DEPTH;
        var bg = this.attachMovie("mcFullSquare", "mcFullSquare_"+depth, depth);
        bg.gotoAndStop(this.size);
        bg._x = this.borderLeft;
        bg._y = this.borderTop;
        bg._visible = true;
        this.width = bg._width;
       
        boardMask    = frutibandas.gui.BoardMask.New(this);
        boardMask.swapDepths( BOARD_MASK_DEPTH );
        boardMask._x = bg._x;
        boardMask._y = bg._y;
        bg.setMask( boardMask );
        
        var size  : Number = this.board.getSize();
        for (var line = 0; line < size; line++) {
            for (var column = 0; column < size; column++) {
                var c    : Coordinate = new Coordinate(column, line);
                var slot : Number     = this.board.getElement(c);
                this.createSlotView(c, slot);
            }
        }
    } // }}}

    private function getDepthOf( c:Coordinate ) : Number
    { // {{{
        return (BANDAS_DEPTH + (c.x+1) + ((c.y+1) * 10));
    } // }}}
}
//EOF
