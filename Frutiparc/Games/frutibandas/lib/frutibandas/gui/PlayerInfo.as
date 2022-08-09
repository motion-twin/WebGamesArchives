// 
// $Id: PlayerInfo.as,v 1.22 2004/06/24 11:43:43  Exp $
// 

import frutibandas.Main;
import frutibandas.gui.CardPane;

class frutibandas.gui.PlayerInfo extends MovieClip
{
    // CONSTANTES
    public static var Width		  : Number = 150;
    public static var Height	  : Number = 468;
    public static var CARD_MARGIN  : Number = 4;
    public static var CARD_SLOT_Y  : Number = 119;
    public static var CARD_SPACING : Number = 4;

    // PARAMETRES
    private var side		    : Number;

    // VARIABLES
    private var id              : Number;
    private var spriteCount   	: String;
    private var remainingTime 	: String;
    private var teamNumber    	: Number;
    private var flTimer         : Boolean;
    private var frutibouilleID  : String;
    private var spriteType  : Number;

    // MOVIECLIPS
    private var slotPane        : CardPane;
    private var frutibouille    : Frutibouille;
    private var bouilleMask     : MovieClip;
    private var portrait		: MovieClip;
    private var infoBar		    : MovieClip;
    private var nameArea		: TextField;
    private var timeArea 		: TextField;
    //private var spriteCountArea : TextField;

    public static function New( parent:MovieClip ) : PlayerInfo
    { // {{{
        var depth : Number  = parent.getNextHighestDepth();
        return PlayerInfo( parent.attachMovie("mcPlayerInfo", "mcPlayerInfo@"+depth, depth) );
    } // }}}

    public function setSide( side:Number ) : Void
    { // {{{
        this.side = side;
    } // }}}

    public function setTeamNumber( n:Number ) : Void
    { // {{{
        this.teamNumber = n;
    } // }}}

    public function setPlayerName( name:String ) : Void
    { // {{{
        this.nameArea.text = name;
    } // }}}

    public function setFrutibouille( fb:String ) : Void
    { // {{{
        this.frutibouilleID = fb;
    } // }}}

    public function setSpriteCount( nbr:Number )
    { // {{{
        this.spriteCount = string(nbr);

    } // }}}

    public function setSpriteType( type:Number )
    { // {{{
        this.spriteType = type;
    } // }}}

    public function setRemainingTime( time:Number )
    { // {{{
        if (time <= 0) { time = 0; }

        this.infoBar.cs.coef = time/Main.game.time;
        this.infoBar.cs.update();
        this.remainingTime = ext.util.MTNumber.getTimeStr(time,":");
    } // }}}

    public function rollOverCard( id )
    { // {{{
        Main.gameUI.chat.initInfoMode(id);
    } // }}}

    public function rollOutCard( id )
    { // {{{
        Main.gameUI.chat.initChatMode(id);
    } // }}}

    public function getCards() : CardPane
    { // {{{
        return this.slotPane;
    } // }}}

    public function draw() 
    { // {{{
        if( side == 1 ){
            this.portrait._x = 52;
            this.infoBar._x = 7;
        }
        this.drawTimer();
        this.drawFrutibouille();
        this.drawSprite();
    } // }}}

    public function setCurrentPlayer( bool:Boolean ) : Void
    { //{{{
        if (bool) {
            this.infoBar.mask.blink.gotoAndPlay(2);
        }
        else {
            this.infoBar.mask.blink.gotoAndStop(1);
        }
    } //}}}


    // ------------------------------------------------------------------------
    // Private methods.
    // ------------------------------------------------------------------------

    private function PlayerInfo()
    { // {{{
        this.slotPane = frutibandas.gui.CardPane.New(this);
    } // }}}

    private function drawTimer()
    { // {{{
        var initObj = {color:0x88872D, ray:15};
        var pos = {x:22,y:60,r:15};

        this.infoBar.cs = this.infoBar.attachMovie("mcCoefSquare","cs", 
                                                    this.infoBar.getNextHighestDepth(), initObj);

        this.infoBar.attachMovie("rondMask","mask", this.infoBar.getNextHighestDepth() );
        this.setCurrentPlayer(false);

        this.infoBar.mask.gotoAndStop( side+1 );
        this.infoBar.mask._width  = pos.r*2;
        this.infoBar.mask._height = pos.r*2;
        this.infoBar.mask._x = pos.x;
        this.infoBar.mask._y = pos.y;
        this.infoBar.mask.setMask(this.infoBar.cs);
        this.infoBar.cs._x = pos.x;
        this.infoBar.cs._y = pos.y;
    } // }}}

    private function drawFrutibouille() : Void
    { // {{{
        var size = this.portrait._width;
        var parm = { id:this.frutibouilleID };
        var depth : Number    = this.portrait.getNextHighestDepth();
        var mc    : MovieClip = this.portrait.attachMovie("mcFrutibouille", "Frutibouille", depth, parm);
        this.bouilleMask  = this.portrait.createEmptyMovieClip("BouilleMask", depth+1);

        this.bouilleMask.beginFill(0xFFFF00);
        this.bouilleMask.moveTo(2, 2);
        this.bouilleMask.lineTo(size-2, 2);
        this.bouilleMask.lineTo(size-2, size-2);
        this.bouilleMask.lineTo(2, size-2);
        this.bouilleMask.lineTo(2, 2);
        this.bouilleMask.endFill();

        mc.setMask(this.bouilleMask);

        this.frutibouille = Frutibouille(mc);        
        this.frutibouille._yscale = size;
        this.frutibouille._xscale = size;

        if ( side == 0 ) {
            this.frutibouille._xscale *= -1;
            this.frutibouille._x       =  size;
        }
    } // }}}

    private function drawSprite()
    { //{{{      
        this.infoBar.mcFruit = frutibandas.gui.Sprite.New( this.infoBar );
        this.infoBar.mcFruit.skin = this.spriteType;
        this.infoBar.mcFruit.team = this.teamNumber;          
        this.infoBar.mcFruit._xscale = 50;
        this.infoBar.mcFruit._yscale = 50;
        this.infoBar.mcFruit._x = 9;
        this.infoBar.mcFruit._y = 11;
        this.infoBar.mcFruit.init();
    } //}}}
}
//EOF
