package com.digitalaisle.uilibrary.modules
{
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.enums.PanelType;
	import com.digitalaisle.frontend.events.ItemFinderEvent;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.supportClasses.ItemFinderBase;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	public class SingleItemFinderBase extends ItemFinderBase
	{
		
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var categoryPanelSlider:DAPanelSlider;
		[SkinPart(required="true")]
		public var itemListPanelSlider:DAPanelSlider;
		[SkinPart(required="false")]
		public var prevNavButton:DASimpleButton;
		[SkinPart(required="false")]
		public var nextNavButton:DASimpleButton;
		
		[Bindable]
		public var mainCategoryData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var categoryData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var itemData:ArrayCollection = new ArrayCollection();
		
		public function SingleItemFinderBase()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case categoryPanelSlider:
					categoryPanelSlider.addEventListener(PanelEvent.CLICK, onPanelClick);
					break;
				case itemListPanelSlider:
					itemListPanelSlider.addEventListener(PanelEvent.CLICK, onPanelClick);
					break;
				case prevNavButton:
					prevNavButton.addEventListener(MouseEvent.CLICK, onPrevNavButtonClick);
					break;
				case nextNavButton:
					nextNavButton.addEventListener(MouseEvent.CLICK, onNextNavButtonClick);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case categoryPanelSlider:
					categoryPanelSlider.destroy();
					break;
				case itemListPanelSlider:
					itemListPanelSlider.removeEventListener(PanelEvent.CLICK, onPanelClick);
					break;
				case prevNavButton:
					prevNavButton.removeEventListener(MouseEvent.CLICK, onPrevNavButtonClick);
					break;
				case nextNavButton:
					nextNavButton.removeEventListener(MouseEvent.CLICK, onNextNavButtonClick);
					break;
			}
		}
		
		override protected function onPreInitialize(e:FlexEvent):void
		{
			super.onPreInitialize(e);
			
			
		}
		
		override protected function onCreationComplete(e:FlexEvent):void
		{
			super.onCreationComplete(e);
			
		}
		
		override protected function onItemFinderInit(e:ItemFinderEvent):void
		{
			super.onItemFinderInit(e);
			
			mainCategoryData = e.data as ArrayCollection;
			if(e.data.length == 1)
				itemFinderUtil.next(e.data[0].id);
			
				
				
			
			//_categoryData.source = itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER).source;
			
		}
		
		override protected function onNext(e:ItemFinderEvent):void
		{
			super.onNext(e);
			
			if(!e.target.isInitialMode)
			{
				switch(e.mode)
				{
					case itemFinderUtil.ITEM_LIST_MODE:
						if(e.data.length > 1)
						{
							currentState = "itemList";
							itemData = e.data as ArrayCollection;
						}else if(e.data == 1)
						{
							itemFinderUtil.next(e.data[0].id);
						}
							
						//currentState = "itemList";
						//itemData = itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER);
						break;
					case itemFinderUtil.ITEM_MODE:
						currentState = "item";
						//productPage.projectContentItem = selectedProduct;
						break;
					case itemFinderUtil.CATEGORY_MODE:
						categoryData = e.data as ArrayCollection;
						currentState = "category";
						break;
					
				}
			}
		}
		
		override protected function onPrev(e:ItemFinderEvent):void
		{
			super.onPrev(e);
			
			if(!e.target.isInitialMode)
			{
				switch(e.mode)
				{
					case itemFinderUtil.ITEM_LIST_MODE:
						if(e.data.length > 1)
						{
							currentState = "itemList";
							itemData = e.data as ArrayCollection;
						}else
						{
							itemFinderUtil.prev();
						}
						//currentState = "itemList";
						//itemData.source = itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER, {panelType:PanelType.LIST}).source;
						break;
					case itemFinderUtil.CATEGORY_MODE:
						if(e.data.length > 1)
						{
							currentState = "category";
							categoryData = e.data as ArrayCollection;
						}else if(e.data.length == 1)
						{
							itemFinderUtil.next(e.data[0].id);
						}
						//currentState = "category";
						//categoryData = itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER, {panelType:PanelType.TITLED});
						break;
				}
			}else
			{
				currentState = "main";
				//categoryPanelSlider.dataProvider = _categoryData;
			}
		}
		
		protected function onPanelClick(e:PanelEvent):void
		{
			switch(e.target)
			{
				case categoryPanelSlider:
					if(itemFinderUtil.currentMode != itemFinderUtil.ITEM_LIST_MODE)
					{
						itemFinderUtil.next(e.target.selectedID);
					}else
					{
						itemFinderUtil.update(e.target.selectedID);
						//var results:ArrayCollection = _itemFinderUtil.fetchRelatedItemsByCateogoryId(e.target.selectedID);
						//_itemData.source = _itemFinderUtil.formatItemsByControlType(results, ControlType.PANELSLIDER, {panelType:PanelType.LIST}).source;
					}
					break;
				case itemListPanelSlider:
					itemFinderUtil.next(e.target.selectedID);
					break;
			}
			
		}
		
		protected function onPrevNavButtonClick(e:MouseEvent):void
		{
			categoryPanelSlider.prevPanel();
		}
		
		protected function onNextNavButtonClick(e:MouseEvent):void
		{
			categoryPanelSlider.nextPanel();
		}
	}
}