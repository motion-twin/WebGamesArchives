// 
// $Id: EffectTitle.as,v 1.1 2004/02/25 17:57:16  Exp $
// 

class frutibandas.gui.EffectTitle extends MovieClip implements frutibandas.gui.Animable
{
    public static var LINK_NAME = "mcEffectTitle";

    private var background : MovieClip;
    private var titleArea  : MovieClip;
    private var step       : Number;
    
    public static function New( parent:MovieClip, depth:Number ) 
    { //{{{
        if (depth == undefined) {
            depth = parent.getNextHighestDepth();
        }
        return EffectTitle( parent.attachMovie(LINK_NAME, "EFX", depth) );
    } //}}}

    public function setTitle(title:String) : Void
    { //{{{
        this.titleArea.titleArea.text = title;
    } //}}}

    public function setTeam( team:Number ) : Void
    { //{{{
        this.background.gotoAndStop(team+1);
    } //}}}

    public function update() : Boolean
    { //{{{
        if (this.step == 0) { 
            this.play(); 
        }
        this.step++;
        if (this.step >= this._totalframes) {
            this.removeMovieClip();
            return false;
        }
        return true;
    } //}}}

    private function EffectTitle() 
    { //{{{
        this.step = 0;
        this.background.stop();
        this.stop();
    } //}}}
}

//EOF

