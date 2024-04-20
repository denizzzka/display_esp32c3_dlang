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
    enum SPI_HOST = spi_host_device_t.SPI2_HOST;

    immutable spi_bus_config_t spi_bus_cfg = {
        mosi_io_num: 3,
        sclk_io_num: 2,
        quadwp_io_num: -1,
        quadhd_io_num: -1,
    };

    immutable spi_device_interface_config_t devcfg = {
        clock_speed_hz: 1 * 1000 * 1000,    //Clock out
        mode: 0,                            //SPI mode 0
        spics_io_num: 7,                    //CS pin
        queue_size: 1,                      //to avoid assert failed: xQueueGenericCreate queue.c
        //~ pre_cb: spi_pre_transfer_callback,  //Specify pre-transfer callback
    };

    extern(C) void spi_pre_transfer_callback(spi_transaction_t *t)
    {
    }

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
        /*const*/ void *tx_buffer;
        uint8_t[4] tx_data;
    };
    union {
        void *rx_buffer;
        uint8_t[4] rx_data;
    };
}

enum TickType_t portMAX_DELAY = 0xffffffff; // from FreeRTOS
extern(C) esp_err_t spi_device_queue_trans(spi_device_handle_t handle, spi_transaction_t *trans_desc, TickType_t ticks_to_wait);
extern(C) esp_err_t spi_device_transmit(spi_device_handle_t handle, spi_transaction_t *trans_desc);

enum SPI_TRANS_USE_TXDATA = (1<<3);  ///< Transmit tx_data member of spi_transaction_t instead of data at tx_buffer. Do not set tx_buffer when using this.
__gshared spi_transaction_t[2] trans;

extern(C) void app_main()
{
    configure_led();
    configure_displ();

    // init transactions
    foreach(ref t; trans)
    {
        t.length = 4 + 5*4;
        t.flags = SPI_TRANS_USE_TXDATA;
    }

    union OutBuf
    {
        union
        {
            ubyte[4]* buffer;
            uint* buffer_int;
        };

        void tube_sel(ubyte tube_num)
        {
            assert(tube_num < 16);

            // MSB бит на оригинальной схеме инверсный, поэтому делаю в логике XOR
            // так, чтобы при увеличении счётчика шёл перебор ламп влево по порядку
            tube_num ^= 0b_0100;

            //FIXME: don't shift - use SPI_WR_BIT_ORDER
            *buffer_int = tube_num << 4;
        }

        void enable_segment(uint seg)
        {
            assert((seg & 0xf0) == 0); // 4 bit nibble is used for tube selection and must be zeroed

            *buffer_int = (*buffer_int | seg) ^ 0xffffff0f /* not inverse tube number bits */;
        }

        struct
        {
            ubyte tube_num;
            ushort seg_val;
        }
    }

    OutBuf buf = {buffer: &trans[0].tx_data};
    ubyte cnt_seg;
    ubyte cnt;

    while (1) {
        blink_led();
        s_led_state = !s_led_state;

        trans[0].tx_buffer = null;
        //~ buf.tube_sel(cnt);
        buf.tube_sel(0);

        import seg_enc : Abc;
        buf.enable_segment(Abc.A);

        cnt++;
        if(cnt > 15)
        {
            cnt = 0;
            cnt_seg++;
        }

        // Send value into display
        spi_device_transmit(spi, &trans[0]);

        vTaskDelay(CONFIG_BLINK_PERIOD / portTICK_PERIOD_MS);
    }
}
