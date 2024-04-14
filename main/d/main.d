// Blink Example

//~ #include <stdio.h>
//~ #include "freertos/FreeRTOS.h"
//~ #include "freertos/task.h"

// freertos/portmacro.h
// #define portTICK_PERIOD_MS              ( ( TickType_t ) 1000 / configTICK_RATE_HZ )
enum CONFIG_FREERTOS_HZ = 1000;
enum portTICK_PERIOD_MS = 1000 / CONFIG_FREERTOS_HZ;

//~ #include "driver/gpio.h"

alias esp_err_t = int;
alias gpio_num_t = int;
alias uint32_t = int;
alias TickType_t = int;

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

//~ #include "esp_log.h"
//~ #include "led_strip.h"
//~ #include "sdkconfig.h"

enum CONFIG_BLINK_PERIOD = 20;

//~ static const char *TAG = "example";

/* Use project configuration menu (idf.py menuconfig) to choose the GPIO to blink,
   or you can edit the following line and set a number here.
*/
//~ #define BLINK_GPIO CONFIG_BLINK_GPIO
enum BLINK_GPIO = 12; // LuatOS ESP32-C3 Development Board (CORE-ESP32)

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

extern(C) void app_main()
{
    /* Configure the peripheral according to the LED type */
    configure_led();

    while (1) {
        //~ ESP_LOGI(TAG, "Turning the LED %s!", s_led_state == true ? "ON" : "OFF");
        blink_led();
        /* Toggle the LED state */
        s_led_state = !s_led_state;
        vTaskDelay(CONFIG_BLINK_PERIOD / portTICK_PERIOD_MS);
    }
}
