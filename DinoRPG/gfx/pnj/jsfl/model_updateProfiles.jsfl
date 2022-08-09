


// options
var recursive = false;
var path = "${paths}";
var export_path = "${exportPath}";

path = path.split("C:").join("file:///C|");

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
				var doc = fl.openDocument(folderURI +"/"+ file);
				if( doc != null ){
					var profileXML = new XML(doc.exportPublishProfileString());
					//
					profileXML.PublishFormatProperties.flashFileName = export_path+flaName+".swf";
					profileXML.PublishFormatProperties.defaultNames = 0
					profileXML.PublishFormatProperties.flash = 1;
					profileXML.PublishFormatProperties.generator = 0;
					profileXML.PublishFormatProperties.projectorWin = 0;
					profileXML.PublishFormatProperties.projectorMac = 0;
					profileXML.PublishFormatProperties.html = 0;
					
					profileXML.PublishFlashProperties.Protect = 1;
					profileXML.PublishFlashProperties.OmitTraceActions = 0;
					profileXML.PublishFlashProperties.Version = 8;
					profileXML.PublishFlashProperties.ActionScriptVersion = 2;
					//
					doc.importPublishProfileString( profileXML.toString() );
					doc.save();
					doc.close();
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
