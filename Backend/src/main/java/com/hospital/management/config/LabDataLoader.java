package com.hospital.management.config;

import com.hospital.management.lab.entity.LabTest;
import com.hospital.management.lab.entity.LabTestParameter;
import com.hospital.management.lab.repository.LabTestRepository;
import com.hospital.management.lab.repository.LabTestParameterRepository;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LabDataLoader {

    @Bean
    CommandLineRunner loadLabData(
            LabTestRepository testRepository,
            LabTestParameterRepository parameterRepository) {

        return args -> {

            if (testRepository.count() > 0) {
                return;
            }

            LabTest cbc = new LabTest(
                    "Complete Blood Count",
                    "Basic blood health test",
                    500.0
            );

            testRepository.save(cbc);

            parameterRepository.save(createParameter("Hemoglobin","g/dL","12-16",cbc));
            parameterRepository.save(createParameter("WBC","/µL","4000-11000",cbc));
            parameterRepository.save(createParameter("Platelets","/µL","150000-450000",cbc));

            System.out.println("Lab test data seeded");
        };
    }

    private LabTestParameter createParameter(
            String name,
            String unit,
            String range,
            LabTest test) {

        LabTestParameter p = new LabTestParameter();
        p.setParameterName(name);
        p.setUnit(unit);
        p.setNormalRange(range);
        p.setLabTest(test);

        return p;
    }
}