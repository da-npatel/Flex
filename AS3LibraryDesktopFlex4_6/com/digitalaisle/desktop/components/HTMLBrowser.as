package com.digitalaisle.desktop.components
{	
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.events.Event;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.MouseEvent;
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
		public var prevButton:DASimpleButton;
		[SkinPart(required="false")]
		public var nextButton:DASimpleButton;
		[SkinPart(required="false")]
		public var reloadButton:DASimpleButton;
		
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
					// htmlControl.htmlLoader.navigateInSystemBrowser = true;
					htmlControl.htmlLoader.manageCookies = true;					
					break;
				case prevButton:
					prevButton.addEventListener(MouseEvent.CLICK, onPrevButtonClicked);
					break;
				case nextButton:
					nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClicked);
					break;
				case reloadButton:
					reloadButton.addEventListener(MouseEvent.CLICK, onReloadButtonClicked);
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
				if (!(_hostDomain && StringUtil.contains(htmlControl.location,_hostDomain) > 0 || htmlControl.htmlText == "<BODY></BODY>"))
				{					
					htmlControl.location = _location;					
				}
			}
			
			if (_enableControls) {
				if (htmlControl.historyLength > 0) {					
					if (htmlControl.historyPosition == 0) {
						// Boundary conditions
						if(htmlControl.historyLength == 1) {
							prevButton.enabled = true;
							nextButton.enabled = false;
						}
						else {
							prevButton.enabled = false;
							nextButton.enabled = true;
						}						
					}
					else {						
						prevButton.enabled = true;
						// Boundary conditions
						if (htmlControl.historyPosition == htmlControl.historyLength - 1) {
							nextButton.enabled = false;
						}
						else {
							nextButton.enabled = true;
						}
					}
					
					/*
					switch (htmlControl.historyPosition) {
						case 0:
							prevButton.enabled = false;
							nextButton.enabled = true;
							break;
						
						case htmlControl.historyLength - 1:
							prevButton.enabled = true;
							nextButton.enabled = false;
							break;
						
						default:
							prevButton.enabled = true;
							nextButton.enabled = true;
							break;						
					}
					*/
				}
				else {
					prevButton.enabled = false;
					nextButton.enabled = false;
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
		
		private function onPrevButtonClicked(e:MouseEvent):void
		{
			htmlControl.historyBack();			
		}
		
		private function onNextButtonClicked(e:MouseEvent):void
		{
			htmlControl.historyForward();			
		}
		
		private function onReloadButtonClicked(e:MouseEvent):void
		{
			htmlControl.reload();
		}
	}
}