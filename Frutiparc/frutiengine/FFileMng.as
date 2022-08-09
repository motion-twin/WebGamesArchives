/*
$Id: FFileMng.as,v 1.11 2004/03/08 17:29:20  Exp $

Class: FFileMng
*/
class FFileMng{//}

	var tree:Object;
	var messages:String = "";
	var inbox:String = "";
	var blackbox:String = "";
	var draftbox:String = "";
	var outbox:String = "";
	var disccollector:String = "";
	var inventory:String = "";
	var mycontact:String = "";
	var recyclebin:String = "";
	
	var treeLoader:HTTP;
	
	
	function FFileMng(){
		//_root.test+="FFileMng\n"
		this.tree = new Object();
	}
	
	/*-----------------------------------------------------------------------
		Function:  init()
		à documenter
	 ------------------------------------------------------------------------*/	
	function init(){
		this.treeLoader = new HTTP("ff/tree",{},{type: "xml",obj: this,method: "onLoadTree"});
	}
	
	/*-----------------------------------------------------------------------
		Function:  onLoadTree(success,data)
		à documenter
	 ------------------------------------------------------------------------*/	
	function onLoadTree(success,data){
		if(!success){
			_global.debug("Error loading folders tree");
			return false;
		}
		
		var bFolder = data.lastChild.attributes.b.toString().split(";");
		this.messages = bFolder[0];
		this.inbox = bFolder[1];
		this.outbox = bFolder[2];
		this.blackbox = bFolder[3];
		this.draftbox = bFolder[4];
		this.disccollector = bFolder[5];
		this.inventory = bFolder[6];
		this.mycontact = bFolder[7];
		this.recyclebin = bFolder[8];
		
		return this.analyseTree(data.lastChild);
	}

	/*-----------------------------------------------------------------------
		Function:  analyseTree(node,parent)
		à documenter
	 ------------------------------------------------------------------------*/	
	function analyseTree(node,parent){
		for(;node.nodeType>0;node=node.nextSibling){
			if(node.nodeName != "f" && node.nodeName != "s") continue;
			
			if(node.attributes.u == undefined) node.attributes.u = "root";
			
			this.tree[node.attributes.u] = {name: node.attributes.n, type: node.attributes.t,tpl: node.attributes.p,childs:new Array(),parent: parent};
			if(parent != undefined && node.nodeName == "f"){
				this.tree[parent].childs.push(node.attributes.u);
			}
			
			if(node.hasChildNodes()){
				this.analyseTree(node.firstChild,node.attributes.u);
			}
		}
		return true;
	}
	
	/*-----------------------------------------------------------------------
		Function:  analyseXml(d)
		à documenter
	 ------------------------------------------------------------------------*/	
	function analyseXml(d){
		var infos = this.tree[d.attributes.u];
		if(infos == undefined) return undefined;
		
		var l = new Object();
		l.uid = d.attributes.u;
		l.type = "folder";
		l.desc = [infos.name,infos.type];
		l.tpl = infos.tpl;
		l.parent = infos.parent;
		l.list = new Array();
		for(var n=d.firstChild;n.nodeType>0;n=n.nextSibling){
			if(this.isFileValid(n)){
				if(n.nodeName == "e"){
					l.list.push({uid: n.attributes.u,type: n.attributes.t,size: n.attributes.s,date: n.attributes.d,access: n.attributes.a,desc: n.firstChild.nodeValue.toString().split("\r\n"),parent: d.attributes.u});
				}else if(n.nodeName == "f"){
					l.list.push(analyseXml(n));
				}
			}
		}
		return l;
	}
	
	function isFileValid(node){
		return true;
	}
//{
}
