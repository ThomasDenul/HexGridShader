//************
// VARIABLES *
//************
cbuffer cbPerObject
{
	float4x4 m_MatrixWorldViewProj : WORLDVIEWPROJECTION;
	float4x4 m_MatrixWorld : WORLD;
	float3 m_LightDir={-0.577f, -0.577f, 0.577f};

	int m_Rows = 5;
	int m_Columns = 5;
	float m_Height = 1.f;
	float m_MaxHeight = 35.f;
	float m_MinHeight = 25.f;
	float m_Time;
	float m_MoveAmount = 1.f;
	float m_MoveSpeed = 5.f;
	float m_Radius = 1.f;
	float3 m_Position = {0.f, 0.f, 0.f};
	float4 m_Color;
	float PI = 3.14159265f;
}

RasterizerState FrontCulling 
{ 
	CullMode = FRONT; 
};

DepthStencilState EnableDepth
{
	DepthEnable = TRUE;
	DepthWriteMask = ALL;
};

BlendState EnableBlending
{
	BlendEnable[0] = TRUE;
	SrcBlend = SRC_ALPHA;
	DestBlend = INV_SRC_ALPHA;
};

//**********
// STRUCTS *
//**********
struct VS_DATA
{
	float3 Position : POSITION;
	float3 Normal : NORMAL;
	float4 Color : COLOR;
};

struct GS_DATA
{
	float4 Position : SV_POSITION;
	float3 Normal : NORMAL;
	float4 Color : COLOR;
};

//****************
// VERTEX SHADER *
//****************
VS_DATA MainVS(VS_DATA vsData)
{
	return vsData;
}

//******************
// GEOMETRY SHADER *
//******************
void CreateVertex(inout TriangleStream<GS_DATA> triStream, float3 pos, float3 normal, float4 color)
{
	//Step 1. Create a GS_DATA object
	GS_DATA MainGS= (GS_DATA)0;
	//Step 2. Transform the position using the WVP Matrix and assign it to (GS_DATA object).Position (Keep in mind: float3 -> float4)
	MainGS.Position = mul(float4(pos,1),m_MatrixWorldViewProj);
	//Step 3. Transform the normal using the World Matrix and assign it to (GS_DATA object).Normal (Only Rotation, No translation!)
	MainGS.Normal = mul(normalize(normal), (float3x3)m_MatrixWorld);
	//Step 4. Assign color to (GS_DATA object).Color
	MainGS.Color = color;
	//Step 5. Append (GS_DATA object) to the TriangleStream parameter
	triStream.Append(MainGS);
}

[maxvertexcount(60)]
[instance(32)]
void HexGenerator(point VS_DATA Vertex[1], inout TriangleStream<GS_DATA> triStream, uint InstanceID : SV_GSInstanceID)
{
	if (InstanceID < m_Columns * m_Rows)
	{
		//Use these variable names
		float3 basePoint, vert1, vert2, vert3, vert4, vert5, vert6, TbasePoint, Tvert1, Tvert2, Tvert3, Tvert4, Tvert5, Tvert6;
		float semiRand = (InstanceID % 7) - ((InstanceID % 3) * 1.2f) + ((InstanceID % 5) * 0.3) * ((InstanceID % 5) * 0.2) + ((InstanceID % 4) * 0.4);

		//BotomPlane
		//**********

		//Step 1. Calculate The basePoint
		basePoint = m_Position;
		if ((int(InstanceID / m_Columns) + 1) % 2 == 0)
			basePoint.x += m_Radius * (InstanceID % m_Columns) * 2 + m_Radius;
		else
			basePoint.x += m_Radius * (InstanceID % m_Columns) * 2;

		if(m_MaxHeight != m_MinHeight)
			basePoint.y -= ((m_MinHeight + semiRand*10) % (m_MaxHeight - m_MinHeight)) + m_MinHeight;
		else
			basePoint.y -= m_MaxHeight;

		basePoint.y += m_MoveAmount * sin((m_Time + (InstanceID % 5) - ((InstanceID % 2) * 0.5f)) * m_MoveSpeed);

		basePoint.z -= m_Radius * (int((InstanceID) / m_Columns) + 1) * 2;
		//Step 2. Calculate The normal of the basePoint
		float3 normal = { 0,-1,0 };
		//Step 4. Calculate hexagon
		//1
		vert1 = basePoint;
		//vert1.y += Height;
		vert1.z += m_Radius;

		//2
		vert2 = basePoint;
		vert2.x += cos(PI / 6) * m_Radius;
		//vert2.y += Height;
		vert2.z += sin(PI / 6) * m_Radius;

		//3
		vert3 = basePoint;
		vert3.x += cos(PI / 6) * m_Radius;
		//vert3.y += Height;
		vert3.z += -sin(PI / 6) * m_Radius;

		//4
		vert4 = basePoint;
		//vert4.y += Height;
		vert4.z += -m_Radius;

		//5
		vert5 = basePoint;
		vert5.x += -cos(PI / 6) * m_Radius;
		//vert5.y += Height;
		vert5.z += -sin(PI / 6) * m_Radius;

		//6
		vert6 = basePoint;
		vert6.x += -cos(PI / 6) * m_Radius;
		//vert6.y += Height;
		vert6.z += sin(PI / 6) * m_Radius;

		triStream.RestartStrip();

		//VERTEX 1
		CreateVertex(triStream, vert1, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, vert2, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, vert4, normal, m_Color);

		//VERTEX 5
		CreateVertex(triStream, vert5, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX 2
		CreateVertex(triStream, vert2, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert3, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);

		//VERTEX 5
		CreateVertex(triStream, vert5, normal, m_Color);

		//VERTEX 6
		CreateVertex(triStream, vert6, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX 3
		CreateVertex(triStream, vert3, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, vert4, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, basePoint, normal, m_Color);

		//VERTEX 6
		CreateVertex(triStream, vert6, normal, m_Color);

		//VERTEX 1
		CreateVertex(triStream, vert1, normal, m_Color);



		//TopPlane
		//********

		//Step 1. Calculate The basePoint
		TbasePoint = m_Position;
		if ((int(InstanceID / m_Columns) + 1) % 2 == 0)
			TbasePoint.x += m_Radius * (InstanceID % m_Columns) * 2 + m_Radius;
		else
			TbasePoint.x += m_Radius * (InstanceID % m_Columns) * 2;

		if(m_MaxHeight != m_MinHeight)
			TbasePoint.y += ((m_MinHeight + semiRand*10) % (m_MaxHeight - m_MinHeight)) + m_MinHeight;
		else
			TbasePoint.y += m_MaxHeight;

		TbasePoint.y += m_MoveAmount * sin((m_Time + (InstanceID % 5) - ((InstanceID % 2) * 0.5f)) * m_MoveSpeed);

		TbasePoint.z -= m_Radius * (int((InstanceID) / m_Columns) + 1) * 2;
		//Step 2. Calculate The normal of the basePoint
		normal = float3(0, 1, 0);
		//Step 4. Calculate hexagon
		//1
		Tvert1 = TbasePoint;
		Tvert1.z += m_Radius;

		//2
		Tvert2 = TbasePoint;
		Tvert2.x += cos(PI / 6) * m_Radius;
		//vert2.y += Height;
		Tvert2.z += sin(PI / 6) * m_Radius;

		//3
		Tvert3 = TbasePoint;
		Tvert3.x += cos(PI / 6) * m_Radius;
		//vert3.y += Height;
		Tvert3.z += -sin(PI / 6) * m_Radius;

		//4
		Tvert4 = TbasePoint;
		//vert4.y += Height;
		Tvert4.z += -m_Radius;

		//5
		Tvert5 = TbasePoint;
		Tvert5.x += -cos(PI / 6) * m_Radius;
		//vert5.y += Height;
		Tvert5.z += -sin(PI / 6) * m_Radius;

		//6
		Tvert6 = TbasePoint;
		Tvert6.x += -cos(PI / 6) * m_Radius;
		//vert6.y += Height;
		Tvert6.z += sin(PI / 6) * m_Radius;

		triStream.RestartStrip();

		//VERTEX 2
		CreateVertex(triStream, Tvert2, normal, m_Color);

		//VERTEX 1
		CreateVertex(triStream, Tvert1, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);

		//VERTEX 5
		CreateVertex(triStream, Tvert5, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert4, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX 3
		CreateVertex(triStream, Tvert3, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert2, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);

		//VERTEX 6
		CreateVertex(triStream, Tvert6, normal, m_Color);

		//VERTEX 5
		CreateVertex(triStream, Tvert5, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX 4
		CreateVertex(triStream, Tvert4, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, Tvert3, normal, m_Color);

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);


		//RESTART STRIP
		triStream.RestartStrip();

		//VERTEX Mid
		CreateVertex(triStream, TbasePoint, normal, m_Color);

		//VERTEX 1
		CreateVertex(triStream, Tvert1, normal, m_Color);

		//VERTEX 6
		CreateVertex(triStream, Tvert6, normal, m_Color);



		//Sides
		//*****

		// Side1

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		float3 dir = (vert1 + vert2) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert1, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert1, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert2, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert2, normal, m_Color);


		// Side2

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		dir = (vert2 + vert3) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert2, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert2, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert3, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert3, normal, m_Color);


		// Side3

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		dir = (vert3 + vert4) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert3, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert3, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert4, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert4, normal, m_Color);


		// Side4

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		dir = (vert4 + vert5) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert4, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert4, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert5, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert5, normal, m_Color);


		// Side5

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		dir = (vert5 + vert6) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert5, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert5, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert6, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert6, normal, m_Color);


		// Side6

		//RESTART STRIP
		triStream.RestartStrip();

		//Calculate normal
		dir = (vert6 + vert1) / 2 - basePoint;
		normal = float3(dir.x, 0, dir.z);
		normal = normalize(normal);

		//VERTEX 1
		CreateVertex(triStream, vert6, normal, m_Color);

		//VERTEX 2
		CreateVertex(triStream, Tvert6, normal, m_Color);

		//VERTEX 3
		CreateVertex(triStream, vert1, normal, m_Color);

		//VERTEX 4
		CreateVertex(triStream, Tvert1, normal, m_Color);
	}
}

//***************
// PIXEL SHADER *
//***************
float4 MainPS(GS_DATA input) : SV_TARGET 
{
	//input.Normal=-normalize(input.Normal);
	//float3 color = m_Color;
	//float s = max(dot(m_LightDir,input.Normal), 0.4f);

	//return float4(color*s,1);


	float3 color_rgb= m_Color.rgb;
	float color_a = m_Color.a;
	
	//HalfLambert Diffuse :)
	float diffuseStrength = dot(input.Normal, -m_LightDir);
	diffuseStrength = diffuseStrength * 0.5 + 0.5;
	diffuseStrength = saturate(diffuseStrength);
	color_rgb = color_rgb * diffuseStrength;
	
	return float4( color_rgb , color_a );
}


//*************
// TECHNIQUES *
//*************
technique11 DefaultTechnique 
{
	pass p0 {
		SetRasterizerState(FrontCulling);	
		SetDepthStencilState(EnableDepth, 0);
		SetBlendState(EnableBlending, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
		SetVertexShader(CompileShader(vs_4_0, MainVS()));
		SetGeometryShader(CompileShader(gs_5_0, HexGenerator()));
		SetPixelShader(CompileShader(ps_4_0, MainPS()));
	}
}