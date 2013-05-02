package com.digitalaisle.frontend.valueObjects.consultationObjects
{
	import mx.collections.ArrayCollection;
	public class QMultipleChoiceObject extends QuestionObject
	{
		public function QMultipleChoiceObject()
		{
			super();
		}

		//DATA
		public var tilesDataProvider:ArrayCollection;
		public var questMinSelect:Number = 0;
		public var questMaxSelect:Number = 1;
		
		//STYLES
		public var styleNameDown:String;
		public var styleNameDisabled:String;
		public var styleNameIdle:String;		
		public var styleHeader:String = "h1";
		public var styleSubheader:String = "h2";

		//LAYOUT
		public var layoutObj:LayoutObject;
		
		//ASSETS
		public var mcButtonIdle:String;
		public var mcButtonDown:String;
		/*public var tilesColumnCount:Number = 1;
		public var tilesRowCount:Number = 2;
		public var tilesColumnWidth:Number = 75;
		public var tilesRowHeight:Number = 75;*/
		

	}
}