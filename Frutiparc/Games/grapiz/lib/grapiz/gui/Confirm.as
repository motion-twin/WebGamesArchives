// 
// $Id
// 

class grapiz.gui.Confirm extends MovieClip 
{
    public static var LINK_NAME : String = "mcConfirm";

    private var btnCancel : MovieClip; 
    private var btnAccept : MovieClip; 
    private var pane      : MovieClip; 

    private var madlock   : Boolean;
    
    private var acceptCallback : grapiz.Callback;
    private var cancelCallback : grapiz.Callback;

    /** Static constructor. */
    public static function New( parent:MovieClip ) : Confirm 
    {//{{{
        var result : Confirm;
        var depth : Number = parent.getNextHighestDepth();
        result = Confirm( parent.attachMovie("mcConfirm", "mcConfirm@"+depth, depth) );
        result.center();
        return result;
    }//}}}

    public function setTitle(txt:String) : Void
    { //{{{
        this.pane.titleArea.text = txt;
    } //}}}
    
    public function setText(txt:String) : Void 
    {//{{{
        this.pane.textArea.text = txt;
    }//}}}

    public function setCancelLabel(txt:String) : Void 
    {//{{{
        this.btnCancel.label = txt;
        // .setVar(this.btnCancel,"label",txt);
    }//}}}
    
    public function setAcceptLabel(txt:String) : Void 
    {//{{{
        this.btnAccept.label = txt;
        // .setVar(this.btnAccept,"label",txt);
    }//}}}

    public function setCancelCallback(callback:grapiz.Callback) : Void 
    {//{{{
        this.cancelCallback = callback;
    }//}}}

    public function setAcceptCallback(callback:grapiz.Callback) : Void 
    {//{{{
        this.acceptCallback = callback;
    }//}}}

    public function show() : Void 
    {//{{{
        this._visible = true;
    }//}}}

    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------

    private function Confirm() 
    {//{{{
		super();
		this.btnCancel = this.btnCancel; // .getVar(this,"btnCancel");
		this.btnAccept = this.btnAccept; // .getVar(this,"btnAccept");
        this.madlock = false;
        this.setCancelLabel("Annuler");
        this.setAcceptLabel("Accepter");
        
		cancelCallback = null;
		acceptCallback = null;

		function onReleaseCancel() { _parent.onCancel(); };
		function onReleaseAccept() { _parent.onAccept(); }

        this.btnCancel.onRelease = onReleaseCancel;
        this.btnAccept.onRelease = onReleaseAccept;
    }//}}}

    private function center() : Void 
    {//{{{
        this._x = (this._parent._width - this._width) / 2;
        this._y = (this._parent._height - this._height) / 2;
    }//}}}

    private function onCancel() : Void 
    {//{{{
        if (this.madlock) return;
        
        this.madlock  = true;
        this._visible = false;
        if (this.cancelCallback != null) {
            this.cancelCallback.execute();
        }
        this.removeMovieClip();
    }//}}}

    private function onAccept() : Void 
    {//{{{
        if (this.madlock) return;

        this.madlock  = true;
        this._visible = false;
        if (this.acceptCallback != null) {
            this.acceptCallback.execute();
        }
        this.removeMovieClip();
    }//}}}
}
//EOF
