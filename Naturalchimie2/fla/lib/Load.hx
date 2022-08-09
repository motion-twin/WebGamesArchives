interface Load {
	public var count : Int ;
	public var n : Int ;
	public var s : String ;
	public var k : String ;
	public var domain : String ;
	public var dataDomain : String ;
	public function update() : Void ;
	public function done() : Bool ;
	public function lock() : Void ;
	public function unlock() : Void ;
	public function isLocked() : Bool ;
	public function isLoading() : Bool ;
	public function initLoading(?c : Int, ?x : Float, ?y : Float) : Void ;	
	public function reportError( e : Dynamic ) : Void ;
	

}