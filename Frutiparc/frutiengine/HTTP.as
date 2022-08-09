/*
$Id: HTTP.as,v 1.15 2004/03/30 14:19:55  Exp $

Class: HTTP
*/

class HTTP{
/// QUEUE
	
	static var queue:Array = new Array();
	static var flIdle:Boolean = true;
	
	static function submitMe(obj){
		if(flIdle){
			if(_global.flDebug) _global.httpDebugBox.addText("flIdle --> false");
			flIdle = false;
			obj.submit();
		}else{
			if(_global.flDebug) _global.httpDebugBox.addText("ENQUEUE: "+FEString.unHTML(obj.action+"?"+obj.output.toString()));
			queue.push(obj);
		}
	}
	
	static function goNext(){
		if(queue.length == 0){
			if(_global.flDebug) _global.httpDebugBox.addText("flIdle --> true");
			flIdle = true;
		}else{
			var t = queue.shift();
			t.submit();
		}
	}
	
/// GLOBAL VARS

	static var defaultParams:Object = new Object();
	static var defaultHeaders:Object = new Object();
	
////

	var action:String;
	var params:Object;
	var callback:Object;
	var method:String;
	var output:LoadVars;
	var input;
	var extra:Object;
	var flArg:Boolean;
	var flHeader:Boolean;
	
	/*
	Function: HTTP
		Manage an http request.
		Request and response will be manage as "varname=value&varname=value..."

		The callback method will be called with paramters success (true/false) and vars (an object containing received variables)

	Paramaters:
		action - FrutiEngine server action to call (ex: ff/get)
		params - Parameters to send (an object similar to a LoadVars object)
		callback - Object containing callback informations : type = xml|data|loadvars, obj, method
		method - GET or POST string
	*/
	function HTTP(action:String,params:Object,callback:Object,method:String,extra:Object){
		this.action = action;
		this.callback = callback;
		this.extra = extra;
		this.flArg = false;
		this.flHeader = false;
		
		if(arguments.length >= 4){
			this.method = method;
		}else{
			this.method = "GET";
		}
		
		this.output = new LoadVars();	
		for(var n in defaultHeaders){
			this.flHeader = true;
			this.output.addRequestHeader(n,defaultHeaders[n]);
		}
		for(var n in defaultParams){
			this.flArg = true;
			this.output[n] = defaultParams[n];
		}
		for(var n in params){
			this.flArg = true;
			this.output[n] = params[n];
		}
		
		if(callback.type == "xml"){
			this.input = new XML();
			this.input.ignoreWhite = true;
			this.input.__http__ = this;
			this.input.onData = function(str){
				if(_global.flDebug){
					_global.httpDebugBox.addText("--- XML ---");
					_global.httpDebugBox.addText(FEString.unHTML(str));
				}
				if(str != undefined){
					this.parseXML(str);
					this.loaded = true;
					this.onLoad(true);
				}else{
					this.onLoad(false);
				}				
			};
			this.input.onLoad = function(success){
				this.__http__.callback.obj[this.__http__.callback.method](success,this,this.__http__.extra);
				HTTP.goNext();
			};
		}else if(callback.type == "data"){
			this.input = new LoadVars();
			this.input.__http__ = this;
			this.input.onData = function(str){
				if(_global.flDebug){
					_global.httpDebugBox.addText("--- DATA ---");
					_global.httpDebugBox.addText(FEString.unHTML(str));
				}
				if(str == undefined){
					this.__http__.callback.obj[this.__http__.callback.method](false,"",this.__http__.extra);
				}else{
					this.__http__.callback.obj[this.__http__.callback.method](true,str,this.__http__.extra);
				}
				HTTP.goNext();
			};
		}else{
			this.input = new LoadVars();
			this.input.__http__ = this;
			this.input.onLoad = function(success){
				var vars = new Object();
				if(_global.flDebug) _global.httpDebugBox.addText("--- LOADVARS ---");
				for(var n in this){
					if(n == "__http__" || n == "onLoad") continue;
					if(_global.flDebug) _global.httpDebugBox.addText(n+" = "+FEString.unHTML(this[n]));
					vars[n] = this[n];
				}
				this.__http__.callback.obj[this.__http__.callback.method](success,vars,this.__http__.extra);
				HTTP.goNext();
			};
		}
		
		submitMe(this);
	}
	
	private function submit(){
		if(this.flArg){
			if(_global.flDebug) _global.httpDebugBox.addText("--- SEND REQUEST[A]: "+FEString.unHTML(_global.baseURL+this.action+"?"+this.output.toString()));
			this.output.sendAndLoad(_global.baseURL+this.action,this.input,this.method);
		}else if(this.flHeader){
			if(_global.flDebug) _global.httpDebugBox.addText("--- SEND REQUEST[H]: "+FEString.unHTML(_global.baseURL+this.action+"?"+this.output.toString()));
			this.output.sendAndLoad(_global.baseURL+this.action,this.input);
		}else{
			if(_global.flDebug) _global.httpDebugBox.addText("--- SEND REQUEST[L]: "+FEString.unHTML(_global.baseURL+this.action));
			this.input.load(_global.baseURL+this.action);
		}
	};	
}
