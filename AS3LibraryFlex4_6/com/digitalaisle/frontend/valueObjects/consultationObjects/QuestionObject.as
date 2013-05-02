package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;

	public class QuestionObject extends Object
	{
		public var uid:int = 0;
		public var type:int = 0;
		public var itemSeqNo:int = 0;
		public var headerText:String;
		public var subheaderText:String;
		public var answersList:ArrayCollection = new ArrayCollection();
		
		public function QuestionObject()
		{
			super();
		}
	}
}