// 
// $Id: TokenListener.as,v 1.1.1.1 2004/01/26 15:09:48  Exp $
//

interface grapiz.TokenListener 
{
    function onMove( token:grapiz.Token, d:grapiz.Direction, n:Number ) : Void;
    function onDestroyed() : Void;
}

//EOF
