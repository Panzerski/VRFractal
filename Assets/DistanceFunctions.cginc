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

float3x3  rotationMatrix3(float3 v, float angle)
{
    float c = cos(radians(angle));
    float s = sin(radians(angle));

    return float3x3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
        (1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
        (1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
    );
}

float3x3 rotationMatrixXYZ(float3 v) {
    return rotationMatrix3(float3(1.0, 0.0, 0.0), v.x) *
        rotationMatrix3(float3(0.0, 1.0, 0.0), v.y) *
        rotationMatrix3(float3(0.0, 0.0, 1.0), v.z);
}

// Return rotation matrix for rotating around vector v by angle
float4x4  rotationMatrix(float3 v, float angle)
{
    float c = cos(radians(angle));
    float s = sin(radians(angle));

    return float4x4(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y, 0.0,
        (1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x, 0.0,
        (1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z, 0.0,
        0.0, 0.0, 0.0, 1.0);
}

float4x4 translate(float3 v) {
    return float4x4(1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        v.x, v.y, v.z, 1.0);
}

float4x4 scale4(float s) {
    return float4x4(s, 0.0, 0.0, 0.0,
        0.0, s, 0.0, 0.0,
        0.0, 0.0, s, 0.0,
        0.0, 0.0, 0.0, 1.0);
}

// Nieskonczone sfery
// r: promień
// c: odstęp
float sdInfSphere(float3 p, float r, float3 c)
{
    p = fmod(p, c) - c * 0.5;
    return sdSphere(p, r);
}

// Krzyż
float sdCross(float3 p, float scale)
{
    float inf = 1e20;

    float da = sdBox(p.xyz, float3(inf, scale, scale));
    float db = sdBox(p.yzx, float3(scale, inf, scale));
    float dc = sdBox(p.zxy, float3(scale, scale, inf));
    return min(da, min(db, dc));
}

// Skończone Powtarzanie Krzyża
// s: skala
// c: odstęp
// l: wektor z liczbą powtórzeń w danej osi
float finitCross(float3 p, float s, float c, float3 l)
{
    p = p - c * clamp(round(p / c), -l, l);

    return sdCross(p,s);
}

// Kostka Mengera
float sdMenger(float3 p, float scale, int iterations)
{
    float distance = sdBox(p, float3(scale*3, scale*3, scale*3));
    float3 tp = p;
    float mainCross = sdCross(p, scale);
    float finCross;
    distance = opS(mainCross, distance);

    for (int i = 0; i < iterations; i++)
    {
        finCross = finitCross(tp, scale / 3, 2 * scale, float3(1, 1, 1));
        distance = opS(finCross, distance);
        tp = tp - (scale * 2) * clamp(round(tp / (scale * 2)), -float3(1, 1, 1), float3(1, 1, 1));
        scale /= 3;
    }

    return distance;
}
// Czworościan Sierpińskiego
float sdSierpinski(float3 z, float Scale,float Scale2, float Offset, int iterations)
{
    int n = 0;
    z = z * 1 / Scale2;

    while (n < iterations) {

        //z = rotate2(z);
        //z = rotate1(z);

        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.y + z.z < 0.0) z.zy = -z.yz;

        //z = rotate2(z);
        //z = rotate1(z);

        z = z * Scale - Offset * (Scale - 1.0);
        n++;
    }
    return length(z) * pow(Scale, -float(n));
}

float sdSierpinski2(float3 z, float Scale, float Scale2, float Offset, int iterations)
{
    int n = 0;
    z = z * 1/Scale2;

    while (n < iterations) {
        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0) z.xz = z.zx;

        z.x = z.x * Scale - Offset * (Scale - 1.0);
        z.y = z.y * Scale;
        z.z = z.z * Scale;

        n++;
    }
    return (length(z) * pow(Scale, -float(n)));
}

float sdSierpinski3(float3 p, float Scale, float Scale2, int iterations)
{
    p = p * 1 / Scale2;
    
    float3 va = float3(0.0, 0.575735, 0.0)*Scale;
    float3 vb = float3(0.0, -1.0, 1.15470)*Scale;
    float3 vc = float3(1.0, -1.0, -0.57735)*Scale;
    float3 vd = float3(-1.0, -1.0, -0.57735)*Scale;

    float a = 0;
    float s = 1;
    float r = 1;
    float dm;
    float3 v;
    [loop]
    for (int i = 0; i < iterations; i++)
    {
        float d, t;
        d = dot(p - va, p - va);

        v = va;
        dm = d;
        t = 0;

        d = dot(p - vb, p - vb);
        if (d < dm)
        {
            v = vb;
            dm = d;
            t = 1.0;
        }

        d = dot(p - vc, p - vc);

        if (d < dm) { v = vc; dm = d; t = 2.0; }
        d = dot(p - vd, p - vd);
        if (d < dm) { v = vd; dm = d; t = 3.0; }

        p = v + 2 * (p - v);
        r *= 2;
        a = t + 4 * a;
        s *= 4;
    }

    return float2((sqrt(dm) - 1.0) / r, a / s);
}

float sdMandelbulb(float3 p,float scale, int iterations)
{
    p = p * 1/scale;
    float3 w = p;
    float m = dot(w, w);

    float dz = 1.0;

    for (int i = 0; i < iterations; i++)
    {
        dz = 8 * pow(sqrt(m), 7.0) * dz + 1.0;
        float r = length(w);
        float b = 8 * acos(w.y / r);
        float a = 8 * atan2(w.x, w.z);
        w = p + pow(r, 8) * float3(sin(b) * sin(a), cos(b), sin(b) * cos(a));

        m = dot(w, w);
        if (m > 256.0)
            break;
    }
    return 0.25 * log(m) * sqrt(m) / dz;
}