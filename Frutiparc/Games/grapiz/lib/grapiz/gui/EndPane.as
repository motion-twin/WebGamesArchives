// 
// $Id: EndPane.as,v 1.4 2004/03/02 18:23:48  Exp $
//

class grapiz.gui.EndPane extends MovieClip 
{
    public static var LINK_NAME : String = "mcEndPane";

    private static var WinText : String = " remporte la partie !";

    private var pane    : MovieClip;
    private var btnQuit : MovieClip;
    private var madLock : Boolean;

    private var quitCallback : grapiz.Callback;

    /** Static constructor. */
    public static function New( game:grapiz.gui.Game ) : EndPane
    { // {{{
        var depth : Number = game.getNextHighestDepth();
        var ePane : EndPane = EndPane( game.attachMovie(LINK_NAME, LINK_NAME+depth, depth) );
        return ePane;
    } // }}}

    public function setText( txt:String ) : Void
    { // {{{
        this.pane.textArea.text = txt;
    } // }}}

    public function setQuitCallback( cb:grapiz.Callback ) : Void 
    { // {{{
        this.quitCallback = cb; 
    } // }}}
    
    /*
    public function setStayCallback( cb:grapiz.Callback ) : Void 
    { // {{{
        this.stayCallback = cb; 
    } // }}}
    */
    
    public function show()
    { // {{{
        this._x = (this._parent._width - this._width) / 2;
        this._y = (this._parent._height - this._height) / 2;
        this._visible = true;
    } // }}}

    
    // ----------------------------------------------------------------------
    // Buttons callbacks.
    // ----------------------------------------------------------------------
    
    public function onQuit() 
    { // {{{
        this.callAndClose( this.quitCallback );
    } // }}}
    
    /*
    public function onStay() 
    { // {{{
        this.callAndClose( this.stayCallback );
    } // }}}
    */
    
    // ----------------------------------------------------------------------
    // Private construction.
    // ----------------------------------------------------------------------
    
    private function EndPane()
    { // {{{
        this.madLock = false;

        this.pane.titleArea.text = grapiz.Texts.END_OF_GAME;

        this.quitCallback = null;

        this.btnQuit.label = "Quitter";
        this.btnQuit.onRelease = function() { this._parent.onQuit(); }
    } // }}}

    private function callAndClose( cb : grapiz.Callback ) : Void
    { // {{{
        if (this.madLock) return;
        if (cb == null) {
            throw new Error("Unable to activate EndPane callback ("+cb+")");
        }
        
        this.madLock = true;
        this._visible = false;
        cb.execute();
        this.removeMovieClip();
    } // }}}
}

//EOF
