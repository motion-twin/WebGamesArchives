package tools;

class ResultsBrowser<T> {

	public var page : Int;
	public var pages : Int;
	public var next : Int;
	public var prev : Int;
	public var size : Int;
	var index : Int;
	var browse : Int -> Int -> List<T>;
	var pageVarName : String;

	public function new( pageVarName="page", count : Int, size : Int, browse : Int -> Int -> List<T>, ?defpos ) {
		this.size = size;
		this.browse = browse;
		this.pageVarName = pageVarName;
		page = App.request.getInt(pageVarName, null);
		if( page == null ) {
			if( defpos == null )
				page = 1;
			else
				page = Std.int(defpos()/size) + 1;
		}
		if( page < 1 )
			page = 1;
		prev = if( page > 1 ) page - 1 else null;
		if( count != null ) {
			pages = Math.ceil(count/size);
			if( pages == 0 )
				pages = 1;
		}
		next = if( pages == null || page < pages ) page + 1 else null;
		index = (page - 1) * size;
	}

	public function current() {
		return browse((page-1)*size,size);
	}


}