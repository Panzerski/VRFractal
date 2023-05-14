// Sfera
// r: promien
float sdSphere(float3 p, float r)
{
	return length(p) - r;
}

// Szescian
// b: rozmiar w x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}

// Torus
// b: duży promien i maly promien
float sdTorus(float3 p, float2 t)
{
	float2 q = float2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}
// Krzyz
//
float sdCross(float3 p, float scale)
{
    float inf = 1e20;

    float da = sdBox(p.xyz, float3(inf, scale, scale));
    float db = sdBox(p.yzx, float3(scale, inf, scale));
    float dc = sdBox(p.zxy, float3(scale, scale, inf));
    return min(da, min(db, dc));
}

// BOOLEAN OPERATORS //

// Union
float opU(float d1, float d2)
{
	return min(d1, d2);
}

// Subtraction
float opS(float d1, float d2)
{
	return max(-d1, d2);
}

// Intersection
float opI(float d1, float d2)
{
	return max(d1, d2);
}

// Nieskonczone sfery
// r: promień
// c: odstęp
float sdInfSphere(float3 p, float r, float3 c)
{
    p = fmod(p, c) - c * 0.5;
    return length(p) - r;
}
float sdCrossing(float3 p, float distance, float s,int r)
{
        float3 tp = p;
        
        if(r>0) distance = opS(sdCross(p, s / 3), distance);
    
        if (r > 1)
        {
            //pierwsze narożniki
            tp += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            //środkowe
            tp.xy -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xz -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.yz -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xy += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xz += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.yz += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            //pozostałe narożniki
            tp.xy -= s * 2 / 3;
            tp.z += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xy += s * 2 / 3;
            tp.z -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xz -= s * 2 / 3;
            tp.y += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.xz += s * 2 / 3;
            tp.y -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.yz -= s * 2 / 3;
            tp.x += s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            tp.yz += s * 2 / 3;
            tp.x -= s * 2 / 3;
            distance = sdCrossing(tp, distance, s / 9, r - 1);
            tp = p;

            r -= 1;
        }

        return distance;
}

// Kostka Mengera
float sdMenger(float3 p, float scale, int iterations)
{
    float distance = sdBox(p, float3(scale, scale, scale));

    distance = sdCrossing(p, distance, scale,iterations);
    
    return distance;
}

// Czworościan Sierpińskiego
float sdSierpinski(float3 p, float3 scale, int iterations)
{
    float sqrt2 = sqrt(2.0);

    // Initial tetrahedron vertices
    float3 vertices[4] = {
        float3(0, 0, sqrt2 / 3),
        float3(sqrt2 / 2, 0, -sqrt2 / 6),
        float3(sqrt2 / 4, sqrt2 / 2, -sqrt2 / 6),
        float3(sqrt2 / 4, sqrt2 / 6, sqrt2 / 2)
    };

    float dist = 1e20;

    // Perform iterations of subdivision
    for (int i = 0; i < iterations; i++)
    {
        float3 tempVertices[4];

        // Subdivide each face of the tetrahedron
        for (int j = 0; j < 4; j++)
        {
            tempVertices[0] = vertices[j];
            tempVertices[1] = (vertices[(j + 1) % 4] + vertices[j]) * 0.5;
            tempVertices[2] = (vertices[(j + 2) % 4] + vertices[j]) * 0.5;
            tempVertices[3] = (vertices[(j + 3) % 4] + vertices[j]) * 0.5;

            // Replace vertices with subdivided faces
            for (int k = 0; k < 4; k++)
            {
                vertices[j] = tempVertices[k];
                // Apply scaling
                vertices[j].x *= scale.x;
                vertices[j].y *= scale.y;
                vertices[j].z *= scale.z;

                // Calculate the distance from the point to the current face
                float currDist = length(p - vertices[j]);
                if (currDist < dist)
                    dist = currDist;
            }
        }
    }
    return dist;
}

float DE(float3 z,float Scale,int Iterations)
{
    float3 a1 = float3(1, 1, 1);
    float3 a2 = float3(-1, -1, 1);
    float3 a3 = float3(1, -1, -1);
    float3 a4 = float3(-1, 1, -1);
    float3 c;
    int n = 0;
    float dist, d;
    while (n < Iterations) {
        c = a1; dist = length(z - a1);
        d = length(z - a2); if (d < dist) { c = a2; dist = d; }
        d = length(z - a3); if (d < dist) { c = a3; dist = d; }
        d = length(z - a4); if (d < dist) { c = a4; dist = d; }
        z = Scale * z - c * (Scale - 1.0);
        n++;
    }

    return length(z) * pow(Scale, float(-n));
}

// Mod Position Axis
float pMod1 (inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}