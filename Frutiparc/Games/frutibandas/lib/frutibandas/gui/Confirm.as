// 
// $Id: Confirm.as,v 1.4 2004/06/24 11:43:43  Exp $
// 

class frutibandas.gui.Confirm extends MovieClip 
{
    private var btnCancel : MovieClip; // Button;
    private var btnAccept : MovieClip; // Button;

    private var text           : String;
    private var madlock        : Boolean;
    private var acceptCallback : frutibandas.Callback;
    private var cancelCallback : frutibandas.Callback;

    /** Static constructor. */
    public static function New( parent:MovieClip ) : Confirm 
    { //{{{
        var result : Confirm;
        var depth : Number = parent.getNextHighestDepth();
        result = Confirm( parent.attachMovie("mcConfirm", "mcConfirm@"+depth, depth) );
        result.center();
        return result;
    } //}}}

    public function setText(txt:String) : Void 
    { //{{{
        this.text = txt;
    } //}}}

    public function setCancelLabel(txt:String) : Void 
    { //{{{
        this.btnCancel.label = txt;
    } //}}}
    
    public function setAcceptLabel(txt:String) : Void 
    { //{{{
        this.btnAccept.label = txt;
    } //}}}

    public function setCancelCallback(callback:frutibandas.Callback) : Void 
    { //{{{
        this.cancelCallback = callback;
    } //}}}

    public function setAcceptCallback(callback:frutibandas.Callback) : Void 
    { //{{{
        this.acceptCallback = callback;
    } //}}}

    public function show() : Void 
    { //{{{
        this._visible = true;
    } //}}}

    // ----------------------------------------------------------------------
    // Private methods
    // ----------------------------------------------------------------------
    
    private function Confirm() 
    { // {{{
		super();
        this.madlock = false;
        this.setCancelLabel("Annuler");
        this.setAcceptLabel("Accepter");
        
		text = null;
		cancelCallback = null;
		acceptCallback = null;

		function onReleaseCancel() { _parent.onCancel(); };
		function onReleaseAccept() { _parent.onAccept(); }

        this.btnCancel.onRelease = onReleaseCancel;
        this.btnAccept.onRelease = onReleaseAccept;
    } // }}}

    private function onCancel() : Void 
    { //{{{
        if (this.madlock) return;
        
        this.madlock  = true;
        this._visible = false;
        if (this.cancelCallback != null) {
            this.cancelCallback.execute();
        }
        this.removeMovieClip();
    } //}}}

    private function onAccept() : Void 
    { //{{{
        if (this.madlock) return;

        this.madlock  = true;
        this._visible = false;
        if (this.acceptCallback != null) {
            this.acceptCallback.execute();
        }
        this.removeMovieClip();
    } //}}}

    private function center() : Void 
    { //{{{
        this._x = (this._parent._width - this._width) / 2;
        this._y = (this._parent._height - this._height) / 2;
    } //}}}
}
//EOF
