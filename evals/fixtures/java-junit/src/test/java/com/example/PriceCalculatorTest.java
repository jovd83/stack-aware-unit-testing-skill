package com.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class PriceCalculatorTest {
    @Test
    void totalAddsNetAndTax() {
        assertEquals(120, new PriceCalculator().total(100, 20));
    }
}
