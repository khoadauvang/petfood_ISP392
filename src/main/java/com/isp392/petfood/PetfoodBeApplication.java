package com.isp392.petfood;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PetfoodBeApplication {
    public static void main(String[] args) {
        System.out.println(">>> Working dir = " + System.getProperty("user.dir"));
        SpringApplication.run(PetfoodBeApplication.class, args);
    }
}
