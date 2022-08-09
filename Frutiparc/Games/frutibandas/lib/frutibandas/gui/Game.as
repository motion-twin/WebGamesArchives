//
// $Id: Game.as,v 1.42 2004/06/24 11:43:43  Exp $
// 

import frutibandas.gui.*;

import frutibandas.Main;
import frutibandas.Time;
import frutibandas.Texts;
import frutibandas.Callback;
import frutibandas.Coordinate;
import frutibandas.Direction;

class frutibandas.gui.Game extends MovieClip 
{
    public  var board              : Board;
    public  var chat               : Chat;
    public  var quitButton         ;
    
    private var playersInfos         : Array;  
    private var madlock              : Boolean;
    private var cardEffectTitleDepth : Number;
    private var confirm              : Popup;

    private var arrowsVisible : Boolean;
    private var arrows : Array;
    private var target : Target;

    /** 
     * Static constructor. 
     */
    public static function New( parent:MovieClip ) : Game    
    {
        var depth  : Number = parent.getNextHighestDepth();
        return Game( parent.attachMovie("mcGame", "Game_"+depth, depth) );
    }

    
    // ----------------------------------------------------------------------
    // Card gui interaction
    // ----------------------------------------------------------------------
    
    /** 
     * Called when a card is pressed 
     */
    public function initCardPlay( id:Number ) : Void    
    {
        this.hideArrows();
        
        // choose card if phase is card selection phase
        if (Main.game.phase == frutibandas.Game.PHASE_CARD_SELECTION) {
            this.chat.initChatMode();
            Main.game.requestChooseCard(id);
            return;
        }

        // not your turn, do nothing
        if (Main.game.currentTeam != Main.game.team) {
            return;
        }
        
        // create a target pointer if card requires a target
        var card : frutibandas.Card = frutibandas.Card.New(id);
        if (card.requiresTarget) {
            target = Target.New(this);
            target.setCard( card );
            target.setValidationCallback( new Callback(this, targetValidated) );
        }
        else {
            if (id == frutibandas.Card.RENFORT) {
                var c : Coordinate = new Coordinate(10203, 20202);
                Main.gameUI.chat.initChatMode(id);
                Main.game.requestPlayCard(id, c);
            }
            else {
                Main.gameUI.chat.initChatMode(id);
                Main.game.requestPlayCard(id);
            }
        }
    }

    /** 
     * Called when a target is validated 
     */
    public function targetValidated( target:Target )
    {
        Main.gameUI.chat.initChatMode();
        var logicCoord : Coordinate;
        logicCoord = this.board.toLogicCoordinate(target.getCoordinate());
        if (!target.getCard().isValidTarget( logicCoord )) {
            this.showArrows();
            return; 
        }
        Main.game.requestPlayCard(target.getCard().id, logicCoord);
        this.target = null;
    }
    

    // ----------------------------------------------------------------------
    // Chat methods
    // ----------------------------------------------------------------------
    
    public function newMessage( src:String, msg:String ) : Void
    {
        this.chat.writeMessage(src, msg);
    }

    public function writeLog( str:String ) : Void
    {
        this.chat.writeLog( str );
    }

    public function toggleChatVisibility() : Void    
    {
        this.chat._visible = !this.chat._visible;
    }

    public function chatHasFocus() : Boolean 
    {
        return this.chat.hasFocus();
    }

    
    // ----------------------------------------------------------------------
    // Game movie clip methods
    // ----------------------------------------------------------------------

    public function show() : Void
    {
        function onQuitRelease() { Main.gameUI.quitRequest(); }
        this.quitButton.onRelease = onQuitRelease;
        
        this.board.show();
        this.chat.show();
        this._visible = true;
    }
    
    public function update() : Void
    {
        this.board.update();
        this.updateTimers();
        this.updateSpriteCounters();
    }

    public function destroy() : Void
    {
        this._visible = false;
        this.removeMovieClip();
    }
    

    // ----------------------------------------------------------------------
    // Quit confirmation
    // ----------------------------------------------------------------------
    
    public function quitRequest() : Void
    {
        if (this.madlock) return;
        this.madlock = true;
       
        confirm = Popup.New(this);
        if (Main.game.isRunning()) {
            confirm.setTitle(Texts.ABANDON_POPUP_TITLE);
            confirm.setText(Texts.ABANDON_POPUP_TEXT);
            var callback : Callback;
            if (Main.gameMode == 1) {
                callback = new Callback(Main.manager, Main.manager.abandon);
            }
            else {
                callback = new Callback(this, quitConfirmed);
            }
            confirm.addButton("Oui", callback);
            confirm.addButton("Non", new Callback(this, quitCancelled));
        }
        else {
            var content  : String = "";
            var callback : Callback = null;

            if (Main.gameMode == 1 && Main.game.getWinnerTeam() != Main.game.team) {
                if (Main.game.getWinnerTeam() == frutibandas.Game.END_DRAW) {
                    content  = Texts.QUIT_POPUP_CH_DRAW;
                    callback = new Callback(this, quitConfirmed);
                }
                else {
                    content  = Texts.QUIT_POPUP_CH_LOST;
                    callback = new Callback(Main.manager, Main.manager.hardReboot);
                }
            }
            else {
                content = Texts.QUIT_POPUP_TEXT_1 
                        + Main.game.getWinner() 
                        + Texts.QUIT_POPUP_TEXT_2;
                callback = new Callback(this, quitConfirmed)
            }
            confirm.setTitle(Texts.QUIT_POPUP_TITLE);
            confirm.setText(content);
            confirm.addButton("Oui", callback);
        }
        confirm.draw();

        // popup will be draw only after movements
        Main.gameUI.board.onMoveBegin( frutibandas.Direction.BadDirection );
        Main.pushAnimation(confirm, Main.ANIM_POPUP_END_GAME);
        Main.gameUI.board.onMoveDone();
    }

    public function quitConfirmed() : Void
    {
        if (Main.game.isRunning()) {
            Main.manager.abandon();
        }
        else {
            Main.manager.quit();
        }
        this.madlock = false;
    }

    public function quitCancelled() : Void     
    {
        this.madlock = false;
    }


    // ----------------------------------------------------------------------
    // Game callbacks reaction
    // ----------------------------------------------------------------------

    public function onTurnChanged( team:Number ) : Void
    { 
        this.playersInfos[ 1 - team ].setCurrentPlayer( false );
        this.playersInfos[ team ].setCurrentPlayer( true );

        if (team == Main.game.team 
            && Main.game.phase > frutibandas.Game.PHASE_CARD_SELECTION) {
            this.showArrows();
        }
        else {
            this.hideArrows();
        }
    } 
    
    public function onCardPlayed( team:Number, id:Number, alreadyDestroyed:Boolean ) : Void
    {
        var effect = EffectTitle.New(this, cardEffectTitleDepth);
        effect.setTitle( frutibandas.Card.New(id).name );
        effect.setTeam( team );
        effect._y = (this._height / 2) - 30;
            
        Main.pushAnimation( effect, Main.ANIM_PRIO_CARD_TITLE );

        // hidden cards are already destroyed by the client interface. we
        // prevent destroying them twice (because the player may have two
        // cards with the same face).
        if (!alreadyDestroyed) {
            this.playersInfos[ team ].getCards().play(id);
        }
    }

    public function onCardConfiscated( confiscTeam:Number, id:Number ) : Void
    {
        playersInfos[1-confiscTeam].getCards().remove( id );
        playersInfos[confiscTeam].getCards().pushAnimated( id );
    }
    
    public function onEnded() : Void
    {
        if (this.target != null) {
            this.target.destroy();
            this.target = null;
        }
        if (this.confirm != null) { 
            this.quitCancelled();
            this.confirm.removeMovieClip();
            this.confirm = null;
            this.madlock = false;
        }
        this.quitRequest();
    }

    
    // ----------------------------------------------------------------------
    // Draft phase methods
    // ----------------------------------------------------------------------

    /** Called at the end of the draft phase. */
    public function showPlayersCards( hands:Array )     
    {
        for (var p=0; p<2; p++) {
            var cards : CardPane = this.playersInfos[p].getCards();
            cards.clear();
            for (var i=0; i<hands[p].length; i++) {
                if (!isNaN( hands[p][i] )) { // kick hack here :)
                    Main.debug("pushing card "+hands[p][i]+" to player "+p+" hand");
                    cards.push( hands[p][i] );
                }
            }
        }
    }

    public function showDraftCards( pool:frutibandas.CardPool, 
                                    currentPlayerCanChoose:Boolean ) 
    {
        this.hideDraftCards();

        if (currentPlayerCanChoose) {
            Main.logMessage(Texts.CHOOSE_A_CARD);
        }

        var i : Number = (currentPlayerCanChoose ? Main.game.team : 1 - Main.game.team);
        var cards : CardPane = this.playersInfos[i].getCards();
        for (var i=0; i<pool.size(); i++) {
            cards.push( pool.getIdOf(i) );
        }
    }
   
    public function hideDraftCards() 
    {
        this.playersInfos[ 1 - Main.game.currentTeam ].getCards().clear();
    }

    
    // ----------------------------------------------------------------------
    // Graphic update
    // ----------------------------------------------------------------------

    public function hideArrows() : Void 
    {
        if (arrowsVisible) {
            for (var i=0; i<4; i++) arrows[i].hide();
            arrowsVisible = false;
        }
    }

    public function showArrows() : Void
    {
        if (arrowsVisible) return;
        if (Main.inputLocked) return;
        if (Main.game.team != Main.game.currentTeam) return;
        if (Main.game.phase <= frutibandas.Game.PHASE_CARD_SELECTION) return;
        if (!Main.game.isRunning()) return;
       
        for (var i=0; i<4; i++) arrows[i].show();
        arrowsVisible = true;
    }
    
    /** Update PlayerInfos with valid times. */
    private function updateTimers() : Void
    {
        for (var i=0; i<Main.game.times.length; i++) {
            this.playersInfos[i].setRemainingTime( Main.game.times[i] );
        }
    }

    /** Update PlayerInfos with valid sprites count. */
    private function updateSpriteCounters() : Void
    {
        this.playersInfos[0].setSpriteCount( Main.game.board.countSpritesOf(0) );
        this.playersInfos[1].setSpriteCount( Main.game.board.countSpritesOf(1) );
    }


    // ----------------------------------------------------------------------
    // Graphic creation methods
    // ----------------------------------------------------------------------

    private function Game()
    {
        super();
        chat = null;
        board = null;
        target = null;
        arrowsVisible = false;
        
        confirm = null;
        madlock = false;
        playersInfos = new Array();
        arrows = new Array();

        createChat();
        createArrows();
        createBoard();
        createPlayersInfos();
        createQuitButton();
        reserveCardTitleEffectDepth();
        // createDebugLaunchers();
    }
    
    private function createDebugLaunchers() : Void    
    {
        for (var i=0; i<12; i++) {
            var depth    : Number    = this.getNextHighestDepth();
            var launcher : MovieClip = this.attachMovie("mcCardLauncher", "CardLauncher_"+depth, depth);
            launcher.id = i;
            launcher.onRelease = function() { 
                this._parent.initCardPlay(this.id); 
            }
            launcher.onRollOver = function() {
                this.gotoAndStop(2);
                this._parent.chat.initInfoMode(this.id);
            }
            launcher.onRollOut = function() {
                this.gotoAndStop(1);
                this._parent.chat.initChatMode();
            }
            launcher.onReleaseOutside = function() {
                this.gotoAndStop(1);
            }
            launcher._y = 0;
            launcher._x = i*launcher._width;
        }
    }

    private function createQuitButton() : Void
    { 
        this.quitButton = this.attachMovie("mcQuit", "QuitButton", this.getNextHighestDepth());
        this.quitButton._x = this._width - this.quitButton._width;
        this.quitButton._y = this._height - this.quitButton._height;
    } 
    
    private function createChat() : Void
    {
        this.chat    = Chat.New(this);
        this.chat._x = (this._width  - this.chat._width) / 2;
        this.chat._y = (this._height - this.chat._height - 7);
    }

    private function createBoard() : Void
    {
        this.board = Board.New(this);
        this.board._x =      (this._width  - this.board._width)  / 2;
        this.board._y = 25 + frutibandas.gui.Board.SlotSize * (10 - Main.game.getBoard().getSize()) / 2;
    }

    private function reserveCardTitleEffectDepth() : Void
    { 
        var eff = this.createEmptyMovieClip("CardEffectTitle", this.getNextHighestDepth());
        this.cardEffectTitleDepth = eff.getDepth();
    } 
    
    private function createArrows() : Void
    {
        arrows.push( frutibandas.gui.Arrow.New( this, Direction.Up ) );
        arrows.push( frutibandas.gui.Arrow.New( this, Direction.Down ) );
        arrows.push( frutibandas.gui.Arrow.New( this, Direction.Left ) );
        arrows.push( frutibandas.gui.Arrow.New( this, Direction.Right ) );
        hideArrows();
    }
    
    private function createPlayersInfos() : Void
    {
        var i : Number = 0;
        for (i = 0; i < Main.game.players.length; i++) {
            
            var pinf : PlayerInfo = PlayerInfo.New(this);
            pinf.setSide(i);
            pinf.setTeamNumber( i );
            pinf.setPlayerName( Main.game.players[i] );
            pinf.setSpriteType( Main.game.skins[i] ); 
            pinf.setSpriteCount( Main.game.board.countSpritesOf(i) );
            pinf.setFrutibouille( Main.game.frutibouilles[i] );
            
            pinf.draw();
    	    pinf._x = 6 + i * (this._parent._width - pinf._width - 12);
	        pinf._y = 6;
            if (i == Main.game.team) {
                pinf.getCards().setVisible(true);
            }
            playersInfos.push(pinf);
        }
    }
}
//EOF
