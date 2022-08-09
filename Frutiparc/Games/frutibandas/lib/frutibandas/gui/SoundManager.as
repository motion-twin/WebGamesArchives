// 
// $Id: SoundManager.as,v 1.3 2004/04/05 17:24:53  Exp $
//

import frutibandas.Main;

class frutibandas.gui.SoundManager
{
    public static var SND_INTRO_LINK_NAME = "mp3Intro";
    public static var SND_LOOP_LINK_NAME  = "mp3Loop";
    
    private var _sndIntro : Sound;
    private var _sndLoop  : Sound;
    
    public function SoundManager( rootMovie : MovieClip ) 
    {
        _sndIntro = new Sound( rootMovie );
        _sndIntro.attachSound( SND_INTRO_LINK_NAME );

        _sndIntro.onSoundComplete = function() { Main.sndManager.playLoop(); }
            
        _sndLoop  = new Sound( rootMovie );
        _sndLoop.attachSound( SND_LOOP_LINK_NAME );
    }

    public function start() : Void
    {
        _sndIntro.start();
    }

    public function playLoop() : Void
    {
        _sndLoop.start(0, 65000);
    }

    public function stop() : Void
    {
        _sndIntro.stop();
        _sndLoop.stop();
    }
}

//EOF
