package com.digitalaisle.uilibrary.containers
{	
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	
	import mx.controls.DateChooser;
	import mx.modules.ModuleBase;
	
	import spark.components.RichText;
	
	public class Calendar extends ModuleBase
	{
				
				
		public function Calendar()
		{
			super();
		}
		
		[SkinPart(required="true")]
		public var calendar:DateChooser;
		
		[SkinPart(required="true")]
		public var btnPrevMonth:DAButton;
		
		[SkinPart(required="true")]
		public var btnNextMonth:DAButton;
		
		[SkinPart(required="false")]
		public var txtPanelTitle:RichText;
		
		[SkinPart(required="false")]
		public var eventsPanel:DAPanelSlider;
		
		[SkinPart(required="false")]
		public var productPage:ProductPage;
		
		[SkinPart(required="false")]
		public var btnPrevFlow:DAButton;
				
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case calendar:
					break;
				case btnNextMonth:
					btnNextMonth.addEventListener(MouseEvent.CLICK, onNextMonthClick);
					break;
				case btnPrevMonth:
					btnPrevMonth.addEventListener(MouseEvent.CLICK, onPrevMonthClick);
					break;
				case txtPanelTitle:
					btnEmail.addEventListener(MouseEvent.CLICK, onNextMonthClick);
					break;
				case eventsPanel:
					image.source = _sourceImage;
					break;
				case productPage:
					video.source = _sourceVideo;
					break;
				case btnPrevFlow:
					contentScroller.content = _bodySource;
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case txtTitle:
					break;
				case txtSubTitle:
					break;
				case btnPrint:
					btnPrint.removeEventListener(MouseEvent.CLICK, print_clickHandler);
					break;
				case btnEmail:
					btnEmail.removeEventListener(MouseEvent.CLICK, email_clickHandler);
					break;
				case image:
					break;
				case video:
					break;
				case contentScroller:
					break;
			}
		}
		
		public function get sourceImage():String { return _sourceImage; }
		public function set sourceImage(value:String):void {
			if(_productViewMode == IMAGE)
			{
				image.source = value;
			}
		}
		
		public function get sourceVideo():String { return _sourceVideo; }
		public function set sourceVideo(value:String):void {
			if(_productViewMode == VIDEO)
			{
				video.source = value;
			}
		}
		
		public function get titleText():String { return _titleText; }
		public function set titleText(value:String):void {
			//Part is required
			txtTitle.text = value;		
		}		
		
		public function get subTitleText():String { return _subTitleText; }
		public function set subTitleText(value:String):void {
			//Check and see if part was added
			if(subTitleText)
				subTitleText.text = value;	
			
		}	
		
		public function get bodyContent():String { return _bodySource; }
		public function set bodyContent(value:String):void {
			//Check and see if part was added
			if(txtBody)
				txtBody.content = value;
		}
		
		public function set productViewMode(value:String):void
		{
			_productViewMode = value;
			switch(_productViewMode)
			{
				case IMAGE:
					currentState = "stateImage";
					break;
				case VIDEO:
					currentState = "stateVideo";
					break;
				case BOTH:
					currentState = "stateVideo";
					break;
				default:
					currentState = "stateImage";
					break;
			}
		}
	}
}