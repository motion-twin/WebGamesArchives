package mt.kiroukou.lang;

class IterableGeneric< A, B >
{
	public var length: Int;
	
	var count: Int;
	var input: A;
	
	function new( input : A )
	{
		count = 0;
		this.input = input;
    }
	
	public function iterator():Iterator<B>
	{
		return this;
	}
	
	public function hasNext(): Bool
	{
		return count < length;
	}
}