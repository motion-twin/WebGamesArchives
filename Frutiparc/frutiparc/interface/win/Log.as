class win.Log extends win.Advance{//}

	
	//CONSTANTES
	var blocMax:Number = 5;
	
	// VARIABLES
	var list:Array;
	var blocList:Array;
	var listDoc:cp.Document;
	var flError:Boolean;
	var index:Number;
	var pageMax:Number;
	var linkIco:String;
	
	// REFERENCES
	var pageSelector:cp.PageSelector;	
	
	
	function Log(){
		
	}
	
	function init(){
		super.init();
		//
		this.flResizable = false;
		super.init();
		this.flError = false;
		this.blocList = new Array();
		this.endInit();
		//		
	};
	
	function initFrameSet(){
		super.initFrameSet();
		// FRAMESHOW
		var margin = Standard.getMargin();
		this.main.newElement({ name:"showFrame", type:"w", min:{w:300,h:200}, flBackground:false, margin:margin})
		this.main.bigFrame = this.main.showFrame;
		
		this.pageMax = 1;
		this.index = 0;
		
		// PAGE CONTROL
		var margin = Standard.getMargin();
		margin.x.min = 10
		var args = {
		}
		var frame = {
			name:"pageSelector",
			link:"cpPageSelector",
			type:"compo",
			margin:margin,
			min:{w:300,h:24},
			args:args
		}
		this.pageSelector = this.margin.bottom.newElement(frame)
		//this.pageSelector.setText("1/5")

	}
	
	function setLog(list){
		if(this.flError) this.removeError();
		//this.main.showFrame.removeElement("listFrame");
		
		//_root.test+="[win.UserLog]setUserLog() list.length("+list.length+")\n"
		
		
		
		this.index = 0;

		this.list = list
		this.pageMax = Math.ceil(this.list.length/5)-1
		this.updatePage();
		this.updatePageSelector();
		this.frameSet.update();
	}
	
	function cleanPage(){
		for(var i=0; i<this.blocMax; i++ ){
			this.main.showFrame.removeElement("bloc"+i);
		}	
	}
	
	function updatePage(){
		
		this.cleanPage();
		
		var max = Math.min(this.list.length,(this.index*this.blocMax)+this.blocMax)
		//_root.test+="("+this.index*this.blocMax+","+max+","+this.list.length+")"
		for(var i=this.index*this.blocMax; i<max; i++){
			 var o = this.list[i]

			var pageObj,margin,args,frame;
			pageObj = {
				pos:{x:0,y:0,w:0,h:0},
				lineList:[]
			}

			pageObj.lineList.push(
				{	
					big:1,
					list:[
						
						{
							type:"page",
							width:60,
							//pos:{x:0,y:0,w:60,h:60},
							lineList:[
								{
									list:[
										{
											type:"link",
											link:"gfxList",
											width:60,
											param:{
												link:this.linkIco,
												frame:o.type
											}
										}	
									]
								}
							]
						},
												
						{	type:"text",
							big: 1,
							param:{
								name: "userLog"+i,
								text: o.flNew ? 
									  "<b>"+Lang.formatDateString(o.time,"short")+" - "+o.content+"</b>"
									: "<b>"+Lang.formatDateString(o.time,"short")+" - </b>"+o.content,
								fieldProperty: { html: 1}
							}
						}
					]
					
				}
				
			);
			margin = Standard.getMargin();
			margin.y.min = 6
			margin.y.ratio = 0 
			args = {
				//flDocumentFit:true,
				//flMask:true,
				//flBackground:true,
				pageObj:pageObj
			}
			frame = {
				name:"bloc"+(i-this.index*this.blocMax),
				link:"cpDocument",
				type:"compo",
				margin:margin,
				flBackground:true,
				mainStyleName:"frSheet",
				min:{w:300,h:60},
				args:args
			}
			
			//this.listDoc = this.main.showFrame.newElement(frame)
			this.main.showFrame.newElement(frame)
			//this.main.showFrame.bigFrame = this.main.showFrame.listFrame;
			
		}
	}
		
	function displayError(error){
		if(this.flError) this.removeError();
		
		//_root.test+="displayError("+error+")\n"
		var margin = Standard.getMargin();
		margin.y.min = 6;
		margin.y.ratio = 0;
		
		var docString = "<p><l><t>"+error+"</t></l></p>"
		var args = {
			doc:new XML(docString),
			flDocumentFit:true
		};
		var frame ={
			name:"errorFrame",
			link:"cpDocument",
			type:"compo",
			min:{w:300,h:40},
			flBackground:true,
			//flTrace:true,
			mainStyleName:"frSystem",
			margin:margin,
			args:args
		}
		this.main.newElement(frame,0)
		this.frameSet.update();
		
		this.flError = true;
	}
	
	function removeError(){
		if(!this.flError) return false;
		
		this.main.removeElement("errorFrame");
		this.frameSet.update();
		
		this.flError = false;
	}
	
	function scrollText(delta){
		this.listDoc.mask.y.path.pixelScroll(delta);
	}

	function prevPage(){
		this.index = Math.max(this.index-1, 0)
		//_root.test+="prevPage() index("+this.index+")\n"
		this.updatePage();
		this.updatePageSelector();
		this.frameSet.update();
	}
	
	function nextPage(){
		//_root.test+="glouglou!!!\n"
		this.index = Math.min(this.index+1, this.pageMax)
		//_root.test+="nextPage() index("+this.index+")\n"
		this.updatePage();
		this.updatePageSelector();
		this.frameSet.update();
	}
	
	function updatePageSelector(){
		this.pageSelector.setText((index+1)+"/"+(this.pageMax+1))
	}
		
	
//{
};