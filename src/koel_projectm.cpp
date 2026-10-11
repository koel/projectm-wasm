#include <emscripten.h>
#include <emscripten/html5.h>
#include <projectM-4/projectM.h>
#include <stdbool.h>

extern "C" {

static projectm_handle instance = NULL;
static EMSCRIPTEN_WEBGL_CONTEXT_HANDLE context = 0;

EMSCRIPTEN_KEEPALIVE int koel_projectm_init(const char *canvas_selector, int width, int height)
{
    EmscriptenWebGLContextAttributes attributes;
    emscripten_webgl_init_context_attributes(&attributes);
    attributes.majorVersion = 2;
    attributes.alpha = false;
    attributes.depth = false;

    context = emscripten_webgl_create_context(canvas_selector, &attributes);

    if (context <= 0) {
        return -1;
    }

    emscripten_webgl_make_context_current(context);
    emscripten_webgl_enable_extension(context, "OES_texture_float");
    emscripten_webgl_enable_extension(context, "EXT_color_buffer_float");

    instance = projectm_create();

    if (!instance) {
        return -2;
    }

    projectm_set_window_size(instance, width, height);

    return 0;
}

EMSCRIPTEN_KEEPALIVE void koel_projectm_load_preset(const char *data)
{
    projectm_load_preset_data(instance, data, false);
}

EMSCRIPTEN_KEEPALIVE void koel_projectm_add_pcm(const float *samples, unsigned int count)
{
    projectm_pcm_add_float(instance, samples, count, PROJECTM_MONO);
}

EMSCRIPTEN_KEEPALIVE void koel_projectm_render(void)
{
    emscripten_webgl_make_context_current(context);
    projectm_opengl_render_frame(instance);
}

EMSCRIPTEN_KEEPALIVE void koel_projectm_destroy(void)
{
    if (instance) {
        projectm_destroy(instance);
        instance = NULL;
    }

    if (context > 0) {
        emscripten_webgl_destroy_context(context);
        context = 0;
    }
}

EMSCRIPTEN_KEEPALIVE void koel_projectm_resize(int width, int height)
{
    projectm_set_window_size(instance, width, height);
}
}
