#include <stdio.h>
#include <string.h>

#include "driver/uart.h"
#include "driver/uart_vfs.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define STR(x) _STR(x)
#define _STR(x) #x

#define UART_ID 2
#define RX_PIN 16
#define TX_PIN 17

#define BUF_SIZE_MAX 128

void app_main(void) {
    printf("hello world!\n");

    // Configure UART
    const uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };

    uart_vfs_dev_use_driver(UART_ID);
    ESP_ERROR_CHECK(uart_driver_install(UART_ID, 512, 512, 0, NULL, 0));
    ESP_ERROR_CHECK(uart_param_config(UART_ID, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(UART_ID, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));

    // Attempt UART readloop
    FILE* uart = fopen("/dev/uart/" STR(UART_ID), "r");
    if (!uart) {
        printf("Failed to open UART " STR(UART_ID) " \n");
        return;
    }

    static char buf[BUF_SIZE_MAX];
    while (1) {
        fgets(buf, BUF_SIZE_MAX, uart);
        fgetc(uart);

        printf("Echo: %s", buf);
        fflush(stdout);
    }
}