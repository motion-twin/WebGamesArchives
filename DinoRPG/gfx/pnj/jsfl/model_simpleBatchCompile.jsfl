


// options
var recursive = false;
var path = "${paths}";
var deployFolder = "${deployFolder}";

path = path.split("C:").join("file:///C|");
deployFolder = deployFolder.split("C:").join("file:///C|");

var errorsURI = path + "logs/errors.txt";
var logURI = path + "logs/log.txt";

createErrorCheck();
createLog();
// call
main();

function main(){
	var folderURI = path;
	processFolder(folderURI);
}

function processFolder(folderURI){
	
	if (folderURI){
		log("Process Folder:"+folderURI+"\n");
		var files = FLfile.listFolder(folderURI, "files");
		var file;
		var i = files.length;
		while(i--){
			file = files[i];
			log("\tProcess File:"+file+"\n");
			if (file.slice(-4).toLowerCase() == ".fla"){
				var flaName = file.split('.').reverse()[1];
				var flatime=Number("0x"+FLfile.getModificationDate(folderURI +"/"+ file));
				var swffile=deployFolder+flaName+".swf";
				var swftime=0;
				if (FLfile.exists( swffile ))  {
					swftime = Number("0x"+FLfile.getModificationDate(swffile));
				}
				log("\t\t"+flaName+" "+flatime+" vs "+swftime+"\n");
				if(swftime<(flatime-1000) || ("${forceBuild}" == "true")){
					if( fl.publishDocument(folderURI +"/"+ file) == false )
					{
						log("impossible de compiler le document "+folderURI +"/"+ file+"\n");				
						fl.outputPanel.save(logURI,true);
						fl.compilerErrors.save(logURI,true);
						logCompileErrors();
						log("\n");
						return;
					}
				}
			}
		}
		
		if (recursive){
			files = FLfile.listFolder(folderURI, "directories");
			i = files.length;
			while(i--){
				processFolder(folderURI +"/"+ files[i]);
			}
		}
	}
	return;
}


function createErrorCheck(){
	FLfile.write(errorsURI, "");
}

function logCompileErrors(){
	fl.compilerErrors.save(errorsURI);
}

function createLog(){
	FLfile.write(logURI, "Compile Log...\n");
}

function log(message){
	FLfile.write(logURI, message+".\n", "append");
}
