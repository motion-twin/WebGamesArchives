// 
// $Id: PlayerInfo.as,v 1.10 2004/03/22 18:42:40  Exp $
//

import grapiz.Main;

class grapiz.gui.PlayerInfo extends MovieClip 
{
    public  static var LINK_NAME : String = "mcPlayerInfo";
    
    private static var CUP_LINK_NAME  : String = "mcCup";
    private static var STAR_LINK_NAME : String = "mcStar";
    private static var FONT_LINK_NAME : String = "mcFontNumber";
    private static var NUMB_LINK_NAME : String = "mcGoldNumber";
    
    private static var MAX_STARS           : Number = 10;

    private static var DECO_ELEMENT_SIZE   : Number = 20;
    private static var DECO_ELEMENT_HEIGHT : Number = 20;
    private static var DECO_X_START        : Number = 94;
    private static var DECO_Y_START        : Number = 40;
    
    private var index          : Number;
    private var score          : Number;
    private var time           : String;
    private var name           : String;
    private var frutibouilleID : String;
    private var gameMode       : Number;
   
    // panel expected width
    private var width        : Number;
    
    // panel elements
    private var fieldName    : TextField;
    private var fieldTime    : TextField;
    private var partA        : MovieClip;
    private var partB        : MovieClip;
    private var partC        : MovieClip;
    private var frutibouille : MovieClip; // Frutibouille;
    private var mark         : MovieClip;

    /** Static constructor. */
    public static function New( parent:MovieClip ) : PlayerInfo 
    { // {{{
        var d : Number = parent.getNextHighestDepth();
        return PlayerInfo( parent.attachMovie(LINK_NAME, "PlayerInfo"+d, d) );        
    } // }}}
    
    /** Set game mode. */
    public function setGameMode( mode:Number ) : Void
    { // {{{
        this.gameMode = mode;
    } // }}}
    
    /** Set player's score. */
    public function setScore( score:Number ) : Void 
    { // {{{
        this.score = score;
    } // }}}

    /** Set player's index (team number). */
    public function setPlayerIndex( i:Number ) : Void
    { // {{{
        this.index = i;
        this.partA.gotoAndStop(i + 1);
        this.mark.gotoAndStop(i + 1);
    } // }}}
    
    /** Set player's name. */
    public function setPlayerName( n:String ) : Void
    { // {{{
        this.name = n;
    } // }}}
   
    /** It's current player turn. */
    public function activateThinking() : Void
    { //{{{
        this.mark.wheel._visible = true;
        this.mark.wheel.play();
    } //}}}

    /** End of turn. */
    public function deactivateThinking() : Void
    { //{{{
        this.mark.wheel._visible = false;
        this.mark.wheel.stop();
    } //}}}
    
    /** Set player's remaining play time. */
    public function setRemainingTime( t:Number ) : Void
    { // {{{
        if (t < 0) t = 0;
        var min : Number = Math.floor( t / (1000 * 60) ); 
        t -= (min * 1000 * 60);
        var sec : Number = Math.floor(t / 1000);
        t -= (sec * 1000);
        this.time = ((min < 10) ? "0" + min : min) + ":" + 
                    ((sec < 10) ? "0" + sec : sec) ;
        /*
        var mil : Number = Math.floor(t / 10);
        this.time = ((min < 10) ? "0" + min : min) + ":" + 
                    ((sec < 10) ? "0" + sec : sec) + ":" + 
                    ((mil < 10) ? "0" + mil : mil);
        */
    } // }}}
    
    /** Set frutibouille id. */
    public function setFrutibouille( fb:String ) : Void
    { // {{{
        this.frutibouilleID = fb;
    } // }}}
   
    /** Set pane width. */
    public function setWidth( w:Number ) : Void
    { // {{{
        this.width = w;
    } // }}}

    /** Draw the playerinfo. */
    public function draw() : Void
    { // {{{
        var w = this.width - DECO_X_START;
     
        this.partB._width = w;
        this.partC._x = partB._x + w;
        this.fieldName._width = w;

        switch (this.gameMode) {
            case 0:
                this.fieldTime._y = 32;
                break;
                
            case 1:
                if (score < MAX_STARS && score > 0) {
                    this.createStarAt(0);
                    for (var i = 1; i < score; i++) {
                        this.createStarAt(i);
                    }
                }
                else if (score > 0){
                    this.createStarAt(0);
                    this.drawGoldNumber( score );
                }
                break;

            case 2:
                this.createCup();
                this.drawGoldNumber( score );
                break;
        }

        this.drawFrutibouille();
    } // }}}    

    // ----------------------------------------------------------------------
    // Graphic creation methods
    // ----------------------------------------------------------------------

    private function PlayerInfo()
    { // {{{
        this.index     = 0;
        this.gameMode  = 1;
        this.name      = undefined;
        this.time      = "00:00:00";
        this.score     = 0;
        this.mark.wheel._visible = false;
        this.stop();
    } // }}}

    private function createStarAt( i:Number ) : Void
    { // {{{
        var str = this.attachMovie(STAR_LINK_NAME, "Star"+i, this.getNextHighestDepth());
        str._x  = DECO_X_START + ( i * DECO_ELEMENT_SIZE);
        str._y  = DECO_Y_START;
    } // }}}

    private function createCup() : Void
    { // {{{
        var cup = this.attachMovie(CUP_LINK_NAME, "CUP", this.getNextHighestDepth());
        cup._x  = DECO_X_START;
        cup._y  = DECO_Y_START;
    } // }}}

    private function drawGoldNumber( value:Number ) : Void
    { // {{{
        // parameter object for goldnumber clip
        var paramObj = { num:string(value), link:FONT_LINK_NAME }; 

        var goldNbr : ext.game.Numb = ext.game.Numb( 
            this.attachMovie(NUMB_LINK_NAME, "num", this.getNextHighestDepth(), paramObj) 
        );

        goldNbr._x = DECO_X_START + DECO_ELEMENT_SIZE + 25;
        goldNbr._y = 34;
    } // }}}

    private function drawFrutibouille() : Void
    { // {{{
        var size  : Number    = 66;
        
        var depth : Number    = this.getNextHighestDepth();;
        this.frutibouille = this.createEmptyMovieClip("Frutibouille", depth);
        this.frutibouille._yscale = size;
        this.frutibouille._xscale = size;
        this.frutibouille._x      = 10;
        this.frutibouille._y      = (this.partA._height - 60) / 2;

        depth = this.frutibouille.getNextHighestDepth();
        var param = { id:this.frutibouilleID };
        var mc : MovieClip;
        mc = this.frutibouille.attachMovie("mcFrutibouille", "Frutibouille", depth, param);

        var bouilleMask = this.frutibouille.createEmptyMovieClip("BouilleMask", depth+1);
        bouilleMask.beginFill(0xFFFF00);
        bouilleMask.moveTo(0,   0);
        bouilleMask.lineTo(100, 0);
        bouilleMask.lineTo(100, 100);
        bouilleMask.lineTo(0,   100);
        bouilleMask.lineTo(0,   0);
        bouilleMask.endFill();
        
        mc.setMask( bouilleMask );
    } // }}}
}

//EOF
