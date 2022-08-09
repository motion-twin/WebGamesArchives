//
// $Id: Chat.as,v 1.19 2004/07/15 17:19:52  Exp $
// 

import frutibandas.Main;

class frutibandas.gui.Chat extends MovieClip {

   public var fps : String;

   /** Static constructor. */
   public static function New( parent : MovieClip ) : Chat    
   {
      var result : frutibandas.gui.Chat;
      var depth  : Number = parent.getNextHighestDepth();
      result = Chat( parent.attachMovie("mcLogBox", "mcLogBox@"+depth, depth) );
      return result;
   }

   public function initChatMode()
   {
      this.gotoAndStop(1);

      function onSetFocusP(a)  { this._parent.onSetFocus(a); }        
      this.inputArea.onSetFocus = onSetFocusP;

      function onKillFocusP(a) { this._parent.onKillFocus(a); }
      this.inputArea.onKillFocus = onKillFocusP;

      this.isFocused = false;
      this.card._visible = false;
      this.infoText._visible = false;
      this.scroll();
   } 

   public function initInfoMode(id)
   { 
      this.gotoAndStop(2);
      this.isFocused = false;
      this.card._visible = true;
      this.card.gotoAndStop(id+10);
      this.infoText._visible = true;
      this.infoText.gotoAndStop(id+1);
   } 

   /** Which object will receive user input on which method. */
   public function setSendCallback( obj, mtd : Function ) : Void
   { 
      this.callback = new frutibandas.Callback(obj, mtd);
   } 

   /** A message was sent by an oponent. */
   public function writeMessage( src : String, msg : String ) : Void
   { 
      this.addText(src+" > "+msg);
   } 

   public function writeLog( msg : String ) : Void
   { 
      this.addText(msg);
   } 

   public function send() : Void
   { 
      if (canSendInput( this.input.toLowerCase())) {
         this.callback.execute_1(this.input);
      }
      else if (this.input != "") {
         addText("message non transmi (mot douteux trouv�)");
      }
      this.input = "";
   } 

   public function addText( str : String ) : Void
   { 
      this.value += str + "<br/>";
      this.scroll();
   } 

   public function getValue() : String
   { 
      return this.value;
   } 

   public function show() : Void
   { 
      this._visible = true;
   } 

   public function hasFocus() : Boolean 
   { 
      return this.isFocused;
   } 

   public function scroll() : Void
   {
      this.chatArea.scroll = this.chatArea.scroll + this.chatArea.maxscroll;
   }

   // ----------------------------------------------------------------------
   // Callbacks
   // ----------------------------------------------------------------------
   public function onSetFocus(oldFocus:MovieClip) : Void
   { 
      this.isFocused = true;
   } 

   public function onKillFocus(newFocus:MovieClip) : Void
   { 
      this.isFocused = false;
   }     

   // ----------------------------------------------------------------------
   // Private methods.
   // ----------------------------------------------------------------------

   private function Chat() 
   { 
      super();

      this.value     = frutibandas.Texts.WARNING_CHEATERS + "<br/>";
      this.input     = "";
      this.isFocused = false;

      this.callback  = null;

      this.initChatMode();
   } 

   private function canSendInput( str:String ) : Boolean
   {
      if (str == "") return false;
      if (str.indexOf("sex") != -1) return false;
      if (str == "merde") return false;
      if (str == "merd") return false;
      if (str.indexOf("putain") != -1) return false;
      if (str == "put1") return false;
      return true;
   }

   private var value     : String;
   private var input     : String;
   private var callback  : frutibandas.Callback;
   private var isFocused : Boolean;

   private var inputArea : TextField;
   private var chatArea  : TextField;
   private var card      : MovieClip;
   private var infoText  : MovieClip;
}

//EOF

