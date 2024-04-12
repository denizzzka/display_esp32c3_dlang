// Blink Example

//~ #include <stdio.h>
//~ #include "freertos/FreeRTOS.h"
//~ #include "freertos/task.h"
//~ #include "driver/gpio.h"
import driver.CMakeFiles.__idf_driver_dir.gpio.gpio;

//~ #include "esp_log.h"
//~ #include "led_strip.h"
//~ #include "sdkconfig.h"

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
    gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
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
