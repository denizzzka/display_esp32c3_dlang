module displ_driver;

import main;

enum TickType_t portMAX_DELAY = 0xffffffff; // from FreeRTOS
extern(C) esp_err_t spi_device_queue_trans(spi_device_handle_t handle, spi_transaction_t *trans_desc, TickType_t ticks_to_wait);
extern(C) esp_err_t spi_device_get_trans_result(spi_device_handle_t handle, spi_transaction_t **trans_desc, TickType_t ticks_to_wait);
extern(C) esp_err_t spi_device_transmit(spi_device_handle_t handle, spi_transaction_t *trans_desc);
extern(C) esp_err_t spi_device_polling_transmit(spi_device_handle_t handle, spi_transaction_t *trans_desc);
extern(C) esp_err_t spi_device_acquire_bus(spi_device_handle_t device, TickType_t wait);

enum SPI_TRANS_USE_TXDATA = (1<<3);  ///< Transmit tx_data member of spi_transaction_t instead of data at tx_buffer. Do not set tx_buffer when using this.

private alias DisplBuff = spi_transaction_t[16];

struct DisplayData
{
    private __gshared DisplBuff[2] displ_buffs;
    private __gshared DisplBuff* curr = &display_data.displ_buffs[0];
    private __gshared DisplBuff* shadow = &display_data.displ_buffs[1];
    private bool needSwapBuff; // TODO: must be atomic for multithreaded platforms
    private bool[DisplBuff.length] blinkFlag;

    void updateDisplayedData()
    {
        needSwapBuff = true;
    }

    private ref spi_transaction_t getTubeByIdx(T)(T idx)
    {
        return (*shadow)[idx];
    }

    void putChar(size_t idx, wchar c, bool blinking = false)
    {
        import seg_enc: utf2seg;

        getTubeByIdx(idx).setTubeSegments(idx, c.utf2seg);
        blinkFlag[idx] = blinking;
    }

    void cleanLine()
    {
        foreach(i; 0 .. (*shadow).length)
            putChar(i, ' ');
    }

    void putLine(T)(in T str)
    if(is(T == wchar[16]) || is(T == wstring))
    {
        foreach(i; 0 .. (str.length > 16 ? 16 : str.length))
            putChar(15 - i, str[i]);
    }
}

__gshared DisplayData display_data;

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

private alias transaction_cb_t = extern(C) void function(spi_transaction_t* trans);

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

enum soc_module_clk_t
{

    SOC_MOD_CLK_CPU = 1,

    SOC_MOD_CLK_RTC_FAST,
    SOC_MOD_CLK_RTC_SLOW,

    SOC_MOD_CLK_APB,
    SOC_MOD_CLK_PLL_F80M,
    SOC_MOD_CLK_PLL_F160M,
    SOC_MOD_CLK_XTAL32K,
    SOC_MOD_CLK_RC_FAST,
    SOC_MOD_CLK_RC_FAST_D256,
    SOC_MOD_CLK_XTAL,
    SOC_MOD_CLK_INVALID,
}

enum soc_periph_gptimer_clk_src_t
{
    GPTIMER_CLK_SRC_APB = soc_module_clk_t.SOC_MOD_CLK_APB,
    GPTIMER_CLK_SRC_XTAL = soc_module_clk_t.SOC_MOD_CLK_XTAL,
    GPTIMER_CLK_SRC_DEFAULT = soc_module_clk_t.SOC_MOD_CLK_APB,
}

alias gptimer_clock_source_t = soc_periph_gptimer_clk_src_t;

enum gptimer_count_direction_t
{
    GPTIMER_COUNT_DOWN,
    GPTIMER_COUNT_UP,
}

struct gptimer_config_t
{
    gptimer_clock_source_t clk_src;
    gptimer_count_direction_t direction;
    uint32_t resolution_hz;

    int intr_priority;

    uint32_t intr_shared = 1;
}

struct gptimer_t;
alias gptimer_handle_t = gptimer_t*;

extern(C) esp_err_t gptimer_new_timer(const gptimer_config_t *config, gptimer_handle_t *ret_timer);
extern(C) esp_err_t gptimer_set_raw_count(gptimer_handle_t timer, uint64_t value);

struct gptimer_alarm_config_t
{
    uint64_t alarm_count;
    uint64_t reload_count;
    uint32_t auto_reload_on_alarm = 1;
}

extern(C) esp_err_t gptimer_set_alarm_action(gptimer_handle_t timer, const gptimer_alarm_config_t *config);

struct gptimer_alarm_event_data_t
{
    uint64_t count_value;
    uint64_t alarm_value;
}

alias gptimer_alarm_cb_t = extern(C) ubyte function(gptimer_handle_t timer, const gptimer_alarm_event_data_t *edata, void *user_ctx);

struct gptimer_event_callbacks_t
{
    gptimer_alarm_cb_t on_alarm;
}

extern(C) esp_err_t gptimer_register_event_callbacks(gptimer_handle_t timer, const gptimer_event_callbacks_t *cbs, void *user_data);
extern(C) esp_err_t gptimer_enable(gptimer_handle_t timer);
extern(C) esp_err_t gptimer_start(gptimer_handle_t timer);

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
        clock_speed_hz: 10 * 1000 * 1000,    //Clock out
        mode: 0,                            //SPI mode 0
        spics_io_num: 7,                    //CS pin
        queue_size: 16,

        //Just for ensure about switching off tubes grids during segments update
        cs_ena_pretrans: 1,
        cs_ena_posttrans: 1,
    };

    spi_bus_initialize(SPI_HOST, &spi_bus_cfg, spi_dma_chan_t.SPI_DMA_DISABLED);
    spi_bus_add_device(SPI_HOST, &devcfg, &spi);

    // init transactions buffers
    {
        foreach(ref trans; display_data.displ_buffs)
            foreach(ubyte tube_num, ref t; trans)
            {
                t.length = 4 + 5*4;
                t.flags = SPI_TRANS_USE_TXDATA;

                t.setTubeSegments(tube_num, 0);
            }
    }

    assert(spi_device_acquire_bus(spi, portMAX_DELAY) == 0, "spi_device_acquire_bus failed");

    gptimer_handle_t gptimer;
    gptimer_config_t timer_config = {
        clk_src: soc_periph_gptimer_clk_src_t.GPTIMER_CLK_SRC_DEFAULT,
        direction: gptimer_count_direction_t.GPTIMER_COUNT_DOWN,
        resolution_hz: 1_000_000, // 1 MHz
    };
    assert(gptimer_new_timer(&timer_config, &gptimer) == 0, "gptimer_new_timer failed");

    gptimer_event_callbacks_t callbacks = {
        on_alarm: &display_one_symbol,
    };

    assert(gptimer_register_event_callbacks(gptimer, &callbacks, null) == 0, "gptimer_register_event_callbacks failed");

    gptimer_alarm_config_t timer_alarm_config = {
        reload_count: 50,
    };

    assert(gptimer_set_alarm_action(gptimer, &timer_alarm_config) == 0, "gptimer_set_alarm_action failed");
    assert(gptimer_enable(gptimer) == 0, "gptimer_enable failed");
    assert(gptimer_start(gptimer) == 0, "gptimer_start failed");
}

private void setTubeSegments(T)(ref spi_transaction_t t, T tube_num, in uint seg)
{
    auto buffer_int = &t.tx_data;

    assert(tube_num < 16);

    // MSB бит на оригинальной схеме инверсный, поэтому делаю в логике XOR
    // так, чтобы при увеличении счётчика шёл перебор ламп влево по порядку
    tube_num ^= 0b_0100;

    //FIXME: don't shift - use SPI_WR_BIT_ORDER
    auto tube_encoded = tube_num << 4;

    assert((seg & 0xf0) == 0); // 4 bit nibble is used for tube selection and must be zeroed

    t.tx_buffer = cast(void*)(tube_encoded | (seg ^ 0xffffff0f)); /* not inverse tube number bits */
}

extern(C) ubyte display_one_symbol(gptimer_handle_t timer, const gptimer_alarm_event_data_t *edata, void *user_ctx)
{
    __gshared static ubyte tube_cnt;

    enum blinkPeriod = 500;
    __gshared static int blinkTime = blinkPeriod;

    spi_transaction_t empty_char;
    empty_char.length = 4 + 5*4;
    empty_char.flags = SPI_TRANS_USE_TXDATA;

    if(display_data.blinkFlag[tube_cnt] && blinkTime < 0)
    {
        empty_char.setTubeSegments(tube_cnt, 0);
        spi_device_polling_transmit(spi, &empty_char);
    }
    else
        spi_device_polling_transmit(spi, &(*display_data.curr)[tube_cnt]);

    tube_cnt++;
    if(tube_cnt >= DisplBuff.length)
    {
        tube_cnt = 0;

        if(display_data.needSwapBuff)
        {
            auto tmp = display_data.curr;
            display_data.curr = display_data.shadow;
            display_data.shadow = tmp;

            display_data.needSwapBuff = false;
        }

        blinkTime--;
        if(blinkTime <= -blinkPeriod)
            blinkTime = blinkPeriod;
    }

    return 0;
}
