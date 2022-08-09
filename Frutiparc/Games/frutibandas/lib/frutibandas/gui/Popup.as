// 
// $Id: Popup.as,v 1.5 2004/03/11 11:35:19  Exp $
//

class frutibandas.gui.Popup extends MovieClip implements frutibandas.gui.Animable
{
	// CONSTANTES
	var mcw = 432
	var mch = 212
	
	// PARAMETRES
	var title:String;
	var text:String;
	
	// VARIABLES
	var runDepth:Number;
	var butList:Array;

    // COMPOSANTS
    var textArea;
    var titleArea;
	
	public static function New( parent:MovieClip ) : Popup
    { //{{{
        var depth : Number = parent.getNextHighestDepth();
        var popup : Popup  = Popup( parent.attachMovie("mcPopup", "Popup_"+depth, depth) );
        popup._x = 133; // (parent._width  - popup._width ) / 2;
        popup._y = 126; // (parent._height - popup._height) / 2;
        return popup;
    } //}}}

	public function setTitle(title)
    { //{{{
		this.title = title;
		this.titleArea.text = this.title;
	} //}}}

    public function setText(text)
    { //{{{
        trace("setting to "+this.textArea+" : "+text);
		this.text = text;
		this.textArea.text = this.text;
		this.textArea._y = 92-(this.textArea.textHeight/2);
	} //}}}
	
	public function addButton(text,callback)
    { //{{{
		var d = this.runDepth++;
		var mc = this.attachMovie("bouton", "but"+d, d);
		mc._y = 162;
		mc.field.text = text;
		mc.callback = callback;
        mc.onRollOver = function() {
            this.lightv._visible = true;
        }
        mc.onRollOut = function() {
            this.lightv._visible = false;
        }
        mc.onRelease = function() { 
            _parent._visible = false;
            callback.execute(); 
            _parent.removeMovieClip();
        }
		mc.lightv._visible = false;
		this.butList.push(mc);
	} //}}}

    public function draw()
    {//{{{
		var pad = mcw/(this.butList.length+1);
		for( var i=0; i<this.butList.length; i++ ){
			var but = this.butList[i];
			but._x = (i+1)*pad;
		}
    }//}}}
    
	public function update() : Boolean
    { //{{{
        this._visible = true;
        return false;
	} //}}}


    // ----------------------------------------------------------------------
    // Private methods
    // ----------------------------------------------------------------------

	private function Popup()
    { //{{{
		this.runDepth = 0;
		this.butList = new Array();
		this.setTitle(this.title);
		this.setText(this.text);
        this._visible = false;
	} //}}}
}
//EOF
