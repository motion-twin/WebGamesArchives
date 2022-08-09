//
// $Id: Game.as,v 1.14 2004/06/24 11:42:39  Exp $
// 

import grapiz.Main;
import grapiz.Texts;
import grapiz.Globals;
import grapiz.Callback;

class grapiz.gui.Game extends MovieClip implements grapiz.GameListener
{
    public static var LINK_NAME : String = "mcGame";

    private var boardBackground : MovieClip;
    private var board           : grapiz.gui.Board;
    private var chatPane        : grapiz.gui.ChatPane;
    private var quitButton      : MovieClip;
    private var playerPanes     : Array;
    private var currentTurn     : Number;
    private var madlock         : Boolean;
    private var confirm         : grapiz.gui.Confirm;

    
    // ----------------------------------------------------------------------
    // Static constructor
    // ----------------------------------------------------------------------
    
    public static function New( parent:MovieClip ) : Game
    {//{{{
        var depth : Number    = parent.getNextHighestDepth();
        var mc    : MovieClip = parent.attachMovie("mcGame", "mcGame_"+depth, depth);
        return Game(mc);
    }//}}}

    public function getChat() : grapiz.gui.ChatPane 
    {//{{{
        return this.chatPane; 
    }//}}}

    public function getBoard() : grapiz.gui.Board 
    {//{{{
        return this.board;
    }//}}}

    public function onQuitPressed() : Void 
    {//{{{
        if (madlock) return;
        madlock = true;
        
        confirm = grapiz.gui.Confirm.New(this);

        confirm.setCancelCallback(new Callback(this, quitCancelled));
        confirm.setAcceptCallback(new Callback(this, quitConfirmed));

        if (Main.game.isPlaying()) {
            confirm.setTitle("Abandonner ?");
            confirm.setText("Attention, quitter la partie donnera la victoire � votre adversaire !");
        }
        else {
            confirm.setTitle("Quitter ?");
            confirm.setText("La partie est termin�e, voulez vous revenir � l'interface de cr�ation de partie ?");
        }
        confirm.show();
    }//}}}

    public function quitConfirmed() : Void 
    {//{{{
        madlock=false; 
        if (Main.game.isPlaying()) {
            Main.manager.abandon(); 
            if (Main.gameMode == 1) {
                Main.manager.hardReboot();
            }
        }
        else {
            Main.manager.quit();
        }
    }//}}}
    
    public function quitCancelled() : Void 
    {//{{{
        madlock=false; 
        trace("quitCancelled()"); 
    }//}}}

    public function show() : Void
    {//{{{
        this.board.show();
        this._visible = true;
    }//}}}

    public function showEditMode() : Void
    {//{{{
        var validBtn = this.createEmptyMovieClip("Validation", this.getNextHighestDepth());
        validBtn._x = 0; 
        validBtn._y = 0;
        validBtn.beginFill(0xFF00FF);
        validBtn.moveTo(0,0);
        validBtn.lineTo(30, 0);
        validBtn.lineto(30, 20);
        validBtn.lineTo(0,  20);
        validBtn.lineTo(0, 0);
        validBtn.endFill();
        validBtn.onRelease = function() { 
            Main.gameUI.showEditResult(); 
        }
        board.showEditionSlots();
    }//}}}
   
    public function showEditResult() : Void
    {//{{{
        var result : String = Main.game.getBoard().getSize() + "\n";
        var slots = board.getEditionSlots();
        for (var i = 0; i<slots.length; i++) {
            var slot = slots[i];
            if (slot.getTeam() != -1) {
                var c = grapiz.Convert.getLogicCoordinate( slot.getCoordinate() );
                result += c.x+" "+c.y+" "+slot.getTeam()+"\n";
            }
        }
        result += "\n";
        chatPane.clear();
        chatPane.addText( result );
        chatPane.setSelectable(true);
    }//}}}
    
    public function update() : Void
    {//{{{
        var game = Main.game;
        for (var i=0; i<playerPanes.length; i++) {
            var t = game.getRemainingTimeOf(i);
            playerPanes[i].setRemainingTime( t );
        }
    }//}}}

    public function onTurn( t:Number ) : Void
    {//{{{
        this.playerPanes[ currentTurn ].deactivateThinking();
        currentTurn = t;
        this.playerPanes[ currentTurn ].activateThinking();
    }//}}}
    
    public function onEnd( winner:String ) : Void
    {//{{{
        // if (madlock) return;
        if (confirm != null) {
            quitCancelled();
            confirm.removeMovieClip();
            confirm = null;
        }
        madlock = true;

        var endPane = grapiz.gui.EndPane.New(this);
        

        var dummy = function(){}
        // endPane.setStayCallback( new grapiz.Callback(this, quitCancelled) );
        //
        if (Main.gameMode == 1 && winner != Main.userLogin) {
            endPane.setText(Texts.LOST_CHALLENGE);
            endPane.setQuitCallback( new grapiz.Callback(Main.manager, Main.manager.hardReboot) );
        }
        else {
            endPane.setText(Texts.QUIT_POPUP_TEXT_1 + winner + Texts.QUIT_POPUP_TEXT_2);
            endPane.setQuitCallback( new grapiz.Callback(this, quitConfirmed) );
        }

        endPane._visible = false;
        Main.endPane = endPane; // endPane.show();
    }//}}}

    public function onMessage( userID:String, message:String ) : Void
    {//{{{ 
        this.chatPane.writeMessage(userID, message);
    }//}}}

    public function writeLog( str:String ) : Void
    {
        this.chatPane.writeLog( str );
    }
   
    
    // ----------------------------------------------------------------------
    // GUI construction methods
    // ----------------------------------------------------------------------

    private function Game()
    {//{{{
        this.madlock    = false;
        this.quitButton = null;
        this.boardBackground = null;
        this.board = null;
        this.chatPane = null;
        this.confirm = null;
        this.playerPanes = new Array();
    
        this.currentTurn = 0;
        this.drawGameBackground();
        this.createChat();
        this.createPlayerPanes();
        this.createBoardBackground();
        this.createBoard();
    }//}}}

    private function drawGameBackground() : Void
    {//{{{
        this.beginFill(0xFFFFFF);
        this.moveTo(0, 0);
        this.lineTo(Globals.GWidth, 0);
        this.lineTo(Globals.GWidth, Globals.GHeight);
        this.lineTo(0, Globals.GHeight);
        this.lineTo(0, 0);
        this.endFill();
    }//}}}
    
    private function createChat() : Void
    {//{{{
        var depth : Number;
        depth = this.getNextHighestDepth();
        this.chatPane = grapiz.gui.ChatPane.New(this);
        this.chatPane._x = Globals.GWidth  - this.chatPane._width;
        this.chatPane._y = Globals.GHeight - this.chatPane._height;
    }//}}}

    private function createBoardBackground() : Void
    {//{{{
        var depth : Number = this.getNextHighestDepth();
        var bg    : MovieClip = this.attachMovie("mcBoardBackground", "BG_"+depth, depth);
        bg._x = 0;
        bg._y = Globals.GHeight - bg._height;
        this.boardBackground = bg;
        this.quitButton = this.boardBackground.quit;
        this.quitButton.onRelease = function() { 
            this._parent._parent.onQuitPressed(); 
        }
    }//}}}

    private function createBoard() : Void
    {//{{{
        this.board = grapiz.gui.Board.New(this.boardBackground);
        this.board._x = 398 / 2;
        this.board._y = 398 / 2;
        
        var boardSize : Number = Main.game.getBoard().getSize();
        var scale : Number;
        switch (boardSize) {
            case 3: scale = 100; break;
            case 4: scale = 90;  break;
            case 5: scale = 80;  break;
        }
        
        this.board._xscale = scale;
        this.board._yscale = scale;
        // this.board._x = 300;
        // this.board._y = 240;
    }//}}}
    
    private function createPlayerPanes() : Void
    {//{{{
        var game : grapiz.Game = Main.game;
        var n : Number = game.getNumberOfTeams();
        var paneWidth : Number = Globals.GWidth / n;
        for (var i=0; i<n; i++) {
            var playerPane : grapiz.gui.PlayerInfo = grapiz.gui.PlayerInfo.New(this);
            playerPane.setGameMode(Main.gameMode);
            playerPane.setPlayerIndex(i);
            playerPane.setPlayerName( game.getNameOf(i) );
            playerPane.setRemainingTime( game.getRemainingTimeOf(i) );
            playerPane.setFrutibouille( game.getFrutibouille(i) );
            playerPane.setScore( game.getScore(i) );
            playerPane.setWidth( paneWidth );
            playerPane.draw();
            playerPane._x = i * paneWidth;
            playerPane._y = 0;
            this.playerPanes.push(playerPane);
        }
    }//}}}
}
//EOF
