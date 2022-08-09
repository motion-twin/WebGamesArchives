// 
// $Id: Main.as,v 1.49 2004/06/24 11:43:43  Exp $
// 

import frutibandas.Direction;
import frutibandas.Texts;
import frutibandas.gui.Game;
import frutibandas.gui.AnimationList;
import frutibandas.gui.AnimationController;

class frutibandas.Main 
{   
    /* Constant data */
    public  static var DEBUG = false;

    public  static var FREE_MODE      = 0;
    public  static var CHALLENGE_MODE = 1;
    public  static var CHAMPION_MODE  = 2;
    
    public  static var ANIM_PRIO_CARD_TITLE =  0;
    public  static var ANIM_PRIO_CARD_PLAY  =  1;
    public  static var ANIM_PRIO_CARD       =  2;
    public  static var ANIM_PRIO_MOVE       =  3;
    public  static var ANIM_PRIO_DEATH      =  4;
    public  static var ANIM_PRIO_DEL_BORDER =  5;
    public  static var ANIM_PRIO_DEL_CARD   =  6;
    public  static var ANIM_PRIO_APP_CARD   =  7;
    public  static var ANIM_POPUP_END_GAME  =  8;

    private static var MAX_ANIM_PRIO        = 12;
    private static var TEAM_LOG_COLOR : Array = ["#777777", "#AA4444", "#44AA44"];
    
    /* Instance data */
    public  static var userLogin  : String = null;
    public  static var manager    : frutibandas.Manager = null;
    public  static var fruticard  : frutibandas.FruticardSlot = null;
    
    private static var _rootMovie : MovieClip = null;
    
    /* Data instantiated for each game session */
    public  static var game            : frutibandas.Game = null;
    public  static var gameUI          : frutibandas.gui.Game = null;
    public  static var gameMode        : Number = -1;
    public  static var inputLocked     : Boolean = false;
    public  static var sndManager      : frutibandas.gui.SoundManager = null;
    private static var _music          : Boolean = true;

    public  static var pause : Boolean = false;
    private static var _kbdController  : frutibandas.gui.KeyboardController = null;
    private static var _animations     : AnimationList = null;
    private static var _animController : AnimationController = null;
    
    /* Debug data */
    public  static var StandaloneDebug  : Boolean = false;
    
    private static var _debugTeam        : Number = 0;
    private static var _lastFps          : Number = 0;
    private static var _fps              : Number = 0;
    
    
    // ----------------------------------------------------------------------
    
    /**
     * Called once on swf load completed.
     */
    public static function init( mc:MovieClip ) : Void
    {
        _animations = new AnimationList();
        _animController = new AnimationController(MAX_ANIM_PRIO);

        registerClasses();
        _rootMovie = mc;
        _rootMovie.stop();

        manager    = new frutibandas.Manager( _rootMovie );
        mc.manager = manager;
        
        _rootMovie._parent.loader.onGameReady();
    }
    
    /**
     * Start a new game.
     */
    public static function start( aGame : frutibandas.Game ) 
    {
        // cleanup old game if not already done
        if (gameUI != null) reset();

        try {
            game       = aGame;
            gameUI     = frutibandas.gui.Game.New(_rootMovie);
           
            // chat messages goes to manager.sendGame() method
            gameUI.chat.setSendCallback( manager, manager.sendGame );
            gameUI.show();
            if (game.phase == frutibandas.Game.PHASE_CARD_SELECTION) {
                // also work for recovery
                gameUI.showDraftCards( game.getPool(), (game.team == game.currentTeam) );
            }
            else {
                // recovery on move phase
                gameUI.showPlayersCards( game.cards );
            }
            gameUI.onTurnChanged( game.currentTeam );
    
            _kbdController = new frutibandas.gui.KeyboardController();
            sndManager = new frutibandas.gui.SoundManager( _rootMovie );
            if (_music) sndManager.start();

            inputLocked = false;

            _rootMovie._visible = true;
            _rootMovie._parent._visible = true;
            _rootMovie.gotoAndPlay(3);

        }
        catch (e:Error) {
            debug("Error in start() : "+e);
        }
    }
    
    /**
     * Destroy user interface and reset static values.
     */
    public static function reset() : Void
    {
        inputLocked  = false;
        game         = undefined;
        gameUI.removeMovieClip();
        gameUI       = null;
        sndManager.stop();
        sndManager = null;
        _kbdController = null;
        _rootMovie._visible = false;
        _rootMovie.stop();
    }

    /**
     * Trace debug message.
     */
    public static function debug(msg : String) : Void 
    {
        manager.debugMessage(msg);
    }

    /**
     * Push a message in the game log pane.
     */
    public static function logMessage(msg:String, team:Number) : Void
    {
        if (team == undefined) team = 0; else team++;
        gameUI.chat.addText('<font color="' + TEAM_LOG_COLOR[team] + '">'+msg+'</font>');
    }
    
    
    /**
     * Main game loop, called by the main MovieClip on each frame.
     */
    public static function mainLoop() : Void
    {
        // _fps++;
        if (game != undefined) {
            // process game time
            if (game.isRunning()) game.processTime();
            
            // process keyboard inputs
            if (_kbdController.hasKey()) processInputs();
            
            // update gui
            gameUI.update();
            
            // run animations
            inputLocked = _animations.update();
            if (!inputLocked) gameUI.showArrows();
            else              gameUI.hideArrows();
        }
        // var now = getTimer();
        // if (now > (_lastFps + 1000)) {
        //    _lastFps = now;
        //    gameUI.chat._fps = string(_fps);
        //    _fps = 0;
        // }
    }


    // ----------------------------------------------------------------------
    // ANIMATION METHODS
    // ----------------------------------------------------------------------

    public static function pushAnimation(animatedObject, priority:Number) : Void
    {
        _animController.push(animatedObject, priority);
    }
    
    public static function flushAnimation() : Void
    {
        gameUI.hideArrows();
        _animations.push( _animController );
        _animations.push( new frutibandas.gui.PauseAnimation() );
        _animController = new frutibandas.gui.AnimationController(MAX_ANIM_PRIO+1);
    }
    
    /** 
     * Retrieve the current animation controller. 
     */
    public static function getAnimControl() : AnimationController
    {
        return _animController;
    }
    
    // ----------------------------------------------------------------------
    // PRIVATE METHODS
    // ----------------------------------------------------------------------
    
    private static function processInputs() : Void 
    {
        if (pause) { debug("pause pause !"); return; }

        if (gameUI.chatHasFocus()) {
            processChatInput();
        }
        else if (!inputLocked) {
            processBoardInput();
        }
    }

    private static function processChatInput() : Void 
    {
        if (_kbdController.nextKey() == Key.ENTER) {
            if (game.isRunning() || gameMode != 1) {
                gameUI.chat.send();
            }
            else {
                gameUI.chat.writeLog(Texts.CHAT_IGNORE_GAME_ENDED);
            }
        }
    }
    
    private static function processBoardInput() : Void
    {
        var key : Number = _kbdController.nextKey();
        
        //{{{ debug inputs
        if (_rootMovie._parent.inFrusion == undefined) {
            
            switch (key) {
                case 67:    // 'c'
                    _debugTeam = 1 - _debugTeam;
                    game.team = _debugTeam;
                    return;
                case Key.UP:
                    game.move(_debugTeam, frutibandas.Direction.Up);
                    return;
                case Key.DOWN:
                    game.move(_debugTeam, frutibandas.Direction.Down);
                    return;
                case Key.LEFT:
                    game.move(_debugTeam, frutibandas.Direction.Left);
                    return;
                case Key.RIGHT:
                    game.move(_debugTeam, frutibandas.Direction.Right);
                    return;
                case 77:
                    toggleMusicOnOff();
                    return;
            }
        }
        //}}}

        switch (key) {
            case Key.UP:
                game.requestMove(Direction.Up);
                break;
            case Key.DOWN:
                game.requestMove(Direction.Down);
                break;
            case Key.LEFT:
                game.requestMove(Direction.Left);
                break;
            case Key.RIGHT:
                game.requestMove(Direction.Right);
                break;
            case 77:
                toggleMusicOnOff();
                break;
        }
    }

    private static function toggleMusicOnOff() : Void
    {
        _music = !_music;
        if (!_music) sndManager.stop();
        else         sndManager.start();
    }

    /** Register movie clips. */
    private static function registerClasses() : Void
    {
        Object.registerClass("mcFrutibouille", Frutibouille);
        Object.registerClass("mcCoefSquare",   ext.geom.CoefSquare);
        Object.registerClass("mcGame",         frutibandas.gui.Game);
        Object.registerClass("mcBandas",       frutibandas.gui.Sprite);
        Object.registerClass("mcLogBox",       frutibandas.gui.Chat);
        Object.registerClass("mcBoard",        frutibandas.gui.Board);
        Object.registerClass("mcPlayerInfo",   frutibandas.gui.PlayerInfo);
        Object.registerClass("mcConfirm",      frutibandas.gui.Confirm);
        Object.registerClass("mcEndPanel",     frutibandas.gui.EndPanel);
        Object.registerClass("mcCardSlot",     frutibandas.gui.CardSlot);
        Object.registerClass("mcPopup",        frutibandas.gui.Popup);
        Object.registerClass("mcTarget",       frutibandas.gui.Target);
        Object.registerClass("mcBoardMask",    frutibandas.gui.BoardMask);
        Object.registerClass("mcSquare",       frutibandas.gui.Slot);
        Object.registerClass("mcEffectTitle",  frutibandas.gui.EffectTitle);
        Object.registerClass("mcTrap",         frutibandas.gui.Trap);
        Object.registerClass("mcArrow",        frutibandas.gui.Arrow);
    }
   
    /** Create a dummy game board for standalone tests. */
    private static function showDummyGame()
    {
        var xmlSrc : String = 
             '<gm t="0" i="360000" c="3:3:3:3:3:7:8:9">'
              +'<u u="a"/>'
              +'<u u="b"/>'
              +'<b size="8" x1="0" x2="7" y1="0" y2="7">'
                +'78778888'
                +'66687888'
                +'87877878'
                +'78777888'
                +'88877887'
                +'78877787'
                +'87787777'
                +'88888778'
              +'</b>'
            +'</gm>';
        var xml    : XMLNode = new XML(xmlSrc).firstChild;

        userLogin = 'a';
        var game : frutibandas.Game = new frutibandas.Game(xml);
        start(game);
    }

    private static function testRecoverGame() 
    {
        userLogin = 'a';
        
        var xmlSrc : String = 
             '<gm t="0" i="380000" c="" p="2">'
              +'<u u="a" i="360000" c="3:4:5"/>'
              +'<u u="b" i="370000" c="7:8"/>'
              +'<b size="8" x1="0" x2="7" y1="0" y2="7">'
                +'78778888'
                +'66687888'
                +'87877878'
                +'78777888'
                +'88877887'
                +'78877787'
                +'87787777'
                +'88888778'
              +'</b>'
            +'</gm>';
        var xml    : XMLNode = new XML(xmlSrc).firstChild;
        
        var game : frutibandas.Game = new frutibandas.Game(xml);
        _rootMovie.play();
        start(game);
    }
}
//eof
