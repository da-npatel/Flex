package com.digitalaisle.uilibrary.modules
{
	import com.digitalaisle.frontend.components.DAContentScroller;
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.frontend.components.DASpindle;
	import com.digitalaisle.frontend.components.DAVideoDisplay;
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.enums.InputType;
	import com.digitalaisle.frontend.enums.PanelType;
	import com.digitalaisle.frontend.events.ItemFinderEvent;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.digitalaisle.frontend.utils.ItemFinderUtil;
	import com.digitalaisle.frontend.valueObjects.DASpindleObject;
	import com.digitalaisle.frontend.valueObjects.entityObjects.BinaryContentItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectProductItem;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.supportClasses.ModuleBase;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	//Change MX Image to Spark Image - Start
	//import mx.controls.Image;
	import spark.components.Image;
	//End
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.RichText;
	import com.digitalaisle.uilibrary.containers.ProductPage;

	public class MultiItemFinder extends ModuleBase 
	{	
		[SkinPart(required="false")]
		public var btnPrevFlow:DAButton;
		
		[SkinPart(required="false")]
		public var btnStartOver:DAButton;
		
		[SkinPart(required="false")]
		public var txtTitle:RichText;
		
		[SkinPart(required="false")]
		public var txtSubTitle:RichText;
		
		[SkinPart(required="false")]
		public var spindle0:DASpindle;
		
		[SkinPart(required="false")]
		public var spindle1:DASpindle;
		
		[SkinPart(required="false")]
		public var spindle2:DASpindle;
		
		[SkinPart(required="false")]
		public var productTitledSlider:DAPanelSlider;
		
		[SkinPart(required="false")]
		public var productPage:ProductPage;
		
		private var _itemFinderUtil:ItemFinderUtil = new ItemFinderUtil();
		private var _initialItemFinderData:ArrayCollection = new ArrayCollection();
		
		public function MultiItemFinder()
		{
			super();
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(e:FlexEvent):void
		{
			addEventListeners();
			_itemFinderObject = DataManager.getInstance().fetchModuleDataById(ApplicationUtil.getInstance().selectedModuleId) as ItemFinderObject;
			
			_itemFinderUtil.addEventListener(ItemFinderEvent.INIT, onItemFinderInit, false, 0, true);
			_itemFinderUtil.init(_itemFinderObject.startingPointItemId, ItemFinderUtil.MULTI);	
		}
	
		override protected function partAdded(partName:String, instance:Object):void
		{
			//TODO: SPINDLE THEME ASSETS AND LOOPING?
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case txtTitle:
					txtTitle.text = _titleText;
					break;
				case txtSubTitle:
					txtSubTitle.text = _subTitleText;
					break;
				case btnPrevFlow:
					btnPrevFlow.addEventListener(MouseEvent.CLICK, onPrev);
					break;
				case btnStartOver:
					btnStartOver.addEventListener(MouseEvent.CLICK, onPrev);
					break;
				case spindle0:
					populateSpindle(spindle0);
					break;
				case spindle1:
					populateSpindle(spindle1);
					break;
				case spindle2:
					populateSpindle(spindle2);
					break;
				case productTitledSlider:
					productTitledSlider.addEventListener(PanelEvent.SINGLE_CLICK, onTitledSliderClick);
					productTitledSlider.clickSound = ApplicationUtil.getInstance().defaultClick;
					break;
				case productPage:
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case txtTitle:
					txtTitle.text = _titleText;
					break;
				case txtSubTitle:
					txtSubTitle.text = _subTitleText;
					break;
				case btnPrevFlow:
					btnPrevFlow.removeEventListener(MouseEvent.CLICK, onPrev);
					break;
				case btnStartOver:
					btnStartOver.removeEventListener(MouseEvent.CLICK, onPrev);
					break;
				case spindle0:
					spindle0.removeEventListener(Event.CHANGE, onCriteriaChange);
					break;
				case spindle1:
					spindle1.removeEventListener(Event.CHANGE, onCriteriaChange);
					break;
				case spindle2:
					spindle2.removeEventListener(Event.CHANGE, onCriteriaChange);
					break;
				case productTitledSlider:
					productTitledSlider.removeEventListener(PanelEvent.SINGLE_CLICK, onTitledSliderClick);
					break;
				case productPage:
					break;
			}
		}
								
		private function addEventListeners():void {
			_itemFinderUtil.addEventListener(ItemFinderEvent.INIT, onItemFinderInit, false, 0, true);
			_itemFinderUtil.addEventListener(ItemFinderEvent.NEXT, onNext, false, 0, true);
			_itemFinderUtil.addEventListener(ItemFinderEvent.PREV, onPrev, false, 0, true);
		}
		
		private function removeEventListeners():void {
			_itemFinderUtil.removeEventListener(ItemFinderEvent.INIT, onItemFinderInit);
			_itemFinderUtil.removeEventListener(ItemFinderEvent.NEXT, onNext);
			_itemFinderUtil.removeEventListener(ItemFinderEvent.PREV, onPrev);
		}
		
		private function onItemFinderInit(e:ItemFinderEvent):void 
		{	
			if(e.data != null && e.data is ArrayCollection)
			{
				_initialItemFinderData = e.data;				
			}
		}
		
		private function onNext(e:ItemFinderEvent):void 
		{
			if(productPage)
			{
				if(!e.target.isInitialMode)
				{
					switch(e.mode)
					{
						case _itemFinderUtil.ITEM_LIST_MODE:
							//TODO: IMPLIMENT THE NEW PANEL WITHOUT THE GROUP
							//currentState = "Browse";
							//_listPanelData.source = _itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER, {panelType:PanelType.LIST}).source;
							break;
						case _itemFinderUtil.ITEM_MODE:
							currentState = "ProductPage";
							var ppi:ProjectProductItem = DataManager.getInstance().fetchContentItemById(e.target.selectedID) as ProjectProductItem;		
							if(ppi.binaryContentItems.length > 0)
							{
								for each(var value:BinaryContentItem in ppi.binaryContentItems)
								{
									if(value.type == 2)
									{
										productPage.productViewMode = ProductPage.VIDEO;
										productPage.sourceVideo = DataManager.getInstance().fetchBinaryContentByType(ppi, BinaryType.VIDEO);
										break;
									}else if(value.type == 0)
									{					
										productPage.productViewMode = ProductPage.IMAGE;
										productPage.sourceImage = DataManager.getInstance().fetchBinaryContentByType(ppi, BinaryType.IMAGE);
									}
								}
							}
							
							productPage.titleText = ppi.name;
							productPage.subTitleText = ppi.shortDescription;
							
							if(ppi.longDescription != null && ppi.longDescription != "")
							{
								productPage.bodyContent = ppi.longDescription as String;
							}				
							break;
						case _itemFinderUtil.CATEGORY_MODE:
							//TODO: IMPLIMENT THE NEW TITLE PANEL WITHOUT THE GROUP
							//_titledPanelData.source = _itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER, {panelType:PanelType.TITLED}).source;
							break;
					}
				}
				
				
			}
		}
		
		private function onPrev(e:ItemFinderEvent):void {
			//TODO: IMPLIMENT THE NEW TITLE PANEL WITHOUT THE GROUP
			currentState = "Main";
			//_titledPanelData.source = _itemFinderUtil.formatItemsByControlType(e.data as ArrayCollection, ControlType.PANELSLIDER, {panelType:PanelType.TITLED}).source;
		}
		
		private function populateSpindle(spindle:DASpindle):void
		{
			var curSpindle:Number = -1;
			switch(spindle.id)
			{
				case "spindle0":
					curSpindle = 0;
					break;
				case "spindle1":
					curSpindle = 1;
					break;
				case "spindle2":
					curSpindle = 2;
					break;
			}
			
			var col:ArrayCollection = _initialItemFinderData as ArrayCollection;
			var cat:ArrayCollection = col[curSpindle] as ArrayCollection;	
			var spindleObj:DASpindleObject;
			categoryData = new ArrayCollection();
			for(i=0; i<cat.length; i++)
			{
				spindleObj = new DASpindleObject(cat[i].name, cat[i].id);
				categoryData.addItem(spindleObj);
			}			
			spindle.dataProvider = categoryData;
			spindle.addEventListener(Event.CHANGE, onCriteriaChange);
		}
		
		private function onTitledSliderClick(e:MouseEvent):void
		{
			_itemFinderUtil.next(e.target.selectedID);
		}
		
		private function onCriteriaChange(e:Event):void {
			
			var sItem0:DASpindleObject = spindle0.selectedItem as DASpindleObject;
			var sItem1:DASpindleObject = spindle1.selectedItem as DASpindleObject;
			var sItem2:DASpindleObject = spindle2.selectedItem as DASpindleObject;
			
			var s0:int = spindle0.selectedID;
			var s1:int = spindle1.selectedID;
			var s2:int = spindle2.selectedID;
			
			var multiCol:ArrayCollection = _itemFinderUtil.fetchResultsByMultiCriteria(s0, s1, s2); //(2459, 2453, 2447);  
			var prodData:ArrayCollection = new ArrayCollection();	
			prodData.source = _itemFinderUtil.formatItemsByControlType(multiCol, ControlType.PANELSLIDER, {panelType:PanelType.TITLED}).source;		
			
			//TODO: NEW PANEL WITHOUT GROUP
			//titledPanelGroup.source = prodData;
			productTitledSlider.source = titledPanelGroup;
		}	
		
		private function onPreviousClick(e:MouseEvent):void
		{
			productTitledSlider.prevPanel();
		}
		
		private function onNextClick(e:MouseEvent):void
		{
			productTitledSlider.nextPanel();
		}
		
		public function destroy():void {	
			removeEventListeners();
			//this.visible = false;
			//currentState = "Browse";
			spindle0.reset();
			spindle1.reset();
			spindle2.reset();
			
			if(productTitledSlider)
			{
				productTitledSlider.destroy();
			}
		}
	}
}