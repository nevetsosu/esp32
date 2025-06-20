#include <stdio.h>

#include "driver/uart.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define STR(x) _STR(x)
#define _STR(x) #x

#define UART_ID 0
#define RX_PIN 3
#define TX_PIN 1

void app_main(void)
{
    // Configure UART
    const uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };
    ESP_ERROR_CHECK(uart_driver_install(UART_ID, 512, 512, 0, NULL, 0));
    ESP_ERROR_CHECK(uart_param_config(UART_ID, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(UART_ID, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));

    FILE* uart = fopen("/dev/uart/" STR(UART_ID), "w");
    if (!uart) {
        printf("Failed to open the uart\n");
        return;
    }

    int counter = 0;
    while(1) {
        fprintf(uart, "Message %d\n", counter);

        counter++;
        vTaskDelay(500 / portTICK_PERIOD_MS);
    }
}
