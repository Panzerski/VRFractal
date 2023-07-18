// Sfera
// r: promien
float sdSphere(float3 p, float r)
{
	return length(p) - r;
}
// Prostopadłościan
// b: rozmiar w x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}
float sdBox2D(float2 p, float2 b)
{
    float2 d = abs(p) - b;
    return length(max(d, 0.0)) + 
        min(max(d.x, d.y), 0.0);
}
// Torus
// b: duży promien i maly promien
float sdTorus(float3 p, float2 t)
{
	float2 q = float2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}
// Unia
float opU(float d1, float d2)
{
	return min(d1, d2);
}
// Różnica
float opS(float d1, float d2)
{
	return max(-d1, d2);
}
// Część Wspólna
float opI(float d1, float d2)
{
	return max(d1, d2);
}
// Rotacja
float3 Rotate(float3 p, float3 angle)
{
    float cx = cos(angle.x);
    float sx = sin(angle.x);
    float3x3 mat1 = float3x3(1, 0, 0,
        0, cx, -sx,
        0, sx, cx);

    float cy = cos(angle.y);
    float sy = sin(angle.y);
    float3x3 mat2 = float3x3(cy, 0, sy,
        0, 1, 0,
        -sy, 0, cy);

    float cz = cos(angle.z);
    float sz = sin(angle.z);
    float3x3 mat3 = float3x3(cz, -sz, 0,
        sz, cz, 0,
        0, 0, 1);

    float3x3 mat = mul(mul(mat3, mat2), mat1);
    return mul(mat, p);
}
// Nieskonczone sfery
// r: promień
// c: odstęp
float sdInfSphere(float3 p, float r, float3 c)
{
    p = fmod(p, c) - c * 0.5;
    return sdSphere(p, r);
}
float maxcomp(float2 p)
{
    return max(p.x, p.y);
}
// Krzyż
float sdCross(float3 p, float scale)
{
    //float inf = 1e20;

    //float da = sdBox(p.xyz, float3(inf, scale, scale));
    //float db = sdBox(p.yzx, float3(scale, inf, scale));
    //float dc = sdBox(p.zxy, float3(scale, scale, inf));

    //Optymalizacja
    //float da = sdBox2D(p.xy, float2(scale, scale));
    //float db = sdBox2D(p.yz, float2(scale, scale));
    //float dc = sdBox2D(p.zx, float2(scale, scale));
    //return min(da, min(db, dc));

    //Optymalizacja 2
    float da = maxcomp(abs(p.xy));
    float db = maxcomp(abs(p.yz));
    float dc = maxcomp(abs(p.zx));
    return min(da, min(db, dc)) - scale;
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
float sdSierpinski3(float3 p, float Scale, float Scale2, int iterations)
{
    p = p / Scale2;
    
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
float sdTetrahedron(float3 z, float3 rotation, float3 rotation2, float Scale, float Scale2, float3 Offset, int iterations)
{
    int n = 0;
    z = z / Scale2;

    while (n < iterations) {

        z = Rotate(z, rotation);

        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.y + z.z < 0.0) z.zy = -z.yz;

        z = Rotate(z, rotation2);

        z = z * Scale - Offset * (Scale - 1.0);
        n++;
    }
    return length(z) * pow(Scale, -float(n));
}
float sdDoubleTetra(float3 z, float3 rotation, float3 rotation2, float Scale, float Scale2, float3 Offset, int iterations)
{
    int n = 0;
    z = z * 1 / Scale2;

    z = Rotate(z, rotation);

    while (n < iterations) {
        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0) z.xz = z.zx;

        z = Rotate(z, rotation2);

        z.x = z.x * Scale - Offset.x * (Scale - 1.0);
        z.y = z.y * Scale;
        z.z = z.z * Scale;
        n++;
    }
    return (length(z) * pow(Scale, -float(n)));
}
float sdFullTetra(float3 z, float3 rotation, float3 rotation2, float Scale, float Scale2, float3 Offset, float Offset2, int iterations)
{
    int n = 0;
    z = z * 1 / Scale2;

    while (n < iterations) {

        z = Rotate(z, rotation);

        if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0) z.xz = z.zx;
        if (z.y - z.z < 0.0) z.yz = z.zy;
        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.y + z.z < 0.0) z.yz = -z.zy;

        z = Rotate(z, rotation2);

        z = z * Scale - Offset * (Scale - 1.0);
        n++;
    }
    return (length(z) * pow(Scale, -float(n)));
}
float sdOctohedron(float3 z, float3 rotation, float3 rotation2, float Scale, float Scale2, float3 Offset, int iterations)
{
    int n = 0;
    z = z / Scale2;

    while (n < iterations) {

        z = Rotate(z, rotation);

        z.x = abs(z.x); z.y = abs(z.y); z.z = abs(z.z);
        if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0) z.xz = z.zx;
        if (z.y - z.z < 0.0) z.zy = z.yz;

        z = Rotate(z, rotation2);

        z = z * Scale - Offset * (Scale - 1.0);
        n++;
    }
    return length(z) * pow(Scale, -float(n));
}