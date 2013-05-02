package com.digitalaisle.frontend.utils
{
	import com.adobe.utils.ArrayUtil;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.events.ItemFinderEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectEventItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectProductItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.TemplateItem;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ItemFinderUtil extends EventDispatcher
	{
		/** MODES **/
		public const CATEGORY_MODE:String = "category";
		public const ITEM_LIST_MODE:String = "itemList";
		public const ITEM_MODE:String = "item";
		public const MULTI_ITEM:String = "multiItem";
		
		/** Item Finder Types **/
		public static const SINGLE:String = "single";
		public static const MULTI:String = "multi";
		
		/** Read/Write **/
		private var _type:String;
		
		/** Read Only **/
		private var _isInitialMode:Boolean = true;
		private var _clickThruPath:Array = new Array();
		private var _currentMode:String = CATEGORY_MODE;
		
		/** Private **/
		private var _currentPosition:int = 0;
		private var _topLevelId:int;
		private var _dataManager:DataManager = DataManager.getInstance();
		private var _data:Object;
		private var _productList:ArrayCollection;
		
		public function ItemFinderUtil(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function init(topLevelId:int, type:String):void
		{
			_topLevelId = topLevelId;
			_type = type;
			
			switch(type)
			{
				case SINGLE:
					_data = _dataManager.fetchRelatedItemsByOwnerId(_topLevelId);
					_currentMode = determineNextMode(_data);//CATEGORY_MODE;
					break;
				case MULTI:
					_data = fetchInitialMultiCriteriaItems(_topLevelId);
					_currentMode = MULTI_ITEM;
					_productList = _dataManager.fetchAllProducts();
					break;
			}
			
			_currentPosition++;
			_clickThruPath.push({id: _topLevelId, mode: _currentMode, data:_data});
			dispatchEvent(new ItemFinderEvent(ItemFinderEvent.INIT, false, false, _currentMode, _data, _currentPosition));
		}
		
		
		/**
		 * Based upon the id supplied via the parameter, the next list of categories or items will be retrieved.  
		 * If the current mode is of Item List then a ProjectProductItem will be retreived.  A dispatch of ItemFinderEvent.NEXT is 
		 * triggered allowing the Item Finder to leverage the properties of this event to navigate through item flow.
		 * @param id: Id of the next level of the product flow
		 * 
		 */		
		public function next(id:int):void
		{
			var nextData:Object = {};
			
			switch(_currentMode)
			{
				case CATEGORY_MODE:
					_data = _dataManager.fetchRelatedItemsByOwnerId(id);
					break;
				case ITEM_LIST_MODE:
					_data = _dataManager.fetchProjectContentItemById(id);
					break;
			}
			
			_currentMode = determineNextMode(_data);
			_currentPosition++;
			_clickThruPath.push({id: id, mode: _currentMode, data:_data});
			
			if(_isInitialMode) 
				_isInitialMode = false;
			
			dispatchEvent(new ItemFinderEvent(ItemFinderEvent.NEXT, false, false, _currentMode, _data, _currentPosition));
		}
		
		
		/**
		 * Based upon the number of steps the item finder has progressed through, this function will take the flow of the 
		 * item finder in reverse.  A dispatch of ItemFinderEvent.PREV is triggered allowing the Item Finder to leverage the 
		 * properties of this event to step back one level at time within the item flow.
		 */		
		public function prev():void
		{
			var mode:int;

			if(_currentPosition > 1)
			{
				_currentPosition--;
				_clickThruPath.pop();
				_currentMode = _clickThruPath[_currentPosition - 1].mode;
				if(_currentPosition == 1)
					_isInitialMode = true;
			}else
			{
				//Reset 
				startOver();
			}
			
			switch(_currentMode)
			{
				case CATEGORY_MODE:
					_data = _clickThruPath[_currentPosition - 1].data;
					break;
				case ITEM_LIST_MODE:
					_data = _clickThruPath[_currentPosition - 1].data;
					break;
			}
			
			dispatchEvent(new ItemFinderEvent(ItemFinderEvent.PREV, false, false, _currentMode, _data, _currentPosition));
		}
		
		
		public function update(id:int):void
		{
			_clickThruPath[_currentPosition - 1].id =  id;
			_data = _dataManager.fetchRelatedItemsByOwnerId(_clickThruPath[_currentPosition - 1].id);
			_clickThruPath[_currentPosition - 1].data = _data;
			_clickThruPath[_currentPosition - 1].mode = _currentMode = determineNextMode(_data);
			
			dispatchEvent(new ItemFinderEvent(ItemFinderEvent.NEXT, false, false, _currentMode, _data, _currentPosition));
		}
		
		/**
		 * Starts over the entire item flow taking it to the initial catagory state.
		 * 
		 */		
		public function startOver():void
		{
			_isInitialMode = true;
			_currentPosition = 1;
			_currentMode = CATEGORY_MODE;
			_data = _dataManager.fetchRelatedItemsByOwnerId(_topLevelId);
			_clickThruPath = [];
			_clickThruPath.push({id: _topLevelId, mode: _currentMode, data:_data});
			dispatchEvent(new ItemFinderEvent(ItemFinderEvent.INIT, false, false, _currentMode, _data, _currentPosition));
		}
		
		
		public function fetchResultsByMultiCriteria(...categoryIds):ArrayCollection
		{
			var results:ArrayCollection = new ArrayCollection();
			
			for(var i:int = 0; i < _productList.length; i++)
			{
				var isRelated:Boolean = true;
				
				for(var j:int = 0; j < categoryIds.length; j++)
				{
					var categoryItem:ProjectContentItem = _dataManager.fetchProjectContentItemById(categoryIds[j]) as ProjectContentItem;
					
					if(!isProductRelatedToCategory(_productList[i].id, categoryItem))
					{
						isRelated = false;
						break;
					}
					
					// loop through all products
					// if product is related to criteria[i], then add, then break;
					// else move onto the all other criterias
					// move onto next product
				}
				
				if(isRelated)
				{
					results.addItem(_productList[i]);
				}
			}
				
			
			return results;
		}
		
		/**
		 * Formats the items within an ArrayCollection to that of a specific supported control
		 * @param items: The ArrayCollection of the ProjectContentItems that need to be formatted
		 * @param controlType: The ControlType of the control that the items need to be formatted for.
		 * @param optionalParams: Provides optional parameter supported through the control and DataManager
		 * @return: Formatted ArrayCollection of items
		 * 
		 */		
		/*public function formatItemsByControlType(items:ArrayCollection, controlType:int, optionalParams:Object = null):ArrayCollection
		{
			return _dataManager.formatCollectionByControlType(items, controlType, optionalParams);
		}*/
		
		
		/**
		 * Fetches the related items of a category Project Product Item.
		 * @param ownerId: Id of the category Project Product Item.
		 * @return: Returns the related items.
		 * 
		 */		
		public function fetchRelatedItemsByCateogoryId(categoryId:int):ArrayCollection
		{
			var results:ArrayCollection = DataManager.getInstance().fetchRelatedItemsByOwnerId(categoryId);
			return results;
		}
		
		/**
		 * 
		 * @param data
		 * @return 
		 * 
		 */		
		private function determineNextMode(data:Object):String
		{
			var nextTemplateItem:TemplateItem;
			if(data is ArrayCollection)
			{
				var itemListData:ArrayCollection = _data as ArrayCollection;
				if(itemListData.length > 0)
				{
					nextTemplateItem = DataManager.getInstance().fetchTemplateItemById(itemListData[0].templateItemId);
					if(ControlType.isItem(nextTemplateItem.controlType))/*(itemListData[0] is ProjectProductItem || itemListData[0] is ProjectEventItem)*/
					{
						_currentMode = ITEM_LIST_MODE;
					}else
					{
						_currentMode = CATEGORY_MODE;
					}
				}
				
			}else
			{
				nextTemplateItem = DataManager.getInstance().fetchTemplateItemById(data.templateItemId);
				_currentMode = ITEM_MODE;
			}
			
			return _currentMode;
		}
		
		private function fetchInitialMultiCriteriaItems(id:int):ArrayCollection
		{
			var multiCriteriaItems:ArrayCollection = new ArrayCollection();
			var relatedItems:ArrayCollection = _dataManager.fetchRelatedItemsByOwnerId(id);
			
			for(var i:int = 0; i < relatedItems.length; i++)
			{
				var relatedList:ArrayCollection = _dataManager.fetchRelatedItemsByOwnerId(relatedItems[i].id);
				multiCriteriaItems.addItem(relatedList);
			}
			
			return multiCriteriaItems;
		}
		
		private function isProductRelatedToCategory(productId:int, categoryItem:ProjectContentItem):Boolean
		{
			var isRelated:Boolean = false;
			//var categoryItem:ProjectContentItem = _dataManager.fetchContentItemById(categoryId);
			for(var i:int = 0; i < categoryItem.relatedItems.length; i++)
			{
				//trace(categoryItem.relatedItems[i].relatedItemId);
				if(productId == categoryItem.relatedItems[i].relatedItemId)
				{
					isRelated = true;
					break;
				}
			}
			return isRelated;
		}

		
		public function get isInitialMode():Boolean
		{
			return _isInitialMode;
		}

		public function get clickThruPath():Array
		{
			return _clickThruPath;
		}
				
		public function get currentMode():String
		{
			return _currentMode;
		}
	
		public function set currentMode(value:String):void
		{
			_currentMode = value;
		}
		
		public function get currentPosition():int
		{
			return _currentPosition;
		}
		
		public function set currentPosition(value:int):void
		{
			_currentPosition = value;
			_clickThruPath.splice(_currentPosition);
			_currentMode = _clickThruPath[_clickThruPath.length - 1].mode;
		}
	}
}
