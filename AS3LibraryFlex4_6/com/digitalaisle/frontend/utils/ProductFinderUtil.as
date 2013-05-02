package com.digitalaisle.frontend.utils
{
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.valueObjects.ProductObject;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.frontend.valueObjects.ProjectObject;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	public final class ProductFinderUtil extends EventDispatcher
	{
		//private var _moduleId:int = ApplicationUtil
		private var _clickThruPath:Array = new Array();
		private var _initialCollection:ArrayCollection;
		
		
		
		public function ProductFinderUtil()
		{
			
		}
		
		public function init(moduleId:int, initalControlType:int, optionalParams:Object):ArrayCollection
		{
			_initialCollection = ApplicationUtil.getInstance().dataManager.fetchRelatedItemsByOwnerId(moduleId, initalControlType, optionalParams);
			_clickThruPath.push(_initialCollection);
			return _initialCollection;
		}
		
		
		public function next(id:int, controlType:int, optionalParams:Object):ArrayCollection
		{
			// Stores within clickthru path
			var results:ArrayCollection = DataManager.getInstance().fetchRelatedItemsByOwnerId(id, controlType, optionalParams);
			
			_clickThruPath.push(results);
			
			return results;
		}
		
		
		public function startOver():ArrayCollection
		{
			var results:ArrayCollection;
			_clickThruPath = _clickThruPath.slice(0,0);
			results = _clickThruPath[0];
			return results;
		}
		
		
		public function prev():ArrayCollection
		{
			var results:ArrayCollection;
			
			if(_clickThruPath.length > 0)
			{
				// CLEAR INTERAL ARRAY????
				_clickThruPath.pop();
				
				results = _clickThruPath[_clickThruPath.length - 1];
			}else
			{
				
			}
			
			return results;
		}
		
		public function fetchInitialContent(uid:String):Object
		{
			var contentObj:Object = {};//DataManager.getInstance().fetchDataByUid(uid);
			
			return contentObj;
		}
		
		
		public function fetchResultsContentType(results:ArrayCollection):int
		{
			var contentType:int = 0;
			
			if(results.length >= 1)
			{
				contentType = results[0].contentType;
			}
			
			return contentType;
		}
		
		
		public function fetchResultsContentTypeByOwnerId(ownerId:int):int
		{
			var contentType:int = 0;
			var results:ArrayCollection = DataManager.getInstance().fetchContentItemsByOwnerId(ownerId);
			
			if(results.length >= 1)
			{
				contentType = results[0].contentType;
			}
			
			return contentType;
		}
		
		public function fetchProductById(productId:int):ProductObject
		{
			var projectContentItem:ProjectContentItem = DataManager.getInstance().fetchContentItemById(productId) as ProjectContentItem;
			var productObject:ProductObject = new ProductObject();
			productObject.uid = projectContentItem.id as String;
			productObject.display = DataManager.getInstance().fetchBinaryContentByType(projectContentItem, BinaryType.IMAGE);
			productObject.title = projectContentItem.name;
			productObject.longDescription = projectContentItem.longDescription;
			return productObject;
		}
		
		
		public function getCurrentPathId():int
		{
			var currentIndex:int = clickThruPath.length - 1;
			return clickThruPath[currentIndex];
		}

		public function get clickThruPath():Array
		{
			return _clickThruPath;
		}

		public function set clickThruPath(value:Array):void
		{
			_clickThruPath = value;
		}
		
		
	}
}