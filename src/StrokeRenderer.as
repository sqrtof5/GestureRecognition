package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.GraphicsStroke;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.display.Shape;
	
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	import flash.geom.Point;
	
	/*
	
	Part of a very simple gesture recognition engine
	Written by Arnaud Icard
	http://www.sqrtof5.com/
	Project page and basic explanations:
	http://blog.sqrtof5.com/?p=173
	
	Note that this class is not required for the recognition
	process per se. It just does a little pink squiggly effect
	while the user is "drawing".

	*/
	
	public class StrokeRenderer {
		
		private var context:Bitmap;

		private var tension_x:Number = 0;
		private var tension_y:Number = 0;
		
		private var bias_x:Number = 2;
		private var bias_y:Number = -2;
		
		private var stroke_r:Number = .16;
		private var color:Number = 0xFD4C88;
		
		function StrokeRenderer(context:Bitmap) {
			this.context = context;
		}
		
		public function setTensionX(newVal:Number):void {
			tension_x = newVal;
		}
		
		public function setTensionY(newVal:Number):void {
			tension_y = newVal;
		}
		
		public function setBiasX(newVal:Number):void {
			bias_x = newVal;
		}
		
		public function setBiasY(newVal:Number):void {
			bias_y = newVal;
		}
		
		public function setStrokeR(newVal:Number):void {
			stroke_r = newVal;
		}
		
		public function setColor(newColor:Number):void {
			color = newColor;
		}
		
		public function draw(drawPoints:Vector.<Point>):void {
			
			var bitmapData:BitmapData = context.bitmapData;
			bitmapData.colorTransform( bitmapData.rect, new ColorTransform( 1.1, 1.1, 1.1, 1, 0, 0, 0, 0 ) );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0), new BlurFilter(6.4, 6.4, 1) );
			//bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0), new GlowFilter(color, .3, 8, 8, /*strength:*/ 2, /*quality:*/ 1, true, false) );
			//bitmapData.scroll(Math.cos(Math.random()*Math.PI)*2, 0);
			
			var shape: Shape = new Shape();
			
			if (drawPoints && drawPoints.length > 0) {
				
				var _fill:GraphicsSolidFill = new GraphicsSolidFill(color);
				var _stroke:GraphicsStroke;
				var _gdata:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
				
				var prev_dist:Number;
				
				var _initPath:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
				_initPath.moveTo(drawPoints[0].x, drawPoints[0].y);
				_gdata.push(_initPath);

				for (var i:uint=1; i<drawPoints.length-2; i++) {
					
					var _pt:Point = drawPoints[uint(i+1)];
					var _dx:Number = drawPoints[i+1].x - drawPoints[i].x;
					var _dy:Number = drawPoints[i+1].y - drawPoints[i].y;
					var _dist:Number = Math.sqrt(_dx*_dx+_dy*_dy);
					var _steps:Number = Math.ceil(_dist * .5);
					
					for (var j:uint=0; j<_steps; j++) {
						
						var _path:GraphicsPath =  new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
						var _t:Number = j*(1/_steps);
						
						if (i > 0 && i < drawPoints.length-1) {
							var str:Number = lerp(prev_dist*stroke_r, _dist*stroke_r, _t);
							_stroke = new GraphicsStroke(str, false, "normal", "round", "round", 3.0, _fill);
						} else {
							var def_str:Number = _dist*stroke_r;
							_stroke = new GraphicsStroke(def_str, false, "normal", "round", "round", 3.0, _fill);
						}
						
						_gdata.push(_stroke);
						
						var _x:Number = hermite(drawPoints[i-1].x, drawPoints[i].x, drawPoints[i+1].x, drawPoints[i+2].x, _t, tension_x, bias_x);
						var _y:Number = hermite(drawPoints[i-1].y, drawPoints[i].y, drawPoints[i+1].y, drawPoints[i+2].y, _t, tension_y, bias_y);
						_path.lineTo(_x, _y);
						
						_gdata.push(_path);
						
					}
					
					prev_dist = _dist;
				
				}
				
				shape.graphics.drawGraphicsData(_gdata);
			
			}
			
			bitmapData.draw( shape, new Matrix( 1, 0, 0, 1, 0, 0 ) );
	
		}
		
		private function lerp(a:Number, b:Number, t:Number):Number {
			return (a*(1-t)+b*t);
		}
		
		private static function hermite(prev_val:Number, a:Number, b:Number, next_val:Number, t:Number, tension:Number, bias:Number):Number {

			var t2:Number = t*t;
			var t3:Number = t2*t;

			var m0:Number = (a-prev_val)*(1+bias)*(1-tension)*.5;
			m0 += (b-a)*(1-bias)*(1-tension)*.5;
			var m1:Number = (b-a)*(1+bias)*(1-tension)*.5;
			m1 += (next_val-b)*(1-bias)*(1-tension)*.5;

			var d0:Number = 2*t3-3*t2+1;
			var d1:Number = t3-2*t2+t;
			var d2:Number = t3-t2;
			var d3:Number = -2*t3+3*t2;

			return (d0*a+d1*m0+d2*m1+d3*b);

		}
		
	}

}