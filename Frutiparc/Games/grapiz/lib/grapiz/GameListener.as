// 
// $Id: GameListener.as,v 1.1 2004/01/28 11:02:00  Exp $
//

interface grapiz.GameListener 
{
    function onEnd( winner:String ) : Void;
    function onMessage( user:String, message:String ) : Void;
}

//EOF
