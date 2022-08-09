// 
// $Id: Main.as,v 1.21 2004/07/15 17:19:42  Exp $
//

class grapiz.Main
{
   public  static var DEBUG     : Boolean = false;

   public static var FREE_MODE      : Number = 0;
   public static var CHALLENGE_MODE : Number = 1;
   public static var LEAGUE_MODE    : Number = 2;

   public  static var rootMovie : MovieClip            = null;
   public  static var userLogin : String           = undefined;    
   public  static var fruticard : grapiz.FruticardSlot = null;
   public  static var gameMode  : Number           = 0;

   public  static var game      : grapiz.Game      = null;
   public  static var gameUI    : grapiz.gui.Game  = null;
   public  static var manager   : grapiz.Manager   = null;
   public  static var inputLock : Boolean          = false;

   public  static var editMode  : Boolean          = false;
   public  static var editTeam  : Number           = 0;
   public  static var editSize  : Number           = 3;

   public  static var animation : grapiz.gui.TokenAnim = null;
   public  static var endPane   : grapiz.gui.EndPane   = null;

   private static var keyboard  : grapiz.gui.KeyboardController = null;
   private static var logColors : Array = ["#777777", "#0000FF", "#FF0000"];

   /**
    * Initialize game client.
    *
    * This method is called from the 'main' movieclip.
    */
   public static function init(mcMain:MovieClip) : Void 
   {
      registerClasses();
      rootMovie = mcMain;
      rootMovie.stop();

      initInFrusion();
      // standaloneEditor();

      rootMovie._parent.loader.onGameReady();
   }

   /**
    * Start playing on a new game.
    *
    * This method is called by fruticonnect manager and initialize game 
    * logic and game movieclips.
    */
   public static function start( game : grapiz.Game ) : Void
   {
      if (Main.gameUI != null) {
         Main.reset(true);
      }

      try {
         Main.game = game;
         grapiz.Convert.prepare(game.getBoard(), grapiz.Globals.CenterX, grapiz.Globals.CenterY);

         gameUI = grapiz.gui.Game.New(rootMovie);
         gameUI.show();
         gameUI.onTurn( game.getCurrentTurn() );

         Main.game.setListener( gameUI );

         rootMovie._visible = true;
         rootMovie._parent._visible = true;
         rootMovie.gotoAndPlay(3); // play();

         keyboard = new grapiz.gui.KeyboardController();
      }
      catch (e) {
         Main.debug(e);
      }
   }

   public static function reset( quickReplay:Boolean ) 
   {
      Main.debug("Reseting");
      Main.game = undefined;
      Main.gameUI.removeMovieClip();
      Main.gameUI = null;
      rootMovie._visible = false;
      rootMovie._parent._visible = false;

      if (!editMode) {
         // rootMovie.gotoAndPlay(2);   // goto stop frame
         rootMovie.stop();
      }

      animation = null;
      if (keyboard != null) {
         Key.removeListener(keyboard);
         keyboard = null;
      }
      if (endPane) endPane.removeMovieClip();
      if (animation) animation = null;
      Main.debug("Reseted");
   }

   /**
    * Game loop.
    *
    * This method is called before grapic update on each frame.
    */
   public static function mainLoop() : Void 
   {
      if (game != null) {
         Main.game.updateTimers();
         processInputs();
         processGraphics();
      }
   }

   public static function logMessage( str:String, team:Number ) : Void 
   {
      if (team == undefined) { team = 0; } else { team++; }
      Main.gameUI.getChat().writeLog('<font color="' + logColors[team] + '">' + str + '</font>');
   }

   public static function debug( s:String ) : Void
   {
      trace(s);
      manager.debugMessage(s);
   }

   private static function processInputs() : Void 
   {
      if (!keyboard.hasKey()) {
         return;
      }

      var key : Number = keyboard.nextKey();

      // chat enter pressed
      var chat = gameUI.getChat();
      if (chat.hasFocus() && key == Key.ENTER) {
         if (game.isPlaying() || gameMode != 1) {
            var msg : String = chat.getInput();
            if (canSendMessage(msg.toLowerCase())) {
               manager.sendGame( htmlEncode(msg) ); 
            }
            else if (msg != "") {
               chat.addText("message non transmi (mot douteux trouv�)");
            }
            chat.flushInput();
         }
         else {
            chat.writeLog( grapiz.Texts.CHAT_IGNORE_GAME_ENDED );
         }
      }
      if (editMode && key <= 100 && key >= 96) {
         editTeam = key - 97;
      }
      // page up, board size ++
      if (editMode && key == 33) {
         editSize++; 
         trace("edit size = "+editSize);
         if (editSize > 5) { editSize = 5; return; }
         standaloneEditor();
      }
      // page down, board size --
      if (editMode && key == 34) {
         editSize--;
         trace("edit size = "+editSize);
         if (editSize < 3) { editSize = 3; return; }
         standaloneEditor();
      }

   }

   private static function processGraphics() : Void 
   {
      Main.gameUI.update();
      if (animation != null) {
         inputLock = true;
         if (animation.update() == false) {
            animation = null;
            inputLock = false;
         }
      }
      else if (endPane != null) {
         endPane.show();
         endPane = null;
      }
   }

   private static function initInFrusion() : Void
   {
      manager           = new grapiz.Manager();
      rootMovie.manager = manager;
   }

   private static function initStandalone() : Void    
   {
      userLogin = "auser";
      manager   = new grapiz.TestManager();
      // testFiveRadiusBoard();
      // testThreeRadiusBoard();
      // testFourPlayerGame(); 
      // testGameCreation();
      // testEndPane();
      // testLogPane();
      // testTextToXml();
      // testHandBoard();
      standaloneEditor();
   }

   private static function registerClasses() : Void
   {
      linkMovieClip( grapiz.gui.Game          );
      linkMovieClip( grapiz.gui.Board         );
      linkMovieClip( grapiz.gui.Token         );
      linkMovieClip( grapiz.gui.EndPane       );
      linkMovieClip( grapiz.gui.Confirm       );
      linkMovieClip( grapiz.gui.ChatPane      );
      linkMovieClip( grapiz.gui.MoveCursor    );
      linkMovieClip( grapiz.gui.PlayerInfo    );
      linkMovieClip( grapiz.gui.AvailableSlot );
      linkMovieClip( grapiz.gui.EditSlot      );

      // external dependencies
      Object.registerClass("mcFrutibouille", Frutibouille  );
      Object.registerClass("mcGoldNumber",   ext.game.Numb );
   }

   /**
    * Register class with its LINK_NAME movieclip.
    *
    * @param aClass A MovieClip class reference containing a static string 
    *               variable LINK_NAME which contains the linkage name of 
    *               the underlying movie clip.
    *               
    * @param append A string to append to the linkage name. This string may 
    *               be usefull to link 'mcNameX' movie clips where X 
    *               represents the movie clip theme.
    */
   private static function linkMovieClip( aClass, append:String )
   {
      if (append == undefined) { 
         append = ""; 
      }
      Object.registerClass(aClass.LINK_NAME + append, aClass);
   }

   private static function canSendMessage( str:String ) : Boolean
   {
      if (str == "") return false;
      if (str.indexOf("sex") != -1) return false;
      if (str == "merde") return false;
      if (str == "merd") return false;
      if (str.indexOf("putain") != -1) return false;
      if (str == "put1") return false;
      return true;
   }

   // ----------------------------------------------------------------------
   // Test Methods
   // ----------------------------------------------------------------------

   private static function testGameCreation() : Void
   {
      var xmlSrc : String = '<fo g="2" t="0" i="60000"><u s="15" u="auser" e="0"/><u u="buser" s="5" e="1"/><b size="4"><s t="0" x="8" y="8"/><s t="0" x="8" y="5"/><s t="0" x="7" y="3"/><s t="0" x="4" y="0"/><s t="0" x="1" y="0"/><s t="0" x="0" y="1"/><s t="0" x="0" y="4"/><s t="0" x="3" y="7"/><s t="0" x="5" y="8"/><s t="1" x="7" y="8"/><s t="1" x="8" y="7"/><s t="1" x="8" y="4"/><s t="1" x="5" y="1"/><s t="1" x="3" y="0"/><s t="1" x="0" y="0"/><s t="1" x="3" y="2"/><s t="1" x="3" y="3"/><s t="1" x="4" y="4"/></b></fo>';
      var xml    : XMLNode = new XML(xmlSrc).firstChild;
      var game   : grapiz.Game = new grapiz.Game(xml);
      gameMode = 1;
      grapiz.Main.start(game);
   }

   private static function testFourPlayerGame() : Void
   {
      var xmlSrc : String = '<fo g="2" t="0" i="60000">'
      + '<u u="auser" e="0" s="4"/>'
      + '<u u="buser" e="1" s="2"/>'
      + '<u u="cuser" e="2" s="0"/>'
      + '<u u="duser" e="3" s="5"/>'
      + '<b size="4">'
      + '<s t="0" x="8" y="8"/>'
      + '<s t="0" x="8" y="5"/>'
      + '<s t="0" x="7" y="3"/>'
      + '<s t="0" x="4" y="0"/>'
      + '<s t="1" x="1" y="0"/>'
      + '<s t="1" x="0" y="1"/>'
      + '<s t="1" x="0" y="4"/>'
      + '<s t="1" x="3" y="7"/>'
      + '<s t="2" x="5" y="8"/>'
      + '<s t="2" x="7" y="8"/>'
      + '<s t="2" x="8" y="7"/>'
      + '<s t="2" x="8" y="4"/>'
      + '<s t="3" x="5" y="1"/>'
      + '<s t="3" x="3" y="0"/>'
      + '<s t="3" x="0" y="0"/>'
      + '<s t="3" x="3" y="2"/>'
      + '<s t="0" x="3" y="3"/>'
      + '<s t="3" x="4" y="4"/>'
      +'</b>'
      +'</fo>';
      var xml    : XMLNode = new XML(xmlSrc).firstChild;
      var game   : grapiz.Game = new grapiz.Game(xml);
      Main.gameMode = 2;
      grapiz.Main.start(game);    
   }

   private static function testFiveRadiusBoard() : Void
   {
      var xmlSrc : String = '<fo g="2" t="0" i="60000">'
      + '<u u="auser" e="0" s="4"/>'
      + '<u u="buser" e="1" s="2"/>'
      + '<u u="cuser" e="2" s="0"/>'
      + '<u u="duser" e="3" s="10"/>'
      + '<b size="5">'
      + '<s t="0" x="8" y="8"/>'
      + '<s t="0" x="8" y="5"/>'
      + '<s t="0" x="7" y="3"/>'
      + '<s t="0" x="4" y="0"/>'
      + '<s t="1" x="1" y="0"/>'
      + '<s t="1" x="0" y="1"/>'
      + '<s t="1" x="0" y="4"/>'
      + '<s t="1" x="3" y="7"/>'
      + '<s t="2" x="5" y="8"/>'
      + '<s t="2" x="7" y="8"/>'
      + '<s t="2" x="8" y="7"/>'
      + '<s t="2" x="8" y="4"/>'
      + '<s t="3" x="5" y="1"/>'
      + '<s t="3" x="3" y="0"/>'
      + '<s t="3" x="0" y="0"/>'
      + '<s t="3" x="3" y="2"/>'
      + '<s t="0" x="3" y="3"/>'
      + '<s t="3" x="4" y="4"/>'
      +'</b>'
      +'</fo>';
      var xml    : XMLNode = new XML(xmlSrc).firstChild;
      var game   : grapiz.Game = new grapiz.Game(xml);
      Main.gameMode = 1;
      grapiz.Main.start(game);    
   }

   private static function testThreeRadiusBoard() : Void 
   {
      var xmlSrc : String = '<fo g="2" t="0" i="60000">'
      + '<u u="auser" e="0" s="4"/>'
      + '<u u="buser" e="1" s="2"/>'
      + '<u u="cuser" e="2" s="0"/>'
      + '<u u="duser" e="3" s="5"/>'
      + '<b size="3">'
      + '<s t="0" x="1" y="0"/>'
      + '<s t="1" x="0" y="1"/>'
      + '<s t="2" x="3" y="0"/>'
      + '<s t="3" x="0" y="0"/>'
      + '<s t="0" x="3" y="2"/>'
      + '<s t="2" x="3" y="3"/>'
      + '<s t="1" x="4" y="4"/>'
      +'</b>'
      +'</fo>';
      var xml    : XMLNode = new XML(xmlSrc).firstChild;
      var game   : grapiz.Game = new grapiz.Game(xml);
      Main.gameMode = 1;
      grapiz.Main.start(game);
      trace(Main.game.getBoard());
   }

   private static function testEndPane() : Void
   {
      Main.game.end(0);
   }

   private static function testLogPane() : Void
   {
      logMessage("this is a logic message", undefined);
      logMessage("this is a team 0 message", 0);
      logMessage("this is a team 1 message", 1);
   }

   private static function testTextToXml() : Void
   {
      var str = 
      '4\n'+
      '7 8 1    8 8 0    8 7 1\n'+
      '8 5 0    8 4 1    7 3 0\n'+  
      '5 1 1    4 0 0    3 0 1\n'+  
      '1 0 0    0 0 1    0 1 0\n'+  
      '0 3 1    0 4 0    1 5 1\n'+
      '3 7 0    4 8 1    5 8 0\n';
      var xml = textToXml(str);
      trace(xml);
   }

   private static function testHandBoard() : Void
   {
      var str = 
      '5\n'
      +'10 10 0\n' 
      +'0 0 0\n'
      +'5 0 1\n'
      +'5 10 1\n'
      +'10 5 2\n'
      +'0 5 2\n';

      var xml    : XMLNode = new XML( textToXml(str) ).firstChild;
      var game   : grapiz.Game = new grapiz.Game(xml);
      trace(boardToString(game.getBoard()));
      grapiz.Main.start(game);        
   }

   private static function standaloneEditor() : Void
   {
      editMode = true;
      var str  : String = "<fo g=\"2\" t=\"0\" i=\"60000\">"+
      "<u u=\"user 1\" e=\"0\" s=\"0\"/>"+
      "<u u=\"user 2\" e=\"1\" s=\"7\"/>"+
      "<u u=\"user 3\" e=\"1\" s=\"10\"/>"+
      "<u u=\"user 4\" e=\"1\" s=\"15\"/>"+
      "<b size=\"" + editSize + "\"/>"+
      "</fo>";
      var xml  : XMLNode = new XML( str ).firstChild;
      var game : grapiz.Game = new grapiz.Game(xml);
      grapiz.Main.start(game);        
      gameUI.showEditMode();
   }

   private static function textToXml( str : String ) : String
   {
      var result : String = '<fo g="2" t="0" i="60000">';
      var lines  : Array  = str.split("\n");
      var size   : String = String( lines.shift() );
      var maxTeam: Number = 0;

      result += '<b size="'+size+'">';

      while (lines.length > 0) {
         var elements = lines.shift().split(" ");
         while (elements.length > 0) {
            var x = elements.shift();
            var y = elements.shift();
            var t = elements.shift();

            if (t != "" && t != undefined){
               if (parseInt(t) > maxTeam){
                  maxTeam = parseInt(t);
               }
               result += '<s t="'+t+'" x="'+x+'" y="'+y+'"/>';            
            }

            var n = elements.shift();
            while (elements.length > 0 && n == "") {
               n = elements.shift();
            }
            if (n != "" && n != undefined) { 
               elements.unshift(n); 
            }
         }
      }

      result += '</b>';
      for (var i=0; i<=maxTeam; i++) {
         result += '<u u="user '+i+'" s="15" e="'+i+'" />';
      }
      result += '</fo>';
      return result;
   }

   private static function boardToString( board:grapiz.Board ) : String
   {
      var result : String = "" + board.getSize() + "\n";
      var tokens : Array  = board.getTokens();
      for (var i=0; i<tokens.length; i++) {
         var token : grapiz.Token = grapiz.Token( tokens[i] );
         if (token != undefined) 
            result += token.getCoordinate().x + " " + 
            token.getCoordinate().y + " " + 
            token.getTeam() + "\n";
      }
      return result;
   }

   private static function htmlEncode( str:String ) : String
   {
      debug("source : " + str);
      var result : String = "";
      for (var i=0; i<str.length; ++i) {
         switch (str.charAt(i)) {
            case "&":
            result += "&amp;";
            break;
            case "<":
            result += "&lt;";
            break;
            case ">":
            result += "&gt;";
            break;
            case "\"":
            result += "&quot;";
            break;
            default:
            result += str.charAt(i);
            break;
         }
      }
      debug("sending : " + result );
      return result;
   }
}

// EOF
