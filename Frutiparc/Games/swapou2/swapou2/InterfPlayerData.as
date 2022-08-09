/*------------------------------------------------------------------------
Classe InterfPlayerData:

Structure de données utilisée par les interfaces
------------------------------------------------------------------------*/
class swapou2.InterfPlayerData {
	public var face : swapou2.Face ;
	//  public var faceBorder ;
	public var maxIndicator ;
	public var powerList ;
	public var power, oldPower ;
	public var powerX, powerY ;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function InterfPlayerData() {
		power = 0 ;
		oldPower = 0 ;
		powerList = new Array() ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		for (var i=0;i<powerList.length;i++)
			powerList[i].removeMovieClip() ;
		face.removeMovieClip() ;
		//    faceBorder.removeMovieClip() ;
		maxIndicator.removeMovieClip() ;
	}
}