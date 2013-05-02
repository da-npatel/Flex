package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.uilibrary.skins.BreadCrumbSkin;
	
	import flash.events.MouseEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class BreadCrumb extends SkinnableComponent
	{
		
		private var _index:int = 0;
		private var _label:String;
		
		public function BreadCrumb(index:int)
		{
			super();
			setStyle("skinClass", BreadCrumbSkin);
			_index = index;
			//addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
		}

		[Bindable]
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public function get index():int
		{
			return _index;
		}

	}
}