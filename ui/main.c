//
// File: main.c
//
// Purpose:
//
//TODO add include guards
#include <stdio.h>
#include "lvgl/lvgl.h"
#include <time.h>

#define SCREEN_X_RES 100 // Horizontal resolution in pixels
#define SCREEN_Y_RES 100 // Vertical resolution in pixels

lv_tick_get_cb_t tick_get_cb() {
    /**
     * Callback function to provide to LVGL. This function gets the current
     * tick count, casts it to the appropriate type (lv_tick_get_cb_t), and
     * returns it.
     * @return the tick count as a lv_tick_get_cb_t
     */
    uint64_t seconds = (uint64_t )clock();
    return (lv_tick_get_cb_t)seconds;
}

int main() {

    // Initialize LVGL
    lv_init();
    // Set the LVGL tick callback. This prevents us from having to pipe the
    // ticks to LVGL internal after every iteration.
    lv_tick_set_cb((lv_tick_get_cb_t) tick_get_cb);
    // Create display
    lv_display_t *display = lv_display_create(SCREEN_X_RES, SCREEN_Y_RES);
    printf("Initialized LVGL\n");

    return 0;
}
