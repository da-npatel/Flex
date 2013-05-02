package com.digitalaisle.uilibrary.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.HGroup;
	
	public class BreadCrumbs extends HGroup
	{
		private var _breadCrumbs:ArrayCollection = new ArrayCollection();
		private var _selectedIndex:int = 0;

		[Bindable]
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			if(_selectedIndex == value) {
				return;
			}
			_selectedIndex = value;
			removeBreadCrumbsUptoIndex(_selectedIndex);
		}
		
		private var _selectedItem:BreadCrumb;

		public function get selectedItem():BreadCrumb
		{
			if(_selectedItem) {
				return _selectedItem;
			}else {
				return getElementAt(0) as BreadCrumb;
			}
		}
		
		
		public function BreadCrumbs()
		{
			super();
			gap = 0;
		}
		
		public function push(label:String):void 
		{
			var breadCrumb:BreadCrumb = new BreadCrumb(_breadCrumbs.length);
			breadCrumb.addEventListener(MouseEvent.CLICK, onBreadCrumbClick, false, 0, true);
			breadCrumb.label = label;
			_breadCrumbs.addItem(breadCrumb);
			addElement(breadCrumb);
		}
		
		public function pop():BreadCrumb 
		{
			if(_breadCrumbs.length > 0) {
				var breadCrumb:BreadCrumb = _breadCrumbs.getItemAt(_breadCrumbs.length - 1) as BreadCrumb;
				_breadCrumbs.removeItemAt(_breadCrumbs.getItemIndex(breadCrumb));
				removeElement(breadCrumb);
				
				var topBreadCrumb:BreadCrumb = _breadCrumbs.getItemAt(_breadCrumbs.length-1) as BreadCrumb;
				_selectedItem = topBreadCrumb;
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
				return breadCrumb;
			}else{
				return null;
			}
		}
		
		private function onBreadCrumbClick(e:Event):void
		{
			selectedIndex = e.currentTarget.index
		}
		
		// Knock out every bread crumb after the one clicked
		private function removeBreadCrumbsUptoIndex(index:int):void 
		{
			while(_breadCrumbs.length > (index + 1)) {
				var breadCrumb:BreadCrumb = _breadCrumbs.source.pop();
				removeElement(breadCrumb);	
			}
			
			_selectedItem = _breadCrumbs.getItemAt(index) as BreadCrumb;
			_breadCrumbs.refresh();
		}
	}
}