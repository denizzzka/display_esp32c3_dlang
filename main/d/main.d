module main;
/*
Маркировка на плате индикаторов:

3Ф7103450
БЦИ-1
*/

//~ #include <stdio.h>
//~ #include "freertos/FreeRTOS.h"
//~ #include "freertos/task.h"

// freertos/portmacro.h
// #define portTICK_PERIOD_MS              ( ( TickType_t ) 1000 / configTICK_RATE_HZ )
enum CONFIG_FREERTOS_HZ = 1000;
enum portTICK_PERIOD_MS = 1000 / CONFIG_FREERTOS_HZ;

alias gpio_num_t = int;
alias uint32_t = uint;
alias uint64_t = ulong;
alias TickType_t = int;
alias esp_err_t = int;

enum gpio_mode_t {
    GPIO_MODE_DISABLE = (0),
    GPIO_MODE_INPUT = (0x00000001),
    GPIO_MODE_OUTPUT = (0x00000002),
    GPIO_MODE_OUTPUT_OD = (((0x00000002)) | ((0x00000004))),
    GPIO_MODE_INPUT_OUTPUT_OD = (((0x00000001)) | ((0x00000002)) | ((0x00000004))),
    GPIO_MODE_INPUT_OUTPUT = (((0x00000001)) | ((0x00000002))),
}

extern(C) esp_err_t gpio_set_level(gpio_num_t gpio_num, uint32_t level);
extern(C) esp_err_t gpio_reset_pin(gpio_num_t gpio_num);
extern(C) esp_err_t gpio_set_direction(gpio_num_t gpio_num, gpio_mode_t mode);
extern(C) void vTaskDelay(const TickType_t xTicksToDelay);

//~ #include "sdkconfig.h"

enum CONFIG_BLINK_PERIOD = 50;
enum BLINK_GPIO = 12;

enum esp_intr_cpu_affinity_t
{
    ESP_INTR_CPU_AFFINITY_AUTO,
    ESP_INTR_CPU_AFFINITY_0,
    ESP_INTR_CPU_AFFINITY_1,
}

alias uint8_t = ubyte;
alias uint16_t = ushort;

ubyte s_led_state = 0;

void blink_led()
{
    /* Set the GPIO level according to the state (LOW or HIGH)*/
    gpio_set_level(BLINK_GPIO, s_led_state);
}

void configure_led()
{
    //~ ESP_LOGI(TAG, "Example configured to blink GPIO LED!");
    gpio_reset_pin(BLINK_GPIO);
    /* Set the GPIO as a push/pull output */
    gpio_set_direction(BLINK_GPIO, gpio_mode_t.GPIO_MODE_OUTPUT);
}

extern(C) int rand();

extern(C) void app_main()
{
    import displ_driver: configure_displ;

    configure_led();
    configure_displ();

    while (1) {
        blink_led();
        s_led_state = !s_led_state;

        vTaskDelay(CONFIG_BLINK_PERIOD / portTICK_PERIOD_MS);
    }
}

//~ extern(C) void esp_error_check_failed_print(const char *msg, esp_err_t rc, const char *file, uint line, const char* fn, const char *expression, ptrdiff_t* addr);

//~ void ESP_ERROR_CHECK(esp_err_t rc, string file = __FILE__, size_t line = __LINE__)
//~ {
    //~ if(rc != 0)
        //~ esp_error_check_failed_print(cast(char*) "ESP_ERROR_CHECK_D", rc, cast(char*) file, line, null, null, null);
//~ }
