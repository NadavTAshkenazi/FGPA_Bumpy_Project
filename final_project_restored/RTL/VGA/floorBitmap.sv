module	floorBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;



localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  


localparam  int OBJECT_HEIGHT_Y = 32;
localparam  int OBJECT_WIDTH_X = 32;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 


logic [0:OBJECT_WIDTH_X-1] [0:OBJECT_HEIGHT_Y-1] [8-1:0] object_colors = {
{8'hAD, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hAD },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD1, 8'hD5, 8'hD5, 8'hB1, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'hD1, 8'hD5, 8'hD5, 8'hD1, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hAD, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAC, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAC, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAC, 8'hAD, 8'hAD, 8'hAD, 8'hAC, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h88, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hB1, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hAD, 8'hAD, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'h8C, 8'hAD, 8'hAC, 8'hAC, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hAD, 8'hAD, 8'hB1, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hD1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'h8C, 8'h8D, 8'hD1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'h8C, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hD1, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hAC, 8'hAC, 8'hAC, 8'h8C, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hB1, 8'hB1, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hB1, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h88, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hB1, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hAD, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'h8C, 8'h8C, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hAD, 8'hAD, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hAD, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'h8C, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'h8C, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hB1, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'hB1, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hD1, 8'h8C, 8'hAC, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'hAD, 8'h8C, 8'h8D, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hD5, 8'hD1, 8'hD5, 8'hD5, 8'hD1, 8'h8C, 8'h8C, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'hAC, 8'h8C, 8'hAD, 8'hD1, 8'hD1, 8'hD5, 8'hD1, 8'hD5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hD5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hD1, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hD1 },
{8'hAD, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hD1, 8'hAD }
};




//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
{16'hC446,     
 16'h8C62,    
 16'h8932,
 16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end
	else begin
		HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  

	
		if (InsideRectangle == 1'b1 )  // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];	 //regular
//			RGBout <= object_colors[(OBJECT_HEIGHT_Y-1) - offsetY][offsetX];	 //upsideDown
//			RGBout <=  {HitEdgeCode, 4'b0000 } ;  //get RGB from the colors table, option  for debug 
		else 
			RGBout <= TRANSPARENT_ENCODING ; // force color to transparent so it will not be displayed 
	end 
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule
