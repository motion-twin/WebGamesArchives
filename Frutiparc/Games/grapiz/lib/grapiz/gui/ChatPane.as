// 
// $Id: ChatPane.as,v 1.9 2004/07/15 17:19:42  Exp $
//

class grapiz.gui.ChatPane extends MovieClip
{
    public static var LINK_NAME : String = "mcChatPane";
    
    private var focused   : Boolean;
    private var input     : String;
    private var content   : String;
    private var textArea  : TextField;
    private var inputArea : TextField;

    /** 
     * Static constructor. 
     */
    public static function New( parent:MovieClip ) : ChatPane 
    { 
        var d : Number = parent.getNextHighestDepth();
        return ChatPane( parent.attachMovie(LINK_NAME, LINK_NAME+d, d) );
    } 

    public function writeMessage( src:String, msg:String ) : Void
    { 
        this.addText(src + " > "+ msg);
    } 

    public function writeLog( msg:String ) : Void
    { 
        this.addText(msg);
    } 

    public function clear() : Void
    {
        this.content = "";
    }
    
    public function addText( str:String ) : Void
    { 
        this.content += str + "<br/>";
        this.textArea.scroll = this.textArea.scroll + this.textArea.maxscroll;
    } 

    public function setSelectable( b:Boolean ) : Void
    {
        textArea.selectable = b;
    }
    
    public function hasFocus() : Boolean 
    { 
        return focused; 
    } 
    
    public function getInput() : String  
    { 
        return this.input; 
    } 
    
    public function flushInput() : Void  
    { 
        input = "";   
    } 
    
    // ----------------------------------------------------------------------
    // callbacks for input textarea
    // ----------------------------------------------------------------------
    
    public function onSetFocus(a:Object) : Void 
    { 
        this.focused = true;
    } 
    
    public function onKillFocus(a:Object) : Void 
    { 
        this.focused = false;
    } 

    // ----------------------------------------------------------------------
    // Private methods
    // ----------------------------------------------------------------------
    
    private function ChatPane()
    { 
        this.content = grapiz.Texts.WARNING_CHEATERS + "<br/>";
        this.input   = "";
        this.focused = false;

        function onSetFocusP(a)  { this._parent.onSetFocus(a);   }
        function onKillFocusP(a) { this._parent.onKillFocusP(a); }
        this.inputArea.onSetFocus  = onSetFocusP;
        this.inputArea.onKillFocus = onKillFocusP;
    } 
}

//EOF
