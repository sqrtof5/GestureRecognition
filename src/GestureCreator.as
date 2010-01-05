package {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	/*
	
	Part of a very simple gesture recognition engine
	Written by Arnaud Icard
	http://www.sqrtof5.com/
	Project page and basic explanations:
	http://blog.sqrtof5.com/?p=173
	
	This class will output raw data path to a textfield.
	Data to be added to GestureDictionary.
	Yup. It ain't pretty.
	If you feel like making this prettier, go for it.
	(personally... I'd like an Air app that outputs to a .JSON file)
	I know I would use it :$
	
	*/
	

	[ SWF (width=800, height=600, backgroundColor=0xAEAEAE, frameRate=31) ]
	
	public class GestureCreator extends Sprite {
		
		private var gestureProcessor	:GestureProcessor;
		private var dataPoints			:Vector.<Point>;
		private var _tf_debug			:TextFormat;
		private var _debug				:TextField;
		private var gestureCont			:Sprite;
		
		public function GestureCreator() {
			
			_tf_debug = new TextFormat();
			_tf_debug.font = "_typewriter";
			_tf_debug.color = 0x333333;
			
			_debug = new TextField();
			_debug.multiline = true;
			_debug.wordWrap = true;
			_debug.x = 35;
			_debug.y = 370;
			_debug.width = 300;
			_debug.height = 200;
			_debug.text = "---\n";
			_debug.setTextFormat(_tf_debug);
			
			gestureCont = new Sprite();
			gestureCont.x = 15;
			gestureCont.y = 15;
			addChild(gestureCont);
			
			addChild(_debug);
			
			gestureProcessor = new GestureProcessor();

			_debug.addEventListener(MouseEvent.MOUSE_DOWN, preventEvent);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			
		}
		
		private function preventEvent(evt:MouseEvent):void {
			evt.stopImmediatePropagation();
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {

			switch(evt.type) {
				case MouseEvent.MOUSE_DOWN:
					if (evt.currentTarget == stage) {
						clearLogs();
						dataPoints = new Vector.<Point>();
						stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
					}
					break;
				case MouseEvent.MOUSE_UP:
					if (evt.currentTarget == stage) {
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
						logMsg(dataPoints.length + " data points");
						doDrawPath(dataPoints, this, true, 1, 0x0000FF);
						var gesturePoints:Vector.<Point> = gestureProcessor.process(dataPoints);
						logMsg(gesturePoints.length + " points in gesture");
						doDrawPath(gesturePoints, gestureCont, true, 1, 0xFF0000, 150);
						doDrawPoints(gesturePoints, gestureCont, false, 2.5, 0xFF0000, 150);
						var str:String = "";
						for (var i:uint = 0; i<gesturePoints.length; i++) {
							str += (gesturePoints[i].x + "," + gesturePoints[i].y + ",");
						}
						logMsg(str);
						dataPoints = new Vector.<Point>();
					}
					break;
				case MouseEvent.MOUSE_MOVE:
					dataPoints.push(new Point(mouseX, mouseY));
					break;
			}

		}
		
			private function doDrawPoints(pts:Vector.<Point>, context:Sprite, clearContext:Boolean = false, r:Number = 2.5, color:Number = 0xFF0000, scale:Number = 1):void {
				if (pts.length > 0) {
					if (clearContext) context.graphics.clear();
					context.graphics.lineStyle();
					gestureCont.graphics.beginFill(color);
					for (var i:uint=0; i<pts.length; i++) {
						context.graphics.drawCircle(pts[i].x * scale, pts[i].y * scale, r);
					}
					context.graphics.endFill();
				}
			}

			private function doDrawPath(pts:Vector.<Point>, context:Sprite, clearContext:Boolean = true, strokeWeight:Number = 1, color:Number = 0xFF0000, scale:Number = 1):void {
				if (pts.length > 0) {
					if (clearContext) context.graphics.clear();
					context.graphics.lineStyle(strokeWeight, color, .6);
					context.graphics.moveTo(pts[0].x * scale, pts[0].y * scale);
					for (var i:uint=1; i<pts.length; i++) {
						context.graphics.lineTo(pts[i].x * scale, pts[i].y * scale);
					}
				}
			}
		
		private function logMsg(msg:String):void {
			_debug.appendText(msg + "\n");
			_debug.setTextFormat(_tf_debug);
		}
		
		private function clearLogs():void {
			_debug.text = "LOGS\n";
			_debug.setTextFormat(_tf_debug);
		}
	
	}

}

