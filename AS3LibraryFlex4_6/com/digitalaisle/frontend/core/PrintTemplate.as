package com.digitalaisle.frontend.core
{
	import com.digitalaisle.frontend.drawing.DottedLine;
	import com.digitalaisle.frontend.events.PrintEvent;
	import com.gskinner.utils.Janitor;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import nl.demonsters.debugger.MonsterDebugger;
		
	public class PrintTemplate extends Sprite
	{
		private static const PAPER_WIDTH:Number = 210;
		private static const MARGIN:Number = 0;
		
		private var _janitor:Janitor;			
		private var _elements:Dictionary;					// Stores references to the print elements
		private var _template:Object;						// Template data object
		private var _templateData:Object;					// Template content
		private var _stageRef:Stage;						// Reference to the stage 
		private var _acurringYPos:Number = 0;				// Print element positioning
		private var _imageObjectsCount:int = 0;				// Total number of image assets (if any)
		private var _imageAssetsLoaded:int = 0;				// Total number of image assets loaded (if any)
		private var _totalDataObjects:uint = 0;				// Total number of print elements
		
		// READ ONLY
		private var _topMargin:Number = 0;					// Height of the top margin
		private var _bottomMargin:Number = 0;				// Height of the bottom margin
		private var _printArea:Rectangle;					// RECTANGULAR area of print template		
		private var _paperHeight:Number = 0;				// Height of the print template
				
		public function PrintTemplate(stageRef:Stage)
		{
			super();
			
			_janitor = new Janitor(this);
			_stageRef = stageRef;
			_elements = new Dictionary(true);			
		}
		
		
		/**
		 * Loads a specific template design to be printed by the Print Manager based on the current data object passed in
		 * @param template: The template data object that stores the print template's settings/schema
		 * @param dataObject: The content used to populate template based on template's data schema
		 */		
		public function loadTemplate(template:Object, dataObject:Object):void
		{
			_template = template.Object[0];

			_totalDataObjects = _template.Property.length;
			
			_templateData = dataObject;
			_topMargin = template.Settings[0].TopMargin[0].nodeValue;
			_bottomMargin = template.Settings[0].BottomMargin[0].nodeValue;
			
			layoutPrintout();
		}
		
		
		/**
		 * Removes any display objects and/or processes that will otherwise remain in memory 
		 */		
		public function destroy():void
		{
			_template = [];
			_templateData = [];
			_janitor.cleanUp();
		}
		
		
		private function layoutPrintout():void
		{
			_acurringYPos = _topMargin;
			
			for(var i:uint = 0; i < _totalDataObjects; i++)
			{
				MonsterDebugger.trace(this, "Print Object = " + _templateData[_template.Property[i].name]);
				if(_templateData[_template.Property[i].name] != null){
					switch(_template.Property[i].type)
					{
						case "text":
							var textAlignment:String = String(_template.Property[i].Alignment[0].nodeValue).toUpperCase();						
							var printFormat:TextFormat = new TextFormat();
							
							// Determine source for font definition
							var fonts:Array = Font.enumerateFonts(true);
							var registered:Boolean;
							for(var f:int=0; f<fonts.length; f++){				
								if(fonts[f].fontName == _template.Property[i].Font[0].nodeValue){				
									printFormat.font = _template.Property[i].Font[0].nodeValue;
									registered = true;
									break;
								}
							}
							if(!registered){
								var ItemFont:Class;
								var myFont:Font;
								try {							
									ItemFont = getDefinitionByName(_template.Property[i].Font[0].nodeValue) as Class;
									myFont = new ItemFont();
									printFormat.font = myFont.fontName;
								} catch (e:Error) {								
									trace("PRINT FAILED: "+e);
									dispatchEvent(new PrintEvent(PrintEvent.PRINT_FAIL));
									return;								
								}								
							}
							
							printFormat.align = TextFormatAlign[textAlignment];
							printFormat.color = uint(_template.Property[i].Color[0].nodeValue);
							printFormat.leftMargin = MARGIN;
							printFormat.size = _template.Property[i].Font[0].size;
							
							var printText:TextField = new TextField();
							printText.name = _template.Property[i].name;
							//printText.embedFonts = true;
							
							printText.multiline = _template.Property[i].Multiline[0].nodeValue;
							printText.wordWrap = printText.multiline;
							printText.width = PAPER_WIDTH;
							
							printText.setTextFormat(printFormat);
							printText.htmlText = _templateData[_template.Property[i].name];						
							printText.autoSize = TextFormatAlign[textAlignment];
							printText.setTextFormat(printFormat);
						
							_elements[printText.name] = printText;
							
							break;
						case "image":
							
							var loader:Loader = new Loader();
							loader.name = _template.Property[i].name;
							loader.load(new URLRequest(_templateData[_template.Property[i].name]/*_template.Property[i].Source[0].nodeValue*/));
							_janitor.addEventListener(loader.contentLoaderInfo, Event.COMPLETE, onImageLoaded, false, true);
							MonsterDebugger.trace(this, "Loading Coupon Asset");
							_elements[loader.name] = loader;
							
							_imageObjectsCount++;
							break;
					}
				}
			}
			
			// IF there are no image elements...PROCEED to print
			if(_imageObjectsCount == 0)
			{
				finalizePrint();
			}
		}
		
		
		// HANDLER upon image loaded
		private function onImageLoaded(e:Event):void
		{
			
			_imageAssetsLoaded++;
			MonsterDebugger.trace(this, "Coupon Asset Loaded");
			if(_imageAssetsLoaded == _imageObjectsCount)
			{
				finalizePrint();
			}	
		}
		
		
		// ADD the elements onto the display list so they can be printed
		private function finalizePrint():void
		{
			
			_acurringYPos = _topMargin + _template.Property[0].BottomPadding[0].nodeValue;
			
			for(var i:int = 0; i < _totalDataObjects; i++)
			{
				_elements[_template.Property[i].name].y = _acurringYPos;
				switch(_template.Property[i].type)
				{
						case "text":
							_acurringYPos += _elements[_template.Property[i].name].textHeight + _template.Property[i].BottomPadding[0].nodeValue;
							break;
						case "image":
							_acurringYPos += _elements[_template.Property[i].name].height + _template.Property[i].BottomPadding[0].nodeValue;
							break;
				}
					
				addChild(_elements[_template.Property[i].name]);
			}
			
			MonsterDebugger.trace(this, "Finalizing Print");
			
			// DRAW a dotted line that will sit on the bottom of the PRINT
			var lineShape:DottedLine = new DottedLine(PAPER_WIDTH, 1, 0x000000, 1, 2, 1);
			_paperHeight = _acurringYPos + _bottomMargin;
			lineShape.y = _paperHeight;
			addChild(lineShape);
			
			_printArea = new Rectangle(0, 0, PAPER_WIDTH, _paperHeight + (lineShape.height * 2));
			
			// NOTIFIES front-end that the template is ready to be printed
			dispatchEvent(new PrintEvent(PrintEvent.PRINT_READY));
		}
		
		
		
		public function get printArea():Rectangle
		{
			return _printArea;
		}

		public function get paperHeight():Number
		{
			return _paperHeight;
		}

		public function get topMargin():Number
		{
			return _topMargin;
		}

		public function get bottomMargin():Number
		{
			return _bottomMargin;
		}

	}
}