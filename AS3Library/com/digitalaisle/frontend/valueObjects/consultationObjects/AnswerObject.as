package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;

	public class AnswerObject extends Object 
	{
		public function AnswerObject()
		{
			super();
		}
		
		public var id:int = 0;
		public var itemSeqNo:int = 0;
		public var name:String = "";
		public var shortDescription:String = "";
		public var longDescription:String = "";
		public var relatedItems:Array = new Array();
		
		//BUTTON IMAGE LINKS
		public var imageIdle:String = "";
		public var imageDown:String = "";
		public var imageDisabled:String = "";
		
		//VARS
		public var selectedValue:Object;
		public var toggle:Boolean = false;
		public var selected:Boolean = false;
		public var value:ArrayCollection = new ArrayCollection();
		
		//STYLES
		public var styleNameDown:String;
		public var styleNameDisabled:String;
		public var styleNameIdle:String;
	}
}