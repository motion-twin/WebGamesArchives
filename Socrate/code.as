
#include "sentence.as"


pubUrl = [
	"http://www.socratomancie.com/monlapin",
	"http://www.socratomancie.com/frutiparc",
	"http://www.socratomancie.com/kadokado",
	"http://www.socratomancie.com/monzoo"

]



function init(){

	timer = 20
	step = 0
	_global.k = 27
	
	var kl = new Object();
	var me = this;
	kl.onKeyDown = function(){
		switch(Key.getCode()){
			case Key.ENTER :
				me.send();
				break;
	
		}
	}
	Key.addListener(kl)
	//Selection.setFocus("main.input.field");
	
	_global.rand = rand;
	
	main.input.field.onChanged = function(){
		me.timer = 200
	}
	
	main.mainBut.stop();
	
}

function loop(){
	timer--;

	switch(step){
		case 0:
			if(timer<0){
				talk(getRandom(sent.hello))
				initWait();
			}
			
			break;
		case 1:
			if(timer<0){
				long++
				_global.k = random(1000)
				if(long>10){
					talk(getRandom(sent.wait3))
				}else if(long>3){
					talk(getRandom(sent.wait2))
				}else{
					talk(getRandom(sent.wait))
				}
				
				timer = 150+random(150)*(1+long*0.5)
			}
			break;
		case 2:
			break;
	}
	
	if(dial!=null){
		dial.timer--;
		if(dial.timer<=0){
			dial.removeMovieClip();
			dial = null
			initWait();
		}
	}
	
	
	
}

function initWait(){
	step = 1
	long = 0
	timer = 200+random(200)
	
}

function send(){

	var baseText = main.input.field.text
	var txt = formatString( baseText )
	
	if( txt.length < 10 ){
		_global.k = 333
		talk(getRandom(sent.short))
		return;
	}
	
	
	main.input.field.text = ""
	_global.k = 0
	for( var i=0; i<txt.length; i++){
		var n = ord(txt.charAt(i))
		_global.k += n*(i+1)
		if(n%i==0){
			_global.k=_global.k^n
		}
	}
	
	lastPred = baseText
	main.mainBut.gotoAndStop(2)
	lastAnswer = sent.answer[ rand(sent.answer.length)]
	talk( lastAnswer );
	
}



function talk(txt){
	
	step = 2
	
	
	main.cadre.socrate.talk(int(txt.length*0.3))
	// DIAL
	if(dial!=null)dial.removeMovieClip();
	dial = main.attachMovie("bulle","dial",40)

	dial.field._width = Math.min(Math.max(70,txt.length*6),170)
	dial.field.text = txt
	dial.field._height = (dial.field.textHeight+1)*1.3//*1.17
	
	var w = dial.field._width+1
	var h = dial.field._height

	dial.sq._width = w
	dial.sq._height = h
	dial.tr._x = w
	dial.bl._y = h
	dial.br._x = w
	dial.br._y = h
	
	dial.t._width = w
	dial.b._width = w
	dial.r._height = h
	dial.l._height = h
	
	dial.r._x = w
	dial.b._y = h

	dial._x = 110
	dial._y = 132 - h*0.5

	dial.timer = 40 + txt.length*3
	
	
	
	
}

function getRandom(a){
	return a[random(a.length)]
}

function rand(n){
	var result = _global.k%n
	_global.k+=n+1;
	return result

}


function formatString(str){
	str = replace(str," ","")
	str = replace(str,"?","")
	str = replace(str,"-","")
	str = replace(str,"'","")
	str = replace(str,"è","e")
	str = replace(str,"é","e")
	str = replace(str,"ê","e")
	return str;	
}


function replace(str,search,replace){
	var preText = "", newText = "";

	if(search.length==1) return str.split(search).join(replace);
	
	var position = str.indexOf(search);
	if(position == -1) return str;
	
	do { 
		position = str.indexOf(search); 
		preText = str.substring(0, position) 
		str = str.substring(position + search.length) 
		newText += preText + replace; 
	} while(str.indexOf(search) != -1) 
	newText += str; 
	return newText; 
} 



function launch(){
	
	lv = new LoadVars();
	if(lastPred!=null){
		lv.lastPred = lastPred
		lv.lastAnswer = lastAnswer
	}
	lv.send(url,"","POST")
	
};

function launchPub(id){
	getUrl(pubUrl[id],"POST")
}
















