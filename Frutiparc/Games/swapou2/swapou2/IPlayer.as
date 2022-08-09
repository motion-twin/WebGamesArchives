interface swapou2.IPlayer {

	function depthManager() : asml.DepthManager;
	function swapDone();
	function explodeDone();
	function gravityDone();
	function fallingDone();
	function specialDone();
	function specialDoneGravity();
	function getLevelWidth() : Number;
	function getLevelHeight() : Number;
	function isIA() : Boolean;

}