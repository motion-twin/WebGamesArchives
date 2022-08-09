
dp_tracer = 120

mcw = 240;
mch = 240;
maxType = 50;
shipSize = 18;
gridSpace= 24
distMin = 17
cooldown = 0;
test = ""
flTracer = false
currentLine = 0;





function init(){
	createEmptyMovieClip("level",80)
	level.d = 0;
	lvl = 0;
	
	//initWaveInfo();
	interfaceWaveName = "mainWave"
	linkCookie();
	
	initButton();
	
	mcBackground.onPress = function(){
		clickBg();
	}
	
	flLock = false;
	mcLock._visible = false;
	
}
/*
function initData(){

	this.data = {
		name:"",
		moveSpeed:1,
		fallSpeed:1,
		list:[]
		
	}
	
}
*/

function initButton(){
	var col = 14
	var ecart = (mch/(col+1))
	
	for( var i=0; i<maxType; i++ ){
		
		this.attachMovie("ship","but"+i,10+i);
		var mc = this["but"+i]
		mc.but.onPress = function(){
				this._parent._parent.createShip(this._parent.type);
		}
		mc.type = i;
		mc._x = (mcw+7) + Math.floor(i/col)*(this.shipSize+4);
		mc._y = ((i%col)+1)*ecart - this.shipSize/2
		#include "../inc/badsName.as"
		mc.attachMovie( "miniWave2SpBads"+badsNameList[i], "skin", 10 )
		mc.skin._x = shipSize/2
		mc.skin._y = shipSize/2
		mc.skin.stop();
		this.dragIcon
	}
};

function createShip(type){
	
	this.attachMovie("ship","dragIcon",1040)
	this.dragIcon._x = _xmouse-shipSize/2
	this.dragIcon._y = _ymouse-shipSize/2
	this.dragIcon.type = type
	#include "../inc/badsName.as"
	this.dragIcon.attachMovie( "miniWave2SpBads"+badsNameList[type], "skin", 10 )
	this.dragIcon.skin._x = shipSize/2
	this.dragIcon.skin._y = shipSize/2
	this.dragIcon.skin.stop();	
	this.dragIcon._alpha = 50;
	//this.dragIcon.startDrag();
	
	this.dragIcon.but.onPress = function(){
		this._parent._parent.release();
	}
	
}

function release(){

	var x = this.dragIcon._x 
	var y = this.dragIcon._y
	
	if(!checkFree(x,y)){
		if(Key.isDown(80)){
			lastFreeInfo.t = this.dragIcon.type
			cleanLevel();
			initLevel();
		}
		return;
	}
	
	if( x>0 && x<mcw && y>0 && y<mch ){
		
		
		insertShip( x, y, this.dragIcon.type, currentLine )
		
		if(Key.isDown(68)||Key.isDown(220)){
			var dx = (x+(shipSize/2))-(mcw/2)
			x = ((mcw/2) - dx) -(shipSize/2)
			insertShip( x, y, this.dragIcon.type, currentLine )
		}
	}else{
	
	}
	if(!Key.isDown(17))dragIcon.removeMovieClip();
	
}

function insertShip(x,y,t,line){
		x = Math.round(x)
		y = Math.round(y)
	
		if( line == undefined ) line = currentLine;
		if( t == undefined ) t = 0
	
		// MC
		var mc = newShip(x,y,t)
		mc.line = line;

		// DATA
		var o = {
			t:t,
			x:x,
			y:y,
			path:mc
		}
		if( data.list[line] == undefined ){
			//_root.test+="creation d'une nouvelle ligne\n"
			data.list[line] = new Array();
		}
		data.list[line].push(o);
}

function newShip(x,y,type){
	var d = level.d++
	
	
	level.attachMovie( "ship", "ship"+d, d )
	var mc = level["ship"+d]

	mc._x = x
	mc._y = y
	mc.type = type
	
	#include "../inc/badsName.as"
	mc.attachMovie( "miniWave2SpBads"+badsNameList[type], "skin", 10 )
	mc.skin._x = shipSize/2
	mc.skin._y = shipSize/2	
	mc.but.onPress = function(){
		this._parent._parent._parent.take(this._parent);
	}	
	mc.skin.stop();
	return mc
}

function take(mc){

	if(!flTracer){
		if(!Key.isDown(46))createShip(mc.type);
		if(!Key.isDown(17)){
			this.removeFromList(mc);
			mc.removeMovieClip();
		}
	}else{
		var index = getIndex(mc)
		var line =  data.list[mc.line]
		var o = line[index]
		line.splice(index,1);
		if(data.list[currentLine] == undefined ){
			data.list[currentLine] = new Array();
		}
		data.list[currentLine].push(o);
		mc.line = currentLine;
		
		if( Key.isDown(17) ){
			o.e=1;
		}else{
			if(o.e)delete o.e;
		}
		updateTracer();
		//removeTracer();
		//createTracer();
	}
}

function removeFromList(mc){
	var line = data.list[mc.line]
	line.splice(getIndex(mc),1)
	if( line.length == 0 ){
		//_root.test+="thotehiethne\n"
		//delete data.list[mc.line];
		data.list.splice(mc.line,1)
	}
}

function getIndex(mc){
	//if( n == undefined ) n = currentLine;
	var line = data.list[mc.line]
	for( var i=0; i<line.length; i++ ){
		if(line[i].path == mc){
			return i;
		}
	}
}
//
function loop(){
	// NECESSAIRE ?
	//so.data.level = waveInfo;
	
	fieldLevelMax.text = "LAST: "+waveInfo.length
	//
	if(cooldown--<0){
		// PASSAGE LEVELS
		if( Key.isDown(Key.SHIFT) && !flLock ){
			if( Key.isDown(Key.UP) ){
				this.moveAll(0,-1)
			}
			if( Key.isDown(Key.DOWN) ){
				this.moveAll(0,1)
			}
			if( Key.isDown(Key.LEFT) ){
				this.moveAll(-1,0)
			}
			if( Key.isDown(Key.RIGHT) ){
				this.moveAll(1,0)
			}	

			if( Key.isDown(88) ){	// -X- couper		// Desactivé pour eviter les erreur
				stamp = data
				resetLevel();
				cooldown = 10
			}

			if( Key.isDown(67) ){	// -C- copier
				stamp = clone(data)
				cooldown = 10
			}		
			if( Key.isDown(86) ){	// -V- coller		// pb avec path ?
				waveInfo[lvl] = clone(stamp);
				//delete stamp;
				cleanLevel();
				initLevel();
				cooldown = 10
			}
			if( Key.isDown(73) ){	// -I- INSERT		// INSERE LE LVL EN MEMOIRE ET DECALE LA VAGUE
				var o = clone(stamp)
				waveInfo.splice(lvl+1,0,o)
				//delete stamp;
				cleanLevel();
				initLevel();
				cooldown = 10			
			}
			if( Key.isDown(82) ){	// -R- REMOVE		// INSERE LE LVL EN MEMOIRE ET DECALE LA VAGUE
				stamp = data
				waveInfo.splice(lvl,1)
				cleanLevel();
				initLevel();
				cooldown = 10			
			}
			
			
			
			
			
		}else{
			if( Key.isDown(Key.UP) ){
				this.incLevel(1)
			}
			if( Key.isDown(Key.DOWN) ){
				this.incLevel(-1)
			}
			
			if( Key.isDown(27) ){
				cooldown = 10
				flLock = !flLock
				mcLock._visible = flLock
			}
			
			
		}
	
	}
	
	// MOVE DRAGICON
	if(this.dragIcon._visible){
		var x = _xmouse - shipSize/2
		var y = _ymouse - shipSize/2	
		if( Key.isDown(16) ){
			this.dragIcon._x = Math.round(x/gridSpace)*gridSpace
			this.dragIcon._y = Math.round(y/gridSpace)*gridSpace
			
		}else{
			this.dragIcon._x = x
			this.dragIcon._y = y
		}
		if(Key.isDown(46)){
			this.dragIcon.removeMovieClip();
		}
	}
	
	// TRACER
	if( Key.isDown(Key.SPACE) ){
		if(!flTracer){
			this.flTracer = true;
			this.dragIcon.removeMovieClip();
			this.createTracer();
		}
		if( Key.isDown(8) ){
			if(flBackSpaceReady){
				flBackSpaceReady = false;
				this.removeLastTracerPoint();
			}
		}else{
			flBackSpaceReady = true;
		}		
	}else{
		if(flTracer){
			this.flTracer = false;
			this.removeTracer();
		}	
	}
	// CURRENTLINE
	var c = currentLine
	for(var i=0; i<10; i++){
		if(Key.isDown(48+i)){
			currentLine = i;
		}
	}
	if( c != currentLine && flTracer){
		updateTracer();
	}
	
	
	
	
}
//
function incLevel(inc){

	saveLevel();
	cleanLevel();
	lvl = Math.max(0,this.lvl+inc);
	initLevel();
	cooldown = 10*(1+(1/cooldown))
}

function cleanLevel(){
	for( var n=0; n<data.list.length; n++ ){
		var line = data.list[n];
		for( var i=0; i<line.length; i++ ){
			line[i].path.removeMovieClip();
		}
	}
	
}

function saveLevel(){
	//_root.test="saveLevel!\n"
	
	// VIRE LES LAYERS VIDES
	/*
	for(var i=0; i<data.list; i++){
		if( data.list[i].length == 0 ){
			_root.test+="- layer viré !\n"
			data.list.splice(i,1)
			i--;
		}
	}
	*/
	

	data.name = interfaceName;
	data.moveSpeed = Number(interfaceSpeed);
	data.fallSpeed = Number(interfaceFall);
	data.ss =  Number(interfaceStartSpeed);
	data.sd =  Number(interfaceStartDecal);
	
	/*
	if( data.list.length == 0 ){
		_root.test += "- c'est tout vide\n"
	}else{
		_root.test += "- reste des trucs:\n"
		for( var i=0; i<data.list.length; i++ ){
			var layer = data.list[i]
			_root.test += " -"+layer+"\n"
		}
		
	}
	*/
	
	/*z
	if( data.list.length == 0 ){
		waveInfo.splice( lvl, 1 )
		//lvl = Math.max(0,lvl-1)
	}else{	
		
		
	}
	*/
	waveInfo[lvl] = data
	
}


function traceWaveInfo(){
	saveLevel();
	
	_root.test = ext.util.PersistCodecOld.encode(this.waveInfo)//str
	
	/*
	var 						str =		"	this.waveInfo = [\n"
	for(var i=0; i<this.waveInfo.length; i++){
		var info = this.waveInfo[i]
							str +=		"		{\n"
							str +=		"			name:\""+info.name+"\",\n"
							str +=		"			moveSpeed:"+info.moveSpeed+",\n"
							str +=		"			fallSpeed:"+info.fallSpeed+",\n"
							str +=		"			ss:"+info.ss+",\n"
							str +=		"			sd:"+info.sd+",\n"
							str +=		"			list:[\n"
		for(var n=0; n<info.list.length; n++){
			var line = info.list[n]
			if(line.length>0){
							str +=		"				[\n"		
				for(var s=0; s<line.length; s++){
					var ship = line[s]
							str +=		"					{ x:"+ship.x+", y:"+ship.y
					if(ship.e != undefined )str += ", e:"+ship.e
					if(ship.t != undefined ){
						str += ", t:"+ship.t
					}
					str += " }"
					if(s<line.length-1)str+=",";
					str+="\n";
								
				}
							str +=		"				]"
				if(n<info.list.length-1)str+=",";
				str+="\n";
			}
		}		
							str +=		"			]\n"
							str +=		"		}"
		
		if(i<this.waveInfo.length-1) str+=",";
		str+="\n";
	}
							str +=		"	]\n"
	_root.test=str
	*/
}

function initLevel(){
	//_root.test+="initLevel()\n\n"
	data = waveInfo[lvl]
	
	if(data == undefined){
		//_root.test+="data undefined\n"
		data = {
			name:" vague no"+(lvl+1)+"...",
			moveSpeed:1,
			fallSpeed:6,
			ss:6,
			sd:6,
			list:[]		
		}
		waveInfo[lvl] = data
	}
	
	if( data.list == undefined ){
		//_root.test+="nouvel Array\n"
		data.list = new Array(); // PATCH
	}
	
	for(var n=0; n<data.list.length; n++){
		//_root.test+="o\n"
		var line = data.list[n]
		//var num = 0
		for(var i=0; i<line.length; i++){
			//_root.test+="-\n"
			var info = line[i]
			
			if( info.t != undefined ){
				//num++
				//_root.test=num+"\n"
				info.path = newShip( info.x, info.y, info.t)
				info.path.line = n;
			}
		}
	}
	//INTERFACE
	interfaceLevel = lvl;
	interfaceName = data.name;
	interfaceFall = data.fallSpeed
	interfaceSpeed = data.moveSpeed
	interfaceStartSpeed = data.ss
	interfaceStartDecal = data.sd
	
}


function createTracer(){
	this.createEmptyMovieClip("tracer",dp_tracer)
	var alpha = 20
	var old = {x:0,y:0}
	
	//var line = data.list[currentLine]
	
	for(var n=0; n<data.list.length; n++){
		
		var line = data.list[n]
		
		for(var i=0; i<line.length; i++){
			var o = line[i]
			var d = shipSize/2
			var alpha = 10+40*i/line.length
			var color;
			if( n==currentLine){
				var color = 0xFFFFFF
			}else{
				var color = 0xFF0000
			}
			
			this.tracer.lineStyle(8,color,alpha)
			
			var x = o.x+d
			var y = o.y+d
			
			if( i == 0 ){
				this.tracer.moveTo(x,y);
			}else{
				this.tracer.lineTo(x,y);
			}
			
			if(o.e){
	
				this.tracer.moveTo(old.x,old.y)
			}else{
				old.x = x
				old.y = y
			}
		}
	}
}

function removeTracer(){
	this.tracer.removeMovieClip();
}

function updateTracer(){
	removeTracer()
	createTracer()
}

function resetPath(){
	var line = data.list[currentLine]
	for( var i=0; i<line.length; i++){
		var o = line[i]
		if( o.t == undefined ){
			line.splice(i,1);
			i--;
		}else{
			delete o.e
		}
	}	
}

function clickBg(){
	if(flTracer){
		var o = {
			x:Math.round(_xmouse-shipSize/2),
			y:Math.round(_ymouse-shipSize/2)
		}
		//_root.test="("+o.x+","+o.y+")\n"
		data.list[currentLine].push(o)
		updateTracer();
	}
}

function removeLastTracerPoint(){
	var line = data.list[currentLine]
	var o = line[line.length-1]
	if(o.t!=undefined){
		line.unshift(line.pop())
	}else{
		line.pop();
	}
	updateTracer();
	
};

function moveAll( x , y ){

	for( var n=0; n<data.list.length; n++){
		if( n == currentLine || Key.isDown(Key.ENTER) ){
			var line = data.list[n]
			for(var i=0; i<line.length; i++){
				var info = line[i]
				info.x += x
				info.y += y
				if( info.path != undefined ){
					info.path._x = info.x
					info.path._y = info.y
				}	
			}
		}
	}
	cooldown = 4 * (1+(1/cooldown))
}

function saveToCookie(){
	so.data.level = waveInfo;
}


// BUTTONS
function loadWave(){
	//_root._alpha = 50
	cleanLevel();
	lvl = 0;
	waveInfo = ext.util.PersistCodecOld.decode( _root.test )
	saveToCookie()
	initLevel();
}

function saveWave(){
	//_root.test+="saveWave\n"
	//so.data.level = waveInfo;
	traceWaveInfo();
}

function linkCookie(){
	//saveWave();
	cleanLevel();
	lvl = 0;
	so = _root.loadData("miniWave2/level/"+interfaceWaveName);
	waveInfo = so.data.level
	if( waveInfo == undefined ){
		waveInfo = new Array();
		saveToCookie()
	}
	initLevel();
}

function backUp(){
	sob = _root.loadData("miniWave2/level/backup");
	sob.data.level = waveInfo;
}


function resetPath(){
	var line = data.list[currentLine];
	for( var i=0; i<line.length; i++){
		var o = line[i]
		if( o.t == undefined ){
			line.splice(i,1);
			i--;
		}else{
			delete o.e
		}
	}	
}

function resetLevel(){
	if(Key.isDown(Key.CONTROL)){
		delete waveInfo[lvl]
		cleanLevel();
		initLevel();
	}
}

function roundLevel(){
	_root.test = "level rounding...\n"
	for( var i=0; i<waveInfo.length; i++ ){
		var wave = waveInfo[i].list
		for( var n=0; n<wave.length; n++ ){
			var line = wave[n]
			for( var ln=0; ln<line.length; ln++ ){
			
				var o = line[ln]
				var x = Math.round(o.x)
				var y = Math.round(o.y)
				if( x != o.x || y != o.y){
					_root.test += " - rounded Line ["+i+","+n+","+ln+"]\n"
					o.x = x;
					o.y = y;
				}
			}
		}		
	}

	
	
}

function cleanWorld(){
	_root.test = "cleaning world...\n"
	var n = 0
	for( var i=0; i<this.waveInfo.length; i++ ){
		var list = this.waveInfo[i].list
		if( list.length == 0 ){
			this.waveInfo.splice(i,1);
			_root.test+=" - vague "+(i+n)+" cleaned\n"
			i--;
			n++;
		}
		
	}
}


// TOOLS

function checkFree(x,y){
	//var line = data.list[currentLine]
	for( var n=0; n<data.list.length; n++ ){
		var line = data.list[n]
		for( var i=0; i<line.length; i++ ){
			var info =line[i]
			if(info.t!=undefined){
				var dif = Math.abs(x-info.x) + Math.abs(y-info.y)
				
				if(dif<distMin){
					lastFreeInfo = info
					return false;
				}
				
			}
		}
	}
	return true;
}

function clone(o){
	var c = new Object();
	for(var elem in o){
		c[elem] = cloneVar( o[elem] )
	}
	return c;	
	
}

function cloneVar(v){
	
	if( v instanceof Array ){
		var a = new Array();
		for(var i=0; i<v.length; i++){
			a[i] = cloneVar( v[i] )
		}
		return a;
	}else if( typeof v == "object" ){
		return clone(v);
	}else{
		return v;
	}
}

// LEVEL

function traceObject(o,sep){
	if(sep==undefined)sep="";
	for(var elem in o){
		var v = o[elem]
		if( typeof v == "object" ){
			_root.test+=sep+" "+elem+" :\n"
			traceObject(v,sep+"-")
		}else{
			_root.test+=sep+" "+elem+" : "+o[elem]+"\n"
		}
	}
	//return c;	
	
}





