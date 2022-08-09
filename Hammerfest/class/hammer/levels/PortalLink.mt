class levels.PortalLink
{

	// from
	var from_did	: int;
	var from_lid	: int;
	var from_pid	: int;

	// to
	var to_did		: int;
	var to_lid		: int;
	var to_pid		: int;



	function new() {
	}


	function cleanUp() {
		if ( Std.isNaN(from_pid) )  {
			from_pid = 0;
		}
		if ( Std.isNaN(to_pid) )  {
			to_pid = 0;
		}
	}


	function trace() {
		Log.trace("link: "+from_did+","+from_lid+"("+from_pid+")  > "+to_did+","+to_lid+"("+to_pid+")");
	}
}

