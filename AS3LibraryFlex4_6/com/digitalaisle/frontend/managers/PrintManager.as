package com.digitalaisle.frontend.managers
{
	import com.digitalaisle.frontend.core.PrintTemplate;
	import com.digitalaisle.frontend.events.PrintEvent;
	import com.greensock.dataTransfer.XMLManager;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.utils.Dictionary;
	
	public class PrintManager extends EventDispatcher
	{
		private static var instance:PrintManager;
		private static var allowInstantiation:Boolean;
		public var printTemplate:PrintTemplate;
		private var _templateXML:XMLManager = new XMLManager();
		private var _printXML:XMLManager = new XMLManager();
		private var _printDictionary:Dictionary = new Dictionary();
		private var _stageRef:Stage;
		private var _printJob:PrintJob;
		public var printObject:PrintTemplate;
		
		public function PrintManager()
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use PrintManager.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():PrintManager
		{
			if (instance == null) {
				allowInstantiation = true;
				instance = new PrintManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function setUpListeners():void
		{
			_templateXML.addEventListener(Event.COMPLETE, onTemplateLoaded, false, 0, true);
		}
		
		
		public function XMLToPrint(source:String):void
		{
			var myObj:Object  = new Object();
			myObj.header = "";
			
		}
		
		
		public function print(template:String, obj:Object):void
		{
			printObject = new PrintTemplate(_stageRef);
			PrintTemplate(printObject).addEventListener(PrintEvent.PRINT_READY, onPrintReady, false, 0, true);
			
			printObject.loadTemplate(_printDictionary[template], obj);
			
			
			function onPrintReady(e:PrintEvent):void
			{
				var options:PrintJobOptions = new PrintJobOptions();
				options.printAsBitmap = false;
				
				var printJob:PrintJob = new PrintJob();
				printJob.start();
				printJob.addPage(printObject, printObject.printArea, options);
				
				//_stageRef.addChild(printObject);
				
				printJob.send();
				//delete printJob;
				dispatchEvent(new PrintEvent(PrintEvent.PRINT_COMPLETE));
				
				printObject.destroy();
			}
		}
		
		public function loadTemplate(template:String):void
		{
			setUpListeners();
			_templateXML.load(template);
		}
		
		private function onTemplateLoaded(e:Event):void
		{
			_templateXML.removeEventListener(Event.COMPLETE, onTemplateLoaded);
			var parsedObject:Object = e.target.parsedObject.PrintTemplate;
			
			for(var i:int = 0; i < parsedObject.length; i++)
			{
				var templateName:String = parsedObject[i].Settings[0].TemplateName[0].nodeValue;
				
				// SAVE to Object/Dictionary
				_printDictionary[templateName] = parsedObject[i];
			}
		}

		public function get stageRef():Stage
		{
			return _stageRef;
		}

		public function set stageRef(value:Stage):void
		{
			_stageRef = value;
		}

	}
}