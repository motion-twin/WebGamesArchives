// 
// $Id: EndPanel.as,v 1.7 2004/06/24 11:43:43  Exp $
// 

import frutibandas.Callback;

class frutibandas.gui.EndPanel extends MovieClip 
{
    private var btnStay : MovieClip;
    private var btnQuit : MovieClip;
    
    private var madlock    : Boolean;
    private var winnerName : String;
    
    private var stayCallback : Callback;
    private var quitCallback : Callback;

    /** Static constructor. */
    public static function New( parent:MovieClip ) : EndPanel 
    {//{{{
        var result: EndPanel;
        var depth = parent.getNextHighestDepth();
        result = EndPanel( parent.attachMovie("mcEndPanel", "mcEndPanel@"+depth, depth) );
        result.center();
        return result;
    }//}}}

    public function setStayCallback( callback:Callback ) : Void 
    {//{{{
        this.stayCallback = callback;
    }//}}}

    public function setQuitCallback( callback:Callback ) : Void 
    {//{{{
        this.quitCallback = callback;
    }//}}}

    public function setWinnerName(name:String) : Void 
    {//{{{
        this.winnerName = name;
    }//}}}

	public function show() : Void 
    {//{{{
		this._visible = true;
	}//}}}

    
    // ----------------------------------------------------------------------
    // Button callbacks.
    // ----------------------------------------------------------------------
    
    public function onStay() : Void 
    {//{{{
        if (this.madlock) return;
        this.madlock  = true;
        this._visible = false;
        if (this.stayCallback != null) this.stayCallback.execute();
        this.removeMovieClip();
    }//}}}
    
    public function onQuit() : Void 
    {//{{{
        if (this.madlock) return;
        this.madlock  = true;
        this._visible = false;
        if (this.quitCallback != null) this.quitCallback.execute();
        this.removeMovieClip();
    }//}}}
    

    // ----------------------------------------------------------------------
    // Private methods.
    // ----------------------------------------------------------------------

    /** Constructor. */
    private function EndPanel() 
    {//{{{
        super();
       
        this.stayCallback = null;
        this.quitCallback = null;
        
        this.winnerName = null;
        this.madlock = false;

        this.btnStay.label = "Rester";
        this.btnQuit.label = "Quitter";
        
        function onReleaseStay() { this._parent.onStay(); }
        function onReleaseQuit() { this._parent.onQuit(); }
        
        this.btnStay.onRelease = onReleaseStay;
        this.btnQuit.onRelease = onReleaseQuit;
    }//}}}

    private function center() : Void 
    {//{{{
        this._x = (this._parent._width - this._width) / 2;
        this._y = (this._parent._height - this._height) / 2;
    }//}}}
}

//EOF
