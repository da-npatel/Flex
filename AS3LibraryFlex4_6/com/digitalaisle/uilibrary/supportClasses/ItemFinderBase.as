package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.entity.RelatedType;
	import com.digitalaisle.frontend.events.ItemFinderEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ItemFinderUtil;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectProductItem;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.containers.ProductPage;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.states.State;

	/**
	 *  Main state of the Item Finder's flow
	 */
	[SkinState("main")]
	
	/**
	 *  Category state of the Item Finder's flow
	 */
	[SkinState("category")]
	
	/**
	 *  Item list state of the Item Finder's flow
	 */
	[SkinState("itemList")]
	
	/**
	 *  Item state of the Item Finder's flow
	 */
	[SkinState("item")]
	
	public class ItemFinderBase extends ModuleBase
	{
		public var itemFinderUtil:ItemFinderUtil = new ItemFinderUtil();
		
		/** Read/Write **/
		private var _selectedProduct:ProjectContentItem;
		
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var productPage:ProductPage;
		[SkinPart(required="false")]
		public var startOverButton:DASimpleButton;
		[SkinPart(required="false")]
		public var previousFlowButton:DASimpleButton;
		[SkinPart(required="false")]
		
		
		public function ItemFinderBase()
		{
			super();
		}
		
		
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"main"}));
			states.push(new State({name:"category"}));
			states.push(new State({name:"itemList"}));
			states.push(new State({name:"item"}));
		}
		
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState, newState, recursive);
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case previousFlowButton:
					previousFlowButton.addEventListener(MouseEvent.CLICK, onPreviousFlowButtonClick);
					break;
				case startOverButton:
					startOverButton.addEventListener(MouseEvent.CLICK, onStartOverButtonClick);
					break;
				case productPage:
					productPage.addEventListener(FlexEvent.ADD, onProductPageAdd);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case previousFlowButton:
					previousFlowButton.removeEventListener(MouseEvent.CLICK, onPreviousFlowButtonClick);
					break;
				case startOverButton:
					startOverButton.removeEventListener(MouseEvent.CLICK, onStartOverButtonClick);
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
			var relatedItem:ProjectContentItem = DataManager.getInstance().fetchRelatedItemByType(projectContentItem.relatedItems, RelatedType.DATA) as ProjectContentItem;;
			itemFinderUtil.addEventListener(ItemFinderEvent.INIT, onItemFinderInit, false, 0, true);
			itemFinderUtil.addEventListener(ItemFinderEvent.NEXT, onNext, false, 0, true);
			itemFinderUtil.addEventListener(ItemFinderEvent.PREV, onPrev, false, 0, true);
			itemFinderUtil.init(relatedItem.id, ItemFinderUtil.SINGLE);
			
		}
		
		override protected function onRemoved(e:FlexEvent):void
		{
			super.onRemoved(e);
			
			itemFinderUtil.removeEventListener(ItemFinderEvent.INIT, onItemFinderInit);
			itemFinderUtil.removeEventListener(ItemFinderEvent.NEXT, onNext);
			itemFinderUtil.removeEventListener(ItemFinderEvent.PREV, onPrev);
		}
		
		protected function onItemFinderInit(e:ItemFinderEvent):void
		{
			currentState = "main";
		}
		
		protected function onNext(e:ItemFinderEvent):void
		{
			switch(e.mode)
			{
				case itemFinderUtil.ITEM_MODE:
					_selectedProduct = e.data as ProjectContentItem;
					break;
			}
		}
		
		protected function onPrev(e:ItemFinderEvent):void
		{
			
		}
		
		protected function onPreviousFlowButtonClick(e:MouseEvent):void
		{
			itemFinderUtil.prev();
		}
		
		protected function onStartOverButtonClick(e:MouseEvent):void
		{
			itemFinderUtil.startOver();
		}
		
		protected function onProductPageAdd(e:FlexEvent):void
		{
			productPage.projectContentItem = selectedProduct;
		}
		
		public function get selectedProduct():ProjectContentItem
		{
			return _selectedProduct;
		}
		
		public function set selectedProduct(value:ProjectContentItem):void
		{
			_selectedProduct = value;
		}
		
	}
}