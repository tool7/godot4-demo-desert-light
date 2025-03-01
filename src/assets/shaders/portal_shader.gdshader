shader_type spatial;

uniform float size: hint_range(0.0,0.5) = 0.5;
uniform float size_inner: hint_range(0.1,1) = 0.2;
uniform float intensity: hint_range(0.0,1) = 1;

uniform sampler2D noise;

uniform vec4 portalFrameColor : source_color;
uniform vec4 portalHighlightColor : source_color;
uniform vec4 inner : source_color;

// https://godotshaders.com/snippet/rotate/
vec2 rotateUV(vec2 uv, vec2 pivot, float angle)
{
    mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
                        vec2(cos(angle), sin(angle)));

    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

void fragment() {
    float dist = length(UV - vec2(0.5,0.5));

    vec2 nuv = UV;

    nuv = rotateUV(UV, vec2(0.5), 45.0*TIME*0.01);
    nuv.x += (TIME*0.1);
    nuv.y -= (TIME*0.1);

    vec4 ntexel = texture(noise,nuv);

    float a = smoothstep(size, size-0.04, dist);
    float a2 = smoothstep(size, (ntexel.r*0.10)+(size-size_inner), dist);

    vec4 result = mix(portalHighlightColor, portalHighlightColor , a);
    ALPHA = a;

    if (a == 1.0) {
        result = inner;
    }

    if (a2 < 0.2) {
        result = portalHighlightColor;
    }

    result = mix(portalFrameColor, result , a2);

    ALBEDO = result.rgb * intensity;
    EMISSION = ALBEDO;
}