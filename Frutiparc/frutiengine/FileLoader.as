/*
$Id: FileLoader.as,v 1.12 2004/02/28 18:03:16  Exp $

Class: FileLoader

Bool: loaded
True when the file was completly loaded
*/
/*
infos: {url, size}
loadingCallBack: {obj, method}
onLoadCallBack: {obj, method}

loadingCallBack called with the object as argument
loadingCallBack called with the object as argument, and success (true if loading succeed)

Properties of the object:
string url
int size
bool loaded
int bytesTotal
int bytesLoaded
int bytesToLoad
int percent
int timeElapsed (ms)
int estimatedTimeLeft (ms)
int transferRate (byte / ms ~ ko / s)

*/
class FileLoader{
	
	/*
	Group: Properties
	*/
	/*
	Property: url
		The file url
	*/
	var url:String;
	/*
	Property: size
		The file theoric size
	*/
	private var size:Number;
	/*
	Property: loaded
		True when the file was completly loaded
	*/
	var mc:MovieClip;
	/*
	Property: loaded
		True when the file was completly loaded
	*/
	var loaded:Boolean = false;
	var bytesTotal:Number;
	var bytesLoaded:Number;
	var bytesToLoad:Number;
	var percent:Number = 0;
	
	var timeStart:Number;
	var timeElapsed:Number = 0;
	var estimatedTimeLeft:Number;
	var transferRate:Number;
	
	//var mcl:FEMCLoader;
	var mcl:MovieClipLoader;

	function FileLoader(url,size){
        _global.debug( "FileLoader::FileLoader" );
		this.url = url;
		this.size = size;
        _global.debug( "FileLoader::FileLoader size = " + size );
        _global.debug( "FileLoader::FileLoader this.size = " + this.size );

		AsBroadcaster.initialize(this);
	}

	function loadClip(mc)
    {
        _global.debug( "FileLoader::loadClip" );
		this.mc = mc;
		
		this.timeStart = getTimer();
		
		//this.mcl = new FEMCLoader();
		this.mcl = new MovieClipLoader();
		this.mcl.addListener(this);
		
		this.mcl.loadClip(this.url,this.mc);
	}
	
	function onLoadError(a,b){
        _global.debug( "FileLoader::onLoadError" );
		this.loaded = false;
		//this.broadcastMessage("onLoadError",a,b);
		this.broadcastMessage("onFileNotFoundError");
	}

	function onLoadStart(){
        _global.debug( "FileLoader::onLoadStart" );
		this.broadcastMessage("onLoadStart");
	}

	function onLoadProgress(mc,loadedBytes,totalBytes){
		//var progress = this.mcl.getProgress();
		this.bytesLoaded = loadedBytes;
		this.bytesTotal = totalBytes;
		this.bytesToLoad = this.bytesTotal - this.bytesLoaded;
		this.percent = Math.round(this.bytesLoaded * 10000 / this.bytesTotal) / 100;
		
		this.timeElapsed = getTimer() - this.timeStart;
		this.transferRate = this.bytesLoaded / this.timeElapsed;
		this.estimatedTimeLeft = this.bytesToLoad / this.transferRate;	

		
		this.broadcastMessage("onLoadProgress",mc,loadedBytes,totalBytes);
	}

	function onLoadComplete(){
		var o = this.mcl.getProgress();
		this.bytesLoaded = o.bytesLoaded;
		this.bytesTotal = o.bytesTotal;
		
        _global.debug( "size=" + this.size );
        _global.debug( "this.bytesLoaded=" + this.bytesLoaded );
        _global.debug( "this.bytesTotal=" + this.bytesTotal );

        
		if(this.size == undefined || this.size == this.bytesLoaded){
			this.loaded = true;
			this.broadcastMessage("onLoadComplete");
		}else{
			this.broadcastMessage("onFalseSizeError");
			//this.broadcastMessage("onLoadError");
		}
	}
	
	function onLoadInit(){
        _global.debug( "FileLoader::onLoadInit this.size=" + this.size);
		
		/*
		for(var element in this.initObj){
			this.mc[element] = this.initObj[element]
		}
		*/
		if(this.size == undefined || this.size == this.bytesLoaded)
        {
            _global.debug( "FileLoader::onLoadInit:: size=" + this.size );
			this.broadcastMessage("onLoadInit");
		}
        else
        {
            _global.debug( "FileLoader::onLoadInit::error" );
			this.broadcastMessage("onFalseSizeError");
			//this.broadcastMessage("onLoadError");
		}
	}

	// Intrinsic
	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}

}
