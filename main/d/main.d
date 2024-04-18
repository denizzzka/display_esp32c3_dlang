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

//~ #include "driver/gpio.h"

alias esp_err_t = int;
alias gpio_num_t = int;
alias uint32_t = uint;
alias uint64_t = ulong;
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
enum BLINK_GPIO = 12;

enum esp_intr_cpu_affinity_t
{
    ESP_INTR_CPU_AFFINITY_AUTO,
    ESP_INTR_CPU_AFFINITY_0,
    ESP_INTR_CPU_AFFINITY_1,
}

alias uint8_t = ubyte;
alias uint16_t = ushort;

struct spi_bus_config_t
{
    union {
      int mosi_io_num;
      int data0_io_num;
    };
    union {
      int miso_io_num;
      int data1_io_num;
    };
    int sclk_io_num;
    union {
      int quadwp_io_num;
      int data2_io_num;
    };
    union {
      int quadhd_io_num;
      int data3_io_num;
    };
    int data4_io_num;
    int data5_io_num;
    int data6_io_num;
    int data7_io_num;
    int max_transfer_sz;
    uint32_t flags;
    esp_intr_cpu_affinity_t isr_cpu_id;
    int intr_flags;
}

private alias transaction_cb_t = void function(void*);

enum spi_clock_source_t
{
    SPI_CLK_SRC_DEFAULT = 4,
    SPI_CLK_SRC_APB = 4,
    SPI_CLK_SRC_XTAL = 10,
}

struct spi_device_interface_config_t
{
    uint8_t command_bits;
    uint8_t address_bits;
    uint8_t dummy_bits;
    uint8_t mode;
    spi_clock_source_t clock_source;
    uint16_t duty_cycle_pos;
    uint16_t cs_ena_pretrans;
    uint8_t cs_ena_posttrans;
    int clock_speed_hz;
    int input_delay_ns;
    int spics_io_num;
    uint32_t flags;
    int queue_size;
    transaction_cb_t pre_cb;
    transaction_cb_t post_cb;
}

enum spi_host_device_t
{

    SPI1_HOST=0,
    SPI2_HOST=1,
    SPI_HOST_MAX,
}

extern(C) esp_err_t spi_bus_initialize(spi_host_device_t host_id, const spi_bus_config_t *bus_config, spi_dma_chan_t dma_chan);
extern(C) esp_err_t spi_bus_add_device(spi_host_device_t host_id, const spi_device_interface_config_t *dev_config, spi_device_handle_t *handle);

enum spi_dma_chan_t
{
  SPI_DMA_DISABLED = 0,
  SPI_DMA_CH_AUTO = 3,
}

struct spi_device_t;
alias spi_device_handle_t = spi_device_t*;
__gshared spi_device_handle_t spi;

void configure_displ()
{
    enum SPI_HOST = spi_host_device_t.SPI_HOST_MAX;

    immutable spi_bus_config_t spi_bus_cfg = {
        mosi_io_num: 3,
        sclk_io_num: 2,
        quadwp_io_num: -1,
        quadhd_io_num: -1,
    };

    immutable spi_device_interface_config_t devcfg = {
        clock_speed_hz //FIXME
    };

    spi_bus_initialize(SPI_HOST, &spi_bus_cfg, spi_dma_chan_t.SPI_DMA_DISABLED);
    spi_bus_add_device(SPI_HOST, &devcfg, &spi);
}

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

struct spi_transaction_t
{
    uint32_t flags;
    uint16_t cmd;
    uint64_t addr;
    size_t length;
    size_t rxlength;
    void *user;
    union {
        const void *tx_buffer;
        uint8_t[4] tx_data;
    };
    union {
        void *rx_buffer;
        uint8_t[4] rx_data;
    };
}

extern(C) esp_err_t spi_device_queue_trans(spi_device_handle_t handle, spi_transaction_t *trans_desc, TickType_t ticks_to_wait);

extern(C) void app_main()
{
    configure_led();
    configure_displ();

    while (1) {
        blink_led();
        s_led_state = !s_led_state;

        // Send random 32-bit value into display
        //TODO implement

        vTaskDelay(CONFIG_BLINK_PERIOD / portTICK_PERIOD_MS);
    }
}
