/*
import mb2.Manager;
import mb2.Const;
import mb2.Sound;
import mb2.Prefs;
*/
import frusion.gameclient.GameClient;

class Client extends GameClient {//}

	var cid:int
	//var startTime:Date;
	
	
	/*
	static var STANDALONE = false;
	/*///*
		static var STANDALONE = true
	//*/
	
	function new() {
		super();
		var gfi = fun(fname) {
			return { name : fname, size : 0 }; 
		};
		var f_true = fun() {
			return true;
		};
		
		
		if( STANDALONE ) {
			getFileInfos = gfi;
			isWhite = f_true;
		}
	}

	public function serviceConnect() {
		Manager.log("[CLIENT] serviceConnect()")
		if( STANDALONE ) {
			slots = [];
			cid = Std.getGlobal("setInterval")(this,"onServiceConnect",500)
			return;
		}
		super.serviceConnect();
	}

	/// -------------- CALLBACKS ------------------------------------

	public function onServiceConnect() {

		Manager.log("[CLIENT] onServiceConnect() : ")
		Manager.log("[CLIENT] Date > "+startTime.toString())
		//Manager.log("[CLIENT] dailyData > "+dailyData.toString())
		//Manager.log("startTime")
		//Manager.log( ">>>"+Log.toString( this ) )
	
			
		Manager.connected();
		if( STANDALONE ) {
			Std.getGlobal("clearInterval")(this.cid)
		}
	}
	
	public function onGameReset() {
		super.onGameReset();
		Manager.log("[CLIENT]onGameReset()")
		Manager.backToMenu();
	}
	
	public function onGameClose() {
		super.onGameClose();
		Manager.log("[CLIENT]onGameClose()")
		Cm.save();
	}
	
	public function onPause(){
		Manager.log("[CLIENT]onPause()")
		Manager.setPause(true)
	}
	
	public function saveSlot(n,data){
		Manager.log("[CLIENT] saveSlot("+n+")")
		super.saveSlot(n,data)
		
	}
	
	/*
	public function onGetTime(){
		Manager.time = startTime
	}
	*/
	
	/*
	public function getFileInfos(f){
		//_root._alpha = 50
		if( STANDALONE ) {
			//_root.test+="map/"+f+"\n"
			return { name : "map/"+f, size : 0 };
		}
		//_root.test+="not STANDALONE\n"
		return super.getFileInfos(f);
	}
	//*/

	/*
	public function getUser(){
		return "Bumdum"
	}
	*/
	
//{
}


