
plMax = 2//9
clMax = 4



function init(){

	so = SharedObject.getLocal("dino");
	cl = so.data.cl
	if(cl==null)initCl();
	

	cadre.loadMovie("../../swf/avatar.swf")
	initNum();
	initKey();

}

function initCl(){
	cl = new Array();
	for( var i=0; i<plMax+clMax; i++ ) cl.push(0);
	so.data.cl = cl

}

function initKey(){
	kl= new Object();
	kl.me = this;
	kl.onKeyDown = function(){
		if( Key.getCode() == 70 ){
			
			this.me.initCl();
			this.me.init();
		}
	}
	Key.addListener(kl);
	
}


// NUMBER
function initNum(){
	
	var n = 0
	for( var n=0; n<plMax+clMax; n++ ){
		attachMovie("intNum","num"+n,10+n);
		var mc = this["num"+n]
		mc._x = 200 + Math.floor(n/4)*60
		mc._y = 11 + (n%4)*31
		mc.field.text = cl[n];
		mc.id = n;
		initSideBut(mc,n);
		
	}
	
	
	
}




function initSideBut(mc,id){
	var me = this;
	mc.f0.onPress = function(){
		me.incId(id,-1);
	}
	mc.f1.onPress = function(){
		me.incId(id,1);
	}
}

function incId(id,inc){

		var max = 9999//pic._totalframes-1
		var n = cl[id]
		n = Math.min(Math.max(0,n+inc),max)
		
		if( n != cl[id] ){
			cl[id] = n
			var mc = this["num"+id]
			mc.field.text = n
			apply();
		}

}


// COLOR
/*
function initColor(){
	var y = 100
	for( var i=0; i<clMax; i++ ){
		var col = hexToCol(cl[plMax+i])
		for( var n=0; n<3; n++ ){
			attachMovie("intColor","cb"+i+"_"+n,100+i*10+n);
			var mc = this["cb"+i+"_"+n];
			mc._x = 10;
			mc._y = y;
			mc.square.gotoAndStop(n+1)
			mc.but._x = (col[n]/255)*140
			initColorButton(mc,i,n)
			
			y += 10;
		}
		y += 4
	}
	
	attachMovie("intField","field",200);
	field._x = 10;
	field._y = y;
	
}

function initColorButton(mc,id,n){
	mc.but.onPress = function(){
		startDrag(mc.but,false,0,3,140,3)
	}
	mc.but.onRelease = function(){
		stopDrag()
		releaseColorButton(mc,id,n)
	}
	
}

function releaseColorButton(mc,id,n){
	var c = mc.but._x/140
	var col = hexToCol( cl[5+id] )
	
	col[n] = int(c*255)
	cl[5+id] = int(colToString(col))

	apply();
}

*/

function apply(){
	
	cadre.apply();
	str = ""
	for( var i=0; i<cl.length; i++ ){
		str += cl[i];
		if(i<cl.length-1)str+=";";
	}
	field.field.text = str;
}


// TOOL

function linkList(){
	cadre.cl = cl
	
}

function hexToCol(hex){
	var c = [
		hex>>16,
		(hex>>8)&0xFF,
		hex&0xFF
	]
	return c;	
}

function colToString(col){
	var str = "0x"
	for( var i=0; i<3; i++ ){
		var c = col[i].toString(16)
		while(c.length<2)c="0"+c
		str+=c
	}
	
	
	return str
	
}





















init();