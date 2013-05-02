package com.digitalaisle.uilibrary.modules
{
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import utils.QuestionAnswerUtil;	
	
	import mx.controls.Image;
	import mx.modules.ModuleBase;
	
	import spark.components.RichText;
	
	public class Consultationbase extends ModuleBase
	{
		[SkinPart(required="true")]
		public var qaUtil:QuestionAnswerUtil;
		
		[SkinPart(required="true")]
		public var video:DAVideoDisplay;
		
		[SkinPart(required="true")]
		public var txtTitle:RichText;
		
		[SkinPart(required="false")]
		public var txtSubTitle:RichText;
		
		[SkinPart(required="false")]
		public var contentScroller:DAContentScroller;
		
		public function Consultationbase()
		{
			super();
		}
		
		
				
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case txtTitle:
					txtTitle.text = _titleText;
					break;
				case txtSubTitle:
					txtSubTitle.text = _subTitleText;
					break;
				case btnPrint:
					btnPrint.addEventListener(MouseEvent.CLICK, print_clickHandler);
					break;
				case btnEmail:
					btnEmail.addEventListener(MouseEvent.CLICK, email_clickHandler);
					break;
				case image:
					image.source = _sourceImage;
					break;
				case video:
					video.source = _sourceVideo;
					break;
				case contentScroller:
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