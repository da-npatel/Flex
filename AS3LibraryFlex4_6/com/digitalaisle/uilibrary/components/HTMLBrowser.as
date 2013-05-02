package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.events.Event;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.html.HTMLLoader;
	
	import mx.collections.ArrayCollection;
	import mx.controls.HTML;
	import mx.events.FlexEvent;
	
	import org.casalib.util.StringUtil;
	
	import spark.components.RadioButton;
	
	public class HTMLBrowser extends ContainerBase
	{
		[SkinPart(required="true")]
		public var htmlControl:HTML;
		[SkinPart(required="false")]
		public var prevButton:DAButton;
		[SkinPart(required="false")]
		public var nextButton:DAButton;
		[SkinPart(required="false")]
		public var reloadButton:DAButton;
		
		private var _projectContentItem:ProjectContentItem;
		private var _supportedDomains:ArrayCollection;
		private var _enableControls:Boolean = true;
		private var _location:String;
		private var _lockDomain:Boolean = false;
		private var _hostDomain:String;
		
		public function HTMLBrowser()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case htmlControl:
					htmlControl.addEventListener(HTMLUncaughtScriptExceptionEvent.UNCAUGHT_SCRIPT_EXCEPTION, onHtmlScriptException);
					htmlControl.addEventListener(Event.LOCATION_CHANGE, onLocationChange);
					htmlControl.paintsDefaultBackground = false;
					htmlControl.addEventListener(FlexEvent.ADD, onHtmlAdd);
					htmlControl.addEventListener(FlexEvent.REMOVE, onHtmlRemove);
					break;
				case prevButton:
					
					break;
				case nextButton:
					
					break;
				case reloadButton:
					
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
		}
		
		private function onHtmlScriptException(e:HTMLUncaughtScriptExceptionEvent):void
		{
			e.target.cancelLoad();
			e.target.historyBack();
			//TODO: Figure out what should I do here
		}
		
		private function onHtmlAdd(e:FlexEvent):void
		{
			//htmlControl.userAgent = "Mozilla/5.0 (Windows; U; en) AppleWebKit/526.9+ (KHTML, like Gecko) AdobeAIR/2.0";
			htmlControl.location = _location;
		}
		
		private function onHtmlRemove(e:FlexEvent):void
		{
			htmlControl.location = "";
			
		}
		
		private function onLocationChange(e:Event):void
		{
			if(_lockDomain)
			{
				if(_hostDomain && StringUtil.contains(htmlControl.location,_hostDomain) > 0 || htmlControl.htmlText == "<BODY></BODY>")
				{
					return;
				}else{
					htmlControl.location = _location;
				}
			}
			
			// TODO: Figure Out Expression to handle support domain check
			//if(_supportedDomains && _supportedDomains.length == 0)
			//	return;			
		}
		
		public function get lockDomain():Boolean
		{
			return _lockDomain;
		}
		
		public function set lockDomain(value:Boolean):void
		{
			_lockDomain = value;
			return;
		}
		
		public function get hostDomain():String
		{
			_hostDomain = hostDomain;
			return _hostDomain;
		}
		
		public function set hostDomain(value:String):void
		{
			value = _hostDomain;
			return;
		}
		
		public function get projectContentItem():ProjectContentItem
		{
			_projectContentItem = projectContentItem;
			return _projectContentItem;
		}
		
		public function set projectContentItem(value:ProjectContentItem):void
		{
			if(htmlControl)
			{
				if(htmlControl.location == value.externalLink)
					return;
				_hostDomain = value.shortDescription;
				_location = value.externalLink;
				htmlControl.location = _location;
			}
		}

		/*public function get location():String
		{
			_location = location;
			return(_location);
		}
		
		public function set location(value:String):void
		{
			if(htmlControl)
			{
				if(htmlControl.location == value)
					return;
				htmlControl.location = value;
			}
		}*/

		[Bindable]
		public function get enableControls():Boolean
		{
			return _enableControls;
		}

		public function set enableControls(value:Boolean):void
		{
			_enableControls = value;
		}
	}
}