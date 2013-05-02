package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;

	public class QPageObject extends Object
	{
		public function QPageObject()
		{
			super();
		}
		
		//DATA
		public var data:ArrayCollection = new ArrayCollection();
		public var header:String;
		public var subHeader:String;
		public var bgImage:String = "";
		
		//LAYOUT
		public var layoutObj:LayoutObject;
	}
	
}