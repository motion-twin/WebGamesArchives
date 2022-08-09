libPath =[
	"bumdum.swf",
	"skool.swf",
	"fe.swf",
	"box.swf",
	"root.swf",
	"frusion.swf",
	"interface.swf",
	"listener.swf",
	"unsorted.swf"
]

logText=""


mcl = new MovieClipLoader()

libToLoad = libPath.length;
libLoaded = 0;


myListener = new Object();
myListener.root = this;
myListener.onLoadComplete = function(mc){
	this.root.logText+="loadComplete("+mc+")\n"
	this.root.libLoaded++;
	if(this.root.libLoaded == this.root.libToLoad){
		this.root.play();
	}else{
		this.root.initLoad(this.root.libLoaded)
	}
}
myListener.onLoadError = function(mc,error){
	this.root.logText+="loadError("+error+")\n"
}
myListener.onLoadStart = function(mc){
	this.root.logText+="loadStart("+mc+")\n"
}
mcl.addListener(myListener)

function initLoad(id){
	this.createEmptyMovieClip("lib"+id,80+id)
	mcl.loadClip("http://www.beta.frutiparc.com/swf/lib/"+libPath[id],this["lib"+id])
}

initLoad(0)

/*
for(var i=0;i<libPath.length;i++){
	//this.createEmptyMovieClip("lib"+i,80+i)
	//mcl.loadClip("http://www.beta.frutiparc.com/swf/lib/"+libPath[i],this["lib"+i])
	this.createEmptyMovieClip("lib0",80)
	mcl.loadClip("http://www.beta.frutiparc.com/swf/lib/"+libPath[0],this.lib0)
}
*/

stop();


