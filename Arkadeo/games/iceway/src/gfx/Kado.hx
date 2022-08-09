package gfx;
import Lib;
import api.AKProtocol;

@:bind("gfx.Kado")
class Kado extends MovieClip
{
	public var prizeToken : SecureInGamePrizeTokens;

	public function new(token)
	{
		super();
		prizeToken = token;
	}
	
}